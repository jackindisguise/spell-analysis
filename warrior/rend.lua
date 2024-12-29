-- spell name
local SPELL_NAME                 = "Rend";

-- local alias
local FindTextInTooltip          = SPELL_ANALYSIS.FindTextInTooltip;
local SPELL_TREE_ID              = SPELL_ANALYSIS.SPELL_TREE_ID;
local SPELL_POWER_TYPE           = SPELL_ANALYSIS.SPELL_POWER_TYPE;
local AnalyzeDamageOverTimeSpell = SPELL_ANALYSIS.AnalyzeDamageOverTimeSpell;
local AddDamageOverTimeAnalysis  = SPELL_ANALYSIS.AddDamageOverTimeAnalysis;
local AddPowerAnalysis           = SPELL_ANALYSIS.AddPowerAnalysis;

-- listener for this spell
SPELL_ANALYSIS.FUN[SPELL_NAME]   = function(tooltip)
	-- hard data
	local name, id = tooltip:GetSpell();

	-- calculate damage
	local damagePattern =
	"Wounds the target causing them to bleed for (%d+) damage over (%d+) sec.";
	local DOTDam, DOTDuration = FindTextInTooltip(tooltip, damagePattern);
	local ticks = DOTDuration / 3;

	-- calculcate mana efficiency
	local costPattern = "(%d+) Rage";
	local cost = FindTextInTooltip(tooltip, costPattern);

	-- do stuff
	local result = AnalyzeDamageOverTimeSpell(DOTDam, DOTDuration, ticks, 0, 0, SPELL_TREE_ID.PHYSICAL,
		SPELL_POWER_TYPE.RAGE, cost, 0);

	-- add line
	tooltip:AddLine("\n");
	AddDamageOverTimeAnalysis(tooltip, result);
	AddPowerAnalysis(tooltip, { dot = result });
end;
