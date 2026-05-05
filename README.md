# d20sh

A D&D-inspired terminal enhancement that gamifies command execution. Roll for init!

Your terminal character has ability scores (STR, DEX, CON, INT, WIS, CHA) that affect command success rates through d20 rolls. Success means you get fancy modern CLI tools; failure means truncated output and flavorful flavor text.

## ✨ Features

- **Character Creation**: Roll 4d6 drop lowest for ability scores, choose your class
- **D20 Roll Mechanics**: Every command rolls d20 + primary ability modifier
- **Success/Failure System**:
  - Natural 1: Command not executed; flavorful failure message
  - Total 2-6: Basic command, output truncated to last 10 lines + partial-failure message
  - Total 7-14: Basic command, normal output
  - Total 15-19: Fancy command (bat, lsd, fd, etc.)
  - Natural 20: Fancy command + epic success message
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

Every command rolls: **d20 + primary_ability_modifier** vs DC 15.

**Outcomes:**
- **Natural 1**: Command not executed; random failure message
- **Total 2-6**: Basic command, piped through `tail -n 10`; random partial-failure message
- **Total 7-14**: Basic command, normal output
- **Total 15-19**: Fancy command (if installed)
- **Natural 20**: Fancy command + random success message after output

### Classes & Primary Abilities

Your class determines which ability score is used for ALL rolls:

- **STR**: Barbarian, Fighter, Paladin
- **DEX**: Rogue, Ranger, Monk
- **INT**: Wizard, Artificer
- **WIS**: Cleric, Druid
- **CHA**: Bard, Sorcerer, Warlock

Ability modifiers use standard D&D formula: `(score - 10) / 2` rounded down

### Fancy Commands

When you succeed (total 15+), these modern tools are used instead:

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

### Mundane roll

```bash
$ ls
🎲 Rolled 11 + 2 (DEX) = 13
Using ls
[plain ls output]
```

### Partial failure (total 2-6)

```bash
$ cat README.md
🎲 Rolled 3 + 2 (DEX) = 5
The output escapes you. Only the tail remains.
Using cat (last 10 lines only)
[last 10 lines of the file]
```

### Natural 20!

```bash
$ grep TODO *.md
🎲 Rolled nat 20!
Using rg
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

With thresholds at 7 (mundane) / 15 (fancy) / 20 (crit), your rough rates:

| Modifier | Avoid Partial-Fail (7+) | Fancy Tools (15+) | Nat 20 |
|----------|-------------------------|-------------------|--------|
| -1       | 65%                     | 25%               | 5%     |
| +0       | 70%                     | 30%               | 5%     |
| +1       | 75%                     | 35%               | 5%     |
| +2       | 80%                     | 40%               | 5%     |
| +3       | 85%                     | 45%               | 5%     |

## 🎨 Philosophy

- **Simple to start**: Just `init` and `setup`
- **Manually editable**: Character file is plain JSON
- **Additive**: Doesn't break existing workflow
- **Fun failure**: Truncated output and flavorful messages, never destructive or slow
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
