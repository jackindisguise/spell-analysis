-- spell name
local SPELL_NAME                 = "Immolate"

-- local alias
local FindTextInTooltip          = BONUS_SPELL_INFO.FindTextInTooltip
local AddHybridDamageAnalysis    = BONUS_SPELL_INFO.AddHybridDamageAnalysis
local AddManaAnalysis            = BONUS_SPELL_INFO.AddManaAnalysis
local SPELL_TREE_ID              = BONUS_SPELL_INFO.SPELL_TREE_ID
local ReverseLookupTable         = BONUS_SPELL_INFO.ReverseLookupTable

-- RGB values
local WHITE                      = { 1, 1, 1 }

-- spell stuff
local SPELL_ID                   = ReverseLookupTable({ 348, 707, 1094, 2941, 11665, 11667, 11668, 25309 })
local RANK_COEFF_TABLE           = {
    { FLAT_COEFF = 0.058, DOT_COEFF = 0.037 }, -- rank 1
    { FLAT_COEFF = 0.125, DOT_COEFF = 0.081 },
    { FLAT_COEFF = 0.2,   DOT_COEFF = 0.13 },
    { FLAT_COEFF = 0.2,   DOT_COEFF = 0.13 },
    { FLAT_COEFF = 0.2,   DOT_COEFF = 0.13 }, -- rank 5
    { FLAT_COEFF = 0.2,   DOT_COEFF = 0.13 },
    { FLAT_COEFF = 0.2,   DOT_COEFF = 0.13 },
    { FLAT_COEFF = 0.2,   DOT_COEFF = 0.13 } -- rank 8
}
local DOT_TICKS                  = 5

-- listener for this spell
BONUS_SPELL_INFO.FUN[SPELL_NAME] = function(tooltip)
    -- hard data
    local name, id = tooltip:GetSpell()
    local spellRank = SPELL_ID[id]
    local coeffTable = RANK_COEFF_TABLE[spellRank]

    -- calculate damage
    local damagePattern =
    "Burns the enemy for (%d+) Fire damage and then an additional (%d+) Fire damage over (%d+) sec."
    local flatDamage, DOTDamage, DOTDuration = FindTextInTooltip(tooltip, damagePattern)
    local bonusFireSpellPower = GetSpellBonusDamage(SPELL_TREE_ID.FIRE)
    local flatDamageSpellPowerBonus = bonusFireSpellPower * coeffTable.FLAT_COEFF
    local DOTDamageSpellPowerBonus = bonusFireSpellPower * coeffTable.DOT_COEFF * DOT_TICKS
    local baseDamage = flatDamage + DOTDamage
    local bonusDamage = flatDamageSpellPowerBonus + DOTDamageSpellPowerBonus
    local finalDamage = baseDamage + bonusDamage

    -- cast time
    local castTimePattern = "(.+) sec cast"
    local castTime = tonumber(FindTextInTooltip(tooltip, castTimePattern))

    -- calculcate mana efficiency
    local costPattern = "(%d+) Mana"
    local cost = FindTextInTooltip(tooltip, costPattern)

    -- add line
    tooltip:AddLine("\n")

    AddHybridDamageAnalysis(tooltip, flatDamage, DOTDamage, castTime, DOTDuration, DOT_TICKS, SPELL_TREE_ID.FIRE,
        coeffTable.FLAT_COEFF, coeffTable.DOT_COEFF)
    AddManaAnalysis(tooltip, cost, finalDamage)

    --[[ track lines
    local lines = GameTooltip:NumLines()
    -- fix lines
    for i = lines + 1, GameTooltip:NumLines() do
        _G["GameTooltipTextLeft" .. i]:SetFont("Fonts\\FRIZQT__.TTF", 15)
    end]]
end
