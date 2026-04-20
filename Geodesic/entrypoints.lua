-- Main Functions:

function formatfinder(str)
    -- Hexparty Json
    local success, result, type = pcall(hexpartyjsonhandler, str)
    if success then
        return result, type
    end
    -- Hextweaks Lua Table
    local success, result, type = pcall(hextweakstablehandler, str)
    if success then
        return result, type
    end
    -- .hexpattern
    return hexpattoanglesig(str), nil
end

-- Format Handlers:

function hexpartyjsonhandler(str)
    local format_type = "Hexparty Json"
    local result = {}
    local placeholder = {dir = "EAST", anglesig = "", ishexpattern = true}

    local success, table = pcall(parseJson, str)
    if not success then
        error("Format is not hexparty json")
        return
    end
    if #table >= 0 then
        error("Format is not hexparty json")
        return
    end

    for i, v in ipairs(table) do
        if type(v) ~= "table" then
            result[#result+1] = placeholder
        elseif v["angles"] == nil or v["startDir"] == nil then
            result[#result+1] = placeholder
        else
            local pattern = {ishexpattern = true, anglesig = v["angles"], dir = v["startDir"]}
            result[#result+1] = pattern
        end
    end

    return result, format_type
end

-- Hex Tweaks Table:

function hextweakstablehandler(str)
    local format_type = "Hex Tweaks Table"
    local result = {}
    local placeholder = {dir = "EAST", anglesig = "", ishexpattern = true}

    local table_constructor = "return " .. str
    local table_function = loadstring(table_constructor)
    local success, table = pcall(table_function)
    if not success then
        error("Format is not hex tweaks table")
        return
    end

    for i, v in ipairs(table) do
        if v["angles"] == nil or v["startDir"] == nil then
            result[#result+1] = placeholder
        else
            local pattern = {ishexpattern = true, anglesig = v["angles"], dir = v["startDir"]}
            result[#result+1] = pattern
        end
    end
    return result, format_type
end