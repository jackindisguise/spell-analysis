-- spell name
local SPELL_NAME               = "Fire Blast";

-- local alias
local FindTextInTooltip        = SPELL_ANALYSIS.FindTextInTooltip;
local SPELL_TREE_ID            = SPELL_ANALYSIS.SPELL_TREE_ID;
local SPELL_POWER_TYPE         = SPELL_ANALYSIS.SPELL_POWER_TYPE;
local ReverseLookupTable       = SPELL_ANALYSIS.ReverseLookupTable;
local AnalyzeDamageRangeSpell  = SPELL_ANALYSIS.AnalyzeDamageRangeSpell;
local AddDamageRangeAnalysis   = SPELL_ANALYSIS.AddDamageRangeAnalysis;
local AddPowerAnalysis         = SPELL_ANALYSIS.AddPowerAnalysis;

-- spell stuff
local SPELL_ID                 = ReverseLookupTable({ 2136, 2137, 2138, 8412, 8413, 10197, 10199 });
local RANK_COEFF_TABLE         = { 0.204, 0.332, 0.429, 0.429, 0.429, 0.429, 0.429 };

-- listener for this spell
SPELL_ANALYSIS.FUN[SPELL_NAME] = function(tooltip)
	-- hard data
	local name, id = tooltip:GetSpell();
	local spellRank = SPELL_ID[id];
	local coeff = RANK_COEFF_TABLE[spellRank];

	-- calculate damage
	local damagePattern =
	"Blasts the enemy for (%d+) to (%d+) Fire damage.";
	local damLow, damHigh = FindTextInTooltip(tooltip, damagePattern);

	-- cast time
	local castTimePattern = "(.+) sec cast";
	local castTime = 0;
	local castTimeString = FindTextInTooltip(tooltip, castTimePattern);
	if castTimeString then castTime = tonumber(castTimeString) or 0; end;

	-- cooldown
	local cooldownPattern = "(.+) sec cooldown";
	local cooldown = tonumber(FindTextInTooltip(tooltip, cooldownPattern));

	-- calculcate mana efficiency
	local costPattern = "(%d+) Mana";
	local cost = FindTextInTooltip(tooltip, costPattern);

	-- analyze dat shit
	local result = AnalyzeDamageRangeSpell(damLow, damHigh, castTime, cooldown, SPELL_TREE_ID.FIRE,
		SPELL_POWER_TYPE.MANA,
		cost, coeff);

	-- add line
	tooltip:AddLine("\n");
	AddDamageRangeAnalysis(tooltip, result);
	AddPowerAnalysis(tooltip, { range = result });
end;
