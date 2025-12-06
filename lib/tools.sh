#!/bin/bash
# Tool detection and installation for d20sh

# List of fancy tools and their package names
# Format: command_name:package_name_brew:package_name_apt:package_name_dnf:package_name_pacman
declare -a FANCY_TOOLS=(
    "bat:bat:bat:bat:bat"
    "lsd:lsd:lsd:lsd:lsd"
    "fd:fd:fd-find:fd-find:fd"
    "rg:ripgrep:ripgrep:ripgrep:ripgrep"
    "delta:git-delta:git-delta:git-delta:git-delta"
    "procs:procs:procs:procs:procs"
    "dust:dust:du-dust:du-dust:dust"
    "htop:htop:htop:htop:htop"
    "tldr:tldr:tldr:tldr:tldr"
)

# Detect package manager
detect_package_manager() {
    if command -v brew &> /dev/null; then
        echo "brew"
    elif command -v apt-get &> /dev/null || command -v apt &> /dev/null; then
        echo "apt"
    elif command -v dnf &> /dev/null; then
        echo "dnf"
    elif command -v pacman &> /dev/null; then
        echo "pacman"
    elif command -v yum &> /dev/null; then
        echo "yum"
    else
        echo "unknown"
    fi
}

# Check if a tool is installed
tool_installed() {
    local tool="$1"
    command -v "$tool" &> /dev/null
}

# Get package name for a tool based on package manager
get_package_name() {
    local tool_info="$1"
    local pkg_manager="$2"

    # Split tool_info by colons
    IFS=':' read -r cmd brew_pkg apt_pkg dnf_pkg pacman_pkg <<< "$tool_info"

    case "$pkg_manager" in
        brew) echo "$brew_pkg" ;;
        apt) echo "$apt_pkg" ;;
        dnf|yum) echo "$dnf_pkg" ;;
        pacman) echo "$pacman_pkg" ;;
        *) echo "$cmd" ;;
    esac
}

# Get command name from tool info
get_command_name() {
    local tool_info="$1"
    echo "${tool_info%%:*}"
}

# Show installation status and offer to install
run_tool_install() {
    echo "🔧 d20sh Fancy Tool Installation"
    echo ""

    local pkg_manager=$(detect_package_manager)
    echo "Detected package manager: $pkg_manager"
    echo ""

    if [[ "$pkg_manager" == "unknown" ]]; then
        echo "⚠️  Could not detect package manager."
        echo "Please install tools manually:"
        echo ""
        for tool_info in "${FANCY_TOOLS[@]}"; do
            local cmd=$(get_command_name "$tool_info")
            echo "  - $cmd"
        done
        echo ""
        return 1
    fi

    # Check which tools are installed
    local -a installed=()
    local -a missing=()
    local -a missing_packages=()

    for tool_info in "${FANCY_TOOLS[@]}"; do
        local cmd=$(get_command_name "$tool_info")
        if tool_installed "$cmd"; then
            installed+=("$cmd")
        else
            missing+=("$cmd")
            local pkg=$(get_package_name "$tool_info" "$pkg_manager")
            missing_packages+=("$pkg")
        fi
    done

    # Display status
    echo "Tool Status:"
    echo ""

    if [[ ${#installed[@]} -gt 0 ]]; then
        echo "✓ Installed:"
        for tool in "${installed[@]}"; do
            echo "  - $tool"
        done
        echo ""
    fi

    if [[ ${#missing[@]} -gt 0 ]]; then
        echo "✗ Missing:"
        for tool in "${missing[@]}"; do
            echo "  - $tool"
        done
        echo ""

        # Offer to install
        read -p "Install missing tools? [y/N] " -n 1 -r
        echo

        if [[ $REPLY =~ ^[Yy]$ ]]; then
            install_tools "$pkg_manager" "${missing_packages[@]}"
        else
            echo "Installation cancelled."
            echo ""
            echo "To install manually, run:"
            show_manual_install_command "$pkg_manager" "${missing_packages[@]}"
        fi
    else
        echo "✓ All fancy tools are installed!"
    fi
}

# Install tools using detected package manager
install_tools() {
    local pkg_manager="$1"
    shift
    local packages=("$@")

    echo ""
    echo "Installing tools..."

    case "$pkg_manager" in
        brew)
            echo "Running: brew install ${packages[*]}"
            brew install "${packages[@]}"
            ;;
        apt)
            echo "Running: sudo apt-get update && sudo apt-get install -y ${packages[*]}"
            sudo apt-get update && sudo apt-get install -y "${packages[@]}"
            ;;
        dnf)
            echo "Running: sudo dnf install -y ${packages[*]}"
            sudo dnf install -y "${packages[@]}"
            ;;
        yum)
            echo "Running: sudo yum install -y ${packages[*]}"
            sudo yum install -y "${packages[@]}"
            ;;
        pacman)
            echo "Running: sudo pacman -S --noconfirm ${packages[*]}"
            sudo pacman -S --noconfirm "${packages[@]}"
            ;;
        *)
            echo "Error: Unknown package manager" >&2
            return 1
            ;;
    esac

    echo ""
    echo "✓ Installation complete!"
}

# Show manual installation command
show_manual_install_command() {
    local pkg_manager="$1"
    shift
    local packages=("$@")

    echo ""
    case "$pkg_manager" in
        brew)
            echo "  brew install ${packages[*]}"
            ;;
        apt)
            echo "  sudo apt-get update && sudo apt-get install -y ${packages[*]}"
            ;;
        dnf)
            echo "  sudo dnf install -y ${packages[*]}"
            ;;
        yum)
            echo "  sudo yum install -y ${packages[*]}"
            ;;
        pacman)
            echo "  sudo pacman -S ${packages[*]}"
            ;;
    esac
}
