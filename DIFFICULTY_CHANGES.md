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

### 2. Fatigue System with Inverse Prime Progression

#### How It Works
- Every command you run increments a counter (0-99)
- At certain counts, you roll with **disadvantage** (2d20, take the lower result)
- The frequency of disadvantage increases as you approach 100
- Counter resets at 100, on Natural 20, or daily

#### Disadvantage Triggers
Commands at these counts trigger disadvantage:
```
2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53,
57, 59, 63, 69, 71, 77, 81, 83, 87, 89, 93, 95, 97, 98
```

**Progression feel:**
- Commands 0-50: Rare disadvantage (5 times)
- Commands 51-70: Occasional disadvantage (6 times)
- Commands 71-90: Frequent disadvantage (10 times)
- Commands 91-99: Nearly constant disadvantage (9 times in 9 commands!)

#### Visual Indicator
When disadvantaged, you'll see:
```
⚠️  [FATIGUED - Rolling with disadvantage]
🎲 Roll 1: 14, Roll 2: 8 → Taking 8
   + 2 (ability) = 10
❌ Failed (need 17+)
```

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

### 4. Reset Conditions

The fatigue counter resets to 0 when:
1. **Natural 20 is rolled** - Your critical success reinvigorates you
2. **Count reaches 100** - The cycle resets
3. **Daily** - Each new day brings fresh energy

## Files Modified

1. **lib/fatigue.sh** (new) - Fatigue tracking and disadvantage logic
2. **lib/dice.sh** - Added `roll_d20_disadvantage()` function
3. **lib/roll.sh** - Integrated fatigue system, updated DC, added visual warnings
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

4. **Monitor fatigue** by running multiple commands and watching for the disadvantage warning

## Expected Difficulty

With DC 17 and the fatigue system:
- Early commands (0-50): ~20-30% success rate
- Mid session (51-70): ~15-25% success rate (occasional disadvantage)
- Late session (71-90): ~10-20% success rate (frequent disadvantage)
- End session (91-99): ~5-15% success rate (nearly constant disadvantage)

When rolling with disadvantage:
- Your success rate drops to roughly the square of your normal rate
- Example: 25% normal → ~6% with disadvantage

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
