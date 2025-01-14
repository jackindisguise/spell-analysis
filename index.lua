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
