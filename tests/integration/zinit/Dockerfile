FROM alpine:latest

# Install zsh, git, curl, and other dependencies
RUN apk add --no-cache zsh git curl

# Install zinit
ENV ZINIT_HOME="/root/.local/share/zinit"
RUN mkdir -p "$ZINIT_HOME" && \
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME/zinit.git"

# Configure .zshrc to use zinit and load the plugin from local directory
# Note: directory-based installation doesn't install completions automatically,
# so we need to use 'zinit creinstall' to install them
RUN echo 'source /root/.local/share/zinit/zinit.git/zinit.zsh' > /root/.zshrc && \
    echo 'zinit load /root/azure-cli-context' >> /root/.zshrc && \
    echo 'zinit creinstall /root/azure-cli-context' >> /root/.zshrc && \
    echo 'autoload -Uz compinit && compinit' >> /root/.zshrc && \
    echo 'export ZSH_AZCTX_CONTEXTS_DIR=/tmp/test-contexts' >> /root/.zshrc

# Copy entire plugin directory to user directory (mimics git clone, done last for better caching)
COPY . /root/azure-cli-context/

# Run the test script from the plugin directory
CMD ["/root/azure-cli-context/tests/integration/zinit/test.zsh"]
