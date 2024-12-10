-- spell name
local SPELL_NAME                 = "Curse of Agony"

-- local alias
local FindTextInTooltip          = BONUS_SPELL_INFO.FindTextInTooltip
local SPELL_BONUS_TREE           = BONUS_SPELL_INFO.SPELL_BONUS_TREE

-- colors
local COLOR_MANA                 = "|cFF60A0FF"
local COLOR_SHADOW               = "|cFF808080"
local COLOR_DAMAGE               = "|cFFFF4040"
local COLOR_RESET                = "|r"

-- spell stuff
local DOT_TICKS                  = 5

-- damage table
local RANK_DAMAGE_COEFF          = {}
RANK_DAMAGE_COEFF[980]           = 0.046 -- rank 1
RANK_DAMAGE_COEFF[1014]          = 0.077
RANK_DAMAGE_COEFF[6217]          = 0.083
RANK_DAMAGE_COEFF[11711]         = 0.083
RANK_DAMAGE_COEFF[11712]         = 0.083 -- rank 5
RANK_DAMAGE_COEFF[11713]         = 0.083

-- listener for this spell
BONUS_SPELL_INFO.FUN[SPELL_NAME] = function(tooltip)
    -- hard data
    local name, id = tooltip:GetSpell()

    -- calculate damage
    local damagePattern =
    "Curses the target with agony, causing (%d+) Shadow damage over (%d+) sec."
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
        __("Deals ${colorDamage}${damage}${colorReset} ${colorShadow}Shadow${colorReset} damage.", {
            colorDamage = COLOR_DAMAGE,
            damage = math.floor(finalDam),
            colorShadow = COLOR_SHADOW,
            colorReset = COLOR_RESET
        }),
        255,
        255, 255)
    tooltip:AddLine(
        __("Deals ${colorDamage}${damage}${colorReset} ${colorShadow}Shadow${colorReset} damage per second.", {
            colorDamage = COLOR_DAMAGE,
            damage = math.floor(finalDam / DOTDuration),
            colorShadow = COLOR_SHADOW,
            colorReset = COLOR_RESET
        }),
        255,
        255, 255)
    tooltip:AddLine(
        __("Costs ${colorMana}${cost}${colorReset} per point of ${colorDamage}damage${colorReset}.", {
            colorMana = COLOR_MANA,
            cost = string.format("%.1f mana", cost / finalDam),
            colorReset = COLOR_RESET,
            colorDamage = COLOR_DAMAGE
        }),
        255,
        255, 255)
end