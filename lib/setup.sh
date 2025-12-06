#!/bin/bash
# Shell setup for d20sh aliases

# Source required libraries
source "$(dirname "${BASH_SOURCE[0]}")/character.sh"

# Generate alias block
generate_aliases() {
    cat << 'EOF'
# d20sh aliases - DO NOT EDIT MANUALLY
# Regenerate with: d20sh setup

alias cat='d20sh roll cat bat'
alias ls='d20sh roll ls lsd'
alias find='d20sh roll find fd'
alias grep='d20sh roll grep rg'
alias diff='d20sh roll diff delta'
alias ps='d20sh roll ps procs'
alias du='d20sh roll du dust'
alias top='d20sh roll top htop'
alias man='d20sh roll man tldr'
EOF
}

# Detect shell config file
detect_shell_config() {
    # Check for zsh first (as specified in requirements)
    if [[ -n "$ZSH_VERSION" ]] || [[ "$SHELL" == *"zsh"* ]]; then
        echo "$HOME/.zshrc"
    elif [[ -f "$HOME/.zshrc" ]]; then
        echo "$HOME/.zshrc"
    elif [[ -f "$HOME/.bashrc" ]]; then
        echo "$HOME/.bashrc"
    else
        echo "$HOME/.zshrc"  # Default to zsh as per requirements
    fi
}

# Check if aliases already exist in config
aliases_already_installed() {
    local config_file="$1"
    [[ -f "$config_file" ]] && grep -q "d20sh aliases" "$config_file"
}

# Remove old aliases from config
remove_old_aliases() {
    local config_file="$1"

    if [[ ! -f "$config_file" ]]; then
        return 0
    fi

    # Remove lines between d20sh markers
    if grep -q "d20sh aliases" "$config_file"; then
        # Use sed to remove the alias block
        # Create temp file for cross-platform compatibility
        local temp_file="${config_file}.d20sh.tmp"
        sed '/# d20sh aliases/,/^alias man=/d' "$config_file" > "$temp_file"
        mv "$temp_file" "$config_file"
        echo "Removed old d20sh aliases"
    fi
}

# Main setup function
run_shell_setup() {
    echo "🎮 d20sh Shell Setup"
    echo ""

    # Check if character exists
    if ! character_exists; then
        echo "⚠️  No character found. Please run 'd20sh init' first." >&2
        echo ""
        echo "You need to create a character before setting up aliases."
        return 1
    fi

    local config_file=$(detect_shell_config)
    echo "Detected shell config: $config_file"
    echo ""

    # Generate aliases
    local aliases=$(generate_aliases)

    echo "Aliases to be added:"
    echo ""
    echo "$aliases"
    echo ""

    # Check if aliases already exist
    if aliases_already_installed "$config_file"; then
        echo "⚠️  d20sh aliases already exist in $config_file"
        read -p "Replace existing aliases? [y/N] " -n 1 -r
        echo

        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Setup cancelled."
            return 0
        fi

        remove_old_aliases "$config_file"
        echo ""
    fi

    # Offer to append to config file
    read -p "Add aliases to $config_file? [y/N] " -n 1 -r
    echo

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Append aliases to config file
        echo "" >> "$config_file"
        echo "$aliases" >> "$config_file"

        echo ""
        echo "✓ Aliases added to $config_file"
        echo ""
        echo "To activate the aliases, run:"
        echo "  source $config_file"
        echo ""
        echo "Or restart your terminal."
    else
        echo ""
        echo "Manual installation:"
        echo "Add the following to your $config_file:"
        echo ""
        echo "$aliases"
        echo ""
        echo "Then run: source $config_file"
    fi

    echo ""
    echo "🎲 Setup complete! Your terminal commands now use d20 rolls!"
    echo ""
    echo "Try running: ls"
}
