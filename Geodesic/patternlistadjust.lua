local touchup_list = {
    ["\\"] = pattern_list["Consideration"],
    ["{"] = pattern_list["Introspection"],
    ["}"] = pattern_list["Retrospection"],
}

-- Init:

function events.entity_init()

for k, v in pairs(touchup_list) do
    pattern_list[k] = v
end

end