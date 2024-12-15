-- spell name
local SPELL_NAME              = "Shoot"

-- local alias
local SPELL_TREE_WORD2ID      = SPELL_ANALYSIS.SPELL_TREE_WORD2ID
local FindTextInTooltip       = SPELL_ANALYSIS.FindTextInTooltip
local SPELL_TREE_ID           = SPELL_ANALYSIS.SPELL_TREE_ID
local SPELL_POWER_TYPE        = SPELL_ANALYSIS.SPELL_POWER_TYPE
local ReverseLookupTable      = SPELL_ANALYSIS.ReverseLookupTable
local AnalyzeDamageRangeSpell = SPELL_ANALYSIS.AnalyzeDamageRangeSpell
local AddDamageRangeAnalysis  = SPELL_ANALYSIS.AddDamageRangeAnalysis
local AddPowerAnalysis        = SPELL_ANALYSIS.AddPowerAnalysis

-- colors
local COLOR_DAMAGE            = "|cFFFF4040"
local COLOR_RESET             = "|r"

-- once i figure out how to determine the damage-type of the wands, I'll fix this
local tt                      = CreateFrame("GameTooltip", "CAKE", UIParent, "GameTooltipTemplate")
local DamageTypeText          = CAKETextLeft4
function GetWandDamageType()
    tt:SetOwner(UIParent, "ANCHOR_NONE")
    tt:SetInventoryItem("player", 18)
    local n = DamageTypeText:GetText()
    tt:Hide()
    return SPELL_TREE_WORD2ID[string.match(n, "%d+ %- %d+ (.+) Damage")]
end

-- listener for this spell
SPELL_ANALYSIS.FUN[SPELL_NAME] = function(tooltip)
    -- hard data
    local name, id = tooltip:GetSpell()

    -- calculate damage
    local speed, lowDmg, hiDmg = UnitRangedDamage("player");
    if speed == 0 then return end

    -- grab the spell tree of this wand using stupid black magic
    local spellTreeID = GetWandDamageType()

    -- add line
    tooltip:AddLine("\n")

    --[[
    tooltip:AddLine(
        string.format("Deals %s%s%s damage on average.", COLOR_DAMAGE, ShortFloat(avgDmg, 2), COLOR_RESET),
        255,
        255, 255)
    tooltip:AddLine(
        string.format("Deals %s%s%s damage per second.", COLOR_DAMAGE, ShortFloat(avgDmg / speed, 2), COLOR_RESET),
        255,
        255, 255)]]

    -- analyze dat shit
    local result = AnalyzeDamageRangeSpell(lowDmg, hiDmg, 0, 0, spellTreeID, SPELL_POWER_TYPE.MANA,
        0, 0)

    AddDamageRangeAnalysis(tooltip, result)
end
