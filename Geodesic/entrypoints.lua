-- Main Functions:

function formatfinder(str)
    -- Hexparty Json
    local success, result = pcall(parseJson, str)
    if success then
        return hexpartyjsonhandler(result)
    end
    -- Hextweaks Lua Table
    local success, result = pcall(hextweakstablehandler, str)
    if success then
        return result
    end
    -- .hexpattern
    return hexpattoanglesig(str)
end

-- Format Handlers:

function hexpartyjsonhandler(table)
    local type = "hexpartyjson"
    local result = {}
    local placeholder = {dir = "EAST", anglesig = "", ishexpattern = true}
    for i, v in ipairs(table) do
        if v["angles"] == nil or v["startDir"] == nil then
            result[#result+1] = placeholder
        else
            local pattern = {ishexpattern = true, anglesig = v["angles"], dir = v["startDir"]}
            result[#result+1] = pattern
        end
    end
    return result, type
end

-- Hex Tweaks Table:

function hextweakstablehandler(str)
    local type = "hextweakstable"
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
    return result, type
end