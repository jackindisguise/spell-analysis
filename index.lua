-- global data
BONUS_SPELL_INFO = {}
BONUS_SPELL_INFO.FUN = {} -- contains keys associated with spell names

-- quick reference
-- RGB colors
local RGB = {
    WHITE = { 255, 255, 255 }
}

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
}

-- spell tree IDs
local SPELL_TREE_ID = {
    PHYSICAL = 1,
    HOLY = 2,
    FIRE = 3,
    NATURE = 4,
    FROST = 5,
    SHADOW = 6,
    ARCANE = 7
}

-- spell tree words
local SPELL_TREE_WORD = {
    "Physical",
    "Holy",
    "Fire",
    "Nature",
    "Frost",
    "Shadow",
    "Arcane"
}

-- common colors for spell tree words
local SPELL_TREE_COLOR = {
    COLOR.PHYSICAL,
    COLOR.HOLY,
    COLOR.FIRE,
    COLOR.NATURE,
    COLOR.FROST,
    COLOR.SHADOW,
    COLOR.ARCANE
}

-- common strings
-- i'll figure out how to do this later
local STRING = {
    DEFAULT_PREFIX = " * "
}

-- Iterate through the provided table and add keys for each value that refer to their keys.
-- Basically reverses the dictionary of the table, but retains both in one table.
local ReverseLookupTable = function(t)
    for k, v in pairs(t) do t[v] = k end
    return t
end

-- Analyze spells that do flat damage.
-- Averages the damage per hit based on on the provided damage range.
-- Adds a DPS calculation based on the average damage and cast time/cooldown.
local AddDamageAnalysis = function(tooltip, damage, delayTime, spellTreeID, coeff, prefix)
    local spellTreeWord = SPELL_TREE_WORD[spellTreeID]
    local spellTreeColor = SPELL_TREE_COLOR[spellTreeID]
    local spellPower = GetSpellBonusDamage(spellTreeID)
    local flatBonus = (spellPower * coeff)
    local flatEmpowered = damage + flatBonus
    tooltip:AddLine("Flat:")
    tooltip:AddLine(
        __(
            "${prefix}Deals ${colorDamage}${damage}${colorReset} ${spellColor}${spellWord}${colorReset} damage.",
            {
                prefix = prefix or STRING.DEFAULT_PREFIX,
                colorDamage = COLOR.DAMAGE,
                damage = string.format("%.1f", flatEmpowered),
                spellColor = spellTreeColor,
                spellWord = spellTreeWord,
                colorReset = COLOR.RESET
            }),
        unpack(RGB.WHITE)
    )
    tooltip:AddLine(
        __(
            "${prefix}Deals ${colorDamage}${damage}${colorReset} ${spellColor}${spellWord}${colorReset} damage per second.",
            {
                prefix = prefix or STRING.DEFAULT_PREFIX,
                colorDamage = COLOR.DAMAGE,
                damage = string.format("%.1f", flatEmpowered / delayTime),
                spellColor = spellTreeColor,
                spellWord = spellTreeWord,
                colorReset = COLOR.RESET
            }),
        unpack(RGB.WHITE)
    )
    if spellPower > 0 then
        tooltip:AddLine(
            __(
                "${prefix}${spellColor}${spellPower} ${spellWord}${colorReset} spell power added ${flatBonus} bonus damage.",
                {
                    prefix = prefix or STRING.DEFAULT_PREFIX,
                    spellPower = spellPower,
                    flatBonus = string.format("%.1f", flatBonus),
                    colorDamage = COLOR.DAMAGE,
                    spellColor = spellTreeColor,
                    spellWord = spellTreeWord,
                    colorReset = COLOR.RESET
                }),
            unpack(RGB.WHITE)
        )
    end
end

-- Analyze spells that do damage in a range.
-- Averages the damage per hit based on on the provided damage range.
-- Adds a DPS calculation based on the average damage and cast time/cooldown.
local AddDamageRangeAnalysis = function(tooltip, low, high, delayTime, spellTreeID, coeff, prefix)
    local spellTreeWord = SPELL_TREE_WORD[spellTreeID]
    local spellTreeColor = SPELL_TREE_COLOR[spellTreeID]
    local spellPower = GetSpellBonusDamage(spellTreeID)
    local flatAverage = (low + high) / 2
    local flatBonus = (spellPower * coeff)
    local flatEmpowered = flatAverage + flatBonus
    tooltip:AddLine("Range:")
    tooltip:AddLine(
        __(
            "${prefix}Deals ${colorDamage}${damage}${colorReset} ${spellColor}${spellWord}${colorReset} damage on average.",
            {
                prefix = prefix or STRING.DEFAULT_PREFIX,
                colorDamage = COLOR.DAMAGE,
                damage = string.format("%.1f", flatEmpowered),
                spellColor = spellTreeColor,
                spellWord = spellTreeWord,
                colorReset = COLOR.RESET
            }),
        unpack(RGB.WHITE)
    )
    tooltip:AddLine(
        __(
            "${prefix}Deals ${colorDamage}${damage}${colorReset} ${spellColor}${spellWord}${colorReset} damage per second.",
            {
                prefix = prefix or STRING.DEFAULT_PREFIX,
                colorDamage = COLOR.DAMAGE,
                damage = string.format("%.1f", flatEmpowered / delayTime),
                spellColor = spellTreeColor,
                spellWord = spellTreeWord,
                colorReset = COLOR.RESET
            }),
        unpack(RGB.WHITE)
    )
    if spellPower > 0 then
        tooltip:AddLine(
            __(
                "${prefix}${spellColor}${spellPower} ${spellWord}${colorReset} spell power added ${flatBonus} bonus damage.",
                {
                    prefix = prefix or STRING.DEFAULT_PREFIX,
                    spellPower = spellPower,
                    flatBonus = string.format("%.1f", flatBonus),
                    colorDamage = COLOR.DAMAGE,
                    spellColor = spellTreeColor,
                    spellWord = spellTreeWord,
                    colorReset = COLOR.RESET
                }),
            unpack(RGB.WHITE)
        )
    end
end

-- Analyze spells that do damage over time.
-- Adds a DPS calculation based on the damage and cast time/duration of the spell/cooldown.
local AddDamageOverTimeAnalysis = function(tooltip, damage, castTime, duration, ticks, spellTreeID, coeff, prefix)
    local spellTreeWord = SPELL_TREE_WORD[spellTreeID]
    local spellTreeColor = SPELL_TREE_COLOR[spellTreeID]
    local spellPower = GetSpellBonusDamage(spellTreeID)
    local delayTime = castTime + duration
    local dotBonus = (spellPower * coeff * ticks)
    local dotEmpowered = damage + dotBonus
    tooltip:AddLine("DoT:")
    tooltip:AddLine(
        __("${prefix}Deals ${colorDamage}${damage}${colorReset} total ${spellColor}${spellWord}${colorReset} damage.",
            {
                prefix = prefix or STRING.DEFAULT_PREFIX,
                colorDamage = COLOR.DAMAGE,
                damage = dotEmpowered,
                spellColor = spellTreeColor,
                spellWord = spellTreeWord,
                colorReset = COLOR.RESET
            }),
        unpack(RGB.WHITE)
    )
    tooltip:AddLine(
        __("${prefix}Deals ${colorDamage}${damage}${colorReset} ${spellColor}${spellWord}${colorReset} damage per tick.",
            {
                prefix = prefix or STRING.DEFAULT_PREFIX,
                colorDamage = COLOR.DAMAGE,
                damage = string.format("%.1f", dotEmpowered / ticks),
                spellColor = spellTreeColor,
                spellWord = spellTreeWord,
                colorReset = COLOR.RESET
            }),
        unpack(RGB.WHITE)
    )
    tooltip:AddLine(
        __("${prefix}Ticks once every ${tickDelay} seconds.",
            {
                prefix = prefix or STRING.DEFAULT_PREFIX,
                tickDelay = duration / ticks
            }),
        unpack(RGB.WHITE)
    )
    tooltip:AddLine(
        __(
            "${prefix}Deals ${colorDamage}${damage}${colorReset} ${spellColor}${spellWord}${colorReset} damage per second.",
            {
                prefix = prefix or STRING.DEFAULT_PREFIX,
                colorDamage = COLOR.DAMAGE,
                damage = string.format("%.1f", dotEmpowered / duration),
                spellColor = spellTreeColor,
                spellWord = spellTreeWord,
                colorReset = COLOR.RESET
            }),
        unpack(RGB.WHITE)
    )
    if spellPower > 0 then
        tooltip:AddLine(
            __(
                "${prefix}${spellColor}${spellPower} ${spellWord}${colorReset} spell power added ${dotBonus} bonus damage.",
                {
                    prefix = prefix or STRING.DEFAULT_PREFIX,
                    spellPower = spellPower,
                    dotBonus = string.format("%.1f", dotBonus),
                    colorDamage = COLOR.DAMAGE,
                    spellColor = spellTreeColor,
                    spellWord = spellTreeWord,
                    colorReset = COLOR.RESET
                }),
            unpack(RGB.WHITE)
        )
    end
end

local AddHybridDamageAnalysis = function(tooltip, immediate, dot, castTime, duration, ticks, spellTreeID, immediateCoeff,
                                         dotCoeff,
                                         prefix)
    local spellTreeWord = SPELL_TREE_WORD[spellTreeID]
    local spellTreeColor = SPELL_TREE_COLOR[spellTreeID]
    local spellPower = GetSpellBonusDamage(spellTreeID)
    local delayTime = castTime + duration
    local immediateBonus = (spellPower * immediateCoeff)
    local immediateEmpowered = immediate + immediateBonus
    local dotBonus = (spellPower * dotCoeff * ticks)
    local dotEmpowered = dot + dotBonus
    local combinedBonus = immediateBonus + dotBonus
    local combined = immediateEmpowered + dotEmpowered
    tooltip:AddLine("Hybrid:")
    tooltip:AddLine(
        __("${prefix}Deals ${colorDamage}${damage}${colorReset} combined ${spellColor}${spellWord}${colorReset} damage.",
            {
                prefix = prefix or STRING.DEFAULT_PREFIX,
                colorDamage = COLOR.DAMAGE,
                damage = combined,
                spellColor = spellTreeColor,
                spellWord = spellTreeWord,
                colorReset = COLOR.RESET
            }),
        unpack(RGB.WHITE)
    )
    tooltip:AddLine(
        __(
            "${prefix}Deals ${colorDamage}${damage}${colorReset} ${spellColor}${spellWord}${colorReset} damage per second.",
            {
                prefix = prefix or STRING.DEFAULT_PREFIX,
                colorDamage = COLOR.DAMAGE,
                damage = math.floor(combined / delayTime),
                spellColor = spellTreeColor,
                spellWord = spellTreeWord,
                colorReset = COLOR.RESET
            }),
        unpack(RGB.WHITE)
    )
    if spellPower > 0 then
        tooltip:AddLine(
            __(
                "${prefix}${spellColor}${spellPower} ${spellWord}${colorReset} spell power added ${combinedBonus} bonus damage.",
                {
                    prefix = prefix or STRING.DEFAULT_PREFIX,
                    spellPower = spellPower,
                    combinedBonus = string.format("%.1f", combinedBonus),
                    colorDamage = COLOR.DAMAGE,
                    spellColor = spellTreeColor,
                    spellWord = spellTreeWord,
                    colorReset = COLOR.RESET
                }),
            unpack(RGB.WHITE)
        )
    end
    AddDamageAnalysis(tooltip, immediate, castTime, spellTreeID, immediateCoeff, prefix)
    AddDamageOverTimeAnalysis(tooltip, dot, castTime, duration, ticks, spellTreeID, dotCoeff, prefix)
end

local AddManaAnalysis = function(tooltip, cost, damage, prefix)
    tooltip:AddLine("Mana:")
    tooltip:AddLine(
        __("${prefix}Costs ${colorMana}${cost}${colorReset} per point of damage.", {
            prefix = prefix or STRING.DEFAULT_PREFIX,
            colorMana = COLOR.MANA,
            cost = string.format("%.2f mana", cost / damage),
            colorReset = COLOR.RESET
        }),
        255,
        255, 255)
    tooltip:AddLine(
        __("${prefix}Spell has ${colorMana}${cost}%${colorReset} mana efficiency.", {
            prefix = prefix or STRING.DEFAULT_PREFIX,
            colorMana = COLOR.MANA,
            cost = string.format("%.2f", (1 - ((cost / damage) - 1)) * 100),
            colorReset = COLOR.RESET
        }),
        255,
        255, 255)
end

-- simplifies finding text in a tooltip
-- this may be super unnecessary
-- also stores last tooltip region data to avoid unnecessary work in the same call
local lastTooltip, lastTooltipRegions = nil, {}
local FindTextInTooltip = function(tooltip, pattern)
    -- handle saved region data
    local regions
    if lastTooltip == tooltip then
        regions = lastTooltipRegions
    else -- generate new regions
        regions = { tooltip:GetRegions() }
        lastTooltip = tooltip
        lastTooltipRegions = regions
    end

    -- iterate over regions with text
    for k, v in pairs(regions) do
        if v and v:GetObjectType() == "FontString" then
            local text = v:GetText()
            if text then
                -- check for matches and return them
                local result = { string.match(v:GetText(), pattern) }
                if result[1] then
                    return unpack(result)
                end
            end
        end
    end
end

-- throw-away listener frame
local listener = CreateFrame("Frame");

-- listen for tooltip generation
-- adds spell analysis for spells!
local TOOLTIP_LISTENER = function(tooltip)
    local name, _id = tooltip:GetSpell()
    if BONUS_SPELL_INFO.FUN[name] then
        -- add bonus spell info to the tooltip!
        BONUS_SPELL_INFO.FUN[name](tooltip)
    end
end

-- hook the game tooltip
GameTooltip:HookScript("OnTooltipSetSpell", TOOLTIP_LISTENER)

-- export common tables
BONUS_SPELL_INFO.RGB                       = RGB
BONUS_SPELL_INFO.COLOR                     = COLOR
BONUS_SPELL_INFO.SPELL_TREE_ID             = SPELL_TREE_ID
BONUS_SPELL_INFO.SPELL_TREE_WORD           = SPELL_TREE_WORD
BONUS_SPELL_INFO.SPELL_TREE_COLOR          = SPELL_TREE_COLOR
BONUS_SPELL_INFO.STRING                    = STRING

-- export useful functions
BONUS_SPELL_INFO.FindTextInTooltip         = FindTextInTooltip
BONUS_SPELL_INFO.ReverseLookupTable        = ReverseLookupTable

-- export analysis and display functions
BONUS_SPELL_INFO.AddDamageAnalysis         = AddDamageAnalysis
BONUS_SPELL_INFO.AddDamageRangeAnalysis    = AddDamageRangeAnalysis
BONUS_SPELL_INFO.AddDamageOverTimeAnalysis = AddDamageOverTimeAnalysis
BONUS_SPELL_INFO.AddHybridDamageAnalysis   = AddHybridDamageAnalysis
BONUS_SPELL_INFO.AddManaAnalysis           = AddManaAnalysis
