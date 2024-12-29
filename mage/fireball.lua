-- spell name
local SPELL_NAME                 = "Fireball";

-- local alias
local FindTextInTooltip          = SPELL_ANALYSIS.FindTextInTooltip;
local SPELL_TREE_ID              = SPELL_ANALYSIS.SPELL_TREE_ID;
local SPELL_POWER_TYPE           = SPELL_ANALYSIS.SPELL_POWER_TYPE;
local ReverseLookupTable         = SPELL_ANALYSIS.ReverseLookupTable;
local AnalyzeDamageOverTimeSpell = SPELL_ANALYSIS.AnalyzeDamageOverTimeSpell;
local AnalyzeDamageRangeSpell    = SPELL_ANALYSIS.AnalyzeDamageRangeSpell;
local AddHybridDamageAnalysis    = SPELL_ANALYSIS.AddHybridDamageAnalysis;
local AddPowerAnalysis           = SPELL_ANALYSIS.AddPowerAnalysis;

-- RGB values
local WHITE                      = { 1, 1, 1 };

-- spell stuff
local SPELL_ID                   = ReverseLookupTable({ 133, 143, 145, 3140, 8400, 8401, 8402, 10148, 10149, 10150, 10151, 25306 });
local RANK_RANGE_COEFF_TABLE     = { 0.123, 0.271, 0.5, 0.793, 0, 0, 0, 0, 0, 0, 0, 0 };

-- listener for this spell
SPELL_ANALYSIS.FUN[SPELL_NAME]   = function(tooltip)
	-- hard data
	local name, id = tooltip:GetSpell();
	local spellRank = SPELL_ID[id];
	local rangeCoeff = RANK_RANGE_COEFF_TABLE[spellRank];

	-- calculate damage
	local damagePattern =
	"Hurls a fiery ball that causes (%d+) to (%d+) Fire damage and an additional (%d+) Fire damage over (%d+) sec.";
	local rangeLow, rangeHigh, DOTDamage, DOTDuration = FindTextInTooltip(tooltip, damagePattern);

	-- cast time
	local castTimePattern = "(.+) sec cast";
	local castTime = tonumber(FindTextInTooltip(tooltip, castTimePattern));

	-- calculcate mana efficiency
	local costPattern = "(%d+) Mana";
	local cost = FindTextInTooltip(tooltip, costPattern);

	local ticks = DOTDuration / 2; -- ticks every 2 seconds, duration increases every few ranks
	local resultRange = AnalyzeDamageRangeSpell(rangeLow, rangeHigh, castTime, 0, SPELL_TREE_ID.FIRE,
		SPELL_POWER_TYPE.MANA, cost,
		rangeCoeff);

	local resultDOT = AnalyzeDamageOverTimeSpell(DOTDamage, DOTDuration, ticks, castTime, 0, SPELL_TREE_ID.FIRE,
		SPELL_POWER_TYPE.MANA, cost, 0);

	-- add line
	tooltip:AddLine("\n");
	AddHybridDamageAnalysis(tooltip, { range = resultRange, dot = resultDOT });
	AddPowerAnalysis(tooltip, { range = resultRange, dot = resultDOT });
end;
