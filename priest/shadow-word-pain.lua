-- spell name
local SPELL_NAME                 = "Shadow Word: Pain";

-- local alias
local FindTextInTooltip          = SPELL_ANALYSIS.FindTextInTooltip;
local SPELL_TREE_ID              = SPELL_ANALYSIS.SPELL_TREE_ID;
local SPELL_POWER_TYPE           = SPELL_ANALYSIS.SPELL_POWER_TYPE;
local ReverseLookupTable         = SPELL_ANALYSIS.ReverseLookupTable;
local AnalyzeDamageOverTimeSpell = SPELL_ANALYSIS.AnalyzeDamageOverTimeSpell;
local AddDamageOverTimeAnalysis  = SPELL_ANALYSIS.AddDamageOverTimeAnalysis;
local AddPowerAnalysis           = SPELL_ANALYSIS.AddPowerAnalysis;

-- spell stuff
local SPELL_ID                   = ReverseLookupTable({ 589, 594, 970, 992, 2767, 10892, 10893, 10894 });
local RANK_COEFF_TABLE           = { 0.067, 0.104, 0.154, 0.167, 0.167, 0.167, 0.167, 0.167 };
local DOT_TICKS                  = 6;

-- listener for this spell
SPELL_ANALYSIS.FUN[SPELL_NAME]   = function(tooltip)
	-- hard data
	local name, id = tooltip:GetSpell();
	local spellRank = SPELL_ID[id];
	local coeff = RANK_COEFF_TABLE[spellRank];
	local ticks = DOT_TICKS;

	-- calculate damage
	local damagePattern =
	"A word of darkness that causes (%d+) Shadow damage over (%d+) sec.";
	local DOTDam, DOTDuration = FindTextInTooltip(tooltip, damagePattern);

	-- calculcate mana efficiency
	local costPattern = "(%d+) Mana";
	local cost = FindTextInTooltip(tooltip, costPattern);

	-- do stuff
	local result = AnalyzeDamageOverTimeSpell(DOTDam, DOTDuration, ticks, 0, 0, SPELL_TREE_ID.SHADOW,
		SPELL_POWER_TYPE.MANA, cost, coeff);

	-- add line
	tooltip:AddLine("\n");
	AddDamageOverTimeAnalysis(tooltip, result);
	AddPowerAnalysis(tooltip, { dot = result });
end;
