-- spell name
local SPELL_NAME               = "Shoot"

-- local alias
local SPELL_TREE_WORD2ID       = SPELL_ANALYSIS.SPELL_TREE_WORD2ID
local SPELL_TREE_ID            = SPELL_ANALYSIS.SPELL_TREE_ID
local SPELL_POWER_TYPE         = SPELL_ANALYSIS.SPELL_POWER_TYPE
local AnalyzeDamageRangeSpell  = SPELL_ANALYSIS.AnalyzeDamageRangeSpell
local AddDamageRangeAnalysis   = SPELL_ANALYSIS.AddDamageRangeAnalysis

-- listener for this spell
SPELL_ANALYSIS.FUN[SPELL_NAME] = function(tooltip)
    -- hard data
    local name, id = tooltip:GetSpell()

    -- calculate damage
    local speed, lowDmg, hiDmg = UnitRangedDamage("player");
    if speed == 0 then return end

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
    local result = AnalyzeDamageRangeSpell(lowDmg, hiDmg, 0, 0, SPELL_TREE_ID.PHYSICAL, SPELL_POWER_TYPE.MANA,
        0, 0)

    AddDamageRangeAnalysis(tooltip, result)
end
