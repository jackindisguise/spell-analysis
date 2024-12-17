-- spell name
local SPELL_NAME                 = "Arcane Missiles"

-- local alias
local FindTextInTooltip          = SPELL_ANALYSIS.FindTextInTooltip
local SPELL_TREE_ID              = SPELL_ANALYSIS.SPELL_TREE_ID
local SPELL_POWER_TYPE           = SPELL_ANALYSIS.SPELL_POWER_TYPE
local ReverseLookupTable         = SPELL_ANALYSIS.ReverseLookupTable
local AnalyzeDamageOverTimeSpell = SPELL_ANALYSIS.AnalyzeDamageOverTimeSpell
local AddDamageOverTimeAnalysis  = SPELL_ANALYSIS.AddDamageOverTimeAnalysis
local AddPowerAnalysis           = SPELL_ANALYSIS.AddPowerAnalysis

-- spell stuff
local SPELL_ID                   = ReverseLookupTable({ 5143, 5144, 5145, 8416, 8417, 10211, 10212, 25345 })
local RANK_COEFF_TABLE           = { 0.132, 0.204, 0.24, 0.24, 0.24, 0.24, 0.24, 0.24 }

-- listener for this spell
SPELL_ANALYSIS.FUN[SPELL_NAME]   = function(tooltip)
    -- hard data
    local name, id = tooltip:GetSpell()
    local spellRank = SPELL_ID[id]
    local coeff = RANK_COEFF_TABLE[spellRank]

    -- calculate damage
    local damagePattern =
    "Launches Arcane Missiles at the enemy, causing (%d+) Arcane damage each second for (%d+) sec."
    local DOTDam, DOTDuration = FindTextInTooltip(tooltip, damagePattern)

    -- calculcate mana efficiency
    local costPattern = "(%d+) Mana"
    local cost = FindTextInTooltip(tooltip, costPattern)

    -- do stuff
    local result = AnalyzeDamageOverTimeSpell(DOTDam * DOTDuration, DOTDuration, DOTDuration, DOTDuration, 0,
        SPELL_TREE_ID.ARCANE,
        SPELL_POWER_TYPE.MANA, cost, coeff)

    -- add line
    tooltip:AddLine("\n")
    AddDamageOverTimeAnalysis(tooltip, result)
    AddPowerAnalysis(tooltip, { dot = result })
end
