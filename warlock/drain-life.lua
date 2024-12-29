-- spell name
local SPELL_NAME = "Drain Life";

--[[
--- TODO:
--- This is a spell that does damage and heals.
--- Add healing to metrics for determining the value of things.
--- It might be worthwhile to combine damage and healing into 1 number.
--- Though that reduces the amount of information we have for analysis later on.
--- I'll think about it.
]]

-- local alias
local FindTextInTooltip = SPELL_ANALYSIS.FindTextInTooltip;
local SPELL_TREE_ID = SPELL_ANALYSIS.SPELL_TREE_ID;
local SPELL_POWER_TYPE = SPELL_ANALYSIS.SPELL_POWER_TYPE;
local ReverseLookupTable = SPELL_ANALYSIS.ReverseLookupTable;
local AnalyzeDamageOverTimeSpell = SPELL_ANALYSIS.AnalyzeDamageOverTimeSpell;
local AddDamageOverTimeAnalysis = SPELL_ANALYSIS.AddDamageOverTimeAnalysis;
local AddPowerAnalysis = SPELL_ANALYSIS.AddPowerAnalysis;

-- spell stuff
local SPELL_ID = ReverseLookupTable({ 689, 699, 709, 7651, 11699, 11700 });
local RANK_COEFF_TABLE = { 0.078, 0.1, 0.1, 0.1, 0.1, 0.1 };
local DOT_TICKS = 5;

-- listener for this spell
SPELL_ANALYSIS.FUN[SPELL_NAME] = function(tooltip)
	-- hard data
	local name, id = tooltip:GetSpell();
	local spellRank = SPELL_ID[id];
	local coeff = RANK_COEFF_TABLE[spellRank];
	local ticks = DOT_TICKS;

	-- calculate damage
	local damagePattern =
	"Transfers (%d+) health every second from the target to the caster.  Lasts (%d+) sec.";
	local DOTDam, DOTDuration = FindTextInTooltip(tooltip, damagePattern);

	-- calculcate mana efficiency
	local costPattern = "(%d+) Mana";
	local cost = FindTextInTooltip(tooltip, costPattern);

	-- do stuff
	local result = AnalyzeDamageOverTimeSpell(DOTDam * DOTDuration, DOTDuration, ticks, DOTDuration, 0,
		SPELL_TREE_ID.SHADOW,
		SPELL_POWER_TYPE.MANA, cost, coeff);

	-- add line
	tooltip:AddLine("\n");
	AddDamageOverTimeAnalysis(tooltip, result);
	AddPowerAnalysis(tooltip, { dot = result });
end;
