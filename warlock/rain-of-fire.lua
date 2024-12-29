-- spell name
local SPELL_NAME                 = "Rain of Fire";

-- local alias
local FindTextInTooltip          = SPELL_ANALYSIS.FindTextInTooltip;
local SPELL_TREE_ID              = SPELL_ANALYSIS.SPELL_TREE_ID;
local SPELL_POWER_TYPE           = SPELL_ANALYSIS.SPELL_POWER_TYPE;
local ReverseLookupTable         = SPELL_ANALYSIS.ReverseLookupTable;
local AnalyzeDamageOverTimeSpell = SPELL_ANALYSIS.AnalyzeDamageOverTimeSpell;
local AddDamageOverTimeAnalysis  = SPELL_ANALYSIS.AddDamageOverTimeAnalysis;
local AddAreaDamageAnalysis      = SPELL_ANALYSIS.AddAreaDamageAnalysis;
local AddPowerAnalysis           = SPELL_ANALYSIS.AddPowerAnalysis;

-- spell stuff
local SPELL_ID                   = ReverseLookupTable({ 5740, 6219, 11677, 11678 });
local COEFF                      = 0.083;
local DOT_TICKS                  = 4;

-- listener for this spell
SPELL_ANALYSIS.FUN[SPELL_NAME]   = function(tooltip)
	-- hard data
	local name, id = tooltip:GetSpell();
	local spellRank = SPELL_ID[id];
	local coeff = COEFF;
	local ticks = DOT_TICKS;

	-- calculate damage
	local damagePattern =
	"Calls down a fiery rain to burn enemies in the area of effect for (%d+) Fire damage over (%d+) sec.";
	local DOTDam, channelDuration = FindTextInTooltip(tooltip, damagePattern);

	-- calculcate mana efficiency
	local costPattern = "(%d+) Mana";
	local cost = FindTextInTooltip(tooltip, costPattern);

	-- do stuff
	local result = AnalyzeDamageOverTimeSpell(DOTDam, channelDuration, ticks, channelDuration, 0, SPELL_TREE_ID.FIRE,
		SPELL_POWER_TYPE.MANA, cost, coeff);

	-- add line
	tooltip:AddLine("\n");
	AddAreaDamageAnalysis(tooltip, { dot = result });
	AddPowerAnalysis(tooltip, { dot = result });
end;
