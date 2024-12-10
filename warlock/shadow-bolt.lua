-- spell name
local SPELL_NAME                 = "Shadow Bolt"

-- local alias
local FindTextInTooltip          = BONUS_SPELL_INFO.FindTextInTooltip
local AddDamageRangeAnalysis     = BONUS_SPELL_INFO.AddDamageRangeAnalysis
local AddManaAnalysis            = BONUS_SPELL_INFO.AddManaAnalysis
local SPELL_TREE_ID              = BONUS_SPELL_INFO.SPELL_TREE_ID
local ReverseLookupTable         = BONUS_SPELL_INFO.ReverseLookupTable

-- spell stuff
local SPELL_ID                   = ReverseLookupTable({ 686, 695, 705, 1088, 1106, 7641, 11659, 11660, 11661, 25307 })
local RANK_COEFF_TABLE           = { 0.14, 0.299, 0.56, 0.857, 0.857, 0.857, 0.857, 0.857, 0.857, 0.857 }

-- listener for this spell
BONUS_SPELL_INFO.FUN[SPELL_NAME] = function(tooltip)
    -- hard data
    local name, id = tooltip:GetSpell()
    local spellRank = SPELL_ID[id]
    local coeff = RANK_COEFF_TABLE[spellRank]

    -- calculate damage
    local damagePattern =
    "Sends a shadowy bolt at the enemy, causing (%d+) to (%d+) Shadow damage."
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
    AddDamageRangeAnalysis(tooltip, damLow, damHigh, castTime, SPELL_TREE_ID.SHADOW, coeff)
    AddManaAnalysis(tooltip, cost, damAvg)
end
