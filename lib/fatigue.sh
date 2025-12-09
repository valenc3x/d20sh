#!/bin/bash
# Fatigue system for d20sh - tracks command count and applies disadvantage

FATIGUE_FILE="$HOME/.config/d20sh/fatigue.json"

# Inverse prime progression - disadvantage triggers at these command counts
# Formula: 100 - prime (for all primes up to 97)
# This makes disadvantage increasingly frequent as you approach 100
DISADVANTAGE_COUNTS=(2 3 5 7 11 13 17 19 23 29 31 37 41 43 47 53 57 59 63 69 71 77 81 83 87 89 93 95 97 98)

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

# Check if current count triggers disadvantage
is_disadvantaged() {
    local count=$(get_command_count)

    # Check if count matches any disadvantage trigger
    for trigger in "${DISADVANTAGE_COUNTS[@]}"; do
        if [[ $count -eq $trigger ]]; then
            return 0  # True - disadvantage applies
        fi
    done

    return 1  # False - no disadvantage
}

# Get count until next disadvantage trigger (for display)
get_next_disadvantage_count() {
    local count=$(get_command_count)

    for trigger in "${DISADVANTAGE_COUNTS[@]}"; do
        if [[ $trigger -gt $count ]]; then
            echo $trigger
            return
        fi
    done

    echo 100  # Next reset
}
