-- spell name
local SPELL_NAME               = "Shoot"

-- local alias
local FindTextInTooltip        = SPELL_ANALYSIS.FindTextInTooltip
local SPELL_BONUS_TREE         = SPELL_ANALYSIS.SPELL_BONUS_TREE

-- colors
local COLOR_MANA               = "|cFF60A0FF"
local COLOR_SHADOW             = "|cFF808080"
local COLOR_DAMAGE             = "|cFFFF4040"
local COLOR_RESET              = "|r"

-- listener for this spell
SPELL_ANALYSIS.FUN[SPELL_NAME] = function(tooltip)
    -- hard data
    local name, id = tooltip:GetSpell()

    -- calculate damage
    local speed, lowDmg, hiDmg, posBuff, negBuff, percent = UnitRangedDamage("player");
    if speed == 0 then return end
    local avgDmg = (lowDmg + hiDmg) / 2

    -- add line
    tooltip:AddLine("\n")
    tooltip:AddLine(
        string.format("Deals %s%d damage%s on average.", COLOR_DAMAGE, avgDmg, COLOR_RESET),
        255,
        255, 255)
    tooltip:AddLine(
        string.format("Deals %s%d damage%s per second.", COLOR_DAMAGE, avgDmg / speed, COLOR_RESET),
        255,
        255, 255)
end
