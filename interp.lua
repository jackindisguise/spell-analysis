-- adds some psuedo template string stuff
__ = function(s, tab)
    return (s:gsub('($%b{})', function(w) return tab[w:sub(3, -2)] or w end))
end
