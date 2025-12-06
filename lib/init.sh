#!/bin/bash
# Character creation wizard for d20sh

# Source required libraries
source "$(dirname "${BASH_SOURCE[0]}")/dice.sh"
source "$(dirname "${BASH_SOURCE[0]}")/character.sh"

# Display class options
show_class_options() {
    cat << 'EOF'

Available classes (primary ability):
  STR: Barbarian, Fighter, Paladin
  DEX: Rogue, Ranger, Monk
  INT: Wizard, Artificer
  WIS: Cleric, Druid
  CHA: Bard, Sorcerer, Warlock

EOF
}

# Validate class name
validate_class() {
    local class="$1"
    case "$class" in
        Barbarian|Fighter|Paladin|Rogue|Ranger|Monk|Wizard|Artificer|Cleric|Druid|Bard|Sorcerer|Warlock)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# Main character creation wizard
run_character_init() {
    echo "🎲 d20sh Character Creation"
    echo ""

    # Check if character already exists
    if character_exists; then
        echo "⚠️  A character already exists: $(jq -r '.name' "$CHARACTER_FILE")"
        read -p "Delete and create a new character? [y/N] " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Character creation cancelled."
            exit 0
        fi
        delete_character
        echo ""
    fi

    # Roll ability scores (4d6 drop lowest, six times)
    echo "🎲 Rolling ability scores (4d6 drop lowest)..."
    echo ""

    local rolls=()
    local values=()

    for i in {1..6}; do
        local result=$(roll_4d6_drop_lowest)
        local dice_rolls="${result%:*}"
        local sum="${result#*:}"

        rolls+=("[$dice_rolls] = $sum")
        values+=("$sum")

        echo "  Roll $i: [$dice_rolls] = $sum"
    done

    echo ""
    echo "Your rolled values: ${values[*]}"
    echo ""

    # Class selection
    show_class_options

    local selected_class=""
    while true; do
        read -p "Select class: " selected_class
        # Capitalize first letter
        selected_class="$(tr '[:lower:]' '[:upper:]' <<< ${selected_class:0:1})${selected_class:1}"

        if validate_class "$selected_class"; then
            break
        else
            echo "Invalid class. Please choose from the list above."
        fi
    done

    local primary_ability=$(get_class_primary_ability "$selected_class")
    echo "Primary ability: $primary_ability"
    echo ""

    # Assign ability scores
    echo "Assign your rolled values to abilities:"
    echo "Available values: ${values[*]}"
    echo ""

    # Use separate variables instead of associative array (bash 3.2 compatibility)
    local str_score dex_score con_score int_score wis_score cha_score
    local available_values=("${values[@]}")  # Copy of values we can modify

    for ability in STR DEX CON INT WIS CHA; do
        while true; do
            read -p "  $ability: " score

            # Check if value is still available
            local found_index=-1
            for i in "${!available_values[@]}"; do
                if [[ "${available_values[$i]}" == "$score" ]]; then
                    found_index=$i
                    break
                fi
            done

            if [[ $found_index -ge 0 ]]; then
                # Use this value and remove it from available
                case "$ability" in
                    STR) str_score=$score ;;
                    DEX) dex_score=$score ;;
                    CON) con_score=$score ;;
                    INT) int_score=$score ;;
                    WIS) wis_score=$score ;;
                    CHA) cha_score=$score ;;
                esac
                unset 'available_values[$found_index]'
                available_values=("${available_values[@]}")  # Re-index array
                break
            else
                echo "    Invalid or already used. Choose from: ${available_values[*]}"
            fi
        done
    done

    echo ""

    # Character name
    read -p "Character name: " char_name
    while [[ -z "$char_name" ]]; do
        echo "Name cannot be empty."
        read -p "Character name: " char_name
    done

    # Subclass (optional)
    read -p "Subclass (optional, for flavor): " subclass
    if [[ -z "$subclass" ]]; then
        subclass="None"
    fi

    echo ""

    # Create character file
    create_character \
        "$char_name" \
        "$selected_class" \
        "$subclass" \
        "$primary_ability" \
        "$str_score" \
        "$dex_score" \
        "$con_score" \
        "$int_score" \
        "$wis_score" \
        "$cha_score"

    # Calculate and display modifier
    local primary_score=""
    case "$primary_ability" in
        STR) primary_score=$str_score ;;
        DEX) primary_score=$dex_score ;;
        CON) primary_score=$con_score ;;
        INT) primary_score=$int_score ;;
        WIS) primary_score=$wis_score ;;
        CHA) primary_score=$cha_score ;;
    esac
    local modifier=$(calculate_modifier "$primary_score")
    local formatted_mod=$(format_modifier "$modifier")

    echo ""
    echo "✓ Character created!"
    echo "  Name: $char_name"
    echo "  Class: $selected_class"
    if [[ "$subclass" != "None" ]]; then
        echo "  Subclass: $subclass"
    fi
    echo "  Primary Ability: $primary_ability ($primary_score)"
    echo "  Modifier: $formatted_mod"
    echo ""
    echo "Next steps:"
    echo "  • Run 'd20sh stats' to view your character sheet"
    echo "  • Run 'd20sh setup' to configure your shell"
}
