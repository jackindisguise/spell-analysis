-- spell name
local SPELL_NAME                    = "Sinister Strike"

-- local alias
local FindTextInTooltip             = BONUS_SPELL_INFO.FindTextInTooltip

-- colors
local COLOR_YELLOW                  = "|cFFFFFF40"
local COLOR_RED                     = "|cFFFF4040"
local COLOR_RESET                   = "|r"

-- other spell info
local COMBAT_TAB                    = 2
local IMPROVED_SINISTER_STRIKE_SLOT = 7

-- bonus damage table
local RANK_BONUS_TABLE              = {}
RANK_BONUS_TABLE[1752]              = 3
RANK_BONUS_TABLE[1757]              = 6
RANK_BONUS_TABLE[1758]              = 10
RANK_BONUS_TABLE[1759]              = 15
RANK_BONUS_TABLE[1760]              = 22
RANK_BONUS_TABLE[8621]              = 33
RANK_BONUS_TABLE[11293]             = 52
RANK_BONUS_TABLE[11294]             = 68

-- energy cost info
local BASE_ENERGY_COST              = 45

-- listener
BONUS_SPELL_INFO.FUN[SPELL_NAME]    = function(tooltip)
    -- hard data
    local name, id = tooltip:GetSpell()

    -- calculate damage
    local baseLo, baseHi = UnitDamage("player") -- base weapon range of main hand
    local baseAvg = (baseLo + baseHi) / 2       -- average weapon damage
    local rankBonus = RANK_BONUS_TABLE[id]      -- flat bonus from SS
    local avgDamage = baseAvg + rankBonus       -- final average damage

    -- calculcate energy efficiency
    --local _, _, _, _, rank = GetTalentInfo(COMBAT_TAB, IMPROVED_SINISTER_STRIKE_SLOT)
    --local cost = BASE_ENERGY_COST - (3 * rank) -- -3 energy per level of ISS
    local costPattern = "(%d+) Energy"
    local cost = FindTextInTooltip(tooltip, costPattern)

    -- add line
    tooltip:AddLine("\n")
    tooltip:AddLine(
        __("Deals ${colorRed}${damage}${colorReset} damage on average.",
            {
                colorRed = COLOR_RED,
                damage = math.floor(avgDamage),
                colorReset = COLOR_RESET
            }), 255,
        255, 255)
    tooltip:AddLine(
        __("Costs ${colorYellow}${cost}${colorReset} per point of damage.",
            {
                colorYellow = COLOR_YELLOW,
                cost = string.format("%.1f energy", cost / avgDamage),
                colorReset = COLOR_RESET
            }),
        255,
        255, 255)
end
