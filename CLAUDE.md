# d20sh

A D&D-inspired terminal enhancement that gamifies command execution. Your terminal character has ability scores that affect command success rates through d20 rolls.

## Core Concept

Commands are wrapped in a roll system where success/failure determines whether you get fancy modern CLI tools or suffer through basic/degraded versions. Think of it like your terminal session as a dungeon crawl where your character's stats matter.

## Character System

### Ability Scores
Uses traditional D&D abilities: STR, DEX, CON, INT, WIS, CHA

**Generation:** Roll 4d6, drop lowest, repeat 6 times. Player assigns results manually to abilities.

**Modifiers:** Standard D&D formula: `(ability_score - 10) / 2` rounded down
- 8 → -1
- 10-11 → 0
- 12-13 → +1
- 14-15 → +2
- 16-17 → +3

### Classes

Classes determine which ability is your **primary ability** (used for all rolls):

- **Strength:** Barbarian, Fighter, Paladin
- **Dexterity:** Rogue, Ranger, Monk
- **Intelligence:** Wizard, Artificer
- **Wisdom:** Cleric, Druid
- **Charisma:** Bard, Sorcerer, Warlock

Players pick a base class (mechanical) and can add a flavor class (cosmetic only).
Example: "Paladin" (base) + "DevOps Paladin" (flavor)

### Character File

Location: `~/.config/d20sh/character.json`
```json
{
  "name": "Grognak the Deployer",
  "class": "Paladin",
  "flavor_class": "DevOps Paladin",
  "created": "2024-12-03",
  "abilities": {
    "STR": 14,
    "DEX": 12,
    "CON": 13,
    "INT": 10,
    "WIS": 8,
    "CHA": 15
  },
  "primary_ability": "STR"
}
```

## Roll Mechanics

### Core Roll
`d20 + primary_ability_modifier` vs DC 15

### Outcomes

**Natural 1 (Critical Fail):**
- Command executes but output is truncated to last 2 lines only
- Overrides any modifiers

**2-14 (Modified Total < 15) - Failure:**
- Commands with fancy versions: use basic version + bad formatting
- Commands without fancy versions: apply bad formatting only

**15+ (Success):**
- Use fancy version of command
- Clean, normal output

**Natural 20 (Critical Success):**
- Use fancy version of command
- Print random success message AFTER output (so it's visible)

### Bad Formatting (on Failure)

Applied to all failed rolls. Two components:

**1. Text Mutation (pick one randomly):**
- Leetspeak: `e→3, a→4, o→0, i→1, s→5, t→7`
- Random capitalization: flip coin per character

**2. Ability-Specific Color Combo:**

Each ability has an awful color scheme (ANSI codes):

- **STR:** Red on magenta `\033[31m\033[45m`
- **DEX:** Dark blue on black `\033[34m\033[40m`
- **CON:** Dark gray on white `\033[90m\033[107m`
- **INT:** Yellow on white `\033[93m\033[107m`
- **WIS:** Green on cyan `\033[32m\033[46m`
- **CHA:** Bright magenta on bright yellow `\033[95m\033[103m`

Use the player's primary ability to determine which color combo to apply.

Reset with `\033[0m` after output.

### Success Messages (Nat 20)

Random selection from pool:
```
"Critical success! The ancient scrolls reveal their secrets clearly."
"The dice gods smile upon you. Command executed flawlessly."
"Natural 20! Even the kernel is impressed."
"Your terminal mastery knows no bounds today!"
"Legendary execution! Tales will be told of this command."
"The spirits of Unix past guide your keystrokes."
"Perfect form! Your command strikes true."
"Critical hit! Maximum effectiveness achieved."
"The RNG gods have blessed this action."
"Flawless victory! Your expertise shines through."
```

Display AFTER command output.

## Command Pairs

### Commands with Fancy Versions
Success (≥15) uses fancy version, failure uses basic + bad formatting:

- `man` → `tldr`
- `cat` → `bat`
- `ls` → `exa` or `lsd`
- `find` → `fd`
- `grep` → `rg` (ripgrep)
- `diff` → `delta`
- `ps` → `procs`
- `du` → `dust`
- `top` → `htop` or `btop`

### Commands with No Fancy Version
Just apply bad formatting on failure:

- `git log`
- `git status`
- `echo`
- `pwd`
- `whoami`
- `date`
- `history`

## Tool Structure

### Commands
```bash
d20sh init         # Character creation wizard
d20sh install      # Check/install fancy CLI tools
d20sh setup        # Generate aliases for .zshrc/.bashrc
d20sh stats        # View current character sheet
d20sh reroll       # Delete character and recreate
```

### Init Flow (Character Creation)

1. Roll 4d6 drop lowest, six times
2. Display all six results
3. Prompt for class selection (shows primary ability for each)
4. Player assigns six rolled values to STR, DEX, CON, INT, WIS, CHA
5. Player enters character name
6. Player enters flavor class (optional, freeform text)
7. Calculate primary ability modifier
8. Write to `~/.config/d20sh/character.json`

### Install Flow

1. Check for fancy commands: `which bat`, `which exa`, `which fd`, etc.
2. Detect package manager (homebrew, apt, pacman, dnf, etc.)
3. Show checklist of installed vs missing
4. Offer to install missing tools
5. Run installation commands with detected package manager

### Setup Flow

1. Check if character exists (require `init` first)
2. Generate alias block for detected shell (.zshrc or .bashrc)
3. Show aliases to user
4. Offer to append to shell config or print for manual addition
5. Remind user to `source ~/.zshrc` or restart shell

Alias format:
```bash
# d20sh aliases - DO NOT EDIT MANUALLY
# Regenerate with: d20sh setup

alias man='d20sh roll man tldr'
alias cat='d20sh roll cat bat'
alias ls='d20sh roll ls exa'
```

### Roll Script (`d20sh roll <basic_cmd> <fancy_cmd>`)

The actual command wrapper:

1. Read character file
2. Get primary ability and modifier
3. Roll d20 (random 1-20)
4. Calculate: `roll + modifier`
5. Determine outcome:
   - Natural 1: Execute basic command, pipe to `tail -n 2`
   - < 15: Execute basic command, apply bad formatting
   - ≥ 15: Execute fancy command (if available), normal output
   - Natural 20: Execute fancy command, append random success message
6. Execute command with appropriate formatting

## Implementation Notes

### Language
Recommend: Bash or Python
- Bash: Native to terminal, easy alias integration
- Python: Better for dice rolling, JSON handling, cross-platform

### Dependencies
- Standard shell tools (bash/zsh)
- `jq` for JSON manipulation (if using bash)
- Fancy CLI tools (optional, installed by tool)

### File Structure
```
~/.config/d20sh/
├── character.json          # Character data
├── roll.sh or roll.py      # Main roll wrapper
└── success_messages.txt    # Pool of nat 20 messages
```

### Shell Detection
Check `$SHELL` or `$0` to determine .bashrc vs .zshrc

### Edge Cases
- No character file exists → prompt to run `init`
- Fancy command not installed → fallback to basic
- Character file corrupted → offer to reroll
- Multiple shell configs → ask which to modify

## Future Expansion Ideas

(Not for initial implementation, but easy to add later)

- Experience/leveling system
- Track command usage statistics
- Proficiency bonuses for frequently used commands
- Racial bonuses (add flavor only)
- Equipment/buffs that modify rolls temporarily
- Party system (share character with team members)
- Different DCs for different commands
- Curse of the typo (advantage/disadvantage on rolls)

## Design Philosophy

- **Simple to start:** Just run `init` and `setup`
- **Manually editable:** Character file is plain JSON
- **Additive:** Doesn't break existing workflow
- **Fun failure:** Bad formatting is annoying but not destructive
- **Rewarding success:** Modern tools are genuinely better
- **Optional:** Easy to disable (just remove aliases)
