-- spell name
local SPELL_NAME               = "Mind Blast"

-- local alias
local FindTextInTooltip        = SPELL_ANALYSIS.FindTextInTooltip
local SPELL_TREE_ID            = SPELL_ANALYSIS.SPELL_TREE_ID
local SPELL_POWER_TYPE         = SPELL_ANALYSIS.SPELL_POWER_TYPE
local ReverseLookupTable       = SPELL_ANALYSIS.ReverseLookupTable
local AnalyzeDamageRangeSpell  = SPELL_ANALYSIS.AnalyzeDamageRangeSpell
local AddDamageRangeAnalysis   = SPELL_ANALYSIS.AddDamageRangeAnalysis
local AddPowerAnalysis         = SPELL_ANALYSIS.AddPowerAnalysis

-- spell stuff
local SPELL_ID                 = ReverseLookupTable({ 8092, 8102, 8103, 8104, 8105, 8106, 10945, 10946, 10947 })
local RANK_COEFF_TABLE         = { 0.268, 0.364, 0.429, 0.429, 0.429, 0.429, 0.429, 0.429, 0.429 }

-- listener for this spell
SPELL_ANALYSIS.FUN[SPELL_NAME] = function(tooltip)
    -- hard data
    local name, id = tooltip:GetSpell()
    local spellRank = SPELL_ID[id]
    local coeff = RANK_COEFF_TABLE[spellRank]

    -- calculate damage
    local damagePattern =
    "Blasts the target for (%d+) to (%d+) Shadow damage"
    local damLow, damHigh = FindTextInTooltip(tooltip, damagePattern)

    -- cast time
    local castTimePattern = "(.+) sec cast"
    local castTime = tonumber(FindTextInTooltip(tooltip, castTimePattern))

    -- cast time
    local cooldownPattern = "(.+) sec cooldown"
    local cooldown = tonumber(FindTextInTooltip(tooltip, cooldownPattern))

    -- calculcate mana efficiency
    local costPattern = "(%d+) Mana"
    local cost = FindTextInTooltip(tooltip, costPattern)

    -- analyze dat shit
    local result = AnalyzeDamageRangeSpell(damLow, damHigh, castTime, cooldown, SPELL_TREE_ID.SHADOW,
        SPELL_POWER_TYPE.MANA,
        cost, coeff)

    -- add line
    tooltip:AddLine("\n")
    AddDamageRangeAnalysis(tooltip, result)
    AddPowerAnalysis(tooltip, { range = result })
end
