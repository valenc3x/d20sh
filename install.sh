#!/bin/bash
# Installation script for d20sh

set -e

INSTALL_DIR="$HOME/.local"
BIN_DIR="$INSTALL_DIR/bin"
SHARE_DIR="$INSTALL_DIR/share/d20sh"

echo "🎲 Installing d20sh..."

# Create directories
mkdir -p "$BIN_DIR"
mkdir -p "$SHARE_DIR/lib"
mkdir -p "$SHARE_DIR/data"

# Copy files
echo "Copying files..."
cp bin/d20sh "$BIN_DIR/d20sh"
cp lib/*.sh "$SHARE_DIR/lib/"
cp data/success_messages.txt "$SHARE_DIR/data/"

# Make executable
chmod +x "$BIN_DIR/d20sh"

echo ""
echo "✓ d20sh installed to $BIN_DIR/d20sh"
echo ""
echo "Next steps:"
echo "  1. Ensure $BIN_DIR is in your PATH"
echo "  2. Run 'd20sh init' to create your character"
echo "  3. Run 'd20sh setup' to configure your shell"
echo ""

# Check if bin directory is in PATH
if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
    echo "⚠️  Warning: $BIN_DIR is not in your PATH"
    echo ""
    echo "Add this to your ~/.zshrc:"
    echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
    echo ""
fi

# Check for jq
if ! command -v jq &> /dev/null; then
    echo "⚠️  Warning: 'jq' is not installed (required for character management)"
    echo ""
    echo "Install with:"
    echo "  brew install jq          # macOS"
    echo "  sudo apt install jq      # Debian/Ubuntu"
    echo "  sudo dnf install jq      # Fedora"
    echo ""
fi
