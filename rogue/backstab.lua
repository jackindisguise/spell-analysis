-- spell name
local SPELL_NAME               = "Backstab"

-- local alias
local FindTextInTooltip        = SPELL_ANALYSIS.FindTextInTooltip
local SPELL_TREE_ID            = SPELL_ANALYSIS.SPELL_TREE_ID
local SPELL_POWER_TYPE         = SPELL_ANALYSIS.SPELL_POWER_TYPE
local ReverseLookupTable       = SPELL_ANALYSIS.ReverseLookupTable
local AnalyzeDamageRangeSpell  = SPELL_ANALYSIS.AnalyzeDamageRangeSpell
local AddDamageRangeAnalysisv2 = SPELL_ANALYSIS.AddDamageRangeAnalysisv2
local AddPowerAnalysis         = SPELL_ANALYSIS.AddPowerAnalysis

-- spell stuff
local SPELL_ID                 = ReverseLookupTable({ 53, 2589, 2590, 2591, 8721, 11279, 11280, 11281 })
local RANK_DAMAGE_TABLE        = { 15, 30, 48, 69, 90, 135, 165, 210 }

-- listener for this spell
SPELL_ANALYSIS.FUN[SPELL_NAME] = function(tooltip)
    -- hard data
    local name, id = tooltip:GetSpell()
    local spellRank = SPELL_ID[id]
    local bonusDamage = RANK_DAMAGE_TABLE[spellRank]

    -- calculate damage
    local baseLow, baseHigh = UnitDamage("player") -- base weapon range of main hand
    local empoweredLow, empoweredHigh = baseLow * 1.5 + bonusDamage, baseHigh * 1.5 + bonusDamage

    -- calculcate energy efficiency
    --local _, _, _, _, rank = GetTalentInfo(COMBAT_TAB, IMPROVED_SINISTER_STRIKE_SLOT)
    --local cost = BASE_ENERGY_COST - (3 * rank) -- -3 energy per level of ISS
    local costPattern = "(%d+) Energy"
    local cost = FindTextInTooltip(tooltip, costPattern)

    -- analyze
    local result = AnalyzeDamageRangeSpell(empoweredLow, empoweredHigh, 0, 0, SPELL_TREE_ID.PHYSICAL,
        SPELL_POWER_TYPE.ENERGY, cost, 0)

    -- add line
    tooltip:AddLine("\n")
    AddDamageRangeAnalysisv2(tooltip, result)
    AddPowerAnalysis(tooltip, result)
end
