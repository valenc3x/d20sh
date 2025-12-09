# d20sh Difficulty Adjustments

This document summarizes the difficulty changes implemented to make d20sh more challenging and punishing.

## Changes Summary

### 1. Increased DC (Difficulty Class)
- **Old DC:** 13 for success
- **New DC:** 17 for success
- **Impact:** With typical modifiers (+1 to +3):
  - +1 modifier: 20% success rate (down from ~45%)
  - +2 modifier: 25% success rate (down from ~50%)
  - +3 modifier: 30% success rate (down from ~55%)

### 2. Three-Tier Fatigue System

Your terminal gets progressively more exhausted as you use it. The fatigue system tracks your command count (0-99) and applies increasingly severe penalties.

#### Fatigue Tiers

**😓 Light Fatigue** (-1 to ability modifier)
- Triggers at commands: **11, 13, 17, 19** (4 triggers)
- Your ability modifier is reduced by 1
- Example: +2 ability becomes +1

**😰 Heavy Fatigue** (no ability modifier)
- Triggers at commands: **22, 41, 58, 71, 82, 89** (6 triggers)
- Your ability modifier is completely negated
- Example: +2 ability becomes +0

**💀 Exhausted** (disadvantage on rolls)
- Triggers at commands: **94, 97, 99** (3 triggers)
- Roll 2d20 and take the lower result
- Most brutal penalty - your success rate drops dramatically

#### Progression Feel

```
Commands 0-10:   Fresh (no penalties)
Commands 11-19:  Tired (4 light fatigue hits)
Commands 20-21:  Brief respite
Commands 22-93:  Heavy fatigue (6 hits, spread out)
Commands 94-99:  Exhausted (3/6 commands have disadvantage)
```

**Gap pattern:** The heavy fatigue triggers use a shrinking gap pattern (19 → 17 → 13 → 11 → 7 gaps), making them more frequent as you approach 90.

#### Visual Indicators

When fatigued, you'll see warnings before your roll:

**Light fatigue:**
```
😓 [Tired - Ability penalty -1]
🎲 Rolled 14
   + 1 (ability) = 15
❌ Failed (need 17+)
```

**Heavy fatigue:**
```
😰 [Heavy Fatigue - No ability modifier]
🎲 Rolled 14
   + 0 (ability) = 14
❌ Failed (need 17+)
```

**Exhausted:**
```
💀 [EXHAUSTED - Rolling with disadvantage]
🎲 Roll 1: 18, Roll 2: 7 → Taking 7
   + 2 (ability) = 9
❌ Failed (need 17+)
```

#### Reset Conditions

The fatigue counter resets to 0 when:
1. **Natural 20 is rolled** - Your critical success reinvigorates you
2. **Count reaches 100** - The cycle resets automatically
3. **Daily** - Each new day brings fresh energy

### 3. Enhanced Bad Formatting on Failures

#### Previous Behavior
Failed rolls applied either:
- Leetspeak (e→3, a→4, o→0, i→1, s→5, t→7) OR
- Random capitalization

Plus ability-based awful color schemes.

#### New Behavior
Failed rolls now apply **BOTH** mutations simultaneously:
1. Leetspeak transformation
2. Random capitalization (50% chance per character)
3. Ability-based color scheme

#### Performance Optimization
To prevent slowdowns on large outputs:
- **Under 50KB:** All output is formatted
- **Over 50KB:** First 25KB + last 25KB are formatted
- Middle section shows: `[... N lines of corrupted data lost to the void ...]`

#### Example Failure Output
Before (just color):
```
drwxr-xr-x 2 user user 4096 Dec  9 20:10 lib
```

After (leetspeak + random caps + color):
```
DrWXr-Xr-X 2 U5Er u53R 4096 d3C  9 20:10 L1B
```

(Plus wrapped in awful colors based on your primary ability)

## Files Modified

1. **lib/fatigue.sh** - Three-tier fatigue tracking system
2. **lib/dice.sh** - Added `roll_d20_disadvantage()` function
3. **lib/roll.sh** - Integrated fatigue system, updated DC to 17, tier-specific penalties
4. **lib/formatting.sh** - Enhanced with dual mutations and character budget

## Testing

To test the new system:

1. **Create a character** (if you haven't already):
   ```bash
   ./bin/d20sh init
   ```

2. **Try some commands** (after running setup):
   ```bash
   d20sh roll ls exa
   d20sh roll cat bat
   d20sh roll grep rg "some pattern" .
   ```

3. **Check your stats**:
   ```bash
   d20sh stats
   ```

4. **Monitor fatigue** by running multiple commands and watching for the fatigue warnings

## Expected Difficulty

### Success Rates by Fatigue Tier

Assuming +2 ability modifier and DC 17:

**Fresh (commands 0-10):**
- Need to roll 15+ on d20
- Success rate: ~30%

**Light Fatigue (commands 11, 13, 17, 19):**
- +2 becomes +1, need to roll 16+
- Success rate: ~25%

**Heavy Fatigue (commands 22, 41, 58, 71, 82, 89):**
- +2 becomes +0, need to roll 17+
- Success rate: ~20%

**Exhausted (commands 94, 97, 99):**
- Roll with disadvantage
- Success rate: ~4% (20% squared)

### Overall Session Difficulty

With DC 17 and the three-tier fatigue system:
- **Early game (0-20):** Moderate challenge, ~25-30% success
- **Mid game (21-93):** Harder, ~20-30% success with occasional heavy fatigue
- **End game (94-99):** Brutal, ~4-20% success with frequent disadvantage

## Configuration

The fatigue state is stored in:
```
~/.config/d20sh/fatigue.json
```

To manually reset your fatigue:
```bash
rm ~/.config/d20sh/fatigue.json
```

Or wait for a Natural 20! 🎲

## Design Philosophy

The three-tier system provides:
1. **Early warning** - Light fatigue at 11 lets you know the system is active
2. **Escalating challenge** - Each tier is noticeably harder than the last
3. **Strategic moments** - Gaps between triggers give breathing room
4. **Dramatic finale** - Commands 94-99 are a gauntlet where disadvantage can strike at any moment
5. **Escape valve** - Natural 20 always offers a way to reset and start fresh
