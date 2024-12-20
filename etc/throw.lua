-- spell name
local SPELL_NAME               = "Throw"
local SPELL_ALIASES            = { "Shoot Crossbow", "Shoot Bow", "Auto Shot" }

-- local alias
local SPELL_TREE_ID            = SPELL_ANALYSIS.SPELL_TREE_ID
local SPELL_POWER_TYPE         = SPELL_ANALYSIS.SPELL_POWER_TYPE
local AnalyzeDamageRangeSpell  = SPELL_ANALYSIS.AnalyzeDamageRangeSpell
local AddDamageRangeAnalysis   = SPELL_ANALYSIS.AddDamageRangeAnalysis

-- listener for this spell
SPELL_ANALYSIS.FUN[SPELL_NAME] = function(tooltip)
    -- calculate damage
    local speed, lowDmg, hiDmg = UnitRangedDamage("player");
    if speed == 0 then return end

    -- add line
    tooltip:AddLine("\n")

    -- analyze dat shit
    local result = AnalyzeDamageRangeSpell(lowDmg, hiDmg, speed, 0, SPELL_TREE_ID.PHYSICAL, SPELL_POWER_TYPE.MANA,
        0, 0)

    AddDamageRangeAnalysis(tooltip, result)
end

-- listener for aliases
for k, v in pairs(SPELL_ALIASES) do
    SPELL_ANALYSIS.FUN[v] = SPELL_ANALYSIS.FUN[SPELL_NAME]
end
