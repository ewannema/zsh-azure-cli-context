# Azure CLI Context Manager

A plugin to make it easier to use multiple Azure accounts via the CLI.

Instead of logging out and back in with different credentials to access
different environments, you switch the context at the CLI instead.

This plugin provides a CLI interface for creating directories (in
`${HOME}/.azure-contexts/"`) to store Azure CLI configurations (contexts) and
switching between them as needed. Under the covers, the environment variable
`AZURE_CONFIG_DIR` is set to the directory for the associated context with
`azctx use <context>`.

Contexts can be created for any level of isolation that you want, but the first
place you will use it is if you have multiple Azure logins.

## Basic Usage

```
# Create a context for a normal user account
azctx new normal-user
azctx use normal-user
az login
az account show

# Create a context for an account with elevated privileges
azctx new admin-user
azctx use admin-user
az login
az account show

# Switch back to the normal user account
azctx use normal-user
az account show

# View available contexts
azctx list

# Check which context is currently active
azctx current
```

## Context Naming Rules

Context names must follow these rules:
- Cannot be empty
- Cannot contain `/` (slashes)
- Cannot be `.` or `..`
- Cannot start with `-` (dash)

**Recommended:** Use alphanumeric characters, underscores, and dashes only.

**Examples:**
```zsh
azctx new prod              # ✓ Valid
azctx new dev-account       # ✓ Valid
azctx new user_context_01   # ✓ Valid
azctx new my/context        # ✗ Invalid - contains slash
azctx new .                 # ✗ Invalid - special name
azctx new -context          # ✗ Invalid - starts with dash
```

## Installation

### Using Zinit

```zsh
zinit light ewannema/zsh-azure-cli-context
```

### Using Oh-My-Zsh

```zsh
# Clone to custom plugins directory
git clone https://github.com/ewannema/zsh-azure-cli-context \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-azure-cli-context

# Add to plugins array in ~/.zshrc
plugins=(... zsh-azure-cli-context)
```

### Using Antigen

```zsh
antigen bundle ewannema/zsh-azure-cli-context
```

### Using zplug

```zsh
zplug "ewannema/zsh-azure-cli-context"
```

### Manual Installation

```zsh
# Clone the repository
git clone https://github.com/ewannema/zsh-azure-cli-context ~/.zsh/zsh-azure-cli-context

# Add to your ~/.zshrc
source ~/.zsh/zsh-azure-cli-context/azure-cli-context.zsh
```

**Note:** The plugin automatically adds its completion directory to `fpath`. If completions don't work, ensure you have `compinit` loaded after sourcing the plugin:

```zsh
autoload -Uz compinit && compinit
```

## Commands

```
azctx current - show the current active context
azctx help - show this help
azctx list - list available contexts
azctx new <context> - make a new context
azctx reset - reset context setting
azctx rm <context> - remove an existing context
azctx run <context> <command> - run a command in a context without switching
azctx use <context> - switch to a context
```

## Contributing

Contributions are welcome! Please see [DEVELOPMENT.md](DEVELOPMENT.md) for development setup, testing guidelines, and contribution workflow.
