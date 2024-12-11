-- spell name
local SPELL_NAME               = "Searing Pain"

-- local alias
local FindTextInTooltip        = SPELL_ANALYSIS.FindTextInTooltip
local AddDamageRangeAnalysis   = SPELL_ANALYSIS.AddDamageRangeAnalysis
local AddManaAnalysis          = SPELL_ANALYSIS.AddManaAnalysis
local SPELL_TREE_ID            = SPELL_ANALYSIS.SPELL_TREE_ID
local ReverseLookupTable       = SPELL_ANALYSIS.ReverseLookupTable

-- spell stuff
local SPELL_ID                 = ReverseLookupTable({ 5676, 17919, 17920, 17921, 17922, 17923 })
local RANK_COEFF_TABLE         = { 0.396, 0.429, 0.429, 0.429, 0.429, 0.429 }

-- listener for this spell
SPELL_ANALYSIS.FUN[SPELL_NAME] = function(tooltip)
    -- hard data
    local name, id = tooltip:GetSpell()
    local spellRank = SPELL_ID[id]
    local coeff = RANK_COEFF_TABLE[spellRank]

    -- calculate damage
    local damagePattern =
    "Inflict searing pain on the enemy target, causing (%d+) to (%d+) Fire damage.  Causes a high amount of threat."
    local damLow, damHigh = FindTextInTooltip(tooltip, damagePattern)
    local damAvg = (damLow + damHigh) / 2

    -- cast time
    local castTimePattern = "(.+) sec cast"
    local castTime = tonumber(FindTextInTooltip(tooltip, castTimePattern))

    -- calculcate mana efficiency
    local costPattern = "(%d+) Mana"
    local cost = FindTextInTooltip(tooltip, costPattern)

    -- add line
    tooltip:AddLine("\n")
    AddDamageRangeAnalysis(tooltip, damLow, damHigh, castTime, SPELL_TREE_ID.FIRE, coeff)
    AddManaAnalysis(tooltip, cost, damAvg)
end
