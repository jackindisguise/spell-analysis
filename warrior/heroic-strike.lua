-- spell name
local SPELL_NAME               = "Heroic Strike"

-- local alias
local FindTextInTooltip        = SPELL_ANALYSIS.FindTextInTooltip
local SPELL_TREE_ID            = SPELL_ANALYSIS.SPELL_TREE_ID
local SPELL_POWER_TYPE         = SPELL_ANALYSIS.SPELL_POWER_TYPE
local ReverseLookupTable       = SPELL_ANALYSIS.ReverseLookupTable
local AnalyzeDamageRangeSpell  = SPELL_ANALYSIS.AnalyzeDamageRangeSpell
local AddDamageRangeAnalysis   = SPELL_ANALYSIS.AddDamageRangeAnalysis
local AddPowerAnalysis         = SPELL_ANALYSIS.AddPowerAnalysis

-- listener
SPELL_ANALYSIS.FUN[SPELL_NAME] = function(tooltip)
    -- hard data
    local name, id = tooltip:GetSpell()

    -- calculate damage
    local damagePattern =
    "A strong attack that increases melee damage by (%d+) and causes a high amount of threat."
    local bonusDamage = FindTextInTooltip(tooltip, damagePattern)
    local baseLow, baseHigh = UnitDamage("player") -- base weapon range of main hand
    local empoweredLow, empoweredHigh = baseLow + bonusDamage, baseHigh + bonusDamage
    local mainSpeed, offSpeed = UnitAttackSpeed("player");

    -- calculcate energy efficiency
    --local _, _, _, _, rank = GetTalentInfo(COMBAT_TAB, IMPROVED_SINISTER_STRIKE_SLOT)
    --local cost = BASE_ENERGY_COST - (3 * rank) -- -3 energy per level of ISS
    local costPattern = "(%d+) Rage"
    local cost = FindTextInTooltip(tooltip, costPattern)

    -- analyze
    local result = AnalyzeDamageRangeSpell(empoweredLow, empoweredHigh, mainSpeed, 0, SPELL_TREE_ID.PHYSICAL,
        SPELL_POWER_TYPE.RAGE, cost, 0)

    -- add line
    tooltip:AddLine("\n")
    AddDamageRangeAnalysis(tooltip, result)
    AddPowerAnalysis(tooltip, { range = result })
end
