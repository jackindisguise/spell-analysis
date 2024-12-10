-- spell name
local SPELL_NAME = "Eviscerate"

-- local alias
local FindTextInTooltip = BONUS_SPELL_INFO.FindTextInTooltip

-- colors
local COLOR_YELLOW = "|cFFFFFF40"
local COLOR_RED = "|cFFFF4040"
local COLOR_RESET = "|r"

-- listener
BONUS_SPELL_INFO.FUN[SPELL_NAME] = function(tooltip)
    local damagePattern = "Finishing move that causes damage per combo point, increased by Attack Power:\r\
%s*1 point%s*: (%d*)-(%d*) damage\r\
%s*2 points*: (%d*)-(%d*) damage\r\
%s*3 points*: (%d*)-(%d*) damage\r\
%s*4 points: (%d*)-(%d*) damage\r\
%s*5 points: (%d*)-(%d*) damage"

    -- calculate average damages
    local oneLow, oneHigh, twoLow, twoHigh, threeLow, threeHigh, fourLow, fourHigh, fiveLow, fiveHigh = FindTextInTooltip(
        tooltip, damagePattern)

    local oneAvg = (oneLow + oneHigh) / 2
    local twoAvg = (twoLow + twoHigh) / 2
    local threeAvg = (threeLow + threeHigh) / 2
    local fourAvg = (fourLow + fourHigh) / 2
    local fiveAvg = (fiveLow + fiveHigh) / 2

    -- calculcate energy efficiency
    local costPattern = "(%d+) Energy"
    local cost = FindTextInTooltip(tooltip, costPattern)

    -- add analysis to tooltip
    tooltip:AddLine("\n")
    tooltip:AddLine(string.format(
        "Deals [ %s%d%s / %s%d%s / %s%d%s / %s%d%s / %s%d%s ] %sdamage%s on average.",
        COLOR_RED, oneAvg, COLOR_RESET,
        COLOR_RED, twoAvg, COLOR_RESET,
        COLOR_RED, threeAvg, COLOR_RESET,
        COLOR_RED, fourAvg, COLOR_RESET,
        COLOR_RED, fiveAvg, COLOR_RESET,
        COLOR_RED, COLOR_RESET), 255, 255, 255)
    tooltip:AddLine(
        string.format(
            "Costs [ %s%.1f%s / %s%.1f%s / %s%.1f%s / %s%.1f%s / %s%.1f%s ] %senergy%s per point of %sdamage%s.",
            COLOR_YELLOW, cost / oneAvg, COLOR_RESET,
            COLOR_YELLOW, cost / twoAvg, COLOR_RESET,
            COLOR_YELLOW, cost / threeAvg, COLOR_RESET,
            COLOR_YELLOW, cost / fourAvg, COLOR_RESET,
            COLOR_YELLOW, cost / fiveAvg, COLOR_RESET,
            COLOR_YELLOW, COLOR_RESET,
            COLOR_RED, COLOR_RESET), 255, 255, 255, true)
end
