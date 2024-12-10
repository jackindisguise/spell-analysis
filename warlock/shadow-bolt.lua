-- spell name
local SPELL_NAME                 = "Shadow Bolt"

-- local alias
local FindTextInTooltip          = BONUS_SPELL_INFO.FindTextInTooltip
local SPELL_BONUS_TREE           = BONUS_SPELL_INFO.SPELL_BONUS_TREE
local COLOR                      = BONUS_SPELL_INFO.COLOR

-- damage table
local RANK_DAMAGE_COEFF          = {}
RANK_DAMAGE_COEFF[686]           = 0.14 -- rank 1
RANK_DAMAGE_COEFF[695]           = 0.299
RANK_DAMAGE_COEFF[705]           = 0.56
RANK_DAMAGE_COEFF[1088]          = 0.857
RANK_DAMAGE_COEFF[1106]          = 0.857 -- rank 5
RANK_DAMAGE_COEFF[7641]          = 0.857
RANK_DAMAGE_COEFF[11659]         = 0.857
RANK_DAMAGE_COEFF[11660]         = 0.857
RANK_DAMAGE_COEFF[11661]         = 0.857
RANK_DAMAGE_COEFF[25307]         = 0.857 -- rank 10

-- listener for this spell
BONUS_SPELL_INFO.FUN[SPELL_NAME] = function(tooltip)
    -- hard data
    local name, id = tooltip:GetSpell()

    -- calculate damage
    local damagePattern =
    "Sends a shadowy bolt at the enemy, causing (%d+) to (%d+) Shadow damage."
    local damLow, damHigh = FindTextInTooltip(tooltip, damagePattern)
    local damAvg = (damLow + damHigh) / 2
    local bonusDamage = GetSpellBonusDamage(SPELL_BONUS_TREE.SHADOW)
    local finalDam = damAvg + (bonusDamage * RANK_DAMAGE_COEFF[id])

    -- cast time
    local castTimePattern = "(.+) sec cast"
    local castTime = tonumber(FindTextInTooltip(tooltip, castTimePattern))

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
                damage = math.floor(finalDam / castTime),
                colorShadow = COLOR.SHADOW,
                colorReset = COLOR.RESET
            }),
        255,
        255, 255)
    tooltip:AddLine(
        __("Costs ${colorMana}${cost}${colorReset} per point of damage.", {
            colorMana = COLOR.MANA,
            cost = string.format("%.1f mana", cost / finalDam),
            colorReset = COLOR.RESET
        }),
        255,
        255, 255)
end
