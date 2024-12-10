-- global data
BONUS_SPELL_INFO = {}
BONUS_SPELL_INFO.FUN = {} -- contains keys associated with spell names

-- simplifies finding text in a tooltip
-- this may be super unnecessary
-- also stores last/current tooltip region data to avoid unnecessary work in the same call
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
        -- this is meant to filter out spellbook tooltips
        -- spellbook entries don't show their rank in the tooltip
        -- not sure if there's a better way
        local rank = select(4, tooltip:GetRegions())
        local text = rank:GetText()
        --if text == nil then return end

        -- add bonus spell info to the tooltip!
        BONUS_SPELL_INFO.FUN[name](tooltip)
    end
    --[[local regions = GameTooltip:GetRegions()
    for i = 1, select("#", GameTooltip:GetRegions()) do
        local region = select(i, GameTooltip:GetRegions())
        if region and region:GetObjectType() == "FontString" then
            local text = region:GetText() -- string or nil
            if text then
                print(i, text)
            end
        end
    end]]
end

-- hook the game tooltip
GameTooltip:HookScript("OnTooltipSetSpell", TOOLTIP_LISTENER)
