-- spell name
local SPELL_NAME = "Drain Life"

--[[
--- TODO:
--- This is a spell that does damage and heals.
--- Add healing to metrics for determining the value of things.
--- It might be worthwhile to combine damage and healing into 1 number.
--- Though that reduces the amount of information we have for analysis later on.
--- I'll think about it.
]]

-- local alias
local FindTextInTooltip          = BONUS_SPELL_INFO.FindTextInTooltip
local SPELL_TREE_ID              = BONUS_SPELL_INFO.SPELL_TREE_ID
local AddDamageOverTimeAnalysis  = BONUS_SPELL_INFO.AddDamageOverTimeAnalysis
local AddManaAnalysis            = BONUS_SPELL_INFO.AddManaAnalysis
local ReverseLookupTable         = BONUS_SPELL_INFO.ReverseLookupTable

-- spell stuff
local SPELL_ID                   = ReverseLookupTable({ 689, 699, 709, 7651, 11699, 11700 })
local RANK_COEFF_TABLE           = { 0.078, 0.1, 0.1, 0.1, 0.1, 0.1 }
local DOT_TICKS                  = 5

-- listener for this spell
BONUS_SPELL_INFO.FUN[SPELL_NAME] = function(tooltip)
    -- hard data
    local name, id = tooltip:GetSpell()
    local spellRank = SPELL_ID[id]
    local coeff = RANK_COEFF_TABLE[spellRank]
    local ticks = DOT_TICKS

    -- calculate damage
    local damagePattern =
    "Transfers (%d+) health every second from the target to the caster.  Lasts (%d+) sec."
    local DOTDam, DOTDuration = FindTextInTooltip(tooltip, damagePattern)
    local spellPower = GetSpellBonusDamage(SPELL_TREE_ID.SHADOW)
    local bonusDamage = spellPower * coeff * ticks
    local empoweredDamage = DOTDam + bonusDamage

    -- cast time
    local castTime = 0

    -- calculcate mana efficiency
    local costPattern = "(%d+) Mana"
    local cost = FindTextInTooltip(tooltip, costPattern)

    -- add line
    tooltip:AddLine("\n")
    AddDamageOverTimeAnalysis(tooltip, DOTDam, castTime, DOTDuration, ticks, SPELL_TREE_ID.SHADOW, coeff)
    AddManaAnalysis(tooltip, cost, empoweredDamage)
end
