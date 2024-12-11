-- spell name
local SPELL_NAME                 = "Curse of Agony"

-- local alias
local FindTextInTooltip          = SPELL_ANALYSIS.FindTextInTooltip
local SPELL_TREE_ID              = SPELL_ANALYSIS.SPELL_TREE_ID
local SPELL_POWER_TYPE           = SPELL_ANALYSIS.SPELL_POWER_TYPE
local ReverseLookupTable         = SPELL_ANALYSIS.ReverseLookupTable
local AnalyzeDamageOverTimeSpell = SPELL_ANALYSIS.AnalyzeDamageOverTimeSpell
local AddDamageOverTimeAnalysis  = SPELL_ANALYSIS.AddDamageOverTimeAnalysis
local AddPowerAnalysis           = SPELL_ANALYSIS.AddPowerAnalysis

-- spell stuff
local SPELL_ID                   = ReverseLookupTable({ 980, 1014, 6217, 11711, 11712, 11713 })
local RANK_COEFF_TABLE           = { 0.046, 0.077, 0.083, 0.083, 0.083, 0.083 }
local DOT_TICKS                  = 12

-- listener for this spell
SPELL_ANALYSIS.FUN[SPELL_NAME]   = function(tooltip)
    -- hard data
    local name, id = tooltip:GetSpell()
    local spellRank = SPELL_ID[id]
    local coeff = RANK_COEFF_TABLE[spellRank]
    local ticks = DOT_TICKS

    -- calculate damage
    local damagePattern =
    "Curses the target with agony, causing (%d+) Shadow damage over (%d+) sec."
    local DOTDam, DOTDuration = FindTextInTooltip(tooltip, damagePattern)

    -- calculcate mana efficiency
    local costPattern = "(%d+) Mana"
    local cost = FindTextInTooltip(tooltip, costPattern)

    -- do stuff
    local result = AnalyzeDamageOverTimeSpell(DOTDam, DOTDuration, ticks, 0, 0, SPELL_TREE_ID.SHADOW,
        SPELL_POWER_TYPE.MANA, cost, coeff)

    -- add line
    tooltip:AddLine("\n")
    AddDamageOverTimeAnalysis(tooltip, result)
    AddPowerAnalysis(tooltip, { dot = result })
end
