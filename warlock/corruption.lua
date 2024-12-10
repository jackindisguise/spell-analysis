-- spell name
local SPELL_NAME                 = "Corruption"

-- local alias
local FindTextInTooltip          = BONUS_SPELL_INFO.FindTextInTooltip
local SPELL_BONUS_TREE           = BONUS_SPELL_INFO.SPELL_BONUS_TREE
local COLOR                      = BONUS_SPELL_INFO.COLOR

-- spell stuff
local DOT_TICKS                  = 4

-- damage table
local RANK_DAMAGE_COEFF          = {}
RANK_DAMAGE_COEFF[172]           = 0.08 -- rank 1
RANK_DAMAGE_COEFF[6222]          = 0.155
RANK_DAMAGE_COEFF[6223]          = 0.167
RANK_DAMAGE_COEFF[7648]          = 0.167
RANK_DAMAGE_COEFF[11671]         = 0.167 -- rank 5
RANK_DAMAGE_COEFF[11672]         = 0.167
RANK_DAMAGE_COEFF[25311]         = 0.167

-- listener for this spell
BONUS_SPELL_INFO.FUN[SPELL_NAME] = function(tooltip)
    -- hard data
    local name, id = tooltip:GetSpell()

    -- calculate damage
    local damagePattern =
    "Corrupts the target, causing (%d+) Shadow damage over (%d+) sec."
    local DOTDam, DOTDuration = FindTextInTooltip(tooltip, damagePattern)
    local bonusDamage = GetSpellBonusDamage(SPELL_BONUS_TREE.SHADOW)
    local DOTDamSpellBonus = bonusDamage * RANK_DAMAGE_COEFF[id] * DOT_TICKS
    local finalDam = DOTDam + DOTDamSpellBonus

    -- calculcate mana efficiency
    local costPattern = "(%d+) Mana"
    local cost = FindTextInTooltip(tooltip, costPattern)

    -- add line
    tooltip:AddLine("\n")
    tooltip:AddLine(
        __("Deals ${colorDamage}${damage}${colorReset} ${colorShadow}Shadow${colorReset} damage.",
            {
                colorDamage = COLOR.DAMAGE,
                damage = math.floor(finalDam),
                colorShadow = COLOR.SHADOW,
                colorReset = COLOR.RESET
            }),
        255,
        255, 255)
    tooltip:AddLine(
        __("Deals ${colorDamage}${damage}${colorReset} ${colorShadow}Shadow${colorReset} damage per second.",
            {
                colorDamage = COLOR.DAMAGE,
                damage = math.floor(finalDam / DOTDuration),
                colorShadow = COLOR.SHADOW,
                colorReset = COLOR.RESET
            }),
        255,
        255, 255)
    tooltip:AddLine(
        __("Costs ${colorMana}${cost}${colorReset} per point of damage.",
            {
                colorMana = COLOR.MANA,
                cost = string.format("%.1f mana", cost / finalDam),
                colorReset = COLOR.RESET,
                colorDamage = COLOR.DAMAGE,
            }),
        255,
        255, 255)
end
