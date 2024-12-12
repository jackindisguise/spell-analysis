-- spell name
local SPELL_NAME               = "Sinister Strike"

---[[
--- I've kind of realized that there is another way to analyze these spells.
--- You regenerate 10 energy per second.
--- This spell costs 45 energy.
--- That means you can use this spell every 4.5 seconds.
--- That means its DPS is effectively damage / 4.5.
--- This presents a complex question about certain systems in the game
--- and how they tie into damage analysis, which pisses me off a lot.
---]]

-- local alias
local FindTextInTooltip        = SPELL_ANALYSIS.FindTextInTooltip
local SPELL_TREE_ID            = SPELL_ANALYSIS.SPELL_TREE_ID
local SPELL_POWER_TYPE         = SPELL_ANALYSIS.SPELL_POWER_TYPE
local ReverseLookupTable       = SPELL_ANALYSIS.ReverseLookupTable
local AnalyzeDamageRangeSpell  = SPELL_ANALYSIS.AnalyzeDamageRangeSpell
local AddDamageRangeAnalysis   = SPELL_ANALYSIS.AddDamageRangeAnalysis
local AddPowerAnalysis         = SPELL_ANALYSIS.AddPowerAnalysis

-- spell stuff
local SPELL_ID                 = ReverseLookupTable({ 1752, 1757, 1758, 1759, 1760, 8621, 11293, 11294 })
local RANK_DAMAGE_TABLE        = { 3, 6, 10, 15, 22, 33, 52, 68 }

-- listener
SPELL_ANALYSIS.FUN[SPELL_NAME] = function(tooltip)
    -- hard data
    local name, id = tooltip:GetSpell()
    local spellRank = SPELL_ID[id]
    local bonusDamage = RANK_DAMAGE_TABLE[spellRank]

    -- calculate damage
    local baseLow, baseHigh = UnitDamage("player") -- base weapon range of main hand
    local empoweredLow, empoweredHigh = baseLow + bonusDamage, baseHigh + bonusDamage

    -- calculcate energy efficiency
    --local _, _, _, _, rank = GetTalentInfo(COMBAT_TAB, IMPROVED_SINISTER_STRIKE_SLOT)
    --local cost = BASE_ENERGY_COST - (3 * rank) -- -3 energy per level of ISS
    local costPattern = "(%d+) Energy"
    local cost = FindTextInTooltip(tooltip, costPattern)

    -- analyze
    local result = AnalyzeDamageRangeSpell(empoweredLow, empoweredHigh, 0, 0, SPELL_TREE_ID.PHYSICAL,
        SPELL_POWER_TYPE.ENERGY, cost, 0)

    -- add line
    tooltip:AddLine("\n")
    AddDamageRangeAnalysis(tooltip, result)
    AddPowerAnalysis(tooltip, { range = result })
end
