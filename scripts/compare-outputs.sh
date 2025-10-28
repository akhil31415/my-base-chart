#!/bin/bash
# Script to compare current Helm template output with expected output
# Usage: ./scripts/compare-outputs.sh [example-name]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

CHART_DIR="./charts/privacera-base-chart"
EXAMPLES_DIR="$CHART_DIR/examples"
EXPECTED_DIR="$EXAMPLES_DIR/expected-outputs"

PASSED=0
FAILED=0
SKIPPED=0

# Function to compare a single example
compare_example() {
    local example_file=$1
    local filename=$(basename "$example_file" .yaml)
    local expected_file="$EXPECTED_DIR/${filename}-expected.yaml"
    
    echo "🔍 Comparing: ${YELLOW}$filename${NC}"
    
    # Check if expected file exists
    if [ ! -f "$expected_file" ]; then
        echo "  ⚠️  No expected output found for $filename"
        SKIPPED=$((SKIPPED + 1))
        return 0
    fi
    
    # Generate current output
    local current_output="/tmp/${filename}-current.yaml"
    if helm template test-app "$CHART_DIR" -f "$example_file" > "$current_output" 2>/dev/null; then
        echo "  ✅ Template rendered successfully"
    else
        echo "  ❌ Template failed for $filename"
        FAILED=$((FAILED + 1))
        return 1
    fi
    
    # Compare outputs
    if diff -u "$expected_file" "$current_output" > /tmp/diff-${filename}.txt; then
        echo "  ✅ Output matches expected"
        PASSED=$((PASSED + 1))
        rm -f /tmp/diff-${filename}.txt
    else
        echo "  ❌ Output differs from expected"
        echo "  📄 Diff saved to: /tmp/diff-${filename}.txt"
        echo "  📊 Diff summary:"
        echo "    Expected lines: $(wc -l < "$expected_file")"
        echo "    Current lines:  $(wc -l < "$current_output")"
        FAILED=$((FAILED + 1))
    fi
    
    echo ""
}

# Function to update expected output
update_expected() {
    local example_file=$1
    local filename=$(basename "$example_file" .yaml)
    local expected_file="$EXPECTED_DIR/${filename}-expected.yaml"
    
    echo "🔄 Updating expected output for: ${YELLOW}$filename${NC}"
    
    if helm template test-app "$CHART_DIR" -f "$example_file" > "$expected_file" 2>/dev/null; then
        echo "  ✅ Expected output updated"
        echo "  📊 New file size: $(wc -l < "$expected_file") lines"
    else
        echo "  ❌ Failed to generate output for $filename"
        return 1
    fi
    
    echo ""
}

# Main execution
echo "🧪 Helm Template Output Comparison"
echo "=================================="
echo ""

# Check if specific example was requested
if [ $# -eq 1 ]; then
    example_name=$1
    example_file="$EXAMPLES_DIR/${example_name}.yaml"
    
    if [ ! -f "$example_file" ]; then
        echo "❌ Example file not found: $example_file"
        exit 1
    fi
    
    compare_example "$example_file"
else
    # Compare all examples
    echo "Comparing all example files..."
    echo ""
    
    for example in "$EXAMPLES_DIR"/*.yaml; do
        # Skip README and TESTING files
        if [[ "$example" == *"README.md" ]] || [[ "$example" == *"TESTING.md" ]]; then
            continue
        fi
        
        compare_example "$example"
    done
fi

# Summary
echo "=================================="
echo "Comparison Summary:"
echo "  ${GREEN}Passed:${NC}  $PASSED"
echo "  ${RED}Failed:${NC}  $FAILED"
echo "  ${YELLOW}Skipped:${NC} $SKIPPED"
echo "=================================="

if [ $FAILED -eq 0 ]; then
    echo "${GREEN}All outputs match expected! 🎉${NC}"
    exit 0
else
    echo "${RED}Some outputs differ! ❌${NC}"
    echo ""
    echo "To update expected outputs, run:"
    echo "  ./scripts/update-expected-outputs.sh"
    exit 1
fi

