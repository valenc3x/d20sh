#!/bin/bash
# Dice rolling functions for d20sh

# Roll a single d20
roll_d20() {
    echo $((RANDOM % 20 + 1))
}

# Roll a single d6
roll_d6() {
    echo $((RANDOM % 6 + 1))
}

# Roll 4d6 and drop the lowest
roll_4d6_drop_lowest() {
    local rolls=()
    local i

    # Roll 4d6
    for i in {1..4}; do
        rolls+=($((RANDOM % 6 + 1)))
    done

    # Sort the array
    IFS=$'\n' sorted=($(sort -n <<<"${rolls[*]}"))
    unset IFS

    # Sum the top 3 (drop index 0, which is the lowest)
    local sum=$((sorted[1] + sorted[2] + sorted[3]))

    # Return format: "rolls:sum" e.g., "4,6,3,2:13"
    echo "${rolls[0]},${rolls[1]},${rolls[2]},${rolls[3]}:$sum"
}

# Calculate ability modifier from ability score
# Formula: (score - 10) / 2, rounded down
calculate_modifier() {
    local score=$1
    local modifier=$(( (score - 10) / 2 ))
    echo $modifier
}

# Format modifier with + or - sign
format_modifier() {
    local mod=$1
    if [[ $mod -ge 0 ]]; then
        echo "+$mod"
    else
        echo "$mod"
    fi
}
