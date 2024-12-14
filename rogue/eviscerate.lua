-- spell name
local SPELL_NAME               = "Eviscerate"

---[[
--- Finishers are gonna be a bitch to implement.
--- They consume energy AND combo points.
--- Annoying.
---]]

-- local alias
local FindTextInTooltip        = SPELL_ANALYSIS.FindTextInTooltip
local COLOR                    = SPELL_ANALYSIS.COLOR
local AddDamageRangeAnalysis   = SPELL_ANALYSIS.AddDamageRangeAnalysis
local AnalyzeDamageRangeSpell  = SPELL_ANALYSIS.AnalyzeDamageRangeSpell
local AddPowerAnalysis         = SPELL_ANALYSIS.AddPowerAnalysis
local SPELL_TREE_ID            = SPELL_ANALYSIS.SPELL_TREE_ID
local SPELL_POWER_TYPE         = SPELL_ANALYSIS.SPELL_POWER_TYPE
local __                       = SPELL_ANALYSIS.__
local ShortFloat               = SPELL_ANALYSIS.ShortFloat

-- spell stuff
local ATTACK_POWER_COEFFICIENT = 0.03 -- 3% bonus damage from attack power

-- listener
SPELL_ANALYSIS.FUN[SPELL_NAME] = function(tooltip)
    local damagePattern = "Finishing move that causes damage per combo point, increased by Attack Power:\r\
%s*1 point%s*: (%d*)-(%d*) damage\r\
%s*2 points*: (%d*)-(%d*) damage\r\
%s*3 points*: (%d*)-(%d*) damage\r\
%s*4 points: (%d*)-(%d*) damage\r\
%s*5 points: (%d*)-(%d*) damage"

    -- calculate average damages
    local oneLow, oneHigh, twoLow, twoHigh, threeLow, threeHigh, fourLow, fourHigh, fiveLow, fiveHigh = FindTextInTooltip(
        tooltip, damagePattern)

    local attackPower, bonusAttackPower = UnitAttackPower("player")
    local totalAttackPower = attackPower + bonusAttackPower
    local attackPowerDamage = totalAttackPower * ATTACK_POWER_COEFFICIENT

    local avg = { (oneLow + oneHigh) / 2, (twoLow + twoHigh) / 2, (threeLow + threeHigh) / 2, (fourLow + fourHigh) / 2, (fiveLow + fiveHigh) /
    2 }
    local avgEmpowered = { avg[1] + attackPowerDamage, avg[2] + attackPowerDamage, avg[3] + attackPowerDamage, avg[4] +
    attackPowerDamage, avg[5] + attackPowerDamage }

    -- calculcate energy efficiency
    local costPattern = "(%d+) Energy"
    local cost = FindTextInTooltip(tooltip, costPattern)

    -- add analysis to tooltip
    tooltip:AddLine("\n")
    tooltip:AddLine(__("${attackPower} Attack Power adds ${colorRed}${attackPowerDamage}${colorReset} bonus damage.", {
        colorRed = COLOR.DAMAGE,
        colorReset = COLOR.RESET,
        attackPower = totalAttackPower,
        attackPowerDamage = attackPowerDamage
    }), 255, 255, 255)
    tooltip:AddLine(
        __(
            "${attackPower} Attack Power adds [ ${colorRed}${attackPowerOne}%${colorReset} / ${colorRed}${attackPowerTwo}%${colorReset} / ${colorRed}${attackPowerThree}%${colorReset} / ${colorRed}${attackPowerFour}%${colorReset} / ${colorRed}${attackPowerFive}%${colorReset} ] bonus damage.",
            {
                colorRed = COLOR.DAMAGE,
                colorReset = COLOR.RESET,
                attackPower = totalAttackPower,
                attackPowerOne = ShortFloat(attackPowerDamage / avg[1] * 100, 1),
                attackPowerTwo = ShortFloat(attackPowerDamage / avg[2] * 100, 1),
                attackPowerThree = ShortFloat(attackPowerDamage / avg[3] * 100, 1),
                attackPowerFour = ShortFloat(attackPowerDamage / avg[4] * 100, 1),
                attackPowerFive = ShortFloat(attackPowerDamage / avg[5] * 100, 1),
            }), 255, 255, 255)
    tooltip:AddLine(
        __(
            "Deals [ ${colorRed}${one}${colorReset} / ${colorRed}${two}${colorReset} / ${colorRed}${three}${colorReset} / ${colorRed}${four}${colorReset} / ${colorRed}${five}${colorReset} ] damage on average.",
            {
                colorRed = COLOR.DAMAGE,
                colorReset = COLOR.RESET,
                one = ShortFloat(avgEmpowered[1], 1),
                two = ShortFloat(avgEmpowered[2], 1),
                three = ShortFloat(avgEmpowered[3], 1),
                four = ShortFloat(avgEmpowered[4], 1),
                five = ShortFloat(avgEmpowered[5], 1)
            }), 255, 255, 255, false)
    tooltip:AddLine(
        __(
            "Costs [ ${colorYellow}${one}${colorReset} / ${colorYellow}${two}${colorReset} / ${colorYellow}${three}${colorReset} / ${colorYellow}${four}${colorReset} / ${colorYellow}${five}${colorReset} ] energy per point of damage.",
            {
                colorYellow = COLOR.ENERGY,
                one = ShortFloat(cost / avgEmpowered[1], 1),
                two = ShortFloat(cost / avgEmpowered[2], 1),
                three = ShortFloat(cost / avgEmpowered[3], 1),
                four = ShortFloat(cost / avgEmpowered[4], 1),
                five = ShortFloat(cost / avgEmpowered[5], 1),
                colorReset = COLOR.RESET
            }
        ), 255, 255, 255, true)
    tooltip:AddLine(
        __(
            "Spell has [ ${colorYellow}${one}%${colorReset} / ${colorYellow}${two}%${colorReset} / ${colorYellow}${three}%${colorReset} / ${colorYellow}${four}%${colorReset} / ${colorYellow}${five}%${colorReset} ] energy efficiency.",
            {
                colorYellow = COLOR.ENERGY,
                one = ShortFloat(avgEmpowered[1] / cost * 100, 1),
                two = ShortFloat(avgEmpowered[2] / cost * 100, 1),
                three = ShortFloat(avgEmpowered[3] / cost * 100, 1),
                four = ShortFloat(avgEmpowered[4] / cost * 100, 1),
                five = ShortFloat(avgEmpowered[5] / cost * 100, 1),
                colorReset = COLOR.RESET
            }
        ), 255, 255, 255, true)

    --[[ test]]
    local analysis = {
        {
            energy = AnalyzeDamageRangeSpell(oneLow, oneHigh, 0, 0, SPELL_TREE_ID.PHYSICAL, SPELL_POWER_TYPE.ENERGY, cost,
                0),
            cp = AnalyzeDamageRangeSpell(oneLow, oneHigh, 0, 0, SPELL_TREE_ID.PHYSICAL, SPELL_POWER_TYPE.COMBO_POINTS, 1,
                0)
        },
        {
            energy = AnalyzeDamageRangeSpell(twoLow, twoHigh, 0, 0, SPELL_TREE_ID.PHYSICAL, SPELL_POWER_TYPE.ENERGY, cost,
                0),
            cp = AnalyzeDamageRangeSpell(twoLow, twoHigh, 0, 0, SPELL_TREE_ID.PHYSICAL, SPELL_POWER_TYPE.COMBO_POINTS, 2,
                0)
        },
        {
            energy = AnalyzeDamageRangeSpell(threeLow, threeHigh, 0, 0, SPELL_TREE_ID.PHYSICAL, SPELL_POWER_TYPE.ENERGY,
                cost, 0),
            cp = AnalyzeDamageRangeSpell(threeLow, threeHigh, 0, 0, SPELL_TREE_ID.PHYSICAL, SPELL_POWER_TYPE
                .COMBO_POINTS, 3,
                0)
        },
        {
            energy = AnalyzeDamageRangeSpell(fourLow, fourHigh, 0, 0, SPELL_TREE_ID.PHYSICAL, SPELL_POWER_TYPE.ENERGY,
                cost, 0),
            cp = AnalyzeDamageRangeSpell(fourLow, fourHigh, 0, 0, SPELL_TREE_ID.PHYSICAL, SPELL_POWER_TYPE.COMBO_POINTS,
                4,
                0)
        },
        {
            energy = AnalyzeDamageRangeSpell(fiveLow, fiveHigh, 0, 0, SPELL_TREE_ID.PHYSICAL, SPELL_POWER_TYPE.ENERGY,
                cost, 0),
            cp = AnalyzeDamageRangeSpell(fiveLow, fiveHigh, 0, 0, SPELL_TREE_ID.PHYSICAL, SPELL_POWER_TYPE.COMBO_POINTS,
                5,
                0)
        }
    }

    --tooltip:AddLine("\n")
    for k, v in pairs(analysis) do
        --        AddDamageRangeAnalysis(tooltip, v.energy, nil, __("${cp} CP:", { cp = k }))
        --AddPowerAnalysis(tooltip, { range = v.energy }, nil, __("${cp} CP:", { cp = k }))
        --AddPowerAnalysis(tooltip, { range = v.cp }, nil, false)
    end
end
