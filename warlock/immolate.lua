-- spell name
local SPELL_NAME                 = "Immolate"

-- local alias
local FindTextInTooltip          = BONUS_SPELL_INFO.FindTextInTooltip
local SPELL_BONUS_TREE           = BONUS_SPELL_INFO.SPELL_BONUS_TREE

-- colors
local COLOR_MANA                 = "|cFF60A0FF"
local COLOR_FIRE                 = "|cFFFFA500"
local COLOR_DAMAGE               = "|cFFFF4040"
local COLOR_RESET                = "|r"

-- RGB values
local WHITE                      = { 1, 1, 1 }
local GREY                       = { 0.5, 0.5, 0.5 }

-- spell stuff
local DOT_TICKS                  = 5

-- damage table
local RANK_COEFF_TABLE           = {}
RANK_COEFF_TABLE[348]            = { FlatCoeff = 0.058, DOTCoeff = 0.037 } -- rank 1
RANK_COEFF_TABLE[707]            = { FlatCoeff = 0.125, DOTCoeff = 0.081 }
RANK_COEFF_TABLE[1094]           = { FlatCoeff = 0.2, DOTCoeff = 0.13 }
RANK_COEFF_TABLE[2941]           = { FlatCoeff = 0.2, DOTCoeff = 0.13 }
RANK_COEFF_TABLE[11665]          = { FlatCoeff = 0.2, DOTCoeff = 0.13 } -- rank 5
RANK_COEFF_TABLE[11667]          = { FlatCoeff = 0.2, DOTCoeff = 0.13 }
RANK_COEFF_TABLE[11668]          = { FlatCoeff = 0.2, DOTCoeff = 0.13 }
RANK_COEFF_TABLE[25309]          = { FlatCoeff = 0.2, DOTCoeff = 0.13 } -- rank 8

-- listener for this spell
BONUS_SPELL_INFO.FUN[SPELL_NAME] = function(tooltip)
    -- hard data
    local name, id = tooltip:GetSpell()

    -- calculate damage
    local damagePattern =
    "Burns the enemy for (%d+) Fire damage and then an additional (%d+) Fire damage over (%d+) sec."
    local flatDam, DOTDam, DOTDuration = FindTextInTooltip(tooltip, damagePattern)
    local bonusFireDamage = GetSpellBonusDamage(SPELL_BONUS_TREE.FIRE)
    local flatDamSpellBonus = bonusFireDamage * RANK_COEFF_TABLE[id].FlatCoeff
    local DOTDamSpellBonus = bonusFireDamage * RANK_COEFF_TABLE[id].DOTCoeff * DOT_TICKS
    local finalDam = flatDam + flatDamSpellBonus + DOTDam + DOTDamSpellBonus

    -- calculcate mana efficiency
    local costPattern = "(%d+) Mana"
    local cost = FindTextInTooltip(tooltip, costPattern)

    -- add line
    tooltip:AddLine("\n")
    tooltip:AddLine(
        string.format("Deals %s%d %sFire%s damage.", COLOR_DAMAGE, finalDam, COLOR_FIRE, COLOR_RESET),
        unpack(WHITE))
    tooltip:AddLine(
        string.format("Costs %s%.1f mana%s per point of damage.", COLOR_MANA, cost / finalDam, COLOR_RESET),
        unpack(WHITE))
    if bonusFireDamage then
        tooltip:AddLine(
            string.format("Bonus %sFire%s spell damage is %s%d%s.", COLOR_FIRE, COLOR_RESET,
                COLOR_DAMAGE, bonusFireDamage, COLOR_RESET),
            unpack(WHITE)
        )
        --[[tooltip:AddLine(
            string.format("Bonus DOT coefficient is %.2f.", RANK_COEFF_TABLE[id].DOTCoeff), unpack(GREY)
        )
        tooltip:AddLine(
            string.format("DOT ticks %d times.", DOT_TICKS), unpack(GREY)
        )
        tooltip:AddLine(
            string.format("Bonus flat Fire damage is %d.", flatDamSpellBonus), unpack(GREY)
        )
        tooltip:AddLine(
            string.format("Bonus flat damage coefficient is %.2f.", RANK_COEFF_TABLE[id].FlatCoeff), unpack(GREY)
        )
        tooltip:AddLine(
            string.format("Bonus DOT Fire damage is %d.", DOTDamSpellBonus), unpack(GREY)
        )]]
    end
end
