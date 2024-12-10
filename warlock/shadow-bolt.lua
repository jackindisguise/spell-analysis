-- spell name
local SPELL_NAME                 = "Shadow Bolt"

-- local alias
local FindTextInTooltip          = BONUS_SPELL_INFO.FindTextInTooltip
local SPELL_BONUS_TREE           = BONUS_SPELL_INFO.SPELL_BONUS_TREE

-- colors
local COLOR_MANA                 = "|cFF60A0FF"
local COLOR_SHADOW               = "|cFF808080"
local COLOR_DAMAGE               = "|cFFFF4040"
local COLOR_RESET                = "|r"

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
        string.format("Deals %s%d %sShadow%s damage%s.", COLOR_DAMAGE, finalDam, COLOR_SHADOW, COLOR_DAMAGE, COLOR_RESET),
        255,
        255, 255)
    tooltip:AddLine(
        string.format("Deals %s%d %sShadow%s damage%s per second.", COLOR_DAMAGE, finalDam / castTime, COLOR_SHADOW,
            COLOR_DAMAGE,
            COLOR_RESET),
        255,
        255, 255)
    tooltip:AddLine(
        string.format("Costs %s%.1f mana%s per point of %sdamage%s.", COLOR_MANA, cost / finalDam, COLOR_RESET,
            COLOR_DAMAGE,
            COLOR_RESET),
        255,
        255, 255)
end
