-- spell name
local SPELL_NAME                  = "Immolate"

-- local alias
local FindTextInTooltip           = SPELL_ANALYSIS.FindTextInTooltip
local SPELL_TREE_ID               = SPELL_ANALYSIS.SPELL_TREE_ID
local SPELL_POWER_TYPE            = SPELL_ANALYSIS.SPELL_POWER_TYPE
local ReverseLookupTable          = SPELL_ANALYSIS.ReverseLookupTable
local AnalyzeDamageOverTimeSpell  = SPELL_ANALYSIS.AnalyzeDamageOverTimeSpell
local AnalyzeFlatDamageSpell      = SPELL_ANALYSIS.AnalyzeFlatDamageSpell
local AddDamageOverTimeAnalysisv2 = SPELL_ANALYSIS.AddDamageOverTimeAnalysisv2
local AddDamageAnalysisv2         = SPELL_ANALYSIS.AddDamageAnalysisv2
local AddPowerAnalysis            = SPELL_ANALYSIS.AddPowerAnalysis

-- RGB values
local WHITE                       = { 1, 1, 1 }

-- spell stuff
local SPELL_ID                    = ReverseLookupTable({ 348, 707, 1094, 2941, 11665, 11667, 11668, 25309 })
local RANK_COEFF_TABLE            = {
    { FLAT_COEFF = 0.058, DOT_COEFF = 0.037 }, -- rank 1
    { FLAT_COEFF = 0.125, DOT_COEFF = 0.081 },
    { FLAT_COEFF = 0.2,   DOT_COEFF = 0.13 },
    { FLAT_COEFF = 0.2,   DOT_COEFF = 0.13 },
    { FLAT_COEFF = 0.2,   DOT_COEFF = 0.13 }, -- rank 5
    { FLAT_COEFF = 0.2,   DOT_COEFF = 0.13 },
    { FLAT_COEFF = 0.2,   DOT_COEFF = 0.13 },
    { FLAT_COEFF = 0.2,   DOT_COEFF = 0.13 } -- rank 8
}
local DOT_TICKS                   = 5

-- listener for this spell
SPELL_ANALYSIS.FUN[SPELL_NAME]    = function(tooltip)
    -- hard data
    local name, id = tooltip:GetSpell()
    local spellRank = SPELL_ID[id]
    local coeffTable = RANK_COEFF_TABLE[spellRank]
    local ticks = DOT_TICKS

    -- calculate damage
    local damagePattern =
    "Burns the enemy for (%d+) Fire damage and then an additional (%d+) Fire damage over (%d+) sec."
    local flatDamage, DOTDamage, DOTDuration = FindTextInTooltip(tooltip, damagePattern)

    -- cast time
    local castTimePattern = "(.+) sec cast"
    local castTime = tonumber(FindTextInTooltip(tooltip, castTimePattern))

    -- calculcate mana efficiency
    local costPattern = "(%d+) Mana"
    local cost = FindTextInTooltip(tooltip, costPattern)

    local resultFlat = AnalyzeFlatDamageSpell(flatDamage, castTime, 0, SPELL_TREE_ID.FIRE, SPELL_POWER_TYPE.MANA, cost,
        coeffTable.FLAT_COEFF)

    local resultDOT = AnalyzeDamageOverTimeSpell(DOTDamage, DOTDuration, ticks, castTime, 0, SPELL_TREE_ID.FIRE,
        SPELL_POWER_TYPE.MANA, cost,
        coeffTable.DOT_COEFF)

    -- add line
    tooltip:AddLine("\n")
    --AddHybridDamageAnalysisv2(tooltip, { flat = resultFlat, dot = resultDOT })
    AddDamageAnalysisv2(tooltip, resultFlat)
    AddDamageOverTimeAnalysisv2(tooltip, resultDOT)
end
