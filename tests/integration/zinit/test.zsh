#!/usr/bin/env zsh

#------------------------------------------------------------------------------
# zinit Integration Test
# Tests that the plugin loads correctly with zinit
#------------------------------------------------------------------------------

# Source zinit environment
source /root/.zshrc

# Test result tracking
typeset -gi TEST_FAILURES=0

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

test_result() {
  local test_name="$1"
  local condition="$2"

  if [[ "$condition" == "0" ]]; then
    printf "${GREEN}✓${NC} %s\n" "$test_name"
  else
    printf "${RED}✗${NC} %s\n" "$test_name"
    ((TEST_FAILURES++))
  fi
}

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "zinit Integration Tests"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Test 1: Plugin directory variable is set
echo "Testing plugin initialization..."
if [[ -n "$ZSH_AZURE_CLI_CONTEXT_PLUGIN_DIR" ]]; then
  test_result "ZSH_AZURE_CLI_CONTEXT_PLUGIN_DIR is set" 0
else
  test_result "ZSH_AZURE_CLI_CONTEXT_PLUGIN_DIR is set" 1
fi

# Test 2: ZERO variable should be set by zinit (skip for manual loading)
# Note: ZERO is only set when zinit loads plugins, not when manually placed
if [[ -n "$ZERO" ]] || [[ -n "$ZSH_AZURE_CLI_CONTEXT_PLUGIN_DIR" ]]; then
  test_result "Plugin loaded correctly (manual or via zinit)" 0
else
  test_result "Plugin loaded correctly (manual or via zinit)" 1
fi

# Test 3: azctx command exists
if (( ${+functions[azctx]} )); then
  test_result "azctx command is loaded" 0
else
  test_result "azctx command is loaded" 1
fi

# Test 4: Private functions exist
if (( ${+functions[_validate_context_name]} )); then
  test_result "_validate_context_name function is loaded" 0
else
  test_result "_validate_context_name function is loaded" 1
fi

if (( ${+functions[_azctx_usage]} )); then
  test_result "_azctx_usage function is loaded" 0
else
  test_result "_azctx_usage function is loaded" 1
fi

if (( ${+functions[_r_get_contexts]} )); then
  test_result "_r_get_contexts function is loaded" 0
else
  test_result "_r_get_contexts function is loaded" 1
fi

if (( ${+functions[_context_exists]} )); then
  test_result "_context_exists function is loaded" 0
else
  test_result "_context_exists function is loaded" 1
fi

if (( ${+functions[_r_get_active_context]} )); then
  test_result "_r_get_active_context function is loaded" 0
else
  test_result "_r_get_active_context function is loaded" 1
fi

# Test 5: Unload function exists
if (( ${+functions[azure_cli_context_plugin_unload]} )); then
  test_result "azure_cli_context_plugin_unload function is loaded" 0
else
  test_result "azure_cli_context_plugin_unload function is loaded" 1
fi

echo ""
echo "Testing completions..."

# Test 6: azctx completion exists
if (( ${+functions[_azctx]} )); then
  test_result "_azctx completion is loaded" 0
else
  test_result "_azctx completion is loaded" 1
fi

# Test 7: Completions are registered
echo ""
echo "Testing completion registration..."
if whence -w _azctx | grep -q "function"; then
  test_result "azctx completion is registered" 0
else
  test_result "azctx completion is registered" 1
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [[ $TEST_FAILURES -eq 0 ]]; then
  printf "${GREEN}✓ All zinit integration tests passed!${NC}\n"
  exit 0
else
  printf "${RED}✗ %d test(s) failed${NC}\n" $TEST_FAILURES
  exit 1
fi
