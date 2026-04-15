-- Custom Definitions:

local custom_pattern_list = {
    ["EXAMPLE"] = {dir = "EAST", anglesig = "w", ishexpattern = true},
}

local replacement_pattern_list = { -- You can use this to replace any default hexcasting patterns. Not recommended but, exists. For per worlds, use the config.
    
}

local inline_function_list = {
    ["EXAMPLE INLINE FUNCTION"] = {ismultipleiotas = true,
    [1] = pattern_list["Reveal"],
    [2] = pattern_list["Hermes' Gambit"],
    },
}

local external_function_list = {
    ["EXAMPLE EXTERNAL FUNCTION"] = {isexternalfunction = true, functionlocation = "file location goes here, onwards from figura/data"},
}

-- Init:

function events.entity_init()

definition_list = listmerger(custom_pattern_list, replacement_pattern_list, inline_function_list, external_function_list)

for k, v in pairs(definition_list) do
    pattern_list[k] = v
end

end

-- Utility Functions:

function listmerger(...)
    local inputs = {...}
    local result = {}
    for _, v in pairs(inputs) do
        for k, value in pairs(v) do
            result[k] = value
        end
    end
    return result
end