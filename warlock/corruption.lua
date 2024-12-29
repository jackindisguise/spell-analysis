-- spell name
local SPELL_NAME                 = "Corruption";

-- local alias
local FindTextInTooltip          = SPELL_ANALYSIS.FindTextInTooltip;
local SPELL_TREE_ID              = SPELL_ANALYSIS.SPELL_TREE_ID;
local SPELL_POWER_TYPE           = SPELL_ANALYSIS.SPELL_POWER_TYPE;
local ReverseLookupTable         = SPELL_ANALYSIS.ReverseLookupTable;
local AnalyzeDamageOverTimeSpell = SPELL_ANALYSIS.AnalyzeDamageOverTimeSpell;
local AddDamageOverTimeAnalysis  = SPELL_ANALYSIS.AddDamageOverTimeAnalysis;
local AddPowerAnalysis           = SPELL_ANALYSIS.AddPowerAnalysis;

-- spell stuff
local SPELL_ID                   = ReverseLookupTable({ 172, 6222, 6223, 7648, 11671, 11672, 25311 });
local RANK_COEFF_TABLE           = { 0.08, 0.155, 0.167, 0.167, 0.167, 0.167, 0.167 };
local DOT_TICKS                  = { 4, 5, 6, 6, 6, 6, 6 };

-- listener for this spell
SPELL_ANALYSIS.FUN[SPELL_NAME]   = function(tooltip)
	-- hard data
	local name, id = tooltip:GetSpell();
	local spellRank = SPELL_ID[id];
	local coeff = RANK_COEFF_TABLE[spellRank];
	local ticks = DOT_TICKS[spellRank];

	-- calculate damage
	local damagePattern =
	"Corrupts the target, causing (%d+) Shadow damage over (%d+) sec.";
	local DOTDam, DOTDuration = FindTextInTooltip(tooltip, damagePattern);

	-- cast time
	local castTimePattern = "(.+) sec cast";
	local castTime = 0;
	local castTimeString = FindTextInTooltip(tooltip, castTimePattern);
	if castTimeString then castTime = tonumber(castTimeString) or 0; end;

	-- calculcate mana efficiency
	local costPattern = "(%d+) Mana";
	local cost = FindTextInTooltip(tooltip, costPattern);

	-- do stuff
	local result = AnalyzeDamageOverTimeSpell(DOTDam, DOTDuration, ticks, castTime, 0, SPELL_TREE_ID.SHADOW,
		SPELL_POWER_TYPE.MANA, cost, coeff);

	-- add line
	tooltip:AddLine("\n");
	AddDamageOverTimeAnalysis(tooltip, result);
	AddPowerAnalysis(tooltip, { dot = result });
end;
