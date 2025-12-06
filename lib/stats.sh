#!/bin/bash
# Character stats display for d20sh

# Source required libraries
source "$(dirname "${BASH_SOURCE[0]}")/dice.sh"
source "$(dirname "${BASH_SOURCE[0]}")/character.sh"

# Display character sheet
show_character_stats() {
    if ! character_exists; then
        echo "No character found. Run 'd20sh init' to create one." >&2
        exit 1
    fi

    load_character

    echo ""
    echo "Character: $CHAR_NAME"
    echo "Class: $CHAR_CLASS"
    if [[ "$CHAR_SUBCLASS" != "None" && -n "$CHAR_SUBCLASS" ]]; then
        echo "Subclass: $CHAR_SUBCLASS"
    fi
    echo "Primary Ability: $CHAR_PRIMARY_ABILITY"
    echo ""
    echo "Ability Scores:"

    # Display each ability with modifier
    for ability in STR DEX CON INT WIS CHA; do
        local score=""
        case "$ability" in
            STR) score=$CHAR_STR ;;
            DEX) score=$CHAR_DEX ;;
            CON) score=$CHAR_CON ;;
            INT) score=$CHAR_INT ;;
            WIS) score=$CHAR_WIS ;;
            CHA) score=$CHAR_CHA ;;
        esac

        local modifier=$(calculate_modifier "$score")
        local formatted_mod=$(format_modifier "$modifier")

        # Mark primary ability
        if [[ "$ability" == "$CHAR_PRIMARY_ABILITY" ]]; then
            printf "  %s: %2d (%s)  ← Primary\n" "$ability" "$score" "$formatted_mod"
        else
            printf "  %s: %2d (%s)\n" "$ability" "$score" "$formatted_mod"
        fi
    done

    # Calculate success probability
    local primary_score=""
    case "$CHAR_PRIMARY_ABILITY" in
        STR) primary_score=$CHAR_STR ;;
        DEX) primary_score=$CHAR_DEX ;;
        CON) primary_score=$CHAR_CON ;;
        INT) primary_score=$CHAR_INT ;;
        WIS) primary_score=$CHAR_WIS ;;
        CHA) primary_score=$CHAR_CHA ;;
    esac

    local modifier=$(calculate_modifier "$primary_score")
    local dc=15
    local need_to_roll=$((dc - modifier))
    local success_count=$((21 - need_to_roll))
    local success_rate=$((success_count * 5))

    echo ""
    echo "Roll modifier: $(format_modifier $modifier)"
    echo "DC to beat: $dc"
    echo "Success rate: ${success_rate}% (need to roll ${need_to_roll}+)"
    echo ""
}

# Reroll character (delete and recreate)
reroll_character() {
    if ! character_exists; then
        echo "No character found. Run 'd20sh init' to create one." >&2
        exit 1
    fi

    echo "Current character: $(jq -r '.name' "$CHARACTER_FILE")"
    read -p "Delete and create a new character? [y/N] " -n 1 -r
    echo

    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Reroll cancelled."
        exit 0
    fi

    delete_character
    echo ""

    # Run character creation
    source "$(dirname "${BASH_SOURCE[0]}")/init.sh"
    run_character_init
}
