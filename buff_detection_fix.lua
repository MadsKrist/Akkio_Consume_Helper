-- BUFF DETECTION FIX: Name-based detection instead of icon-based
-- This file contains the solution to fix the icon conflict issue

--[[
PROBLEM ANALYSIS:
The current addon uses icon-based buff detection which fails because:
1. Multiple buffs share the same icon (e.g., Dreamshard Elixir and Greater Arcane Elixir)
2. Many food items use "Interface\\Icons\\Spell_Misc_Food" 
3. Some items use "Interface\\Icons\\INV_Boots_Plate_03"

SOLUTION:
Implement name-based buff detection using tooltip scanning or UnitBuff with proper parsing.
]]

-- Enhanced buff scanning function that gets both texture and name
local function scanActiveBuffs()
    local activeBuffs = {}
    local activeBuffNames = {}
    
    for i = 1, 40 do
        local buffTexture = UnitBuff("player", i)
        if not buffTexture then break end
        
        activeBuffs[buffTexture] = true
        
        -- Method 1: Tooltip scanning to get buff name
        GameTooltip:SetOwner(UIParent, "ANCHOR_NONE")
        GameTooltip:SetPlayerBuff(i)
        local buffName = GameTooltipTextLeft1:GetText()
        GameTooltip:Hide()
        
        if buffName then
            activeBuffNames[buffName] = true
        end
    end
    
    return activeBuffs, activeBuffNames
end

-- Improved buff detection function
local function isBuffActive(buffData)
    if not buffData then return false end
    
    -- For weapon enchants, continue using the existing method
    if buffData.isWeaponEnchant then
        return checkWeaponEnchant(buffData.slot)
    end
    
    local activeBuffs, activeBuffNames = scanActiveBuffs()
    
    -- Method 1: Try name-based detection first (most reliable)
    if buffData.buffName and activeBuffNames[buffData.buffName] then
        return true
    end
    
    -- Method 2: Try direct name match if buffName not specified
    if activeBuffNames[buffData.name] then
        return true
    end
    
    -- Method 3: Fallback to icon-based detection (legacy compatibility)
    if buffData.buffIcon and activeBuffs[buffData.buffIcon] then
        return true
    end
    
    if buffData.raidbuffIcon and activeBuffs[buffData.raidbuffIcon] then
        return true
    end
    
    return false
end

--[[
DATA STRUCTURE ADDITIONS NEEDED:

Add buffName field to items that have conflicts:

{ name = "Greater Arcane Elixir", buffName = "Arcane Intellect", ... },
{ name = "Dreamshard Elixir", buffName = "Dreamshard Elixir", ... },

For food items sharing icons:
{ name = "Smoked Desert Dumplings", buffName = "Well Fed", ... },
{ name = "Grilled Squid", buffName = "Well Fed", ... },
{ name = "Nightfin Soup", buffName = "Well Fed", ... },

Note: Many food buffs might all show as "Well Fed" in game, which would still
need different handling. In that case, we might need spell IDs or item-specific
detection methods.
]]

--[[
IMPLEMENTATION STEPS:

1. Add buffName fields to all entries in Akkio_Consume_Helper_Data.allBuffs
2. Replace the current buff detection logic in Akkio_Consume_HelperTable.lua
3. Update the UpdateBuffStatusOnly function to use isBuffActive()
4. Test thoroughly with items that previously had conflicts

SPECIFIC LINES TO REPLACE:

In Akkio_Consume_HelperTable.lua around line 481:
OLD: if buffTexture == data.buffIcon or buffTexture == data.raidbuffIcon then
NEW: if isBuffActive(data) then
]]

-- Alternative method using UnitBuff with index lookup
local function getBuffNameByTexture(targetTexture)
    for i = 1, 40 do
        local buffTexture = UnitBuff("player", i)
        if not buffTexture then break end
        
        if buffTexture == targetTexture then
            -- Use tooltip to get the name
            GameTooltip:SetOwner(UIParent, "ANCHOR_NONE")
            GameTooltip:SetPlayerBuff(i)
            local buffName = GameTooltipTextLeft1:GetText()
            GameTooltip:Hide()
            return buffName
        end
    end
    return nil
end

-- Function to build a mapping of known buff names (for testing/debugging)
local function buildBuffNameMap()
    local buffMap = {}
    local activeBuffs, activeBuffNames = scanActiveBuffs()
    
    DEFAULT_CHAT_FRAME:AddMessage("=== ACTIVE BUFFS DEBUG ===")
    for buffName, _ in pairs(activeBuffNames) do
        DEFAULT_CHAT_FRAME:AddMessage("Buff Name: " .. buffName)
        buffMap[buffName] = true
    end
    DEFAULT_CHAT_FRAME:AddMessage("=========================")
    
    return buffMap
end

-- Debug command to test buff detection
SLASH_TESTBUFFS1 = "/testbuffs"
SlashCmdList["TESTBUFFS"] = function()
    buildBuffNameMap()
end