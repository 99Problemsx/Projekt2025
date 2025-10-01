# Changelog

## Version 1.3.1 - 2025-09-09

### Bug Fixes
- **Level Caps EX / Multiple Item Use**:
  - Fixed: Pokémon now reliably learn all level-up moves after each individual level increment when using Rare Candies (including multi-use).
  - Evolution checks run after each increment; evolutions trigger as expected.

- **Following Pokemon EX**:
  - Fixed: Following Pokemon now properly reappears after map transfers (entering/exiting buildings).
  - Fixed: Hidden follower state is correctly reset after map transitions.

### Notes
- EXP Candies still use the current EXP-based flow; the per-level learn routine can be added there as well upon request.

## Version 1.3.0 - 2024-12-19

### New Features
- **Swimming Sprites for Following Pokemon**: Following Pokemon now automatically use their swimming sprites when available while surfing
  - Automatic switching between normal and swimming sprites based on terrain
  - Supports both normal and shiny swimming sprites
  - Fallback to normal follower sprites when no swimming sprite is available

### Improvements
- **Level Caps EX Plugin**: 
  - All hardcoded variable IDs replaced with constants from `000_Config.rb`
  - Proper usage of `LEVEL_CAP_VARIABLE` (198), `LEVEL_CAP_MODE_VARIABLE` (199), `LEVEL_CAP_BYPASS_SWITCH` (200)
  - Enhanced debug output for better tracking

- **Multiple Item Use Plugin**:
  - Compatibility with Level Caps EX for Rare Candies and EXP Candies
  - Prevents leveling beyond the set level cap
  - Single confirmation message for multiple item usage

- **Ledge Assist Plugin**:
  - Full support for all ledge directions (vertical, horizontal, diagonal)
  - Improved distance calculation based on jump direction
  - Smart return positioning for all movement directions
  - Now works correctly with vertical ledges

### Bug Fixes
- **Following Pokemon EX**: 
  - Following Pokemon now only use swimming sprites when actually standing on water tiles
  - Fixed: Swimming sprites were activated too early (while still on land)
  - Automatic sprite refresh when entering/leaving water areas

- **Level Caps EX**: 
  - Fixed: Pokemon could level beyond the level cap when using Rare Candies/EXP Candies
  - Fixed: Multiple confirmation messages when using multiple items
  - Proper per-level checking for Rare Candy usage

- **Ledge Assist**: 
  - Fixed: Prompt was not triggered for vertical ledges
  - Fixed: Incorrect positioning for horizontal jumps

### Technical Changes
- **Following Pokemon EX**:
  - Extended `GameData::Species.ow_sprite_filename` with `swimming` parameter
  - New method `FollowingPkmn.should_use_swimming_sprites?` with terrain check
  - Automatic sprite refresh in `moveto` and `fancy_moveto` on terrain change

- **Level Caps EX**:
  - All `LevelCapsEX` module methods now use constants instead of hardcoded values
  - Improved `ItemHandlers` for Rare Candy with proper level cap checking
  - Compatibility with "Multiple Item Use" plugin

- **Multiple Item Use**:
  - Integration with Level Caps EX for automatic quantity limitation
  - Enhanced `pbBagUseItem` with compatibility checks
  - Support for Terastallization plugin (Tera Shards)

## Version 1.2.0 - 2024-12-18

### New Features
- **Multiple Item Use Plugin**: Enables using multiple items at once
- **Level Caps EX Integration**: Full compatibility with Level Cap system

### Improvements
- **Following Pokemon EX**: Enhanced follower logic and movement
- General codebase optimizations

## Version 1.1.0 - 2024-12-17

### New Features
- **Following Pokemon EX Plugin**: Fully functional Following Pokemon system
- **Ledge Assist Plugin**: Pokémon Scarlet/Violet-like ledge return system

### Bug Fixes
- Various stability improvements
- Follower movement optimizations

## Version 1.0.0 - 2024-12-16

### Initial Release
- Base Pokemon Essentials v21.1 setup
- Basic plugin structure established
