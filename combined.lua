local GCD = select(2, UnitClass("player")) == "ROGUE" and 1 or 1.5;

-- Iterate through the provided table and add keys for each value that refer to their keys.
-- Basically reverses the dictionary of the table, but retains both in one table.
local ReverseLookupTable = function(t)
	for k, v in pairs(t) do t[v] = k; end;
	return t;
end;

-- quick reference
-- RGB colors
local RGB = {
	WHITE = { 1, 1, 1 }
};

-- common color words
local COLOR = {
	-- power colors
	MANA     = "|cFF60A0FF",
	ENERGY   = "|cFFFFFF40",

	-- spell trees
	PHYSICAL = "|cFFDAF7A6",
	HOLY     = "|cFFf9e79f",
	FIRE     = "|cFFFFA500",
	NATURE   = "|cFF2ecc71",
	FROST    = "|cFF3498db",
	SHADOW   = "|cFFA000A0",
	ARCANE   = "|cFFbb8fce",

	-- etc
	DAMAGE   = "|cFFFF4040",

	-- reset colors
	RESET    = "|r"
};

-- spell tree IDs
local SPELL_TREE_ID = {
	PHYSICAL = 1,
	HOLY = 2,
	FIRE = 3,
	NATURE = 4,
	FROST = 5,
	SHADOW = 6,
	ARCANE = 7
};

-- spell tree words
local SPELL_TREE_WORD = {
	"Physical",
	"Holy",
	"Fire",
	"Nature",
	"Frost",
	"Shadow",
	"Arcane"
};

local SPELL_TREE_WORD2ID = ReverseLookupTable(SPELL_TREE_WORD);

-- common colors for spell tree words
local SPELL_TREE_COLOR = {
	COLOR.PHYSICAL,
	COLOR.HOLY,
	COLOR.FIRE,
	COLOR.NATURE,
	COLOR.FROST,
	COLOR.SHADOW,
	COLOR.ARCANE
};

SPELL_TREE_COLOR[0] = COLOR.SHADOW;

local SPELL_POWER_TYPE = {
	MANA = 0,
	RAGE = 1,
	FOCUS = 2,
	ENERGY = 3,
	COMBO_POINTS = 4
};

local SPELL_POWER_WORD = {
	"Rage",
	"Focus",
	"Energy",
	"Combo Points"
};
SPELL_POWER_WORD[0] = "Mana";

local SPELL_POWER_COLOR = {
	COLOR.DAMAGE, -- 1
	COLOR.DAMAGE,
	COLOR.ENERGY,
	COLOR.ENERGY
};
SPELL_POWER_COLOR[0] = COLOR.MANA; -- 0

-- common strings
-- i'll figure out how to do this later
local STRING = {
	DEFAULT_PREFIX = " * "
};


-- Display a number as a float with the provided precision, but removes unnecessary 0s from the end.
local ShortFloat = function(n, precision)
	return select(1, string.format("%." .. precision .. "f", n):gsub("%.?[0]+$", ""));
end;

-- Simple templating system for strings that doesn't rely on `string.format()`.
local __ = function(s, tab)
	return (s:gsub('($%b{})', function(w) return tab[w:sub(3, -2)] or w; end));
end;

-- Simplifies finding text in a tooltip.
-- Stores the last tooltip region data to avoid unnecessary work in the same call.
local lastTooltip, lastTooltipRegions = nil, {};
local FindTextInTooltip = function(tooltip, pattern)
	-- iterate over regions with text
	local regions = { tooltip:GetRegions() };
	for k, v in pairs(regions) do
		if v and v:GetObjectType() == "FontString" then
			local text = v:GetText();
			if text then
				-- check for matches and return them
				local result = { string.match(v:GetText(), pattern) };
				if result[1] then
					return unpack(result);
				end;
			end;
		end;
	end;
end;

--- Analyze damage-range-type spells and return the analysis data table.
---@return SpellDamageRangeData data
local AnalyzeDamageRangeSpell = function(low, high, castTime, cooldown, spellTreeID, spellPowerType, spellPowerCost,
										 coeff)
	local actualCooldown = math.max(cooldown, GCD);
	local spellPower = spellTreeID == 0 and 0 or GetSpellBonusDamage(spellTreeID);
	local spellPowerDamage = spellPower * coeff;
	local avg = (low + high) / 2;
	local delayTime = math.max(castTime, actualCooldown);
	local baseDPS = avg / delayTime;
	local empoweredLow = low + spellPowerDamage;
	local empoweredHigh = high + spellPowerDamage;
	local empoweredAvg = (empoweredLow + empoweredHigh) / 2;
	local empoweredDPS = (empoweredAvg) / delayTime;
	return {
		-- basic spell stuff
		castTime = castTime,
		cooldown = actualCooldown,
		delayTime = delayTime,
		spellPowerType = spellPowerType,
		spellPowerCost = spellPowerCost,

		-- basic damage spell stuff
		spellTreeID = spellTreeID,
		coefficient = coeff,
		spellPower = spellPower,
		spellPowerDamage = spellPowerDamage,
		baseDPS = baseDPS,
		empoweredDPS = empoweredDPS,

		-- damage range spell stuff
		low = low,
		empoweredLow = empoweredLow,
		high = high,
		empoweredHigh = empoweredHigh,
		avg = avg,
		empoweredAvg = empoweredAvg
	};
end;

--- Analyze flat-damage-type spells and return the analysis data table.
---@return SpellFlatDamageData data
local AnalyzeFlatDamageSpell = function(damage, castTime, cooldown, spellTreeID, spellPowerType,
										spellPowerCost, coeff)
	local actualCooldown = math.max(cooldown, GCD);
	local spellPower = (spellTreeID == SPELL_TREE_ID.PHYSICAL and UnitAttackPower("player")) or
		GetSpellBonusDamage(spellTreeID);
	local spellPowerDamage = spellPower * coeff;
	local delayTime = math.max(castTime, actualCooldown);
	local baseDPS = damage / delayTime;
	local empoweredDamage = (damage + spellPowerDamage);
	local empoweredDPS = empoweredDamage / delayTime;
	return {
		-- basic spell stuff
		castTime = castTime,
		cooldown = actualCooldown,
		delayTime = delayTime,
		spellPowerType = spellPowerType,
		spellPowerCost = spellPowerCost,

		-- basic damage spell stuff
		spellTreeID = spellTreeID,
		coefficient = coeff,
		spellPower = spellPower,
		spellPowerDamage = spellPowerDamage,
		baseDPS = baseDPS,
		empoweredDPS = empoweredDPS,

		-- flat damage spell stuff
		damage = damage,
		empoweredDamage = empoweredDamage
	};
end;

--- Analyze damage-over-time-type spells and return the analysis data table.
---@return SpellDamageOverTimeData data
local AnalyzeDamageOverTimeSpell = function(damage, duration, ticks, castTime, cooldown, spellTreeID,
											spellPowerType,
											spellPowerCost, coeff)
	local actualCooldown = math.max(cooldown, GCD);
	local spellPower = GetSpellBonusDamage(spellTreeID);
	local spellPowerDamage = spellPower * coeff * ticks;
	local delayTime = math.max(castTime, actualCooldown, duration);
	local baseDPS = damage / delayTime;
	local empoweredDamage = (damage + spellPowerDamage);
	local empoweredDPS = empoweredDamage / delayTime;
	local damagePerTick = damage / ticks;
	local empoweredDamagePerTick = empoweredDamage / ticks;
	return {
		-- basic spell stuff
		castTime = castTime,
		cooldown = actualCooldown,
		delayTime = delayTime,
		spellPowerType = spellPowerType,
		spellPowerCost = spellPowerCost,

		-- basic damage spell stuff
		spellTreeID = spellTreeID,
		coefficient = coeff,
		spellPower = spellPower,
		spellPowerDamage = spellPowerDamage,
		baseDPS = baseDPS,
		empoweredDPS = empoweredDPS,

		-- damage over time spell stuff
		damage = damage,
		empoweredDamage = empoweredDamage,
		damagePerTick = damagePerTick,
		empoweredDamagePerTick = empoweredDamagePerTick,
		duration = duration,
		ticks = ticks
	};
end;

-- Analyze spells that do flat damage.
-- Averages the damage per hit based on on the provided damage range.
-- Adds a DPS calculation based on the average damage and delay time.
-- Also calculcates bonus damage from spell power ("spell bonus damage").
---@param tooltip GameTooltip
---@param data SpellFlatDamageData
local AddDamageAnalysis = function(tooltip, data, prefix, header)
	local spellTreeWord = SPELL_TREE_WORD[data.spellTreeID];
	local spellTreeColor = SPELL_TREE_COLOR[data.spellTreeID];
	if header == true or header == nil then
		tooltip:AddLine("Flat Damage:");
	else
		tooltip:AddLine(header);
	end;
	tooltip:AddLine(
		__(
			"${prefix}Deals ${colorDamage}${damage}${colorReset} ${spellColor}${spellWord}${colorReset} damage.",
			{
				prefix = prefix or STRING.DEFAULT_PREFIX,
				colorDamage = COLOR.DAMAGE,
				damage = ShortFloat(data.empoweredDamage, 1),
				spellColor = spellTreeColor,
				spellWord = spellTreeWord,
				colorReset = COLOR.RESET
			}),
		unpack(RGB.WHITE)
	);
	tooltip:AddLine(
		__(
			"${prefix}Deals ${colorDamage}${damage}${colorReset} ${spellColor}${spellWord}${colorReset} damage per second.",
			{
				prefix = prefix or STRING.DEFAULT_PREFIX,
				colorDamage = COLOR.DAMAGE,
				damage = ShortFloat(data.empoweredDPS, 1),
				spellColor = spellTreeColor,
				spellWord = spellTreeWord,
				colorReset = COLOR.RESET
			}),
		unpack(RGB.WHITE)
	);
	if data.spellPower > 0 then
		tooltip:AddLine(
			__(
				"${prefix}${spellColor}${spellPower} ${spellWord}${colorReset} spell power added ${colorDamage}${flatBonus}${colorReset} damage.",
				{
					prefix = prefix or STRING.DEFAULT_PREFIX,
					spellPower = data.spellPower,
					flatBonus = ShortFloat(data.spellPowerDamage, 1),
					colorDamage = COLOR.DAMAGE,
					spellColor = spellTreeColor,
					spellWord = spellTreeWord,
					colorReset = COLOR.RESET
				}),
			unpack(RGB.WHITE)
		);
		tooltip:AddLine(
			__(
				"${prefix}${spellColor}${spellPower} ${spellWord}${colorReset} spell power added ${colorDamage}${spellPowerBenefit}%${colorReset} damage.",
				{
					prefix = prefix or STRING.DEFAULT_PREFIX,
					spellPower = data.spellPower,
					spellPowerBenefit = ShortFloat(data.spellPowerDamage / data.damage * 100, 2),
					colorDamage = COLOR.DAMAGE,
					spellColor = spellTreeColor,
					spellWord = spellTreeWord,
					colorReset = COLOR.RESET
				}),
			unpack(RGB.WHITE)
		);
	end;
end;

-- Analyze spells that do damage in a range.
-- Averages the damage per hit based on on the provided damage range.
-- Adds a DPS calculation based on the average damage and cast time/cooldown.
---@param tooltip GameTooltip
---@param data SpellDamageRangeData
local AddDamageRangeAnalysis = function(tooltip, data, prefix, header)
	local spellTreeWord = SPELL_TREE_WORD[data.spellTreeID];
	local spellTreeColor = SPELL_TREE_COLOR[data.spellTreeID];
	local spellPower = GetSpellBonusDamage(data.spellTreeID);
	if header == true or header == nil then
		tooltip:AddLine("Damage Range:");
	else
		tooltip:AddLine(header);
	end;
	tooltip:AddLine(
		__(
			"${prefix}${colorDamage}${damage}${colorReset} ${spellColor}${spellWord}${colorReset} damage on average.",
			{
				prefix = prefix or STRING.DEFAULT_PREFIX,
				colorDamage = COLOR.DAMAGE,
				damage = ShortFloat(data.empoweredAvg, 1),
				spellColor = spellTreeColor,
				spellWord = spellTreeWord,
				colorReset = COLOR.RESET
			}),
		unpack(RGB.WHITE)
	);
	if data.empoweredDPS ~= data.empoweredAvg then
		tooltip:AddLine(
			__(
				"${prefix}${colorDamage}${damage}${colorReset} ${spellColor}${spellWord}${colorReset} damage per second.",
				{
					prefix = prefix or STRING.DEFAULT_PREFIX,
					colorDamage = COLOR.DAMAGE,
					damage = ShortFloat(data.empoweredDPS, 1),
					spellColor = spellTreeColor,
					spellWord = spellTreeWord,
					colorReset = COLOR.RESET
				}),
			unpack(RGB.WHITE)
		);
	end;
	if spellPower > 0 then
		tooltip:AddLine(
			__(
				"${prefix}${spellColor}${spellPower} ${spellWord}${colorReset} spell power added ${colorDamage}${flatBonus}${colorReset} damage.",
				{
					prefix = prefix or STRING.DEFAULT_PREFIX,
					spellPower = spellPower,
					flatBonus = ShortFloat(data.spellPowerDamage, 1),
					colorDamage = COLOR.DAMAGE,
					spellColor = spellTreeColor,
					spellWord = spellTreeWord,
					colorReset = COLOR.RESET
				}),
			unpack(RGB.WHITE)
		);
		tooltip:AddLine(
			__(
				"${prefix}${spellColor}${spellPower} ${spellWord}${colorReset} spell power added ${colorDamage}${spellPowerBenefit}%${colorReset} damage.",
				{
					prefix = prefix or STRING.DEFAULT_PREFIX,
					spellPower = spellPower,
					spellPowerBenefit = ShortFloat(data.spellPowerDamage / data.avg * 100, 2),
					colorDamage = COLOR.DAMAGE,
					spellColor = spellTreeColor,
					spellWord = spellTreeWord,
					colorReset = COLOR.RESET
				}),
			unpack(RGB.WHITE)
		);
	end;
end;

-- Analyze spells that do damage over time.
-- Adds a DPS calculation based on the damage and cast time/duration of the spell/cooldown.
---@param tooltip GameTooltip
---@param data SpellDamageOverTimeData
local AddDamageOverTimeAnalysis = function(tooltip, data, prefix, header)
	local spellTreeWord = SPELL_TREE_WORD[data.spellTreeID];
	local spellTreeColor = SPELL_TREE_COLOR[data.spellTreeID];
	local spellPower = GetSpellBonusDamage(data.spellTreeID);
	if header == true or header == nil then
		tooltip:AddLine("Damage over Time:");
	else
		tooltip:AddLine(header);
	end;
	tooltip:AddLine(
		__(
			"${prefix}${colorDamage}${damage}${colorReset} total ${spellColor}${spellWord}${colorReset} damage.",
			{
				prefix = prefix or STRING.DEFAULT_PREFIX,
				colorDamage = COLOR.DAMAGE,
				damage = ShortFloat(data.empoweredDamage, 1),
				spellColor = spellTreeColor,
				spellWord = spellTreeWord,
				colorReset = COLOR.RESET
			}),
		unpack(RGB.WHITE)
	);
	local tickDelay = data.duration / data.ticks;
	tooltip:AddLine(
		__("${prefix}Ticks ${ticks} times, once every ${tickDelay} ${seconds}.",
			{
				prefix = prefix or STRING.DEFAULT_PREFIX,
				ticks = data.ticks,
				tickDelay = tickDelay,
				seconds = tickDelay == 1 and "second" or "seconds"
			}),
		unpack(RGB.WHITE)
	);

	-- don't bother showing this if ticks == duration
	if data.empoweredDPS ~= data.empoweredDamagePerTick then
		tooltip:AddLine(
			__(
				"${prefix}${colorDamage}${damage}${colorReset} ${spellColor}${spellWord}${colorReset} damage per tick.",
				{
					prefix = prefix or STRING.DEFAULT_PREFIX,
					colorDamage = COLOR.DAMAGE,
					damage = ShortFloat(data.empoweredDamagePerTick, 1),
					spellColor = spellTreeColor,
					spellWord = spellTreeWord,
					colorReset = COLOR.RESET
				}),
			unpack(RGB.WHITE)
		);
	end;


	tooltip:AddLine(
		__(
			"${prefix}${colorDamage}${damage}${colorReset} ${spellColor}${spellWord}${colorReset} damage per second.",
			{
				prefix = prefix or STRING.DEFAULT_PREFIX,
				colorDamage = COLOR.DAMAGE,
				damage = ShortFloat(data.empoweredDPS, 1),
				spellColor = spellTreeColor,
				spellWord = spellTreeWord,
				colorReset = COLOR.RESET
			}),
		unpack(RGB.WHITE)
	);

	if spellPower > 0 then
		tooltip:AddLine(
			__(
				"${prefix}${spellColor}${spellPower} ${spellWord}${colorReset} spell power added ${colorDamage}${dotBonus}${colorReset} damage.",
				{
					prefix = prefix or STRING.DEFAULT_PREFIX,
					spellPower = spellPower,
					dotBonus = ShortFloat(data.spellPowerDamage, 1),
					colorDamage = COLOR.DAMAGE,
					spellColor = spellTreeColor,
					spellWord = spellTreeWord,
					colorReset = COLOR.RESET
				}),
			unpack(RGB.WHITE)
		);
		tooltip:AddLine(
			__(
				"${prefix}${spellColor}${spellPower} ${spellWord}${colorReset} spell power added ${colorDamage}${spellPowerBenefit}%${colorReset} damage.",
				{
					prefix = prefix or STRING.DEFAULT_PREFIX,
					spellPower = spellPower,
					spellPowerBenefit = ShortFloat(data.spellPowerDamage / data.damage * 100, 2),
					colorDamage = COLOR.DAMAGE,
					spellColor = spellTreeColor,
					spellWord = spellTreeWord,
					colorReset = COLOR.RESET
				}),
			unpack(RGB.WHITE)
		);
	end;
end;

-- Analyze spells that do damage over time.
-- Adds a DPS calculation based on the damage and cast time/duration of the spell/cooldown.
---@param tooltip GameTooltip
---@param data SpellMixin
---@param prefix string|nil
---@param header string|nil
local AddAreaDamageAnalysis = function(tooltip, data, prefix, header)
	local something = data.dot or data.flat or data.range; -- dot first is important
	-- this ensures future attempts to access delayTime will find the dot's delayTime
	-- this is important for DPS accuracy
	if not something then return; end;

	-- add individual analysis
	if data.flat then AddDamageAnalysis(tooltip, data.flat, prefix); end;
	if data.range then AddDamageRangeAnalysis(tooltip, data.range, prefix); end;
	if data.dot then AddDamageOverTimeAnalysis(tooltip, data.dot, prefix); end;

	-- add combined analysis
	local spellTreeWord = SPELL_TREE_WORD[something.spellTreeID];
	local spellTreeColor = SPELL_TREE_COLOR[something.spellTreeID];
	local spellPower = something.spellPower;
	local damage = (data.dot and data.dot.damage or 0) + (data.flat and data.flat.damage or 0) +
		(data.range and data.range.avg or 0);
	local empoweredDamage = (data.dot and data.dot.empoweredDamage or 0) + (data.flat and data.flat.empoweredDamage or 0) +
		(data.range and data.range.empoweredAvg or 0);
	local empoweredDPS = (data.dot and data.dot.empoweredDPS or 0) + (data.flat and data.flat.empoweredDPS or 0) +
		(data.range and data.range.empoweredDPS or 0);
	local spellPowerDamage = (data.dot and data.dot.spellPowerDamage or 0) +
		(data.flat and data.flat.spellPowerDamage or 0) +
		(data.range and data.range.spellPowerDamage or 0);
	if header == true or header == nil then
		tooltip:AddLine("AoE:");
	else
		tooltip:AddLine(header);
	end;
	tooltip:AddLine(
		__(
			"${prefix}Deals up to ${colorDamage}${damage}${colorReset} ${spellColor}${spellWord}${colorReset} damage.",
			{
				prefix = prefix or STRING.DEFAULT_PREFIX,
				colorDamage = COLOR.DAMAGE,
				damage = ShortFloat(empoweredDamage * 20, 1),
				spellColor = spellTreeColor,
				spellWord = spellTreeWord,
				colorReset = COLOR.RESET
			}),
		unpack(RGB.WHITE)
	);
	tooltip:AddLine(
		__(
			"${prefix}Deals up to ${colorDamage}${damage}${colorReset} ${spellColor}${spellWord}${colorReset} damage per second.",
			{
				prefix = prefix or STRING.DEFAULT_PREFIX,
				colorDamage = COLOR.DAMAGE,
				damage = ShortFloat(empoweredDPS * 20, 1),
				spellColor = spellTreeColor,
				spellWord = spellTreeWord,
				colorReset = COLOR.RESET
			}),
		unpack(RGB.WHITE)
	);
	if spellPower > 0 then
		tooltip:AddLine(
			__(
				"${prefix}${spellColor}${spellPower} ${spellWord}${colorReset} spell power added ${colorDamage}${flatBonus}${colorReset} damage.",
				{
					prefix = prefix or STRING.DEFAULT_PREFIX,
					spellPower = spellPower,
					flatBonus = ShortFloat(spellPowerDamage, 1),
					colorDamage = COLOR.DAMAGE,
					spellColor = spellTreeColor,
					spellWord = spellTreeWord,
					colorReset = COLOR.RESET
				}),
			unpack(RGB.WHITE)
		);
		tooltip:AddLine(
			__(
				"${prefix}${spellColor}${spellPower} ${spellWord}${colorReset} spell power added ${colorDamage}${spellPowerBenefit}%${colorReset} damage.",
				{
					prefix = prefix or STRING.DEFAULT_PREFIX,
					spellPower = spellPower,
					spellPowerBenefit = ShortFloat(spellPowerDamage / damage * 100, 2),
					colorDamage = COLOR.DAMAGE,
					spellColor = spellTreeColor,
					spellWord = spellTreeWord,
					colorReset = COLOR.RESET
				}),
			unpack(RGB.WHITE)
		);
	end;
end;

---@param tooltip GameTooltip
---@param data SpellMixin
---@param prefix string|nil
local AddHybridDamageAnalysis = function(tooltip, data, prefix, header)
	local something = data.dot or data.flat or data.range; -- dot first is important
	-- this ensures future attempts to access delayTime will find the dot's delayTime
	-- this is important for DPS accuracy
	if not something then return; end;

	-- add individual analysis
	if data.flat then AddDamageAnalysis(tooltip, data.flat, prefix); end;
	if data.range then AddDamageRangeAnalysis(tooltip, data.range, prefix); end;
	if data.dot then AddDamageOverTimeAnalysis(tooltip, data.dot, prefix); end;

	-- add combined analysis
	local spellTreeWord = SPELL_TREE_WORD[something.spellTreeID];
	local spellTreeColor = SPELL_TREE_COLOR[something.spellTreeID];
	local spellPower = something.spellPower;
	local damage = (data.dot and data.dot.damage or 0) + (data.flat and data.flat.damage or 0) +
		(data.range and data.range.avg or 0);
	local empoweredDamage = (data.dot and data.dot.empoweredDamage or 0) + (data.flat and data.flat.empoweredDamage or 0) +
		(data.range and data.range.empoweredAvg or 0);
	local spellPowerDamage = (data.dot and data.dot.spellPowerDamage or 0) +
		(data.flat and data.flat.spellPowerDamage or 0) +
		(data.range and data.range.spellPowerDamage or 0);
	if header == true or header == nil then
		tooltip:AddLine("Combined:");
	else
		tooltip:AddLine(header);
	end;
	tooltip:AddLine(
		__(
			"${prefix}Deals ${colorDamage}${damage}${colorReset} combined ${spellColor}${spellWord}${colorReset} damage.",
			{
				prefix = prefix or STRING.DEFAULT_PREFIX,
				colorDamage = COLOR.DAMAGE,
				damage = ShortFloat(empoweredDamage, 1),
				spellColor = spellTreeColor,
				spellWord = spellTreeWord,
				colorReset = COLOR.RESET
			}),
		unpack(RGB.WHITE)
	);
	tooltip:AddLine(
		__(
			"${prefix}Deals ${colorDamage}${damage}${colorReset} ${spellColor}${spellWord}${colorReset} damage per second.",
			{
				prefix = prefix or STRING.DEFAULT_PREFIX,
				colorDamage = COLOR.DAMAGE,
				damage = ShortFloat(empoweredDamage / something.delayTime, 1),
				spellColor = spellTreeColor,
				spellWord = spellTreeWord,
				colorReset = COLOR.RESET
			}),
		unpack(RGB.WHITE)
	);
	if spellPower > 0 then
		tooltip:AddLine(
			__(
				"${prefix}${spellColor}${spellPower} ${spellWord}${colorReset} spell power added ${colorDamage}${flatBonus}${colorReset} damage.",
				{
					prefix = prefix or STRING.DEFAULT_PREFIX,
					spellPower = spellPower,
					flatBonus = ShortFloat(spellPowerDamage, 1),
					colorDamage = COLOR.DAMAGE,
					spellColor = spellTreeColor,
					spellWord = spellTreeWord,
					colorReset = COLOR.RESET
				}),
			unpack(RGB.WHITE)
		);
		tooltip:AddLine(
			__(
				"${prefix}${spellColor}${spellPower} ${spellWord}${colorReset} spell power added ${colorDamage}${spellPowerBenefit}%${colorReset} damage.",
				{
					prefix = prefix or STRING.DEFAULT_PREFIX,
					spellPower = spellPower,
					spellPowerBenefit = ShortFloat(spellPowerDamage / damage * 100, 2),
					colorDamage = COLOR.DAMAGE,
					spellColor = spellTreeColor,
					spellWord = spellTreeWord,
					colorReset = COLOR.RESET
				}),
			unpack(RGB.WHITE)
		);
	end;
end;

---@param tooltip GameTooltip
---@param data SpellMixin
---@param prefix string|nil
local AddPowerAnalysis = function(tooltip, data, prefix, header)
	local something = data.flat or data.dot or data.range;
	if not something then return; end;
	local spellPowerType = something.spellPowerType;
	local powerTypeWord = SPELL_POWER_WORD[spellPowerType];
	local powerTypeColor = SPELL_POWER_COLOR[spellPowerType];
	local empoweredDamage = (data.dot and data.dot.empoweredDamage or 0) + (data.flat and data.flat.empoweredDamage or 0) +
		(data.range and data.range.empoweredAvg or 0);
	local empoweredDPS = (data.dot and data.dot.empoweredDPS or 0) + (data.flat and data.flat.empoweredDPS or 0) +
		(data.range and data.range.empoweredDPS or 0);
	local damagePerPower = something.spellPowerCost / empoweredDamage;
	local DPSPerPower = something.spellPowerCost / empoweredDPS;
	local powerPerDamage = empoweredDamage / something.spellPowerCost;
	local powerPerDPS = empoweredDPS / something.spellPowerCost;
	if header == true or header == nil then
		tooltip:AddLine("Power:");
	else
		tooltip:AddLine(header);
	end;
	tooltip:AddLine(
		__("${prefix}${powerTypeColor}${cost} ${powerTypeWord}${colorReset} per point of damage.", {
			prefix = prefix or STRING.DEFAULT_PREFIX,
			powerTypeColor = powerTypeColor,
			powerTypeWord = powerTypeWord,
			cost = ShortFloat(damagePerPower, 2),
			colorReset = COLOR.RESET
		}),
		unpack(RGB.WHITE)
	);
	if DPSPerPower ~= damagePerPower then
		tooltip:AddLine(
			__("${prefix}${powerTypeColor}${cost} ${powerTypeWord}${colorReset} per point of DPS.", {
				prefix = prefix or STRING.DEFAULT_PREFIX,
				powerTypeColor = powerTypeColor,
				powerTypeWord = powerTypeWord,
				cost = ShortFloat(DPSPerPower, 2),
				colorReset = COLOR.RESET
			}),
			unpack(RGB.WHITE)
		);
	end;
	tooltip:AddLine(
		__("${prefix}${powerTypeColor}${cost}% ${powerTypeWord}${colorReset} damage efficiency.", {
			prefix = prefix or STRING.DEFAULT_PREFIX,
			powerTypeColor = powerTypeColor,
			powerTypeWord = powerTypeWord,
			cost = ShortFloat(powerPerDamage * 100, 2),
			colorReset = COLOR.RESET
		}),
		unpack(RGB.WHITE)
	);
	tooltip:AddLine(
		__("${prefix}${powerTypeColor}${cost}% ${powerTypeWord}${colorReset} DPS efficiency.", {
			prefix = prefix or STRING.DEFAULT_PREFIX,
			powerTypeColor = powerTypeColor,
			powerTypeWord = powerTypeWord,
			cost = ShortFloat(powerPerDPS * 100, 2),
			colorReset = COLOR.RESET
		}),
		unpack(RGB.WHITE)
	);
end;

-- throw-away listener frame
local listener = CreateFrame("Frame");

-- listen for tooltip generation
-- adds spell analysis for spells!
local TOOLTIP_LISTENER = function(tooltip)
	local name, _id = tooltip:GetSpell();
	if SPELL_ANALYSIS.FUN[name] then
		-- add bonus spell info to the tooltip!
		SPELL_ANALYSIS.FUN[name](tooltip);
	end;
end;

-- hook the game tooltip
GameTooltip:HookScript("OnTooltipSetSpell", TOOLTIP_LISTENER);

-- export package
SPELL_ANALYSIS = {};
SPELL_ANALYSIS.FUN = {}; -- contains keys associated with spell names

-- common data
SPELL_ANALYSIS.GCD = GCD;

-- export common tables
SPELL_ANALYSIS.RGB = RGB;
SPELL_ANALYSIS.COLOR = COLOR;
SPELL_ANALYSIS.SPELL_TREE_ID = SPELL_TREE_ID;
SPELL_ANALYSIS.SPELL_TREE_WORD = SPELL_TREE_WORD;
SPELL_ANALYSIS.SPELL_TREE_WORD2ID = SPELL_TREE_WORD2ID;
SPELL_ANALYSIS.SPELL_TREE_COLOR = SPELL_TREE_COLOR;
SPELL_ANALYSIS.SPELL_POWER_TYPE = SPELL_POWER_TYPE;
SPELL_ANALYSIS.SPELL_POWER_COLOR = SPELL_POWER_COLOR;
SPELL_ANALYSIS.STRING = STRING;

-- export useful functions
SPELL_ANALYSIS.FindTextInTooltip = FindTextInTooltip;
SPELL_ANALYSIS.ReverseLookupTable = ReverseLookupTable;
SPELL_ANALYSIS.ShortFloat = ShortFloat;
SPELL_ANALYSIS.__ = __;

-- etc
SPELL_ANALYSIS.AnalyzeFlatDamageSpell = AnalyzeFlatDamageSpell;
SPELL_ANALYSIS.AnalyzeDamageRangeSpell = AnalyzeDamageRangeSpell;
SPELL_ANALYSIS.AnalyzeDamageOverTimeSpell = AnalyzeDamageOverTimeSpell;

-- export analysis and display functions
SPELL_ANALYSIS.AddDamageAnalysis = AddDamageAnalysis;
SPELL_ANALYSIS.AddDamageRangeAnalysis = AddDamageRangeAnalysis;
SPELL_ANALYSIS.AddDamageOverTimeAnalysis = AddDamageOverTimeAnalysis;
SPELL_ANALYSIS.AddAreaDamageAnalysis = AddAreaDamageAnalysis;
SPELL_ANALYSIS.AddHybridDamageAnalysis = AddHybridDamageAnalysis;
SPELL_ANALYSIS.AddPowerAnalysis = AddPowerAnalysis;



---[[
--- taken from etc\attack.lua
---]]
(function()
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

end)();


---[[
--- taken from etc\shoot.lua
---]]
(function()
-- spell name
local SPELL_NAME              = "Shoot";

-- local alias
local SPELL_TREE_WORD2ID      = SPELL_ANALYSIS.SPELL_TREE_WORD2ID;
local SPELL_POWER_TYPE        = SPELL_ANALYSIS.SPELL_POWER_TYPE;
local AnalyzeDamageRangeSpell = SPELL_ANALYSIS.AnalyzeDamageRangeSpell;
local AddDamageRangeAnalysis  = SPELL_ANALYSIS.AddDamageRangeAnalysis;

-- once i figure out how to determine the damage-type of the wands, I'll fix this
-- i tried reallly hard to get this to work in a more elegant way
-- i ended up stealing this off a forum post from like 2012
local tt                      = CreateFrame("GameTooltip", "CAKE", UIParent, "GameTooltipTemplate");
local DamageTypeText          = _G["CAKETextLeft4"];
function GetWandDamageType()
	tt:SetOwner(UIParent, "ANCHOR_NONE");
	local _ = tt:SetInventoryItem("player", 18);
	local n = DamageTypeText:GetText();
	tt:Hide();
	return SPELL_TREE_WORD2ID[string.match(n, "%d+ %- %d+ (.+) Damage")];
end;

-- listener for this spell
SPELL_ANALYSIS.FUN[SPELL_NAME] = function(tooltip)
	-- calculate damage
	local speed, lowDmg, hiDmg = UnitRangedDamage("player");
	if speed == 0 then return; end;

	-- grab the spell tree of this wand using stupid black magic
	local spellTreeID = GetWandDamageType();

	-- add line
	tooltip:AddLine("\n");

	-- analyze dat shit
	local result = AnalyzeDamageRangeSpell(lowDmg, hiDmg, speed, 0, spellTreeID, SPELL_POWER_TYPE.MANA,
		0, 0);

	AddDamageRangeAnalysis(tooltip, result);
end;

end)();


---[[
--- taken from etc\throw.lua
---]]
(function()
-- spell name
local SPELL_NAME               = "Throw";
local SPELL_ALIASES            = { "Shoot Crossbow", "Shoot Bow", "Auto Shot" };

-- local alias
local SPELL_TREE_ID            = SPELL_ANALYSIS.SPELL_TREE_ID;
local SPELL_POWER_TYPE         = SPELL_ANALYSIS.SPELL_POWER_TYPE;
local AnalyzeDamageRangeSpell  = SPELL_ANALYSIS.AnalyzeDamageRangeSpell;
local AddDamageRangeAnalysis   = SPELL_ANALYSIS.AddDamageRangeAnalysis;

-- listener for this spell
SPELL_ANALYSIS.FUN[SPELL_NAME] = function(tooltip)
	-- calculate damage
	local speed, lowDmg, hiDmg = UnitRangedDamage("player");
	if speed == 0 then return; end;

	-- add line
	tooltip:AddLine("\n");

	-- analyze dat shit
	local result = AnalyzeDamageRangeSpell(lowDmg, hiDmg, speed, 0, SPELL_TREE_ID.PHYSICAL, SPELL_POWER_TYPE.MANA,
		0, 0);

	AddDamageRangeAnalysis(tooltip, result);
end;

-- listener for aliases
for k, v in pairs(SPELL_ALIASES) do
	SPELL_ANALYSIS.FUN[v] = SPELL_ANALYSIS.FUN[SPELL_NAME];
end;

end)();


---[[
--- taken from hunter\arcane-shot.lua
---]]
(function()
-- spell name
local SPELL_NAME               = "Arcane Shot";

-- local alias
local FindTextInTooltip        = SPELL_ANALYSIS.FindTextInTooltip;
local SPELL_TREE_ID            = SPELL_ANALYSIS.SPELL_TREE_ID;
local SPELL_POWER_TYPE         = SPELL_ANALYSIS.SPELL_POWER_TYPE;
local ReverseLookupTable       = SPELL_ANALYSIS.ReverseLookupTable;
local AnalyzeFlatDamageSpell   = SPELL_ANALYSIS.AnalyzeFlatDamageSpell;
local AddDamageAnalysis        = SPELL_ANALYSIS.AddDamageAnalysis;
local AddPowerAnalysis         = SPELL_ANALYSIS.AddPowerAnalysis;

-- spell stuff
local SPELL_ID                 = ReverseLookupTable({});
local RANK_COEFF_TABLE         = {}; -- add SP coefficients later

-- listener
SPELL_ANALYSIS.FUN[SPELL_NAME] = function(tooltip)
	-- hard data
	local name, id = tooltip:GetSpell();

	-- calculate damage
	local damagePattern =
	"An instant shot that causes (%d+) Arcane damage.";
	local bonusDamage = FindTextInTooltip(tooltip, damagePattern);

	local baseLow, baseHigh = UnitRangedDamage("player"); -- base weapon range of ranged weapon
	local empoweredLow, empoweredHigh = baseLow + bonusDamage, baseHigh + bonusDamage;

	-- calculcate mana efficiency
	local costPattern = "(%d+) Mana";
	local cost = FindTextInTooltip(tooltip, costPattern);

	-- cast time
	local cooldownPattern = "(.+) sec cooldown";
	local cooldown = tonumber(FindTextInTooltip(tooltip, cooldownPattern));

	-- analyze
	local result = AnalyzeFlatDamageSpell(bonusDamage, 0, cooldown, SPELL_TREE_ID.ARCANE,
		SPELL_POWER_TYPE.MANA, cost, 0);

	-- add line
	tooltip:AddLine("\n");
	AddDamageAnalysis(tooltip, result);
	AddPowerAnalysis(tooltip, { flat = result });
end;

end)();


---[[
--- taken from hunter\raptor-strike.lua
---]]
(function()
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

end)();


---[[
--- taken from hunter\serpent-sting.lua
---]]
(function()
-- spell name
local SPELL_NAME                 = "Serpent Sting";

-- local alias
local FindTextInTooltip          = SPELL_ANALYSIS.FindTextInTooltip;
local SPELL_TREE_ID              = SPELL_ANALYSIS.SPELL_TREE_ID;
local SPELL_POWER_TYPE           = SPELL_ANALYSIS.SPELL_POWER_TYPE;
local ReverseLookupTable         = SPELL_ANALYSIS.ReverseLookupTable;
local AnalyzeDamageOverTimeSpell = SPELL_ANALYSIS.AnalyzeDamageOverTimeSpell;
local AddDamageOverTimeAnalysis  = SPELL_ANALYSIS.AddDamageOverTimeAnalysis;
local AddPowerAnalysis           = SPELL_ANALYSIS.AddPowerAnalysis;

-- spell stuff
local SPELL_ID                   = ReverseLookupTable({});
local RANK_COEFF_TABLE           = {}; -- add SP coefficients later
local TICKS                      = 5;

-- listener for this spell
SPELL_ANALYSIS.FUN[SPELL_NAME]   = function(tooltip)
	-- hard data
	local name, id = tooltip:GetSpell();
	local spellRank = SPELL_ID[id];
	local ticks = TICKS;

	-- calculate damage
	local damagePattern =
	"Stings the target, causing (%d+) Nature damage over (%d+) sec.";
	local DOTDam, DOTDuration = FindTextInTooltip(tooltip, damagePattern);

	-- calculcate mana efficiency
	local costPattern = "(%d+) Mana";
	local cost = FindTextInTooltip(tooltip, costPattern);

	-- do stuff
	local result = AnalyzeDamageOverTimeSpell(DOTDam, DOTDuration, ticks, 0, 0, SPELL_TREE_ID.NATURE,
		SPELL_POWER_TYPE.MANA, cost, 0);

	-- add line
	tooltip:AddLine("\n");
	AddDamageOverTimeAnalysis(tooltip, result);
	AddPowerAnalysis(tooltip, { dot = result });
end;

end)();


---[[
--- taken from mage\arcane-explosion.lua
---]]
(function()
-- spell name
local SPELL_NAME               = "Arcane Explosion";

-- local alias
local FindTextInTooltip        = SPELL_ANALYSIS.FindTextInTooltip;
local SPELL_TREE_ID            = SPELL_ANALYSIS.SPELL_TREE_ID;
local SPELL_POWER_TYPE         = SPELL_ANALYSIS.SPELL_POWER_TYPE;
local ReverseLookupTable       = SPELL_ANALYSIS.ReverseLookupTable;
local AnalyzeDamageRangeSpell  = SPELL_ANALYSIS.AnalyzeDamageRangeSpell;
local AddAreaDamageAnalysis    = SPELL_ANALYSIS.AddAreaDamageAnalysis;
local AddPowerAnalysis         = SPELL_ANALYSIS.AddPowerAnalysis;

-- spell stuff
local SPELL_ID                 = ReverseLookupTable({ 1449, 8437, 8438, 8439, 10201, 10202 });
local COEFF                    = { 0.111, 0.143, 0.143, 0.143, 0.143, 0.143 };

-- listener for this spell
SPELL_ANALYSIS.FUN[SPELL_NAME] = function(tooltip)
	-- hard data
	local name, id = tooltip:GetSpell();
	local spellRank = SPELL_ID[id];
	local coeff = COEFF[spellRank];

	-- calculate damage
	local damagePattern =
	"Causes an explosion of arcane magic around the caster, causing (%d+) to (%d+) Arcane damage";
	local damLow, damHigh = FindTextInTooltip(tooltip, damagePattern);

	-- calculcate mana efficiency
	local costPattern = "(%d+) Mana";
	local cost = FindTextInTooltip(tooltip, costPattern);

	-- do stuff
	local result = AnalyzeDamageRangeSpell(damLow, damHigh, 0, 0, SPELL_TREE_ID.ARCANE,
		SPELL_POWER_TYPE.MANA, cost, coeff);

	-- add line
	tooltip:AddLine("\n");
	AddAreaDamageAnalysis(tooltip, { range = result });
	AddPowerAnalysis(tooltip, { range = result });
end;

end)();


---[[
--- taken from mage\arcane-missiles.lua
---]]
(function()
-- spell name
local SPELL_NAME                 = "Arcane Missiles";

-- local alias
local FindTextInTooltip          = SPELL_ANALYSIS.FindTextInTooltip;
local SPELL_TREE_ID              = SPELL_ANALYSIS.SPELL_TREE_ID;
local SPELL_POWER_TYPE           = SPELL_ANALYSIS.SPELL_POWER_TYPE;
local ReverseLookupTable         = SPELL_ANALYSIS.ReverseLookupTable;
local AnalyzeDamageOverTimeSpell = SPELL_ANALYSIS.AnalyzeDamageOverTimeSpell;
local AddDamageOverTimeAnalysis  = SPELL_ANALYSIS.AddDamageOverTimeAnalysis;
local AddPowerAnalysis           = SPELL_ANALYSIS.AddPowerAnalysis;

-- spell stuff
local SPELL_ID                   = ReverseLookupTable({ 5143, 5144, 5145, 8416, 8417, 10211, 10212, 25345 });
local RANK_COEFF_TABLE           = { 0.132, 0.204, 0.24, 0.24, 0.24, 0.24, 0.24, 0.24 };

-- listener for this spell
SPELL_ANALYSIS.FUN[SPELL_NAME]   = function(tooltip)
	-- hard data
	local name, id = tooltip:GetSpell();
	local spellRank = SPELL_ID[id];
	local coeff = RANK_COEFF_TABLE[spellRank];

	-- calculate damage
	local damagePattern =
	"Launches Arcane Missiles at the enemy, causing (%d+) Arcane damage each second for (%d+) sec.";
	local DOTDam, DOTDuration = FindTextInTooltip(tooltip, damagePattern);

	-- calculcate mana efficiency
	local costPattern = "(%d+) Mana";
	local cost = FindTextInTooltip(tooltip, costPattern);

	-- do stuff
	local result = AnalyzeDamageOverTimeSpell(DOTDam * DOTDuration, DOTDuration, DOTDuration, DOTDuration, 0,
		SPELL_TREE_ID.ARCANE,
		SPELL_POWER_TYPE.MANA, cost, coeff);

	-- add line
	tooltip:AddLine("\n");
	AddDamageOverTimeAnalysis(tooltip, result);
	AddPowerAnalysis(tooltip, { dot = result });
end;

end)();


---[[
--- taken from mage\fire-blast.lua
---]]
(function()
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

end)();


---[[
--- taken from mage\fireball.lua
---]]
(function()
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

end)();


---[[
--- taken from mage\frostbolt.lua
---]]
(function()
-- spell name
local SPELL_NAME               = "Frostbolt";

-- local alias
local FindTextInTooltip        = SPELL_ANALYSIS.FindTextInTooltip;
local SPELL_TREE_ID            = SPELL_ANALYSIS.SPELL_TREE_ID;
local SPELL_POWER_TYPE         = SPELL_ANALYSIS.SPELL_POWER_TYPE;
local ReverseLookupTable       = SPELL_ANALYSIS.ReverseLookupTable;
local AnalyzeDamageRangeSpell  = SPELL_ANALYSIS.AnalyzeDamageRangeSpell;
local AddDamageRangeAnalysis   = SPELL_ANALYSIS.AddDamageRangeAnalysis;
local AddPowerAnalysis         = SPELL_ANALYSIS.AddPowerAnalysis;

-- spell stuff
local SPELL_ID                 = ReverseLookupTable({ 116, 205, 837, 7322, 8406, 8407, 8408, 10179, 10180, 10181, 25304 });
local RANK_COEFF_TABLE         = { 0.163, 0.269, 0.463, 0.706, 0.814, 0.814, 0.814, 0.814, 0.814, 0.814, 0.814 };

-- listener for this spell
SPELL_ANALYSIS.FUN[SPELL_NAME] = function(tooltip)
	-- hard data
	local name, id = tooltip:GetSpell();
	local spellRank = SPELL_ID[id];
	local coeff = RANK_COEFF_TABLE[spellRank];

	-- calculate damage
	local damagePattern =
	"Launches a bolt of frost at the enemy, causing (%d+) to (%d+)  Frost damage";
	local damLow, damHigh = FindTextInTooltip(tooltip, damagePattern);

	-- cast time
	local castTimePattern = "(.+) sec cast";
	local castTime = tonumber(FindTextInTooltip(tooltip, castTimePattern));

	-- calculcate mana efficiency
	local costPattern = "(%d+) Mana";
	local cost = FindTextInTooltip(tooltip, costPattern);

	-- analyze dat shit
	local result = AnalyzeDamageRangeSpell(damLow, damHigh, castTime, 0, SPELL_TREE_ID.FROST, SPELL_POWER_TYPE.MANA,
		cost, coeff);

	-- add line
	tooltip:AddLine("\n");
	AddDamageRangeAnalysis(tooltip, result);
	AddPowerAnalysis(tooltip, { range = result });
end;

end)();


---[[
--- taken from priest\mind-blast.lua
---]]
(function()
-- spell name
local SPELL_NAME               = "Mind Blast";

-- local alias
local FindTextInTooltip        = SPELL_ANALYSIS.FindTextInTooltip;
local SPELL_TREE_ID            = SPELL_ANALYSIS.SPELL_TREE_ID;
local SPELL_POWER_TYPE         = SPELL_ANALYSIS.SPELL_POWER_TYPE;
local ReverseLookupTable       = SPELL_ANALYSIS.ReverseLookupTable;
local AnalyzeDamageRangeSpell  = SPELL_ANALYSIS.AnalyzeDamageRangeSpell;
local AddDamageRangeAnalysis   = SPELL_ANALYSIS.AddDamageRangeAnalysis;
local AddPowerAnalysis         = SPELL_ANALYSIS.AddPowerAnalysis;

-- spell stuff
local SPELL_ID                 = ReverseLookupTable({ 8092, 8102, 8103, 8104, 8105, 8106, 10945, 10946, 10947 });
local RANK_COEFF_TABLE         = { 0.268, 0.364, 0.429, 0.429, 0.429, 0.429, 0.429, 0.429, 0.429 };

-- listener for this spell
SPELL_ANALYSIS.FUN[SPELL_NAME] = function(tooltip)
	-- hard data
	local name, id = tooltip:GetSpell();
	local spellRank = SPELL_ID[id];
	local coeff = RANK_COEFF_TABLE[spellRank];

	-- calculate damage
	local damagePattern =
	"Blasts the target for (%d+) to (%d+) Shadow damage";
	local damLow, damHigh = FindTextInTooltip(tooltip, damagePattern);

	-- cast time
	local castTimePattern = "(.+) sec cast";
	local castTime = tonumber(FindTextInTooltip(tooltip, castTimePattern));

	-- cast time
	local cooldownPattern = "(.+) sec cooldown";
	local cooldown = tonumber(FindTextInTooltip(tooltip, cooldownPattern));

	-- calculcate mana efficiency
	local costPattern = "(%d+) Mana";
	local cost = FindTextInTooltip(tooltip, costPattern);

	-- analyze dat shit
	local result = AnalyzeDamageRangeSpell(damLow, damHigh, castTime, cooldown, SPELL_TREE_ID.SHADOW,
		SPELL_POWER_TYPE.MANA,
		cost, coeff);

	-- add line
	tooltip:AddLine("\n");
	AddDamageRangeAnalysis(tooltip, result);
	AddPowerAnalysis(tooltip, { range = result });
end;

end)();


---[[
--- taken from priest\shadow-word-pain.lua
---]]
(function()
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

end)();


---[[
--- taken from priest\smite.lua
---]]
(function()
-- spell name
local SPELL_NAME               = "Smite";

-- local alias
local FindTextInTooltip        = SPELL_ANALYSIS.FindTextInTooltip;
local SPELL_TREE_ID            = SPELL_ANALYSIS.SPELL_TREE_ID;
local SPELL_POWER_TYPE         = SPELL_ANALYSIS.SPELL_POWER_TYPE;
local ReverseLookupTable       = SPELL_ANALYSIS.ReverseLookupTable;
local AnalyzeDamageRangeSpell  = SPELL_ANALYSIS.AnalyzeDamageRangeSpell;
local AddDamageRangeAnalysis   = SPELL_ANALYSIS.AddDamageRangeAnalysis;
local AddPowerAnalysis         = SPELL_ANALYSIS.AddPowerAnalysis;

-- spell stuff
local SPELL_ID                 = ReverseLookupTable({ 585, 591, 598, 984, 1004, 6060, 10933, 10934 });
local RANK_COEFF_TABLE         = { 0.123, 0.271, 0.554, 0.714, 0.714, 0.714, 0.714, 0.714 };

-- listener for this spell
SPELL_ANALYSIS.FUN[SPELL_NAME] = function(tooltip)
	-- hard data
	local name, id = tooltip:GetSpell();
	local spellRank = SPELL_ID[id];
	local coeff = RANK_COEFF_TABLE[spellRank];

	-- calculate damage
	local damagePattern =
	"Smite an enemy for (%d+) to (%d+) Holy damage.";
	local damLow, damHigh = FindTextInTooltip(tooltip, damagePattern);

	-- cast time
	local castTimePattern = "(.+) sec cast";
	local castTime = tonumber(FindTextInTooltip(tooltip, castTimePattern));

	-- calculcate mana efficiency
	local costPattern = "(%d+) Mana";
	local cost = FindTextInTooltip(tooltip, costPattern);

	-- analyze dat shit
	local result = AnalyzeDamageRangeSpell(damLow, damHigh, castTime, 0, SPELL_TREE_ID.HOLY,
		SPELL_POWER_TYPE.MANA,
		cost, coeff);

	-- add line
	tooltip:AddLine("\n");
	AddDamageRangeAnalysis(tooltip, result);
	AddPowerAnalysis(tooltip, { range = result });
end;

end)();


---[[
--- taken from rogue\backstab.lua
---]]
(function()
-- spell name
local SPELL_NAME               = "Backstab";

-- local alias
local FindTextInTooltip        = SPELL_ANALYSIS.FindTextInTooltip;
local SPELL_TREE_ID            = SPELL_ANALYSIS.SPELL_TREE_ID;
local SPELL_POWER_TYPE         = SPELL_ANALYSIS.SPELL_POWER_TYPE;
local ReverseLookupTable       = SPELL_ANALYSIS.ReverseLookupTable;
local AnalyzeDamageRangeSpell  = SPELL_ANALYSIS.AnalyzeDamageRangeSpell;
local AddDamageRangeAnalysis   = SPELL_ANALYSIS.AddDamageRangeAnalysis;
local AddPowerAnalysis         = SPELL_ANALYSIS.AddPowerAnalysis;

-- spell stuff
local SPELL_ID                 = ReverseLookupTable({ 53, 2589, 2590, 2591, 8721, 11279, 11280, 11281 });
local RANK_DAMAGE_TABLE        = { 15, 30, 48, 69, 90, 135, 165, 210 };

-- listener for this spell
SPELL_ANALYSIS.FUN[SPELL_NAME] = function(tooltip)
	-- hard data
	local name, id = tooltip:GetSpell();
	local spellRank = SPELL_ID[id];
	local bonusDamage = RANK_DAMAGE_TABLE[spellRank];

	-- calculate damage
	local baseLow, baseHigh = UnitDamage("player"); -- base weapon range of main hand
	local empoweredLow, empoweredHigh = baseLow * 1.5 + bonusDamage, baseHigh * 1.5 + bonusDamage;

	-- calculcate energy efficiency
	--local _, _, _, _, rank = GetTalentInfo(COMBAT_TAB, IMPROVED_SINISTER_STRIKE_SLOT)
	--local cost = BASE_ENERGY_COST - (3 * rank) -- -3 energy per level of ISS
	local costPattern = "(%d+) Energy";
	local cost = FindTextInTooltip(tooltip, costPattern);

	-- analyze
	local result = AnalyzeDamageRangeSpell(empoweredLow, empoweredHigh, 0, 0, SPELL_TREE_ID.PHYSICAL,
		SPELL_POWER_TYPE.ENERGY, cost, 0);

	-- add line
	tooltip:AddLine("\n");
	AddDamageRangeAnalysis(tooltip, result);
	AddPowerAnalysis(tooltip, result);
end;

end)();


---[[
--- taken from rogue\eviscerate.lua
---]]
(function()
-- spell name
local SPELL_NAME               = "Eviscerate";

---[[
--- Finishers are gonna be a bitch to implement.
--- They consume energy AND combo points.
--- Annoying.
---]]

-- local alias
local FindTextInTooltip        = SPELL_ANALYSIS.FindTextInTooltip;
local COLOR                    = SPELL_ANALYSIS.COLOR;
local AddDamageRangeAnalysis   = SPELL_ANALYSIS.AddDamageRangeAnalysis;
local AnalyzeDamageRangeSpell  = SPELL_ANALYSIS.AnalyzeDamageRangeSpell;
local AddPowerAnalysis         = SPELL_ANALYSIS.AddPowerAnalysis;
local SPELL_TREE_ID            = SPELL_ANALYSIS.SPELL_TREE_ID;
local SPELL_POWER_TYPE         = SPELL_ANALYSIS.SPELL_POWER_TYPE;
local __                       = SPELL_ANALYSIS.__;
local ShortFloat               = SPELL_ANALYSIS.ShortFloat;

-- spell stuff
local ATTACK_POWER_COEFFICIENT = 0.03; -- 3% bonus damage from attack power

-- listener
SPELL_ANALYSIS.FUN[SPELL_NAME] = function(tooltip)
	local damagePattern = "Finishing move that causes damage per combo point, increased by Attack Power:\r\
%s*1 point%s*: (%d*)-(%d*) damage\r\
%s*2 points*: (%d*)-(%d*) damage\r\
%s*3 points*: (%d*)-(%d*) damage\r\
%s*4 points: (%d*)-(%d*) damage\r\
%s*5 points: (%d*)-(%d*) damage";

	-- calculate average damages
	local oneLow, oneHigh, twoLow, twoHigh, threeLow, threeHigh, fourLow, fourHigh, fiveLow, fiveHigh = FindTextInTooltip(
		tooltip, damagePattern);

	local attackPower, bonusAttackPower = UnitAttackPower("player");
	local totalAttackPower = attackPower + bonusAttackPower;
	local attackPowerDamage = totalAttackPower * ATTACK_POWER_COEFFICIENT;

	local avg = { (oneLow + oneHigh) / 2, (twoLow + twoHigh) / 2, (threeLow + threeHigh) / 2, (fourLow + fourHigh) / 2, (fiveLow + fiveHigh) /
	2 };
	local avgEmpowered = { avg[1] + attackPowerDamage, avg[2] + attackPowerDamage, avg[3] + attackPowerDamage, avg[4] +
	attackPowerDamage, avg[5] + attackPowerDamage };

	-- calculcate energy efficiency
	local costPattern = "(%d+) Energy";
	local cost = FindTextInTooltip(tooltip, costPattern);

	-- add analysis to tooltip
	tooltip:AddLine("\n");
	tooltip:AddLine(__("${attackPower} Attack Power adds ${colorRed}${attackPowerDamage}${colorReset} bonus damage.", {
		colorRed = COLOR.DAMAGE,
		colorReset = COLOR.RESET,
		attackPower = totalAttackPower,
		attackPowerDamage = attackPowerDamage
	}), 255, 255, 255);
	tooltip:AddLine(
		__(
			"${attackPower} Attack Power adds [ ${colorRed}${attackPowerOne}%${colorReset} / ${colorRed}${attackPowerTwo}%${colorReset} / ${colorRed}${attackPowerThree}%${colorReset} / ${colorRed}${attackPowerFour}%${colorReset} / ${colorRed}${attackPowerFive}%${colorReset} ] bonus damage.",
			{
				colorRed = COLOR.DAMAGE,
				colorReset = COLOR.RESET,
				attackPower = totalAttackPower,
				attackPowerOne = ShortFloat(attackPowerDamage / avg[1] * 100, 1),
				attackPowerTwo = ShortFloat(attackPowerDamage / avg[2] * 100, 1),
				attackPowerThree = ShortFloat(attackPowerDamage / avg[3] * 100, 1),
				attackPowerFour = ShortFloat(attackPowerDamage / avg[4] * 100, 1),
				attackPowerFive = ShortFloat(attackPowerDamage / avg[5] * 100, 1),
			}), 255, 255, 255);
	tooltip:AddLine(
		__(
			"Deals [ ${colorRed}${one}${colorReset} / ${colorRed}${two}${colorReset} / ${colorRed}${three}${colorReset} / ${colorRed}${four}${colorReset} / ${colorRed}${five}${colorReset} ] damage on average.",
			{
				colorRed = COLOR.DAMAGE,
				colorReset = COLOR.RESET,
				one = ShortFloat(avgEmpowered[1], 1),
				two = ShortFloat(avgEmpowered[2], 1),
				three = ShortFloat(avgEmpowered[3], 1),
				four = ShortFloat(avgEmpowered[4], 1),
				five = ShortFloat(avgEmpowered[5], 1)
			}), 255, 255, 255, false);
	tooltip:AddLine(
		__(
			"Costs [ ${colorYellow}${one}${colorReset} / ${colorYellow}${two}${colorReset} / ${colorYellow}${three}${colorReset} / ${colorYellow}${four}${colorReset} / ${colorYellow}${five}${colorReset} ] energy per point of damage.",
			{
				colorYellow = COLOR.ENERGY,
				one = ShortFloat(cost / avgEmpowered[1], 1),
				two = ShortFloat(cost / avgEmpowered[2], 1),
				three = ShortFloat(cost / avgEmpowered[3], 1),
				four = ShortFloat(cost / avgEmpowered[4], 1),
				five = ShortFloat(cost / avgEmpowered[5], 1),
				colorReset = COLOR.RESET
			}
		), 255, 255, 255, true);
	tooltip:AddLine(
		__(
			"Spell has [ ${colorYellow}${one}%${colorReset} / ${colorYellow}${two}%${colorReset} / ${colorYellow}${three}%${colorReset} / ${colorYellow}${four}%${colorReset} / ${colorYellow}${five}%${colorReset} ] energy efficiency.",
			{
				colorYellow = COLOR.ENERGY,
				one = ShortFloat(avgEmpowered[1] / cost * 100, 1),
				two = ShortFloat(avgEmpowered[2] / cost * 100, 1),
				three = ShortFloat(avgEmpowered[3] / cost * 100, 1),
				four = ShortFloat(avgEmpowered[4] / cost * 100, 1),
				five = ShortFloat(avgEmpowered[5] / cost * 100, 1),
				colorReset = COLOR.RESET
			}
		), 255, 255, 255, true);

	--[[ test]]
	local analysis = {
		{
			energy = AnalyzeDamageRangeSpell(oneLow, oneHigh, 0, 0, SPELL_TREE_ID.PHYSICAL, SPELL_POWER_TYPE.ENERGY, cost,
				0),
			cp = AnalyzeDamageRangeSpell(oneLow, oneHigh, 0, 0, SPELL_TREE_ID.PHYSICAL, SPELL_POWER_TYPE.COMBO_POINTS, 1,
				0)
		},
		{
			energy = AnalyzeDamageRangeSpell(twoLow, twoHigh, 0, 0, SPELL_TREE_ID.PHYSICAL, SPELL_POWER_TYPE.ENERGY, cost,
				0),
			cp = AnalyzeDamageRangeSpell(twoLow, twoHigh, 0, 0, SPELL_TREE_ID.PHYSICAL, SPELL_POWER_TYPE.COMBO_POINTS, 2,
				0)
		},
		{
			energy = AnalyzeDamageRangeSpell(threeLow, threeHigh, 0, 0, SPELL_TREE_ID.PHYSICAL, SPELL_POWER_TYPE.ENERGY,
				cost, 0),
			cp = AnalyzeDamageRangeSpell(threeLow, threeHigh, 0, 0, SPELL_TREE_ID.PHYSICAL, SPELL_POWER_TYPE
				.COMBO_POINTS, 3,
				0)
		},
		{
			energy = AnalyzeDamageRangeSpell(fourLow, fourHigh, 0, 0, SPELL_TREE_ID.PHYSICAL, SPELL_POWER_TYPE.ENERGY,
				cost, 0),
			cp = AnalyzeDamageRangeSpell(fourLow, fourHigh, 0, 0, SPELL_TREE_ID.PHYSICAL, SPELL_POWER_TYPE.COMBO_POINTS,
				4,
				0)
		},
		{
			energy = AnalyzeDamageRangeSpell(fiveLow, fiveHigh, 0, 0, SPELL_TREE_ID.PHYSICAL, SPELL_POWER_TYPE.ENERGY,
				cost, 0),
			cp = AnalyzeDamageRangeSpell(fiveLow, fiveHigh, 0, 0, SPELL_TREE_ID.PHYSICAL, SPELL_POWER_TYPE.COMBO_POINTS,
				5,
				0)
		}
	};

	--tooltip:AddLine("\n")
	for k, v in pairs(analysis) do
		--        AddDamageRangeAnalysis(tooltip, v.energy, nil, __("${cp} CP:", { cp = k }))
		--AddPowerAnalysis(tooltip, { range = v.energy }, nil, __("${cp} CP:", { cp = k }))
		--AddPowerAnalysis(tooltip, { range = v.cp }, nil, false)
	end;
end;

end)();


---[[
--- taken from rogue\sinister-strike.lua
---]]
(function()
-- spell name
local SPELL_NAME               = "Sinister Strike";

---[[
--- I've kind of realized that there is another way to analyze these spells.
--- You regenerate 10 energy per second.
--- This spell costs 45 energy.
--- That means you can use this spell every 4.5 seconds (though you can use it 2 times instantly).
--- That means its DPS is effectively damage / 4.5.
--- This presents a complex question about certain systems in the game
--- and how they tie into damage analysis, which pisses me off a lot.
---]]

-- local alias
local FindTextInTooltip        = SPELL_ANALYSIS.FindTextInTooltip;
local SPELL_TREE_ID            = SPELL_ANALYSIS.SPELL_TREE_ID;
local SPELL_POWER_TYPE         = SPELL_ANALYSIS.SPELL_POWER_TYPE;
local ReverseLookupTable       = SPELL_ANALYSIS.ReverseLookupTable;
local AnalyzeDamageRangeSpell  = SPELL_ANALYSIS.AnalyzeDamageRangeSpell;
local AddDamageRangeAnalysis   = SPELL_ANALYSIS.AddDamageRangeAnalysis;
local AddPowerAnalysis         = SPELL_ANALYSIS.AddPowerAnalysis;

-- spell stuff
local SPELL_ID                 = ReverseLookupTable({ 1752, 1757, 1758, 1759, 1760, 8621, 11293, 11294 });
local RANK_DAMAGE_TABLE        = { 3, 6, 10, 15, 22, 33, 52, 68 };

-- listener
SPELL_ANALYSIS.FUN[SPELL_NAME] = function(tooltip)
	-- hard data
	local name, id = tooltip:GetSpell();
	local spellRank = SPELL_ID[id];
	local bonusDamage = RANK_DAMAGE_TABLE[spellRank];

	-- calculate damage
	local baseLow, baseHigh = UnitDamage("player"); -- base weapon range of main hand
	local empoweredLow, empoweredHigh = baseLow + bonusDamage, baseHigh + bonusDamage;

	-- calculcate energy efficiency
	--local _, _, _, _, rank = GetTalentInfo(COMBAT_TAB, IMPROVED_SINISTER_STRIKE_SLOT)
	--local cost = BASE_ENERGY_COST - (3 * rank) -- -3 energy per level of ISS
	local costPattern = "(%d+) Energy";
	local cost = FindTextInTooltip(tooltip, costPattern);

	-- analyze
	local result = AnalyzeDamageRangeSpell(empoweredLow, empoweredHigh, 0, 0, SPELL_TREE_ID.PHYSICAL,
		SPELL_POWER_TYPE.ENERGY, cost, 0);

	-- add line
	tooltip:AddLine("\n");
	AddDamageRangeAnalysis(tooltip, result);
	AddPowerAnalysis(tooltip, { range = result });
end;

end)();


---[[
--- taken from shaman\lightning-bolt.lua
---]]
(function()
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

end)();


---[[
--- taken from warlock\corruption.lua
---]]
(function()
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

end)();


---[[
--- taken from warlock\curse-of-agony.lua
---]]
(function()
-- spell name
local SPELL_NAME                 = "Curse of Agony";

-- local alias
local FindTextInTooltip          = SPELL_ANALYSIS.FindTextInTooltip;
local SPELL_TREE_ID              = SPELL_ANALYSIS.SPELL_TREE_ID;
local SPELL_POWER_TYPE           = SPELL_ANALYSIS.SPELL_POWER_TYPE;
local ReverseLookupTable         = SPELL_ANALYSIS.ReverseLookupTable;
local AnalyzeDamageOverTimeSpell = SPELL_ANALYSIS.AnalyzeDamageOverTimeSpell;
local AddDamageOverTimeAnalysis  = SPELL_ANALYSIS.AddDamageOverTimeAnalysis;
local AddPowerAnalysis           = SPELL_ANALYSIS.AddPowerAnalysis;

-- spell stuff
local SPELL_ID                   = ReverseLookupTable({ 980, 1014, 6217, 11711, 11712, 11713 });
local RANK_COEFF_TABLE           = { 0.046, 0.077, 0.083, 0.083, 0.083, 0.083 };
local DOT_TICKS                  = 12;

-- listener for this spell
SPELL_ANALYSIS.FUN[SPELL_NAME]   = function(tooltip)
    -- hard data
    local name, id = tooltip:GetSpell();
    local spellRank = SPELL_ID[id];
    local coeff = RANK_COEFF_TABLE[spellRank];
    local ticks = DOT_TICKS;

    -- calculate damage
    local damagePattern =
    "Curses the target with agony, causing (%d+) Shadow damage over (%d+) sec.";
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

end)();


---[[
--- taken from warrior\heroic-strike.lua
---]]
(function()
-- spell name
local SPELL_NAME               = "Heroic Strike";

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
	"A strong attack that increases melee damage by (%d+) and causes a high amount of threat.";
	local bonusDamage = FindTextInTooltip(tooltip, damagePattern);
	local baseLow, baseHigh = UnitDamage("player"); -- base weapon range of main hand
	local empoweredLow, empoweredHigh = baseLow + bonusDamage, baseHigh + bonusDamage;
	local mainSpeed, offSpeed = UnitAttackSpeed("player");

	-- calculcate energy efficiency
	--local _, _, _, _, rank = GetTalentInfo(COMBAT_TAB, IMPROVED_SINISTER_STRIKE_SLOT)
	--local cost = BASE_ENERGY_COST - (3 * rank) -- -3 energy per level of ISS
	local costPattern = "(%d+) Rage";
	local cost = FindTextInTooltip(tooltip, costPattern);

	-- analyze
	local result = AnalyzeDamageRangeSpell(empoweredLow, empoweredHigh, mainSpeed, 0, SPELL_TREE_ID.PHYSICAL,
		SPELL_POWER_TYPE.RAGE, cost, 0);

	-- add line
	tooltip:AddLine("\n");
	AddDamageRangeAnalysis(tooltip, result);
	AddPowerAnalysis(tooltip, { range = result });
end;

end)();


---[[
--- taken from warlock\drain-life.lua
---]]
(function()
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

end)();


---[[
--- taken from warrior\rend.lua
---]]
(function()
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

end)();


---[[
--- taken from warlock\drain-soul.lua
---]]
(function()
-- spell name
local SPELL_NAME                 = "Drain Soul";

-- local alias
local FindTextInTooltip          = SPELL_ANALYSIS.FindTextInTooltip;
local SPELL_TREE_ID              = SPELL_ANALYSIS.SPELL_TREE_ID;
local SPELL_POWER_TYPE           = SPELL_ANALYSIS.SPELL_POWER_TYPE;
local ReverseLookupTable         = SPELL_ANALYSIS.ReverseLookupTable;
local AnalyzeDamageOverTimeSpell = SPELL_ANALYSIS.AnalyzeDamageOverTimeSpell;
local AddDamageOverTimeAnalysis  = SPELL_ANALYSIS.AddDamageOverTimeAnalysis;
local AddPowerAnalysis           = SPELL_ANALYSIS.AddPowerAnalysis;

-- spell stuff
local SPELL_ID                   = ReverseLookupTable({ 1120, 8288, 8289, 11675 });
local RANK_COEFF_TABLE           = { 0.063, 0.1, 0.1, 0.1 };
local DOT_TICKS                  = 5;

-- listener for this spell
SPELL_ANALYSIS.FUN[SPELL_NAME]   = function(tooltip)
	-- hard data
	local name, id = tooltip:GetSpell();
	local spellRank = SPELL_ID[id];
	local coeff = RANK_COEFF_TABLE[spellRank];
	local ticks = DOT_TICKS;

	-- calculate damage
	local damagePattern =
	"Drains the soul of the target, causing (%d+) Shadow damage over (%d+) sec.";
	local DOTDam, DOTDuration = FindTextInTooltip(tooltip, damagePattern);

	-- calculcate mana efficiency
	local costPattern = "(%d+) Mana";
	local cost = FindTextInTooltip(tooltip, costPattern);

	-- do stuff
	local result = AnalyzeDamageOverTimeSpell(DOTDam, DOTDuration, DOTDuration, DOTDuration, 0, SPELL_TREE_ID.SHADOW,
		SPELL_POWER_TYPE.MANA, cost, coeff);

	-- add line
	tooltip:AddLine("\n");
	AddDamageOverTimeAnalysis(tooltip, result);
	AddPowerAnalysis(tooltip, { dot = result });
end;

end)();


---[[
--- taken from warlock\immolate.lua
---]]
(function()
-- spell name
local SPELL_NAME                 = "Immolate";

-- local alias
local FindTextInTooltip          = SPELL_ANALYSIS.FindTextInTooltip;
local SPELL_TREE_ID              = SPELL_ANALYSIS.SPELL_TREE_ID;
local SPELL_POWER_TYPE           = SPELL_ANALYSIS.SPELL_POWER_TYPE;
local ReverseLookupTable         = SPELL_ANALYSIS.ReverseLookupTable;
local AnalyzeDamageOverTimeSpell = SPELL_ANALYSIS.AnalyzeDamageOverTimeSpell;
local AnalyzeFlatDamageSpell     = SPELL_ANALYSIS.AnalyzeFlatDamageSpell;
local AddHybridDamageAnalysis    = SPELL_ANALYSIS.AddHybridDamageAnalysis;
local AddPowerAnalysis           = SPELL_ANALYSIS.AddPowerAnalysis;

-- RGB values
local WHITE                      = { 1, 1, 1 };

-- spell stuff
local SPELL_ID                   = ReverseLookupTable({ 348, 707, 1094, 2941, 11665, 11667, 11668, 25309 });
local RANK_COEFF_TABLE           = {
	{ FLAT_COEFF = 0.058, DOT_COEFF = 0.037 }, -- rank 1
	{ FLAT_COEFF = 0.125, DOT_COEFF = 0.081 },
	{ FLAT_COEFF = 0.2,   DOT_COEFF = 0.13 },
	{ FLAT_COEFF = 0.2,   DOT_COEFF = 0.13 },
	{ FLAT_COEFF = 0.2,   DOT_COEFF = 0.13 }, -- rank 5
	{ FLAT_COEFF = 0.2,   DOT_COEFF = 0.13 },
	{ FLAT_COEFF = 0.2,   DOT_COEFF = 0.13 },
	{ FLAT_COEFF = 0.2,   DOT_COEFF = 0.13 } -- rank 8
};
local DOT_TICKS                  = 5;

-- listener for this spell
SPELL_ANALYSIS.FUN[SPELL_NAME]   = function(tooltip)
	-- hard data
	local name, id = tooltip:GetSpell();
	local spellRank = SPELL_ID[id];
	local coeffTable = RANK_COEFF_TABLE[spellRank];
	local ticks = DOT_TICKS;

	-- calculate damage
	local damagePattern =
	"Burns the enemy for (%d+) Fire damage and then an additional (%d+) Fire damage over (%d+) sec.";
	local flatDamage, DOTDamage, DOTDuration = FindTextInTooltip(tooltip, damagePattern);

	-- cast time
	local castTimePattern = "(.+) sec cast";
	local castTime = tonumber(FindTextInTooltip(tooltip, castTimePattern));

	-- calculcate mana efficiency
	local costPattern = "(%d+) Mana";
	local cost = FindTextInTooltip(tooltip, costPattern);

	local resultFlat = AnalyzeFlatDamageSpell(flatDamage, castTime, 0, SPELL_TREE_ID.FIRE, SPELL_POWER_TYPE.MANA, cost,
		coeffTable.FLAT_COEFF);

	local resultDOT = AnalyzeDamageOverTimeSpell(DOTDamage, DOTDuration, ticks, castTime, 0, SPELL_TREE_ID.FIRE,
		SPELL_POWER_TYPE.MANA, cost,
		coeffTable.DOT_COEFF);

	-- add line
	tooltip:AddLine("\n");
	AddHybridDamageAnalysis(tooltip, { flat = resultFlat, dot = resultDOT });
	--AddDamageAnalysis(tooltip, resultFlat)
	--AddDamageOverTimeAnalysis(tooltip, resultDOT)
	AddPowerAnalysis(tooltip, { flat = resultFlat, dot = resultDOT });
end;

end)();


---[[
--- taken from warlock\rain-of-fire.lua
---]]
(function()
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

end)();


---[[
--- taken from warlock\searing-pain.lua
---]]
(function()
-- spell name
local SPELL_NAME               = "Searing Pain";

-- local alias
local FindTextInTooltip        = SPELL_ANALYSIS.FindTextInTooltip;
local SPELL_TREE_ID            = SPELL_ANALYSIS.SPELL_TREE_ID;
local SPELL_POWER_TYPE         = SPELL_ANALYSIS.SPELL_POWER_TYPE;
local ReverseLookupTable       = SPELL_ANALYSIS.ReverseLookupTable;
local AnalyzeDamageRangeSpell  = SPELL_ANALYSIS.AnalyzeDamageRangeSpell;
local AddDamageRangeAnalysis   = SPELL_ANALYSIS.AddDamageRangeAnalysis;
local AddPowerAnalysis         = SPELL_ANALYSIS.AddPowerAnalysis;

-- spell stuff
local SPELL_ID                 = ReverseLookupTable({ 5676, 17919, 17920, 17921, 17922, 17923 });
local RANK_COEFF_TABLE         = { 0.396, 0.429, 0.429, 0.429, 0.429, 0.429 };

-- listener for this spell
SPELL_ANALYSIS.FUN[SPELL_NAME] = function(tooltip)
	-- hard data
	local name, id = tooltip:GetSpell();
	local spellRank = SPELL_ID[id];
	local coeff = RANK_COEFF_TABLE[spellRank];

	-- calculate damage
	local damagePattern =
	"Inflict searing pain on the enemy target, causing (%d+) to (%d+) Fire damage.  Causes a high amount of threat.";
	local damLow, damHigh = FindTextInTooltip(tooltip, damagePattern);

	-- cast time
	local castTimePattern = "(.+) sec cast";
	local castTime = tonumber(FindTextInTooltip(tooltip, castTimePattern));

	-- calculcate mana efficiency
	local costPattern = "(%d+) Mana";
	local cost = FindTextInTooltip(tooltip, costPattern);

	-- analyze dat shit
	local result = AnalyzeDamageRangeSpell(damLow, damHigh, castTime, 0, SPELL_TREE_ID.FIRE, SPELL_POWER_TYPE.MANA,
		cost, coeff);

	-- add line
	tooltip:AddLine("\n");
	AddDamageRangeAnalysis(tooltip, result);
	AddPowerAnalysis(tooltip, { range = result });
end;

end)();


---[[
--- taken from warlock\shadow-bolt.lua
---]]
(function()
-- spell name
local SPELL_NAME               = "Shadow Bolt";

-- local alias
local FindTextInTooltip        = SPELL_ANALYSIS.FindTextInTooltip;
local SPELL_TREE_ID            = SPELL_ANALYSIS.SPELL_TREE_ID;
local SPELL_POWER_TYPE         = SPELL_ANALYSIS.SPELL_POWER_TYPE;
local ReverseLookupTable       = SPELL_ANALYSIS.ReverseLookupTable;
local AnalyzeDamageRangeSpell  = SPELL_ANALYSIS.AnalyzeDamageRangeSpell;
local AddDamageRangeAnalysis   = SPELL_ANALYSIS.AddDamageRangeAnalysis;
local AddPowerAnalysis         = SPELL_ANALYSIS.AddPowerAnalysis;

-- spell stuff
local SPELL_ID                 = ReverseLookupTable({ 686, 695, 705, 1088, 1106, 7641, 11659, 11660, 11661, 25307 });
local RANK_COEFF_TABLE         = { 0.14, 0.299, 0.56, 0.857, 0.857, 0.857, 0.857, 0.857, 0.857, 0.857 };

-- listener for this spell
SPELL_ANALYSIS.FUN[SPELL_NAME] = function(tooltip)
	-- hard data
	local name, id = tooltip:GetSpell();
	local spellRank = SPELL_ID[id];
	local coeff = RANK_COEFF_TABLE[spellRank];

	-- calculate damage
	local damagePattern =
	"Sends a shadowy bolt at the enemy, causing (%d+) to (%d+) Shadow damage.";
	local damLow, damHigh = FindTextInTooltip(tooltip, damagePattern);

	-- cast time
	local castTimePattern = "(.+) sec cast";
	local castTime = tonumber(FindTextInTooltip(tooltip, castTimePattern));

	-- calculcate mana efficiency
	local costPattern = "(%d+) Mana";
	local cost = FindTextInTooltip(tooltip, costPattern);

	-- analyze dat shit
	local result = AnalyzeDamageRangeSpell(damLow, damHigh, castTime, 0, SPELL_TREE_ID.SHADOW, SPELL_POWER_TYPE.MANA,
		cost, coeff);

	-- add line
	tooltip:AddLine("\n");
	AddDamageRangeAnalysis(tooltip, result);
	AddPowerAnalysis(tooltip, { range = result });
end;

end)();