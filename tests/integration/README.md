# Integration Tests

Docker-based integration tests for verifying the plugin works correctly with different plugin managers.

## Requirements

- Docker installed and running
- Bash shell (for running the test runner script)

## Running Tests

### Run All Integration Tests

```bash
make test-integration
```

Or run the script directly:

```bash
./tests/integration/run-tests.sh
```

### Run Individual Plugin Manager Tests

#### Oh My Zsh

```bash
cd /path/to/zsh-azure-cli-context
docker build -t azure-cli-context-test-omz -f tests/integration/oh-my-zsh/Dockerfile .
docker run --rm azure-cli-context-test-omz
```

#### zinit

```bash
cd /path/to/zsh-azure-cli-context
docker build -t azure-cli-context-test-zinit -f tests/integration/zinit/Dockerfile .
docker run --rm azure-cli-context-test-zinit
```

## Test Structure

```
tests/integration/
├── README.md                    # This file
├── run-tests.sh                 # Main test runner script
├── oh-my-zsh/                   # Oh My Zsh tests
│   ├── Dockerfile               # Test environment
│   └── test.zsh                 # Test script
└── zinit/                       # zinit tests
    ├── Dockerfile               # Test environment
    └── test.zsh                 # Test script
```

## Adding New Plugin Managers

To add tests for a new plugin manager:

1. Create a new directory: `tests/integration/<manager-name>/`
2. Create a Dockerfile: `tests/integration/<manager-name>/Dockerfile`
3. Create a test script: `tests/integration/<manager-name>/test.zsh`
4. Add a new test case in `run-tests.sh`

### Dockerfile Template

```dockerfile
FROM alpine:latest

# Install dependencies (Alpine Linux)
RUN apk add --no-cache zsh git curl

# Install the plugin manager
# ... manager-specific installation ...

# Configure to load the plugin
# ... manager-specific configuration ...

# Copy entire plugin directory (mimics git clone, done last for better caching)
COPY . /path/to/plugin/dir/

# Run test script from plugin directory
CMD ["/path/to/plugin/dir/tests/integration/<manager-name>/test.zsh"]
```

## Troubleshooting

### Docker Build Failures

Check the build logs in `/tmp/docker-build-*.log`:
```bash
cat /tmp/docker-build-azure-cli-context-test-omz.log
```

### Test Failures

Run the Docker container interactively to debug:
```bash
docker run -it --rm azure-cli-context-test-omz /bin/zsh
```

Then manually source the configuration and run tests:
```bash
source /root/.zshrc
/test.zsh
```
