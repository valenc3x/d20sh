#!/bin/bash
# Color formatting for failed rolls

# Maximum characters to format (50KB)
MAX_FORMAT_CHARS=51200

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

# Apply leetspeak transformation
apply_leetspeak() {
    local text="$1"
    # Use tr for fast character replacement
    # e→3, a→4, o→0, i→1, s→5, t→7
    echo "$text" | tr 'eaoist' '340157' | tr 'EAOIST' '340157'
}

# Apply random capitalization
apply_random_caps() {
    local text="$1"
    local result=""
    local i

    for ((i=0; i<${#text}; i++)); do
        local char="${text:$i:1}"
        # 50% chance to uppercase
        if [[ $((RANDOM % 2)) -eq 0 ]]; then
            char=$(echo "$char" | tr '[:lower:]' '[:upper:]')
        else
            char=$(echo "$char" | tr '[:upper:]' '[:lower:]')
        fi
        result="${result}${char}"
    done

    echo "$result"
}

# Apply both text mutations
apply_text_mutations() {
    local text="$1"

    # First apply leetspeak, then random caps
    text=$(apply_leetspeak "$text")
    text=$(apply_random_caps "$text")

    echo "$text"
}

# Apply bad formatting to a single line
format_bad_line() {
    local line="$1"
    local colors="$2"

    # Apply text mutations
    local mutated=$(apply_text_mutations "$line")

    # Apply awful colors
    echo -e "\033[${colors}m${mutated}\033[0m"
}

# Apply bad formatting to stdin with character budget
apply_bad_formatting() {
    local primary_ability="$1"
    local colors=$(get_ability_colors "$primary_ability")

    # Read all input into an array
    local lines=()
    while IFS= read -r line; do
        lines+=("$line")
    done

    # Calculate total character count
    local total_chars=0
    local line_count=${#lines[@]}
    for line in "${lines[@]}"; do
        total_chars=$((total_chars + ${#line}))
    done

    # If under budget, format everything
    if [[ $total_chars -le $MAX_FORMAT_CHARS ]]; then
        for line in "${lines[@]}"; do
            format_bad_line "$line" "$colors"
        done
    else
        # Over budget - format first 25KB and last 25KB
        local half_budget=$((MAX_FORMAT_CHARS / 2))
        local char_count=0
        local first_section_end=0
        local last_section_start=$line_count

        # Find where first section ends
        for ((i=0; i<line_count; i++)); do
            char_count=$((char_count + ${#lines[$i]}))
            if [[ $char_count -ge $half_budget ]]; then
                first_section_end=$i
                break
            fi
        done

        # Find where last section starts (count backwards)
        char_count=0
        for ((i=line_count-1; i>=0; i--)); do
            char_count=$((char_count + ${#lines[$i]}))
            if [[ $char_count -ge $half_budget ]]; then
                last_section_start=$i
                break
            fi
        done

        # Format first section
        for ((i=0; i<=first_section_end; i++)); do
            format_bad_line "${lines[$i]}" "$colors"
        done

        # Print signal loss message
        local skipped_lines=$((last_section_start - first_section_end - 1))
        if [[ $skipped_lines -gt 0 ]]; then
            echo -e "\033[${colors}m[... $skipped_lines lines of corrupted data lost to the void ...]\033[0m"
        fi

        # Format last section
        for ((i=last_section_start; i<line_count; i++)); do
            format_bad_line "${lines[$i]}" "$colors"
        done
    fi
}

# Apply color-only formatting (no text mutations)
apply_color_only() {
    local primary_ability="$1"
    local colors=$(get_ability_colors "$primary_ability")

    # Just apply colors, no text mutations
    while IFS= read -r line; do
        echo -e "\033[${colors}m${line}\033[0m"
    done
}

# Format output based on outcome
format_output() {
    local outcome="$1"
    local primary_ability="$2"

    case "$outcome" in
        nat1|failure_full)
            # Bad color + text mutations (leetspeak + random caps)
            apply_bad_formatting "$primary_ability"
            ;;
        failure_color)
            # Bad color only, no text mutations
            apply_color_only "$primary_ability"
            ;;
        *)
            # Normal output
            cat
            ;;
    esac
}
