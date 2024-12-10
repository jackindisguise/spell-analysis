-- spell name
local SPELL_NAME                 = "Eviscerate"

-- local alias
local FindTextInTooltip          = BONUS_SPELL_INFO.FindTextInTooltip

-- colors
local COLOR_YELLOW               = "|cFFFFFF40"
local COLOR_RED                  = "|cFFFF4040"
local COLOR_RESET                = "|r"

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
    tooltip:AddLine(
        __(
            "Deals [ ${colorRed}${one}${colorReset} / ${colorRed}${two}${colorReset} / ${colorRed}${three}${colorReset} / ${colorRed}${four}${colorReset} / ${colorRed}${five}${colorReset} ] damage on average.",
            {
                colorRed = COLOR_RED,
                colorReset = COLOR_RESET,
                one = math.floor(oneAvg),
                two = math.floor(twoAvg),
                three = math.floor(threeAvg),
                four = math.floor(fourAvg),
                five = math.floor(fiveAvg)
            }), 255, 255, 255)
    tooltip:AddLine(
        __(
            "Costs [ ${colorYellow}${one}${colorReset} / ${colorYellow}${two}${colorReset} / ${colorYellow}${three}${colorReset} / ${colorYellow}${four}${colorReset} / ${colorYellow}${five}${colorReset} ] energy per point of damage.",
            {
                colorYellow = COLOR_YELLOW,
                one = string.format("%.1f", cost / oneAvg),
                two = string.format("%.1f", cost / twoAvg),
                three = string.format("%.1f", cost / threeAvg),
                four = string.format("%.1f", cost / fourAvg),
                five = string.format("%.1f", cost / fiveAvg),
                colorReset = COLOR_RESET
            }
        ), 255, 255, 255, true)
end
