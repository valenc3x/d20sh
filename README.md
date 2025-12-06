# d20sh

A D&D-inspired terminal enhancement that gamifies command execution. Roll for init!

Your terminal character has ability scores (STR, DEX, CON, INT, WIS, CHA) that affect command success rates through d20 rolls. Success means you get fancy modern CLI tools; failure means you suffer through basic versions with awful formatting.

## ✨ Features

- **Character Creation**: Roll 4d6 drop lowest for ability scores, choose your class
- **D20 Roll Mechanics**: Every command rolls d20 + ability modifier + day-of-week bonus
- **Day-of-Week Bonuses**: Motivation on Monday/Friday, harsh penalties on weekends
- **Success/Failure System**:
  - Natural 1: Output truncated to 2 lines
  - 2-10: Basic command with terrible colors
  - 11-12: Basic command, no formatting (barely made it!)
  - 13-19: Fancy command (bat, lsd, fd, etc.)
  - Natural 20 or 21+: Fancy command + epic success message
- **Fancy Tool Integration**: Automatically uses modern CLI alternatives when you succeed

## 🎮 Quick Start

### Installation

```bash
git clone https://github.com/valenc3x/d20sh.git
cd d20sh
./install.sh
```

Make sure `~/.local/bin` is in your PATH:
```bash
export PATH="$HOME/.local/bin:$PATH"
```

### Setup

1. **Create your character:**
   ```bash
   d20sh init
   ```
   Roll for ability scores, choose your class, name your character!

2. **Install fancy tools (optional but recommended):**
   ```bash
   d20sh install
   ```
   Automatically detects your package manager and installs modern CLI tools.

3. **Configure your shell:**
   ```bash
   d20sh setup
   ```
   Adds aliases to your `.zshrc` to enable d20 rolls for commands.

4. **Activate aliases:**
   ```bash
   source ~/.zshrc
   ```
   Or restart your terminal.

5. **Start rolling!**
   ```bash
   ls        # Rolls d20, might use lsd or basic ls
   cat file  # Rolls d20, might use bat or basic cat
   grep foo  # Rolls d20, might use ripgrep or basic grep
   ```

## 🎲 How It Works

### Roll Mechanics

Every command rolls: **d20 + primary_ability_modifier + day_of_week_bonus**

**Day-of-Week Bonuses:**
- Weekend (Sat/Sun): **-3** (discourages weekend work!)
- Monday/Friday: **+2** (motivation boost)
- Tuesday/Thursday: **+1**
- Wednesday: **+0** (hump day)

**Outcomes:**
- **Natural 1**: Critical failure, output truncated to last 2 lines
- **Total 2-10**: Failure, basic command with awful colors (based on your primary ability)
- **Total 11-12**: Barely made it, basic command without colors
- **Total 13-19**: Success, fancy command (if installed)
- **Natural 20 or Total 20+**: Critical success, fancy command + random success message

### Classes & Primary Abilities

Your class determines which ability score is used for ALL rolls:

- **STR**: Barbarian, Fighter, Paladin
- **DEX**: Rogue, Ranger, Monk
- **INT**: Wizard, Artificer
- **WIS**: Cleric, Druid
- **CHA**: Bard, Sorcerer, Warlock

Ability modifiers use standard D&D formula: `(score - 10) / 2` rounded down

### Fancy Commands

When you succeed (roll 13+), these modern tools are used instead:

| Basic | Fancy | Description |
|-------|-------|-------------|
| `cat` | `bat` | Syntax highlighting, line numbers |
| `ls` | `lsd` | Icons, colors, tree view |
| `find` | `fd` | Faster, simpler syntax |
| `grep` | `rg` (ripgrep) | Blazing fast search |
| `diff` | `delta` | Beautiful diffs |
| `ps` | `procs` | Modern process viewer |
| `du` | `dust` | Intuitive disk usage |
| `top` | `htop` | Interactive process viewer |
| `man` | `tldr` | Simplified examples |

## 📋 Commands

```bash
d20sh init              # Create a new character
d20sh stats             # View character sheet
d20sh reroll            # Delete and recreate character
d20sh install           # Install fancy CLI tools
d20sh setup             # Generate shell aliases
d20sh help              # Show help message
```

## 🎯 Examples

### Character with +2 modifier on Monday (+2 day bonus = +4 total)

```bash
$ ls
🎲 Rolled 15 + 2 (ability) +2 (Monday) = 19
✓ Success (using lsd)
[beautiful colorful directory listing]
```

### Same character on Saturday (-3 day bonus = -1 total)

```bash
$ cat README.md
🎲 Rolled 8 + 2 (ability) -3 (Saturday) = 7
❌ Failed (need 11+)
[output with terrible yellow-on-white colors]
```

### Natural 20!

```bash
$ grep TODO *.md
🎲 Rolled 20 + 2 (ability) +2 (Monday) = 24
⭐ Critical success! (using rg)
[fast ripgrep results]

The dice gods smile upon you. Command executed flawlessly.
```

## 🔧 Configuration

Character file: `~/.config/d20sh/character.json`

You can manually edit ability scores, class, or name. Just don't break the JSON!

## 🐛 Troubleshooting

**Aliases not working?**
- Make sure you ran `source ~/.zshrc` after setup
- Check that aliases were added: `tail ~/.zshrc`

**"Character not found" errors?**
- Run `d20sh init` to create a character first

**Fancy tools not being used?**
- Run `d20sh install` to install missing tools
- Check installation: `which bat lsd fd rg`

**Bash 3.2 compatibility issues?**
- The tool now supports macOS's default bash 3.2
- If you see errors about associative arrays, update to latest version

## 📊 Success Rate Calculator

With DC thresholds at 11/13/20, your success rates:

| Modifier | Avoid Failure (11+) | Fancy Tools (13+) | Crit Success (20+) |
|----------|---------------------|-------------------|---------------------|
| -1 | 50% | 40% | 5% |
| +0 | 50% | 40% | 5% |
| +1 | 55% | 45% | 10% |
| +2 | 60% | 50% | 15% |
| +3 | 65% | 55% | 20% |

Add day bonuses for the full picture!

## 🎨 Philosophy

- **Simple to start**: Just `init` and `setup`
- **Manually editable**: Character file is plain JSON
- **Additive**: Doesn't break existing workflow
- **Fun failure**: Bad formatting is annoying but not destructive
- **Rewarding success**: Modern tools are genuinely better
- **Optional**: Easy to disable (just remove aliases)

## 📜 License

MIT License - See LICENSE file

## 🙏 Credits

Inspired by D&D 5e mechanics and the amazing modern CLI tools community.

Fancy tools used:
- [bat](https://github.com/sharkdp/bat)
- [lsd](https://github.com/lsd-rs/lsd)
- [fd](https://github.com/sharkdp/fd)
- [ripgrep](https://github.com/BurntSushi/ripgrep)
- [delta](https://github.com/dandavison/delta)
- [procs](https://github.com/dalance/procs)
- [dust](https://github.com/bootandy/dust)
- [htop](https://htop.dev/)
- [tldr](https://github.com/tldr-pages/tldr)

---

**Now roll for initiative and may the RNG gods be ever in your favor!** 🎲
