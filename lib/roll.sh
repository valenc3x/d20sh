#!/bin/bash
# Roll wrapper for command execution

# Source required libraries
source "$(dirname "${BASH_SOURCE[0]}")/dice.sh"
source "$(dirname "${BASH_SOURCE[0]}")/character.sh"
source "$(dirname "${BASH_SOURCE[0]}")/formatting.sh"
source "$(dirname "${BASH_SOURCE[0]}")/fatigue.sh"

# Get day of week bonus
get_day_bonus() {
    local day=$(date +%u)  # 1=Monday, 7=Sunday

    case "$day" in
        1|5) echo 2 ;;   # Monday, Friday: +2
        2|4) echo 1 ;;   # Tuesday, Thursday: +1
        3)   echo 0 ;;   # Wednesday: +0
        6|7) echo -3 ;;  # Saturday, Sunday: -3
        *) echo 0 ;;
    esac
}

# Get day name for display
get_day_name() {
    date +%A
}

# Get random success message
get_success_message() {
    if [[ -n "$DATA_DIR" && -f "$DATA_DIR/success_messages.txt" ]]; then
        shuf -n 1 "$DATA_DIR/success_messages.txt"
    else
        echo "Critical success! The dice gods smile upon you."
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

    # Check for daily reset
    check_daily_reset

    # Get modifiers
    local ability_mod=$(get_primary_ability_modifier)
    local day_bonus=$(get_day_bonus)
    local day_name=$(get_day_name)

    # Check fatigue level
    local fatigue_level=$(get_fatigue_level)
    local fatigue_penalty=0

    # Apply fatigue penalty to ability modifier
    case "$fatigue_level" in
        light)
            fatigue_penalty=1
            ability_mod=$((ability_mod - 1))
            ;;
        heavy)
            fatigue_penalty=$ability_mod
            ability_mod=0
            ;;
        exhausted)
            # Disadvantage is applied to roll, not modifier
            fatigue_penalty=0
            ;;
    esac

    # Roll d20 (with or without disadvantage for exhausted state)
    local roll
    local roll_display=""
    if [[ "$fatigue_level" == "exhausted" ]]; then
        # Roll with disadvantage
        local disadvantage_result=$(roll_d20_disadvantage)
        local roll1=$(echo "$disadvantage_result" | cut -d: -f1 | cut -d, -f1)
        local roll2=$(echo "$disadvantage_result" | cut -d: -f1 | cut -d, -f2)
        roll=$(echo "$disadvantage_result" | cut -d: -f2)
        roll_display="Roll 1: $roll1, Roll 2: $roll2 → Taking $roll"
    else
        roll=$(roll_d20)
        roll_display="$roll"
    fi

    local total=$((roll + ability_mod + day_bonus))

    # Determine outcome (DC 17)
    local outcome=""
    local use_fancy=false
    local show_message=false

    if [[ $roll -eq 1 ]]; then
        outcome="nat1"
    elif [[ $roll -eq 20 ]] || [[ $total -ge 20 ]]; then
        outcome="crit"
        use_fancy=true
        show_message=true
        # Natural 20 resets fatigue
        reset_fatigue_counter
    elif [[ $total -ge 17 ]]; then
        outcome="success"
        use_fancy=true
    else
        outcome="failure"
    fi

    # Increment command counter (unless it was a nat 20, which already reset it)
    if [[ $roll -ne 20 ]]; then
        increment_command_count > /dev/null
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

    # Display roll info to stderr (so it doesn't interfere with command output)

    # Show fatigue warning if applicable
    case "$fatigue_level" in
        light)
            echo "😓 [Tired - Ability penalty -1]" >&2
            ;;
        heavy)
            echo "😰 [Heavy Fatigue - No ability modifier]" >&2
            ;;
        exhausted)
            echo "💀 [EXHAUSTED - Rolling with disadvantage]" >&2
            ;;
    esac

    # Show roll
    echo "🎲 Rolled $roll_display" >&2

    # Show modifiers and total
    if [[ $day_bonus -ne 0 ]]; then
        local day_sign=""
        if [[ $day_bonus -gt 0 ]]; then
            day_sign="+"
        fi
        echo "   + $ability_mod (ability) ${day_sign}${day_bonus} ($day_name) = $total" >&2
    else
        echo "   + $ability_mod (ability) = $total" >&2
    fi

    # Execute command and format output
    if [[ "$outcome" == "nat1" ]]; then
        echo "💀 Natural 1! Your senses fail you..." >&2
        command "$basic_cmd" "${cmd_args[@]}" 2>&1 | format_output "nat1" "$CHAR_PRIMARY_ABILITY"
    elif [[ "$outcome" == "failure" ]]; then
        echo "❌ Failed (need 17+)" >&2
        command "$basic_cmd" "${cmd_args[@]}" 2>&1 | format_output "failure" "$CHAR_PRIMARY_ABILITY"
    elif [[ "$outcome" == "success" ]]; then
        if $use_fancy; then
            echo "✓ Success (using $fancy_cmd)" >&2
        else
            echo "✓ Success ($fancy_cmd not installed, using $basic_cmd)" >&2
        fi
        command "$exec_cmd" "${cmd_args[@]}"
    elif [[ "$outcome" == "crit" ]]; then
        if $use_fancy; then
            echo "⭐ Critical success! (using $fancy_cmd)" >&2
        else
            echo "⭐ Critical success! ($fancy_cmd not installed, using $basic_cmd)" >&2
        fi
        command "$exec_cmd" "${cmd_args[@]}"

        # Show success message AFTER output
        echo "" >&2
        echo "$(get_success_message)" >&2
    fi
}
