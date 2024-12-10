-- spell name
local SPELL_NAME                 = "Backstab"

-- local alias
local FindTextInTooltip          = BONUS_SPELL_INFO.FindTextInTooltip
local COLOR                      = BONUS_SPELL_INFO.COLOR

-- bonus damage table
local RANK_BONUS_DAMAGE_TABLE    = {}
RANK_BONUS_DAMAGE_TABLE[53]      = 15
RANK_BONUS_DAMAGE_TABLE[2589]    = 30
RANK_BONUS_DAMAGE_TABLE[2590]    = 48
RANK_BONUS_DAMAGE_TABLE[2591]    = 69
RANK_BONUS_DAMAGE_TABLE[8721]    = 90
RANK_BONUS_DAMAGE_TABLE[11279]   = 135
RANK_BONUS_DAMAGE_TABLE[11280]   = 165
RANK_BONUS_DAMAGE_TABLE[11281]   = 210

-- listener for this spell
BONUS_SPELL_INFO.FUN[SPELL_NAME] = function(tooltip)
    -- hard data
    local name, id = tooltip:GetSpell()

    -- calculate damage
    local baseLo, baseHi = UnitDamage("player")   -- base weapon range of main hand
    local baseAvg = (baseLo + baseHi) / 2         -- average weapon damage
    local modifiedAvg = baseAvg * 1.5             -- +50% from backstab
    local rankBonus = RANK_BONUS_DAMAGE_TABLE[id] -- flat bonus from backstab
    local avgDamage = modifiedAvg + rankBonus     -- final average

    -- calculcate energy efficiency
    local costPattern = "(%d+) Energy"
    local cost = FindTextInTooltip(tooltip, costPattern)

    -- add line
    tooltip:AddLine("\n")
    tooltip:AddLine(
        __("Deals ${colorRed}${damage}${colorReset} damage on average.",
            {
                colorRed = COLOR.DAMAGE,
                damage = math.floor(avgDamage),
                colorReset = COLOR.RESET
            }),
        255,
        255, 255)
    tooltip:AddLine(
        __("Costs ${colorYellow}${cost}${colorReset} per point of damage.",
            {
                colorYellow = COLOR.ENERGY,
                cost = string.format("%.1f energy", math.floor(cost / avgDamage)),
                colorReset = COLOR.RESET,
                colorRed = COLOR.DAMAGE
            }),
        255,
        255, 255)
end
