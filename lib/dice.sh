#!/bin/bash
# Dice rolling functions for d20sh

# Roll a single d20
roll_d20() {
    echo $((RANDOM % 20 + 1))
}

# Roll with disadvantage (2d20, take lower)
# Returns: "roll1,roll2:result" e.g., "14,8:8"
roll_d20_disadvantage() {
    local roll1=$((RANDOM % 20 + 1))
    local roll2=$((RANDOM % 20 + 1))

    local result=$roll1
    if [[ $roll2 -lt $roll1 ]]; then
        result=$roll2
    fi

    echo "${roll1},${roll2}:${result}"
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
    IFS=$'\n' sorted=($(printf '%s\n' "${rolls[@]}" | sort -n))
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
