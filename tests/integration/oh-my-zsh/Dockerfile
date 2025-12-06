FROM alpine:latest

# Install zsh, git, curl, and other dependencies
RUN apk add --no-cache zsh git curl

# Install Oh My Zsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Configure Oh My Zsh to load the plugin
RUN sed -i 's/plugins=(git)/plugins=(git azure-cli-context)/' /root/.zshrc && \
    echo 'export ZSH_AZCTX_CONTEXTS_DIR=/tmp/test-contexts' >> /root/.zshrc

# Copy entire plugin directory (mimics git clone, done last for better caching)
COPY . /root/.oh-my-zsh/custom/plugins/azure-cli-context/

# Run the test script from the plugin directory
CMD ["/root/.oh-my-zsh/custom/plugins/azure-cli-context/tests/integration/oh-my-zsh/test.zsh"]
