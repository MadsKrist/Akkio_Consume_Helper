# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is **Akkio's Consume Helper**, a World of Warcraft Classic addon for Turtle WoW (1.12) that provides advanced buff and consumable tracking with weapon enchant support. The addon helps players monitor buffs, track consumables in their bags, and manage shopping lists for raid preparation.

## Architecture

### Core Components

**Main Entry Point**: `Akkio_Consume_HelperTable.lua`
- Central addon logic and UI management
- Version migration system
- Settings persistence and validation
- Event handling and frame management

**Data Layer**: `Akkio_Consume_Helper_Data.lua`
- Centralized buff/consumable database with 80+ items
- Organized into categories: Class Buffs, Flasks, Elixirs & Juju, Food & Drinks, Weapon Enchants, Alcoholic Beverages, Combat Potions
- Each item includes: name, icon paths, duration, item IDs, spell IDs, weapon slot info

**Shopping List Module**: `Akkio_Consume_Helper_ShoppingList.lua`
- Standalone module for low consumable tracking
- Category-based and individual threshold management
- Smart bag scanning with charged item detection
- Separate UI with scroll frames and settings

**UI Templates**: `Akkio_Consume_Helper_Templates.xml`
- Reusable XML templates for EditBox components
- Consistent styling and event handling

**Configuration**: `Akkio_Consume_Helper.toc`
- Addon metadata and load order
- Interface version 11200 (WoW 1.12)
- SavedVariablesPerCharacter for per-character settings

### Key Design Patterns

**Modular Architecture**: Each major feature is contained in its own file with clear interfaces
**Event-Driven**: Uses WoW event system for buff detection and UI updates
**Dual Timer System**: Timestamp tracking for consumables, WoW API for weapon enchants
**Persistent Settings**: Character-specific saved variables with version migration
**Performance Optimization**: Smart caching, combat-aware updates, efficient bag scanning

## Development Commands

### Testing & Debugging
```
/act                    # Open buff selection window
/actsettings           # Open main settings panel
/actshop               # Open shopping list window
/actwelcome            # Show welcome window
/actdebug              # Comprehensive diagnostic information
/acthoverfix           # Reset hover-to-show state
/actbuffstatus         # Force refresh buff status UI
/actreset              # Open reset confirmation dialog
```

### Development Workflow
This addon has no build system - it's deployed directly to WoW's AddOns folder. The typical workflow is:

1. **Install**: Copy files to `Interface/AddOns/Akkio_Consume_Helper/`
2. **Test**: Launch WoW, enable addon, test with `/act` and other commands
3. **Debug**: Use `/actdebug` for state inspection and `/acthoverfix` for UI issues
4. **Validate**: Check CHANGELOG.md for version-specific testing requirements

## Key Implementation Details

### Buff Detection System
- Scans player buffs using `UnitBuff()` API
- Weapon enchants detected via `GetWeaponEnchantInfo()`
- Smart bag scanning handles charged items (negative counts) vs stacked items
- Dual timer architecture: manual timestamps for consumables, API-based for enchants

### Settings Management
```lua
Akkio_Consume_Helper_Settings = {
  version = "1.1.3",
  enabledBuffs = {},           -- Array of enabled buff names
  settings = {                 -- UI and behavior settings
    scale, updateTimer, iconsPerRow, hoverToShow, lockFrame, etc.
  },
  shoppingList = {             -- Shopping list configuration
    thresholds = {},           -- Category-based minimums
    individualThresholds = {}  -- Item-specific overrides
  }
}
```

### Data Structure
```lua
-- Example from Akkio_Consume_Helper_Data.allBuffs
{ 
  name = "Flask of the Titans",
  icon = "Interface\\Icons\\INV_Potion_62",
  buffIcon = "Interface\\Icons\\INV_Potion_62",
  duration = 7200,
  itemID = 13510,
  canBeAnounced = false
}
```

### Weapon Enchant Handling
Weapon enchants are handled specially with slot-specific tracking:
```lua
{
  name = "Dense Sharpening Stone",
  slot = "mainhand",          -- or "offhand"
  isWeaponEnchant = true,
  itemID = 12404
}
```

## Recent Changes (v1.1.3)

- **First-Time User Experience**: Welcome window with tutorial
- **Turtle WoW Expansion**: 20+ new Turtle WoW-specific consumables
- **Enhanced Organization**: Restructured categories (Alcoholic Beverages, Combat Potions)
- **Timer Drift Detection**: Fixed accuracy issues with buff timers

## Common Development Tasks

### Adding New Consumables
1. Add entry to `Akkio_Consume_Helper_Data.allBuffs` with proper structure
2. Include icon path, duration, itemID, and category placement
3. Test with `/actdebug` to verify detection
4. Update shopping list integration if needed

### UI Modifications
- Main UI frames in `Akkio_Consume_HelperTable.lua`
- Shopping list UI in `Akkio_Consume_Helper_ShoppingList.lua` 
- XML templates in `Akkio_Consume_Helper_Templates.xml`
- All frames use manual backdrop setup for Classic compatibility

### Performance Optimization
- Smart caching with 2-second refresh cycles
- Combat-aware performance modes
- Efficient bag scanning with charged item handling
- Memory management with automatic cleanup

### Version Migration
The addon includes a comprehensive version migration system that handles settings updates between versions. When adding breaking changes, update the migration logic in `Akkio_Consume_HelperTable.lua`.

## Important Notes

- **No Build System**: Direct file deployment to WoW AddOns folder
- **Classic API**: Uses WoW 1.12 API calls, no modern WoW features
- **Character-Specific**: All settings are per-character via SavedVariablesPerCharacter
- **Turtle WoW Focus**: Specifically designed for Turtle WoW private server with custom content
- **Modular Design**: Each major feature is self-contained for easier maintenance