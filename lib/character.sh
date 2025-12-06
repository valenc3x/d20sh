#!/bin/bash
# Character management functions for d20sh

CHARACTER_FILE="$HOME/.config/d20sh/character.json"
CONFIG_DIR="$HOME/.config/d20sh"

# Check if character exists
character_exists() {
    [[ -f "$CHARACTER_FILE" ]]
}

# Load character data and export key variables
load_character() {
    if ! character_exists; then
        echo "Error: No character found. Run 'd20sh init' to create one." >&2
        return 1
    fi

    if ! command -v jq &> /dev/null; then
        echo "Error: 'jq' is required but not installed." >&2
        return 1
    fi

    # Export character data as environment variables
    export CHAR_NAME=$(jq -r '.name' "$CHARACTER_FILE")
    export CHAR_CLASS=$(jq -r '.class' "$CHARACTER_FILE")
    export CHAR_SUBCLASS=$(jq -r '.subclass // "None"' "$CHARACTER_FILE")
    export CHAR_PRIMARY_ABILITY=$(jq -r '.primary_ability' "$CHARACTER_FILE")

    # Export all ability scores
    export CHAR_STR=$(jq -r '.abilities.STR' "$CHARACTER_FILE")
    export CHAR_DEX=$(jq -r '.abilities.DEX' "$CHARACTER_FILE")
    export CHAR_CON=$(jq -r '.abilities.CON' "$CHARACTER_FILE")
    export CHAR_INT=$(jq -r '.abilities.INT' "$CHARACTER_FILE")
    export CHAR_WIS=$(jq -r '.abilities.WIS' "$CHARACTER_FILE")
    export CHAR_CHA=$(jq -r '.abilities.CHA' "$CHARACTER_FILE")

    return 0
}

# Get primary ability score
get_primary_ability_score() {
    load_character || return 1

    case "$CHAR_PRIMARY_ABILITY" in
        STR) echo "$CHAR_STR" ;;
        DEX) echo "$CHAR_DEX" ;;
        CON) echo "$CHAR_CON" ;;
        INT) echo "$CHAR_INT" ;;
        WIS) echo "$CHAR_WIS" ;;
        CHA) echo "$CHAR_CHA" ;;
        *) echo "10" ;; # Default to 10 if something is wrong
    esac
}

# Get primary ability modifier
get_primary_ability_modifier() {
    local score=$(get_primary_ability_score)
    calculate_modifier "$score"
}

# Create character file
create_character() {
    local name="$1"
    local class="$2"
    local subclass="$3"
    local primary_ability="$4"
    local str="$5"
    local dex="$6"
    local con="$7"
    local int="$8"
    local wis="$9"
    local cha="${10}"

    # Ensure config directory exists
    mkdir -p "$CONFIG_DIR"

    # Create JSON file
    cat > "$CHARACTER_FILE" << EOF
{
  "name": "$name",
  "class": "$class",
  "subclass": "$subclass",
  "created": "$(date +%Y-%m-%d)",
  "abilities": {
    "STR": $str,
    "DEX": $dex,
    "CON": $con,
    "INT": $int,
    "WIS": $wis,
    "CHA": $cha
  },
  "primary_ability": "$primary_ability"
}
EOF

    echo "✓ Character created at $CHARACTER_FILE"
}

# Delete character file
delete_character() {
    if character_exists; then
        rm "$CHARACTER_FILE"
        echo "✓ Character deleted"
    else
        echo "No character file found"
    fi
}

# Map class to primary ability
get_class_primary_ability() {
    local class="$1"

    case "$class" in
        Barbarian|Fighter|Paladin) echo "STR" ;;
        Rogue|Ranger|Monk) echo "DEX" ;;
        Wizard|Artificer) echo "INT" ;;
        Cleric|Druid) echo "WIS" ;;
        Bard|Sorcerer|Warlock) echo "CHA" ;;
        *) echo "STR" ;; # Default
    esac
}
