#!/bin/bash
# ============================================================
# release-summary — one-line installer
# curl -sSL https://raw.githubusercontent.com/DavidMachile/release-summary/main/install.sh | bash
# ============================================================
set -eu

INSTALL_DIR="${HOME}/bin"
BIN_NAME="release-summary"
REPO="DavidMachile/release-summary"
BRANCH="master"
RAW_URL="https://raw.githubusercontent.com/${REPO}/${BRANCH}/${BIN_NAME}.sh"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}==>${NC} Installing release-summary..."

# Pick install dir: ~/bin if exists, else try /usr/local/bin (may need sudo)
if [[ -d "${HOME}/bin" ]] || mkdir -p "${HOME}/bin" 2>/dev/null; then
    DEST="${HOME}/bin/${BIN_NAME}"
elif [[ -w /usr/local/bin ]]; then
    DEST="/usr/local/bin/${BIN_NAME}"
else
    echo -e "${YELLOW}==>${NC} Need sudo to install to /usr/local/bin"
    sudo curl -sSL "$RAW_URL" -o "/usr/local/bin/${BIN_NAME}"
    sudo chmod +x "/usr/local/bin/${BIN_NAME}"
    echo -e "${GREEN}==>${NC} Installed to /usr/local/bin/${BIN_NAME}"
    echo -e "${GREEN}==>${NC} Done! Try: release-summary --help"
    exit 0
fi

curl -sSL "$RAW_URL" -o "$DEST"
chmod +x "$DEST"

# Check if install dir is in PATH
if ! echo "$PATH" | tr ':' '\n' | grep -qF "$(dirname "$DEST")"; then
    echo -e "${YELLOW}==>${NC} Add ~/bin to your PATH:"
    echo '  echo '\''export PATH="$HOME/bin:$PATH"'\'' >> ~/.zshrc'
    echo '  source ~/.zshrc'
fi

echo -e "${GREEN}==>${NC} Installed to $DEST"
echo -e "${GREEN}==>${NC} Done! Try: ${BIN_NAME} --help"
