-- spell name
local SPELL_NAME               = "Raptor Strike";

-- local alias
local FindTextInTooltip        = SPELL_ANALYSIS.FindTextInTooltip;
local SPELL_TREE_ID            = SPELL_ANALYSIS.SPELL_TREE_ID;
local SPELL_POWER_TYPE         = SPELL_ANALYSIS.SPELL_POWER_TYPE;
local ReverseLookupTable       = SPELL_ANALYSIS.ReverseLookupTable;
local AnalyzeDamageRangeSpell  = SPELL_ANALYSIS.AnalyzeDamageRangeSpell;
local AddDamageRangeAnalysis   = SPELL_ANALYSIS.AddDamageRangeAnalysis;
local AddPowerAnalysis         = SPELL_ANALYSIS.AddPowerAnalysis;

-- listener
SPELL_ANALYSIS.FUN[SPELL_NAME] = function(tooltip)
	-- hard data
	local name, id = tooltip:GetSpell();

	-- calculate damage
	local damagePattern =
	"A strong attack that increases melee damage by (%d+).";
	local bonusDamage = FindTextInTooltip(tooltip, damagePattern);
	local baseLow, baseHigh = UnitDamage("player"); -- base weapon range of main hand
	local empoweredLow, empoweredHigh = baseLow + bonusDamage, baseHigh + bonusDamage;

	-- calculcate mana efficiency
	local costPattern = "(%d+) Mana";
	local cost = FindTextInTooltip(tooltip, costPattern);

	-- cast time
	local cooldownPattern = "(.+) sec cooldown";
	local cooldown = tonumber(FindTextInTooltip(tooltip, cooldownPattern));

	-- analyze
	local result = AnalyzeDamageRangeSpell(empoweredLow, empoweredHigh, 0, cooldown, SPELL_TREE_ID.PHYSICAL,
		SPELL_POWER_TYPE.MANA, cost, 0);

	-- add line
	tooltip:AddLine("\n");
	AddDamageRangeAnalysis(tooltip, result);
	AddPowerAnalysis(tooltip, { range = result });
end;
