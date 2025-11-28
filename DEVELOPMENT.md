# Development Guide

This guide is for developers who want to contribute to the Azure CLI Context Manager plugin.

## Development Setup

### Prerequisites

- ZSH 5.8 or later
- Git
- (Optional) shellcheck for linting

### Clone the Repository

```zsh
git clone https://github.com/ewannema/zsh-azure-cli-context.git
cd zsh-azure-cli-context
```

## Testing

### Install Testing Dependencies

**Using Homebrew (macOS):**
```zsh
brew install shellcheck
```

**Manual installation:**
```zsh
# Install shellcheck (varies by platform)
# Ubuntu/Debian: sudo apt-get install shellcheck
# Fedora: sudo dnf install shellcheck
# macOS: brew install shellcheck
```

### Running Tests

**Run all tests:**
```zsh
make test
```

**Run linting:**
```zsh
make lint
```

### Test Structure

## Project Structure

```
zsh-azure-cli-context/
├── azure-cli-context.zsh    # Main plugin file
├── completions/
│   └── _azctx               # ZSH completion definitions
├── scripts/
│   └── test                 # Test suite (pure ZSH, executable)
├── .github/
│   └── workflows/
│       └── test.yml         # CI/CD configuration
├── README.md                # End-user documentation
├── DEVELOPMENT.md           # This file
├── LICENSE
└── Makefile                 # Convenience commands
```

## Code Style

### Shell Script Conventions

- **Indentation**: 2 spaces (no tabs)
- **Line endings**: LF (Unix-style)
- **Encoding**: UTF-8
- **Functions**: Use descriptive names, prefix private functions with `_`
- **Variables**: Use `local` for function-local variables
- **Quoting**: Always quote variable expansions unless you specifically need word splitting
- **Error handling**: Check return codes and provide meaningful error messages

### ZSH Best Practices

- Use ZSH-specific features (globs, parameter expansion modifiers, etc.)
- Keep `[@]` for array expansions to maintain compatibility
- Use `typeset -g` for global variables
- Use glob qualifiers like `(N)` for null_glob
- Prefer ZSH built-ins over external commands when possible

### EditorConfig

The project includes an `.editorconfig` file. Make sure your editor supports it for automatic formatting.

## Making Changes

### Workflow

1. **Fork the repository** on GitHub
2. **Create a feature branch** from `main`:
   ```zsh
   git checkout -b feature/my-new-feature
   ```
3. **Make your changes**
4. **Add tests** for new functionality
5. **Run tests** to ensure they pass:
   ```zsh
   make test
   ```
6. **Lint your code**:
   ```zsh
   make lint
   ```
7. **Commit your changes** with clear, descriptive messages:
   ```zsh
   git commit -m "Add feature: description of what was added"
   ```
8. **Push to your fork**:
   ```zsh
   git push origin feature/my-new-feature
   ```
9. **Submit a pull request** to the main repository

### Commit Messages

Follow these guidelines:
- Use present tense ("Add feature" not "Added feature")
- Use imperative mood ("Move cursor to..." not "Moves cursor to...")
- Limit first line to 72 characters
- Reference issues and pull requests when relevant

Examples:
- `Add support for context renaming`
- `Fix error handling in rm command`
- `Update README with new installation instructions`
- `Refactor context validation logic`

## Testing Your Changes

### Manual Testing

Source the plugin in a test shell:
```zsh
# In a new ZSH session
source ./azure-cli-context.zsh

# Test the functionality
azctx new test-context
azctx use test-context
azctx list
azctx rm test-context
```

### Test Completions

```zsh
# Reload completion system
autoload -Uz compinit
compinit

# Test completions
azctx <TAB>
azctx use <TAB>
azctx run <TAB>
```

### Automated Testing

Always add tests for:
- New commands or subcommands
- Bug fixes (write a failing test first, then fix the bug)
- Edge cases and error conditions
- Changes to existing behavior

## Continuous Integration

Tests run automatically via GitHub Actions on:
- Every push to `main` branch
- All pull requests
- Multiple environments (Ubuntu, macOS)
- Multiple ZSH versions (5.8, 5.9)

Check the Actions tab on GitHub to see test results.

## Debugging

### Debug Tests

```zsh
# Run tests with execution trace
zsh -x scripts/test

# Add debug output in scripts/test
test_case "my test"
setup
echo "DEBUG: Variable value: $MY_VAR" >&2
azctx list
echo "DEBUG: AZURE_CONFIG_DIR: $AZURE_CONFIG_DIR" >&2
teardown
```

## Getting Help

- **Issues**: Report bugs or request features via [GitHub Issues](https://github.com/ewannema/zsh-azure-cli-context/issues)
- **Pull Requests**: Submit contributions via pull requests

## Resources

- [ZSH Documentation](https://zsh.sourceforge.io/Doc/)
- [ZSH Completion System Guide](https://github.com/zsh-users/zsh-completions/blob/master/zsh-completions-howto.org)
- [ShellCheck](https://www.shellcheck.net/)

## License

See [LICENSE](LICENSE) file for details.
