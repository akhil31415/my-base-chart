#!/bin/bash
# Script to update expected Helm template outputs
# Usage: ./scripts/update-expected-outputs.sh [example-name]

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

UPDATED=0
FAILED=0

# Function to update a single example
update_example() {
    local example_file=$1
    local filename=$(basename "$example_file" .yaml)
    local expected_file="$EXPECTED_DIR/${filename}-expected.yaml"
    
    echo "🔄 Updating: ${YELLOW}$filename${NC}"
    
    # Generate new output
    if helm template test-app "$CHART_DIR" -f "$example_file" > "$expected_file" 2>/dev/null; then
        local lines=$(wc -l < "$expected_file")
        echo "  ✅ Updated expected output ($lines lines)"
        UPDATED=$((UPDATED + 1))
    else
        echo "  ❌ Failed to generate output for $filename"
        FAILED=$((FAILED + 1))
    fi
    
    echo ""
}

# Main execution
echo "🔄 Updating Expected Helm Template Outputs"
echo "========================================="
echo ""

# Check if specific example was requested
if [ $# -eq 1 ]; then
    example_name=$1
    example_file="$EXAMPLES_DIR/${example_name}.yaml"
    
    if [ ! -f "$example_file" ]; then
        echo "❌ Example file not found: $example_file"
        exit 1
    fi
    
    update_example "$example_file"
else
    # Update all examples
    echo "Updating all example files..."
    echo ""
    
    for example in "$EXAMPLES_DIR"/*.yaml; do
        # Skip README and TESTING files
        if [[ "$example" == *"README.md" ]] || [[ "$example" == *"TESTING.md" ]]; then
            continue
        fi
        
        update_example "$example"
    done
fi

# Summary
echo "=================================="
echo "Update Summary:"
echo "  ${GREEN}Updated:${NC} $UPDATED"
echo "  ${RED}Failed:${NC}  $FAILED"
echo "=================================="

if [ $FAILED -eq 0 ]; then
    echo "${GREEN}All expected outputs updated! 🎉${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Review the changes: git diff $EXPECTED_DIR/"
    echo "  2. Commit the updates: git add $EXPECTED_DIR/ && git commit -m 'chore: update expected template outputs'"
    exit 0
else
    echo "${RED}Some updates failed! ❌${NC}"
    exit 1
fi

