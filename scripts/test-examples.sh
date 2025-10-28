#!/bin/bash
# Script to test all Helm chart examples
# Usage: ./scripts/test-examples.sh

set -e

echo "🧪 Testing Helm Chart Examples"
echo "=============================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

PASSED=0
FAILED=0
SKIPPED=0

# Test a single cloud configuration
test_cloud_config() {
    local cloud=$1
    local file=$2
    
    echo "Testing: ${YELLOW}$cloud${NC} ($file)"
    
    # Lint check
    if helm lint ./charts/privacera-base-chart -f "./charts/privacera-base-chart/examples/$file" &>/dev/null; then
        echo "  ${GREEN}✓${NC} Lint passed"
    else
        echo "  ${RED}✗${NC} Lint failed"
        FAILED=$((FAILED + 1))
        return 1
    fi
    
    # Template check
    if helm template test-$cloud ./charts/privacera-base-chart -f "./charts/privacera-base-chart/examples/$file" &>/dev/null; then
        echo "  ${GREEN}✓${NC} Template rendered"
        PASSED=$((PASSED + 1))
    else
        echo "  ${RED}✗${NC} Template failed"
        FAILED=$((FAILED + 1))
        return 1
    fi
    
    echo ""
}

# Test all example files
test_all_examples() {
    echo "Testing standard examples..."
    echo ""
    
    for file in ./charts/privacera-base-chart/examples/*.yaml; do
        if [[ "$file" == *"test-"* ]] || [[ "$file" == *"README.md" ]] || [[ "$file" == *"TESTING.md" ]]; then
            SKIPPED=$((SKIPPED + 1))
            continue
        fi
        
        filename=$(basename "$file")
        echo "Testing: ${YELLOW}$filename${NC}"
        
        # Lint check
        if helm lint ./charts/privacera-base-chart -f "$file" &>/dev/null; then
            echo "  ${GREEN}✓${NC} Lint passed"
        else
            echo "  ${RED}✗${NC} Lint failed"
            FAILED=$((FAILED + 1))
            continue
        fi
        
        # Template check
        if helm template test-app ./charts/privacera-base-chart -f "$file" &>/dev/null; then
            echo "  ${GREEN}✓${NC} Template rendered"
            PASSED=$((PASSED + 1))
        else
            echo "  ${RED}✗${NC} Template failed"
            FAILED=$((FAILED + 1))
        fi
        
        echo ""
    done
}

# Main execution
echo "Starting tests..."
echo ""

# Test cloud-specific configurations
test_cloud_config "aws" "test-aws-eks.yaml"
test_cloud_config "azure" "test-azure-aks.yaml"
test_cloud_config "gcp" "test-gcp-gke.yaml"
test_cloud_config "generic" "test-generic-nginx.yaml"

echo ""
echo "---"
echo ""

# Test all other examples
test_all_examples

# Summary
echo "=============================="
echo "Test Summary:"
echo "  ${GREEN}Passed:${NC}  $PASSED"
echo "  ${RED}Failed:${NC}  $FAILED"
echo "  ${YELLOW}Skipped:${NC} $SKIPPED"
echo "=============================="

if [ $FAILED -eq 0 ]; then
    echo "${GREEN}All tests passed! 🎉${NC}"
    exit 0
else
    echo "${RED}Some tests failed! ❌${NC}"
    exit 1
fi

