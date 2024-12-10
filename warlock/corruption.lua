-- spell name
local SPELL_NAME                 = "Corruption"

-- local alias
local FindTextInTooltip          = BONUS_SPELL_INFO.FindTextInTooltip
local SPELL_TREE_ID              = BONUS_SPELL_INFO.SPELL_TREE_ID
local AddDamageOverTimeAnalysis  = BONUS_SPELL_INFO.AddDamageOverTimeAnalysis
local AddManaAnalysis            = BONUS_SPELL_INFO.AddManaAnalysis
local ReverseLookupTable         = BONUS_SPELL_INFO.ReverseLookupTable

-- spell stuff
local SPELL_ID                   = ReverseLookupTable({ 172, 6222, 6223, 7648, 11671, 11672, 25311 })
local RANK_COEFF_TABLE           = { 0.08, 0.155, 0.167, 0.167, 0.167, 0.167, 0.167 }
local DOT_TICKS                  = { 4, 5, 6, 6, 6, 6, 6 }

-- listener for this spell
BONUS_SPELL_INFO.FUN[SPELL_NAME] = function(tooltip)
    -- hard data
    local name, id = tooltip:GetSpell()
    local spellRank = SPELL_ID[id]
    local coeff = RANK_COEFF_TABLE[spellRank]
    local ticks = DOT_TICKS[spellRank]

    -- calculate damage
    local damagePattern =
    "Corrupts the target, causing (%d+) Shadow damage over (%d+) sec."
    local DOTDam, DOTDuration = FindTextInTooltip(tooltip, damagePattern)
    local spellPower = GetSpellBonusDamage(SPELL_TREE_ID.SHADOW)
    local bonusDamage = spellPower * coeff * ticks
    local empoweredDamage = DOTDam + bonusDamage

    -- cast time
    local castTimePattern = "(.+) sec cast"
    local castTime = 0
    local castTimeString = FindTextInTooltip(tooltip, castTimePattern)
    if castTimeString then castTime = tonumber(castTimeString) or 0 end

    -- calculcate mana efficiency
    local costPattern = "(%d+) Mana"
    local cost = FindTextInTooltip(tooltip, costPattern)

    -- add line
    tooltip:AddLine("\n")
    AddDamageOverTimeAnalysis(tooltip, DOTDam, castTime, DOTDuration, ticks, SPELL_TREE_ID.SHADOW, coeff)
    AddManaAnalysis(tooltip, cost, empoweredDamage)
end
