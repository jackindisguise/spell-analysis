-- spell name
local SPELL_NAME               = "Lightning Bolt";

-- local alias
local FindTextInTooltip        = SPELL_ANALYSIS.FindTextInTooltip;
local SPELL_TREE_ID            = SPELL_ANALYSIS.SPELL_TREE_ID;
local SPELL_POWER_TYPE         = SPELL_ANALYSIS.SPELL_POWER_TYPE;
local ReverseLookupTable       = SPELL_ANALYSIS.ReverseLookupTable;
local AnalyzeDamageRangeSpell  = SPELL_ANALYSIS.AnalyzeDamageRangeSpell;
local AddDamageRangeAnalysis   = SPELL_ANALYSIS.AddDamageRangeAnalysis;
local AddPowerAnalysis         = SPELL_ANALYSIS.AddPowerAnalysis;

-- spell stuff
local SPELL_ID                 = ReverseLookupTable({ 403, 529, 548, 915, 943, 6041, 10391, 10392, 15207, 15208 });
local RANK_COEFF_TABLE         = { 0.123, 0.314, 0.554, 0.857, 0.857, 0.857, 0.857, 0.857, 0.857, 0.857 };

-- listener for this spell
SPELL_ANALYSIS.FUN[SPELL_NAME] = function(tooltip)
	-- hard data
	local name, id = tooltip:GetSpell();
	local spellRank = SPELL_ID[id];
	local coeff = RANK_COEFF_TABLE[spellRank];

	-- calculate damage
	local damagePattern =
	"Casts a bolt of lightning at the target for (%d+) to (%d+) Nature damage.";
	local damLow, damHigh = FindTextInTooltip(tooltip, damagePattern);

	-- cast time
	local castTimePattern = "(.+) sec cast";
	local castTime = tonumber(FindTextInTooltip(tooltip, castTimePattern));

	-- calculcate mana efficiency
	local costPattern = "(%d+) Mana";
	local cost = FindTextInTooltip(tooltip, costPattern);

	-- analyze dat shit
	local result = AnalyzeDamageRangeSpell(damLow, damHigh, castTime, 0, SPELL_TREE_ID.NATURE, SPELL_POWER_TYPE.MANA,
		cost, coeff);

	-- add line
	tooltip:AddLine("\n");
	AddDamageRangeAnalysis(tooltip, result);
	AddPowerAnalysis(tooltip, { range = result });
end;
