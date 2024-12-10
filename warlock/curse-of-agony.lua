-- spell name
local SPELL_NAME                 = "Curse of Agony"

-- local alias
local FindTextInTooltip          = BONUS_SPELL_INFO.FindTextInTooltip
local SPELL_TREE_ID              = BONUS_SPELL_INFO.SPELL_TREE_ID
local AddDamageOverTimeAnalysis  = BONUS_SPELL_INFO.AddDamageOverTimeAnalysis
local AddManaAnalysis            = BONUS_SPELL_INFO.AddManaAnalysis
local ReverseLookupTable         = BONUS_SPELL_INFO.ReverseLookupTable

-- spell stuff
local SPELL_ID                   = ReverseLookupTable({ 980, 1014, 6217, 11711, 11712, 11713 })
local RANK_COEFF_TABLE           = { 0.046, 0.077, 0.083, 0.083, 0.083, 0.083 }
local DOT_TICKS                  = 12

-- listener for this spell
BONUS_SPELL_INFO.FUN[SPELL_NAME] = function(tooltip)
    -- hard data
    local name, id = tooltip:GetSpell()
    local spellRank = SPELL_ID[id]
    local coeff = RANK_COEFF_TABLE[spellRank]
    local ticks = DOT_TICKS

    -- calculate damage
    local damagePattern =
    "Curses the target with agony, causing (%d+) Shadow damage over (%d+) sec."
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
