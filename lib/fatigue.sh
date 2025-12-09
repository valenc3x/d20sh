#!/bin/bash
# Fatigue system for d20sh - tracks command count and applies penalties

FATIGUE_FILE="$HOME/.config/d20sh/fatigue.json"

# Three-tier fatigue system
# Light fatigue: -1 to ability modifier
LIGHT_FATIGUE_COUNTS=(11 13 17 19)

# Heavy fatigue: no ability modifier
HEAVY_FATIGUE_COUNTS=(22 41 58 71 82 89)

# Exhausted: roll with disadvantage
EXHAUSTED_COUNTS=(94 97 99)

# Initialize fatigue file if it doesn't exist
init_fatigue_file() {
    if [[ ! -f "$FATIGUE_FILE" ]]; then
        mkdir -p "$(dirname "$FATIGUE_FILE")"
        cat > "$FATIGUE_FILE" << EOF
{
  "command_count": 0,
  "last_reset": "$(date +%Y-%m-%d)"
}
EOF
    fi
}

# Check if we need a daily reset
check_daily_reset() {
    init_fatigue_file

    local last_reset=$(jq -r '.last_reset' "$FATIGUE_FILE")
    local today=$(date +%Y-%m-%d)

    if [[ "$last_reset" != "$today" ]]; then
        reset_fatigue_counter
    fi
}

# Get current command count
get_command_count() {
    init_fatigue_file
    jq -r '.command_count' "$FATIGUE_FILE"
}

# Increment command counter
increment_command_count() {
    init_fatigue_file
    local current=$(get_command_count)
    local new_count=$((current + 1))

    # Reset to 0 if we hit 100
    if [[ $new_count -ge 100 ]]; then
        new_count=0
    fi

    # Update file
    jq --arg count "$new_count" '.command_count = ($count | tonumber)' "$FATIGUE_FILE" > "${FATIGUE_FILE}.tmp"
    mv "${FATIGUE_FILE}.tmp" "$FATIGUE_FILE"

    echo "$new_count"
}

# Reset fatigue counter (called on nat 20 or daily reset)
reset_fatigue_counter() {
    init_fatigue_file
    local today=$(date +%Y-%m-%d)

    jq --arg date "$today" '.command_count = 0 | .last_reset = $date' "$FATIGUE_FILE" > "${FATIGUE_FILE}.tmp"
    mv "${FATIGUE_FILE}.tmp" "$FATIGUE_FILE"
}

# Check if current count triggers light fatigue
is_light_fatigue() {
    local count=$(get_command_count)

    for trigger in "${LIGHT_FATIGUE_COUNTS[@]}"; do
        if [[ $count -eq $trigger ]]; then
            return 0  # True
        fi
    done

    return 1  # False
}

# Check if current count triggers heavy fatigue
is_heavy_fatigue() {
    local count=$(get_command_count)

    for trigger in "${HEAVY_FATIGUE_COUNTS[@]}"; do
        if [[ $count -eq $trigger ]]; then
            return 0  # True
        fi
    done

    return 1  # False
}

# Check if current count triggers exhausted state
is_exhausted() {
    local count=$(get_command_count)

    for trigger in "${EXHAUSTED_COUNTS[@]}"; do
        if [[ $count -eq $trigger ]]; then
            return 0  # True
        fi
    done

    return 1  # False
}

# Get fatigue level (returns: none, light, heavy, or exhausted)
get_fatigue_level() {
    if is_exhausted; then
        echo "exhausted"
    elif is_heavy_fatigue; then
        echo "heavy"
    elif is_light_fatigue; then
        echo "light"
    else
        echo "none"
    fi
}
