-- global data
BONUS_SPELL_INFO = {}
BONUS_SPELL_INFO.FUN = {} -- contains keys associated with spell names

-- quick reference
BONUS_SPELL_INFO.SPELL_BONUS_TREE = {
    PHYSICAL = 1,
    HOLY = 2,
    FIRE = 3,
    NATURE = 4,
    FROST = 5,
    SHADOW = 6,
    ARCANE = 7
}

-- common color words
BONUS_SPELL_INFO.COLOR = {
    -- power colors
    MANA   = "|cFF60A0FF",
    ENERGY = "|cFFFFFF40",

    -- spell trees
    FIRE   = "|cFFFFA500",
    SHADOW = "|cFF808080",

    -- etc
    DAMAGE = "|cFFFF4040",

    -- reset colors
    RESET  = "|r"
}

-- simplifies finding text in a tooltip
-- this may be super unnecessary
-- also stores last tooltip region data to avoid unnecessary work in the same call
local lastTooltip, lastTooltipRegions = nil, nil
BONUS_SPELL_INFO.FindTextInTooltip = function(tooltip, pattern)
    -- handle saved region data
    local regions = nil
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

-- table of spell bonus info functions
local TOOLTIP_LISTENER = function(tooltip)
    local name, _id = tooltip:GetSpell()
    if BONUS_SPELL_INFO.FUN[name] then
        -- add bonus spell info to the tooltip!
        BONUS_SPELL_INFO.FUN[name](tooltip)
    end
end

-- hook the game tooltip
GameTooltip:HookScript("OnTooltipSetSpell", TOOLTIP_LISTENER)
