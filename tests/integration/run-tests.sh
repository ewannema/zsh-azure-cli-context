#!/usr/bin/env bash

#------------------------------------------------------------------------------
# Integration Test Runner
# Runs Docker-based integration tests for different plugin managers
#------------------------------------------------------------------------------

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Track results
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Get the repository root directory
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Plugin Manager Integration Tests${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

run_test() {
  local test_name="$1"
  local dockerfile="$2"
  local image_name="$3"

  echo -e "${YELLOW}▶${NC} Running ${test_name}..."
  ((TOTAL_TESTS++))

  # Build the Docker image
  echo "  Building Docker image..."
  if docker build -t "$image_name" -f "$dockerfile" "$REPO_ROOT" > /tmp/docker-build-$image_name.log 2>&1; then
    echo -e "  ${GREEN}✓${NC} Build successful"
  else
    echo -e "  ${RED}✗${NC} Build failed"
    echo "  Check /tmp/docker-build-$image_name.log for details"
    ((FAILED_TESTS++))
    return 1
  fi

  # Run the test
  echo "  Running test..."
  if docker run --rm "$image_name"; then
    echo -e "${GREEN}✓${NC} ${test_name} passed"
    ((PASSED_TESTS++))
  else
    echo -e "${RED}✗${NC} ${test_name} failed"
    ((FAILED_TESTS++))
    return 1
  fi

  echo ""
}

# Change to repo root
cd "$REPO_ROOT"

# Run Oh My Zsh test
run_test "Oh My Zsh Integration" \
  "tests/integration/oh-my-zsh/Dockerfile" \
  "azure-cli-context-test-omz"

# Run zinit test
run_test "zinit Integration" \
  "tests/integration/zinit/Dockerfile" \
  "azure-cli-context-test-zinit"

# Print summary
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "Total tests:  $TOTAL_TESTS"
printf "Passed:       ${GREEN}%d${NC}\n" $PASSED_TESTS
printf "Failed:       ${RED}%d${NC}\n" $FAILED_TESTS
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

if [[ $FAILED_TESTS -eq 0 ]]; then
  echo -e "${GREEN}✓ All integration tests passed!${NC}"
  exit 0
else
  echo -e "${RED}✗ Some tests failed${NC}"
  exit 1
fi
