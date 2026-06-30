-- VERY Work in progress, still need to implement special handlers, 
-- and will probably need to switch the structure entirely to somewhat of a copy of hexpattoanglesig.lua
-- In order to have specific custom syntax and such.

-- Main Functions:

function hexparsetrimmed(str)
    -- Replace intro retro
    str = string.gsub(str, "%)", ",close_paren,")
    str = string.gsub(str, "%(", ",open_paren,")
    -- Remove comments
    str = string.gsub(str, "comment_[^%s\n\r]*", "")
    str = string.gsub(str, "//[^\n\r]*", "")
    str = string.gsub(str, "/%*.-%*/", "")
    -- Remove whitespaces and newlines
    str = string.gsub(str, "\n", ",")
    str = string.gsub(str, "\r", ",")
    str = string.gsub(str, "%s", "")
    -- Split apart the string
    local str_list = stringsplitter(str, ",")
    -- Get rid of empty strings
    for i, v in ipairs(str_list) do
        if v == "" then
            str_list[i] = nil
        end
    end
    str_list = tablecompresser(str_list)
    -- Trim everything that remains
    for i, v in ipairs(str_list) do
        str_list[i] = trim(v)
    end

    return str_list
end

function replaceids(list)
    for i, v in ipairs(list) do
        local match = id_list[trim(v)]
        if match ~= nil then
            list[i] = match
        elseif match == nil then
            local spechandlerresult = hexparsespecialhandler(trim(v))
            if spechandlerresult ~= nil then
                list[i] = spechandlerresult
            end
        end
    end
    return list
end

function hexparsetoanglesig(hexparse, recursion_check)
    --[[
    local recursion_limit = 1
    if recursion_check == nil then recursion_check = 0 end
    if recursion_check > recursion_limit then error("Recursive function call detected, halting importation", 100) end
    ]]

    local string_processed = replaceids(hexparsetrimmed(hexparse))
    local anglesig_tabled = hextrimmedtopatterns(string_processed, recursion_check)
    return anglesig_tabled
end

-- Constants:

id_list = {}
for k, v in pairs(pattern_list) do
    if v["id"] ~= nil then
        id_list[v["id"]] = v
    end
end