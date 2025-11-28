.PHONY: test lint clean help

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Available targets:'
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

test: ## Run all tests
	@./scripts/test

lint: ## Run shellcheck linting
	@echo "Running shellcheck..."
	@shellcheck -s bash \
		-e SC2034 \
		-e SC2154 \
		-e SC2296 \
		-e SC2206 \
		-e SC2207 \
		azure-cli-context.zsh completions/_azctx || echo "Found issues (some may be ZSH-specific)"

clean: ## Clean up temporary test files
	@echo "Cleaning up..."
	@rm -rf /tmp/zsh-azure-cli-context-test-*
	@echo "Done"

.DEFAULT_GOAL := help
