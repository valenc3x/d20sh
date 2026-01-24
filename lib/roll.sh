#!/bin/bash
# Roll wrapper for command execution

# Source required libraries
source "$(dirname "${BASH_SOURCE[0]}")/dice.sh"
source "$(dirname "${BASH_SOURCE[0]}")/character.sh"
source "$(dirname "${BASH_SOURCE[0]}")/formatting.sh"

# Get random success message
get_success_message() {
    if [[ -n "$DATA_DIR" && -f "$DATA_DIR/success_messages.txt" ]]; then
        shuf -n 1 "$DATA_DIR/success_messages.txt"
    else
        echo "Critical success! The dice gods smile upon you."
    fi
}

# Get failure message based on ability
get_failure_message() {
    local ability="$1"

    case "$ability" in
        STR) echo "your might falters" ;;
        DEX) echo "your reflexes betray you" ;;
        CON) echo "your endurance fails" ;;
        INT) echo "your mind draws a blank" ;;
        WIS) echo "your judgment fails" ;;
        CHA) echo "your charm falls flat" ;;
        *) echo "the command fizzles" ;;
    esac
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
    local outcome=""
    local use_fancy=false

    if [[ $roll -eq 1 ]]; then
        outcome="nat1"
    elif [[ $roll -eq 20 ]]; then
        outcome="nat20"
        use_fancy=true
    elif [[ $total -ge 20 ]]; then
        outcome="fancy"
        use_fancy=true
    elif [[ $total -ge 11 ]]; then
        outcome="normal"
    elif [[ $total -ge 6 ]]; then
        outcome="color_swap"
    else
        outcome="letter_swap"
    fi

    # Check if fancy command is available
    if $use_fancy && ! command -v "$fancy_cmd" &> /dev/null; then
        use_fancy=false
    fi

    # Determine which command to execute
    local exec_cmd="$basic_cmd"
    if $use_fancy; then
        exec_cmd="$fancy_cmd"
    fi

    # Display roll info to stderr
    local bonus_sign=""
    if [[ $ability_mod -ge 0 ]]; then
        bonus_sign="+"
    fi
    echo "d20: $roll ${bonus_sign}${ability_mod} = $total" >&2

    # Execute command and format output
    if [[ "$outcome" == "nat1" ]]; then
        echo "Natural 1! $(get_failure_message "$CHAR_PRIMARY_ABILITY")" >&2
    elif [[ "$outcome" == "letter_swap" ]]; then
        command "$basic_cmd" "${cmd_args[@]}" 2>&1 | format_output "letter_swap" "$CHAR_PRIMARY_ABILITY"
    elif [[ "$outcome" == "color_swap" ]]; then
        command "$basic_cmd" "${cmd_args[@]}" 2>&1 | format_output "color_swap" "$CHAR_PRIMARY_ABILITY"
    elif [[ "$outcome" == "normal" ]]; then
        command "$basic_cmd" "${cmd_args[@]}"
    elif [[ "$outcome" == "nat20" ]]; then
        command "$exec_cmd" "${cmd_args[@]}"
        echo "" >&2
        echo "$(get_success_message)" >&2
    elif [[ "$outcome" == "fancy" ]]; then
        command "$exec_cmd" "${cmd_args[@]}"
    fi
}
