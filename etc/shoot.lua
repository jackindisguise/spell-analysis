-- spell name
local SPELL_NAME              = "Shoot"

-- local alias
local SPELL_TREE_WORD2ID      = SPELL_ANALYSIS.SPELL_TREE_WORD2ID
local SPELL_POWER_TYPE        = SPELL_ANALYSIS.SPELL_POWER_TYPE
local AnalyzeDamageRangeSpell = SPELL_ANALYSIS.AnalyzeDamageRangeSpell
local AddDamageRangeAnalysis  = SPELL_ANALYSIS.AddDamageRangeAnalysis

-- once i figure out how to determine the damage-type of the wands, I'll fix this
-- i tried reallly hard to get this to work in a more elegant way
-- i ended up stealing this off a forum post from like 2012
local tt                      = CreateFrame("GameTooltip", "CAKE", UIParent, "GameTooltipTemplate")
local DamageTypeText          = _G["CAKETextLeft4"]
function GetWandDamageType()
    tt:SetOwner(UIParent, "ANCHOR_NONE")
    local _ = tt:SetInventoryItem("player", 18)
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
