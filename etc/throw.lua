-- spell name
local SPELL_NAME               = "Shoot"

-- local alias
local ShortFloat               = SPELL_ANALYSIS.ShortFloat

-- colors
local COLOR_DAMAGE             = "|cFFFF4040"
local COLOR_RESET              = "|r"

-- once i figure out how to determine the damage-type of the wands, I'll fix this

-- listener for this spell
SPELL_ANALYSIS.FUN[SPELL_NAME] = function(tooltip)
    -- hard data
    local name, id = tooltip:GetSpell()

    -- calculate damage
    local speed, lowDmg, hiDmg = UnitRangedDamage("player");
    if speed == 0 then return end
    local avgDmg = (lowDmg + hiDmg) / 2

    -- add line
    tooltip:AddLine("\n")
    tooltip:AddLine(
        string.format("Deals %s%s%s damage on average.", COLOR_DAMAGE, ShortFloat(avgDmg, 2), COLOR_RESET),
        255,
        255, 255)
    tooltip:AddLine(
        string.format("Deals %s%s%s damage per second.", COLOR_DAMAGE, ShortFloat(avgDmg / speed, 2), COLOR_RESET),
        255,
        255, 255)
end
