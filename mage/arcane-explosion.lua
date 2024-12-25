-- spell name
local SPELL_NAME               = "Arcane Explosion"

-- local alias
local FindTextInTooltip        = SPELL_ANALYSIS.FindTextInTooltip
local SPELL_TREE_ID            = SPELL_ANALYSIS.SPELL_TREE_ID
local SPELL_POWER_TYPE         = SPELL_ANALYSIS.SPELL_POWER_TYPE
local ReverseLookupTable       = SPELL_ANALYSIS.ReverseLookupTable
local AnalyzeDamageRangeSpell  = SPELL_ANALYSIS.AnalyzeDamageRangeSpell
local AddAreaDamageAnalysis    = SPELL_ANALYSIS.AddAreaDamageAnalysis
local AddPowerAnalysis         = SPELL_ANALYSIS.AddPowerAnalysis

-- spell stuff
local SPELL_ID                 = ReverseLookupTable({ 1449, 8437, 8438, 8439, 10201, 10202 })
local COEFF                    = { 0.111, 0.143, 0.143, 0.143, 0.143, 0.143 }

-- listener for this spell
SPELL_ANALYSIS.FUN[SPELL_NAME] = function(tooltip)
    -- hard data
    local name, id = tooltip:GetSpell()
    local spellRank = SPELL_ID[id]
    local coeff = COEFF[spellRank]

    -- calculate damage
    local damagePattern =
    "Causes an explosion of arcane magic around the caster, causing (%d+) to (%d+) Arcane damage"
    local damLow, damHigh = FindTextInTooltip(tooltip, damagePattern)

    -- calculcate mana efficiency
    local costPattern = "(%d+) Mana"
    local cost = FindTextInTooltip(tooltip, costPattern)

    -- do stuff
    local result = AnalyzeDamageRangeSpell(damLow, damHigh, 0, 0, SPELL_TREE_ID.ARCANE,
        SPELL_POWER_TYPE.MANA, cost, coeff)

    -- add line
    tooltip:AddLine("\n")
    AddAreaDamageAnalysis(tooltip, { range = result })
    AddPowerAnalysis(tooltip, { range = result })
end
