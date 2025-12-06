#!/bin/bash
# Color formatting for failed rolls

# Get color codes for ability-specific awful color combos
get_ability_colors() {
    local ability="$1"

    case "$ability" in
        STR) echo "31;45" ;;      # Red on magenta
        DEX) echo "34;40" ;;      # Dark blue on black
        CON) echo "90;107" ;;     # Dark gray on white
        INT) echo "93;107" ;;     # Yellow on white
        WIS) echo "32;46" ;;      # Green on cyan
        CHA) echo "95;103" ;;     # Bright magenta on bright yellow
        *) echo "0" ;;            # Default (no color)
    esac
}

# Apply bad formatting to stdin
apply_bad_formatting() {
    local primary_ability="$1"
    local colors=$(get_ability_colors "$primary_ability")

    # Apply colors to each line
    while IFS= read -r line; do
        echo -e "\033[${colors}m${line}\033[0m"
    done
}

# Format output based on outcome
format_output() {
    local outcome="$1"
    local primary_ability="$2"

    case "$outcome" in
        nat1)
            # Truncate to last 2 lines
            tail -n 2
            ;;
        failure)
            # Apply bad colors
            apply_bad_formatting "$primary_ability"
            ;;
        plain|success|crit)
            # Normal output
            cat
            ;;
    esac
}
