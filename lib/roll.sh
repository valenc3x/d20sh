#!/bin/bash
# Roll wrapper for command execution

# Source required libraries
source "$(dirname "${BASH_SOURCE[0]}")/dice.sh"
source "$(dirname "${BASH_SOURCE[0]}")/character.sh"

# Number of lines to keep on partial failure (2-6)
PARTIAL_FAIL_TAIL_LINES=10

# Pick a random non-empty line from a file. Portable across macOS and Linux
# (shuf is GNU-only and not present on macOS by default).
pick_random_line() {
    awk 'BEGIN { srand() }
         /[^[:space:]]/ { lines[++n] = $0 }
         END { if (n > 0) print lines[int(rand() * n) + 1] }' "$1"
}

# Get random success message (nat 20)
get_success_message() {
    if [[ -n "$DATA_DIR" && -f "$DATA_DIR/success_messages.txt" ]]; then
        pick_random_line "$DATA_DIR/success_messages.txt"
    else
        echo "Critical success! The dice gods smile upon you."
    fi
}

# Get random critical failure message (nat 1)
get_crit_fail_message() {
    if [[ -n "$DATA_DIR" && -f "$DATA_DIR/failure_messages.txt" ]]; then
        pick_random_line "$DATA_DIR/failure_messages.txt"
    else
        echo "Critical fail! The command slips from your grasp."
    fi
}

# Get random partial failure message (2-6)
get_partial_fail_message() {
    if [[ -n "$DATA_DIR" && -f "$DATA_DIR/partial_failure_messages.txt" ]]; then
        pick_random_line "$DATA_DIR/partial_failure_messages.txt"
    else
        echo "The output escapes you. Only the tail remains."
    fi
}

# Main roll wrapper
roll_command() {
    local basic_cmd="$1"
    local fancy_cmd="$2"
    shift 2
    # All remaining args are passed to the command
    local cmd_args=("$@")

    # Load character
    if ! load_character; then
        echo "Error: No character found. Run 'd20sh init' first." >&2
        # Fallback to basic command
        command "$basic_cmd" "${cmd_args[@]}"
        return
    fi

    # Get ability modifier
    local ability_mod=$(get_primary_ability_modifier)

    # Roll d20
    local roll=$(roll_d20)
    local total=$((roll + ability_mod))

    # Determine outcome
    #   nat 1                -> skip execution + failure message
    #   total 2-6            -> basic + tail -n 10 + partial-failure message
    #   total 7-14           -> basic command, normal output
    #   total 15-19          -> fancy command (fallback to basic if missing)
    #   nat 20               -> fancy command + success message after output
    local outcome=""
    local use_fancy=false

    if [[ $roll -eq 1 ]]; then
        outcome="nat1"
    elif [[ $roll -eq 20 ]]; then
        outcome="nat20"
        use_fancy=true
    elif [[ $total -ge 15 ]]; then
        outcome="fancy"
        use_fancy=true
    elif [[ $total -ge 7 ]]; then
        outcome="mundane"
    else
        outcome="partial"
    fi

    # Check if fancy command is available; fall back to basic if not
    if $use_fancy && ! command -v "$fancy_cmd" &> /dev/null; then
        use_fancy=false
    fi

    local exec_cmd="$basic_cmd"
    if $use_fancy; then
        exec_cmd="$fancy_cmd"
    fi

    # ANSI color codes for header
    local reset="\033[0m"
    local bold="\033[1m"
    local dim="\033[2m"
    local red="\033[31m"
    local green="\033[32m"
    local yellow="\033[33m"
    local cyan="\033[36m"
    local white="\033[37m"

    # Build character title: "Name, Subclass Class" or "Name, Class"
    local char_title="${CHAR_NAME}"
    if [[ -n "$CHAR_SUBCLASS" && "$CHAR_SUBCLASS" != "None" ]]; then
        char_title="${char_title}, ${CHAR_SUBCLASS} ${CHAR_CLASS}"
    else
        char_title="${char_title}, ${CHAR_CLASS}"
    fi

    local bonus_sign=""
    if [[ $ability_mod -ge 0 ]]; then
        bonus_sign="+"
    fi

    local line="${dim}─────────────────────────────────────────────────────${reset}"

    # Display roll info to stderr
    echo -e "⚔ ${line}" >&2
    case "$outcome" in
        nat1)
            echo -e "  ${bold}${char_title}${reset} rolled a ${red}nat 1${reset} for ${cyan}${basic_cmd}${reset}!" >&2
            echo -e "  ${red}Command not executed!${reset}" >&2
            ;;
        nat20)
            echo -e "  ${bold}${char_title}${reset} rolled a ${yellow}nat 20${reset} for ${cyan}${basic_cmd}${reset}!" >&2
            echo -e "  Using ${bold}${green}${exec_cmd}${reset}" >&2
            ;;
        partial)
            echo -e "  ${bold}${char_title}${reset} rolled a ${white}${roll}${reset} ${dim}(${bonus_sign}${ability_mod} ${CHAR_PRIMARY_ABILITY})${reset} for ${cyan}${basic_cmd}${reset}!" >&2
            echo -e "  ${dim}$(get_partial_fail_message)${reset}" >&2
            echo -e "  Using ${bold}${exec_cmd}${reset} ${dim}(last ${PARTIAL_FAIL_TAIL_LINES} lines only)${reset}" >&2
            ;;
        *)
            echo -e "  ${bold}${char_title}${reset} rolled a ${white}${roll}${reset} ${dim}(${bonus_sign}${ability_mod} ${CHAR_PRIMARY_ABILITY})${reset} for ${cyan}${basic_cmd}${reset}!" >&2
            echo -e "  Using ${bold}$(if $use_fancy; then echo "${green}${exec_cmd}"; else echo "${exec_cmd}"; fi)${reset}" >&2
            ;;
    esac
    echo -e "${line}" >&2

    # Execute command per outcome
    case "$outcome" in
        nat1)
            echo -e "\n  ${red}$(get_crit_fail_message)${reset}\n" >&2
            ;;
        partial)
            command "$basic_cmd" "${cmd_args[@]}" 2>&1 | tail -n "$PARTIAL_FAIL_TAIL_LINES"
            ;;
        mundane)
            command "$basic_cmd" "${cmd_args[@]}"
            ;;
        fancy)
            command "$exec_cmd" "${cmd_args[@]}"
            ;;
        nat20)
            command "$exec_cmd" "${cmd_args[@]}"
            echo -e "\n  ${yellow}$(get_success_message)${reset}\n" >&2
            ;;
    esac
}
