-- spell name
local SPELL_NAME               = "Attack";

-- local alias
local SPELL_TREE_ID            = SPELL_ANALYSIS.SPELL_TREE_ID;
local SPELL_POWER_TYPE         = SPELL_ANALYSIS.SPELL_POWER_TYPE;
local AnalyzeDamageRangeSpell  = SPELL_ANALYSIS.AnalyzeDamageRangeSpell;
local AddDamageRangeAnalysis   = SPELL_ANALYSIS.AddDamageRangeAnalysis;

-- listener for this spell
SPELL_ANALYSIS.FUN[SPELL_NAME] = function(tooltip)
	-- calculate damage
	local lowDmg, hiDmg, offLow, offHigh = UnitDamage("player");
	local speed, speedOff = UnitAttackSpeed("player");

	-- add line
	tooltip:AddLine("\n");

	-- analyze dat shit
	local mainResult = AnalyzeDamageRangeSpell(lowDmg, hiDmg, speed, 0, SPELL_TREE_ID.PHYSICAL, nil, 0, 0);
	AddDamageRangeAnalysis(tooltip, mainResult);

	if speedOff then
		local offResult = AnalyzeDamageRangeSpell(offLow, offHigh, speedOff, 0, SPELL_TREE_ID.PHYSICAL, nil, 0, 0);
		AddDamageRangeAnalysis(tooltip, offResult);
	end;
end;
