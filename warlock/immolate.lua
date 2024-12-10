-- spell name
local SPELL_NAME                 = "Immolate"

-- local alias
local FindTextInTooltip          = BONUS_SPELL_INFO.FindTextInTooltip
local SPELL_BONUS_TREE           = BONUS_SPELL_INFO.SPELL_BONUS_TREE
local COLOR                      = BONUS_SPELL_INFO.COLOR

-- RGB values
local WHITE                      = { 1, 1, 1 }

-- spell stuff
local DOT_TICKS                  = 5

-- damage table
local RANK_COEFF_TABLE           = {}
RANK_COEFF_TABLE[348]            = { FLAT_COEFF = 0.058, DOT_COEFF = 0.037 } -- rank 1
RANK_COEFF_TABLE[707]            = { FLAT_COEFF = 0.125, DOT_COEFF = 0.081 }
RANK_COEFF_TABLE[1094]           = { FLAT_COEFF = 0.2, DOT_COEFF = 0.13 }
RANK_COEFF_TABLE[2941]           = { FLAT_COEFF = 0.2, DOT_COEFF = 0.13 }
RANK_COEFF_TABLE[11665]          = { FLAT_COEFF = 0.2, DOT_COEFF = 0.13 } -- rank 5
RANK_COEFF_TABLE[11667]          = { FLAT_COEFF = 0.2, DOT_COEFF = 0.13 }
RANK_COEFF_TABLE[11668]          = { FLAT_COEFF = 0.2, DOT_COEFF = 0.13 }
RANK_COEFF_TABLE[25309]          = { FLAT_COEFF = 0.2, DOT_COEFF = 0.13 } -- rank 8

-- listener for this spell
BONUS_SPELL_INFO.FUN[SPELL_NAME] = function(tooltip)
    -- hard data
    local name, id = tooltip:GetSpell()

    -- calculate damage
    local damagePattern =
    "Burns the enemy for (%d+) Fire damage and then an additional (%d+) Fire damage over (%d+) sec."
    local flatDam, DOTDam, DOTDuration = FindTextInTooltip(tooltip, damagePattern)
    local bonusFireDamage = GetSpellBonusDamage(SPELL_BONUS_TREE.FIRE)
    local flatDamSpellBonus = bonusFireDamage * RANK_COEFF_TABLE[id].FLAT_COEFF
    local DOTDamSpellBonus = bonusFireDamage * RANK_COEFF_TABLE[id].DOT_COEFF * DOT_TICKS
    local finalDam = flatDam + flatDamSpellBonus + DOTDam + DOTDamSpellBonus

    -- calculcate mana efficiency
    local costPattern = "(%d+) Mana"
    local cost = FindTextInTooltip(tooltip, costPattern)

    -- add line
    tooltip:AddLine("\n")
    tooltip:AddLine(
        __("Deals ${colorDamage}${damage}${colorReset} ${colorFire}Fire${colorReset} damage.", {
            colorDamage = COLOR.DAMAGE,
            damage = math.floor(finalDam),
            colorFire = COLOR.FIRE,
            colorReset = COLOR.RESET
        }),
        unpack(WHITE))
    tooltip:AddLine(
        __("Deals ${colorDamage}${damage}${colorReset} ${colorFire}Fire${colorReset} damage per second.", {
            colorDamage = COLOR.DAMAGE,
            damage = math.floor(finalDam / DOTDuration),
            colorShadow = COLOR.FIRE,
            colorReset = COLOR.RESET
        }),
        unpack(WHITE))
    tooltip:AddLine(
        __("Costs ${colorMana}${manaPerDamage} mana${colorReset} per point of damage.", {
            colorMana = COLOR.MANA,
            manaPerDamage = string.format("%.1f", cost / finalDam),
            colorReset = COLOR.RESET
        }),
        unpack(WHITE))
    if bonusFireDamage then
        tooltip:AddLine(
            __("Bonus ${colorFire}Fire${colorReset} spell damage is ${colorDamage}${bonusFireDamage}${colorReset}.", {
                colorFire = COLOR.FIRE,
                colorReset = COLOR.RESET,
                colorDamage = COLOR.DAMAGE,
                bonusFireDamage = bonusFireDamage
            }),
            unpack(WHITE)
        )
        --[[tooltip:AddLine(
            string.format("Bonus DOT coefficient is %.2f.", RANK_COEFF_TABLE[id].DOT_COEFF), unpack(GREY)
        )
        tooltip:AddLine(
            string.format("DOT ticks %d times.", DOT_TICKS), unpack(GREY)
        )
        tooltip:AddLine(
            string.format("Bonus flat Fire damage is %d.", flatDamSpellBonus), unpack(GREY)
        )
        tooltip:AddLine(
            string.format("Bonus flat damage coefficient is %.2f.", RANK_COEFF_TABLE[id].FLAT_COEFF), unpack(GREY)
        )
        tooltip:AddLine(
            string.format("Bonus DOT Fire damage is %d.", DOTDamSpellBonus), unpack(GREY)
        )]]
    end
end
