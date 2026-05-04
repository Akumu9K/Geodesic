-- Main Functions:

function entrypointwrapper(str, recursion_check)
    local recursion_limit = 1
    if recursion_check == nil then recursion_check = 0 end
    if recursion_check > recursion_limit then error("Recursive function call detected, halting importation", 100) end

    local result, type = formatfinder(str, recursion_check)
    return result, type
end

function formatfinder(str, recursion_check)
    -- Hexparty Json
    local success, result, type = pcall(hexpartyjsonhandler, str)
    if success and #result > 0 then
        return result, type
    end
    -- Hextweaks Lua Table
    local success, result, type = pcall(hextweakstablehandler, str)
    if success and #result > 0 then
        return result, type
    end
    -- HexAssembly
    local type = "HexAssembly"
    if string.find(str, "%<MAIN%>:") then
        return hexpattoanglesig(hexassemble(str), recursion_check), type
    end
    -- .hexpattern
    local type = ".hexpattern"
    local result = hexpattoanglesig(str, recursion_check)
    if #result > 0 then
        return result, type
    end
    -- Hexparse
    local type = "HexParse"
    local result = hexparsetoanglesig(str, recursion_check)
    if #result > 0 then
        return result, type
    end
    -- No Format Found:
    error("Unknown format, or malformed/unimportable file", 100)
end

-- Format Handlers:

-- TODO: Make more complex checks, these can be fooled sometimes

-- HexParty Json:

function hexpartyjsonhandler(str)
    local format_type = "Hexparty Json"
    local result = {}
    local placeholder = {dir = "EAST", anglesig = "", ishexpattern = true}

    local success, table = pcall(parseJson, str)
    if not success then
        error("Format is not hexparty json")
        return
    end
    if #table <= 0 then
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