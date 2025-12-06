# Unit Tests

Fast, isolated unit tests for the azure-cli-context plugin.

## Running Tests

### Via Make

```bash
make test-unit
# or just
make test
```

### Directly

```bash
./tests/unit/run-tests.sh
```

## Test Methodology

The unit tests use:
- **Temporary directories** - Tests run in isolated temporary directories
- **No external dependencies** - Pure Zsh testing framework
- **Fast execution** - All tests run in under a second

## Test Output

Tests provide colored output:
- 🟡 Yellow ▶ - Test running
- 🟢 Green ✓ - Test passed
- 🔴 Red ✗ - Test failed (with error message)

## Adding New Tests

To add a new test, follow this pattern in `run-tests.sh`:

```zsh
test_case "Description of what you're testing"
setup
# Your test code here
if [[ condition ]]; then
  pass
else
  fail "Expected X but got Y"
fi
teardown
```

### Helper Functions

- `test_case "description"` - Start a new test
- `pass` - Mark test as passed
- `fail "message"` - Mark test as failed with message
- `setup` - Create test environment
- `teardown` - Clean up test environment
- `run_command cmd` - Run command and capture output/exit code

### Available Variables

- `$CMD_OUTPUT` - Output from last `run_command`
- `$CMD_EXIT` - Exit code from last `run_command`
- `$ZSH_AZCTX_CONTEXTS_DIR` - Temporary test directory
