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
```

## Installation

Add the plugin using your ZSH plugin manager of choice.

## Commands

```
azctx help - show this help
azctx list - list available contexts
azctx new <context> - make a new context
azctx reset - reset context setting
azctx rm <context> - remove an existing context
azctx use <context> - switch to a context
```
