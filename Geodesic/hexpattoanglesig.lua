-- Main Functions:

function hexpattrimmed(str)
    -- Split apart the lines
    str = stringsplitter(str,"\r")
    if #str <= 1 then
        str = stringsplitter(str[1],"\n")
    end
    -- Trim the excess whitespace (Gets rid of \n too it seems)
    for k, v in pairs(str) do
        str[k] = trim(v)
    end
    -- Get rid of comments and empty spaces
    for k, v in pairs(str) do
        local i, j = string.find(v,"//")
        if i ~= nil then
            str[k] = trim(string.sub(v, 1, i-1))
        end
        if str[k] == "" then
            str[k] = nil
        end
    end
    -- Compess down so no more empty spaces remain
    str = tablecompresser(str)
    -- Replace intro and retro with the relevant names
    for k, v in pairs(str) do
        if v == "{" then
            str[k] = "Introspection"
        elseif v == "}" then
            str[k] = "Retrospection"
        end
    end
    -- Trim once more
    for k, v in pairs(str) do
        str[k] = trim(v)
    end
    return str
end

function hextrimmedtopatterns(str_table, recursion_check)
    local patterns = {}
    for i, v in ipairs(str_table) do
        local resolved_pattern = patternresolver(v, recursion_check)
        if resolved_pattern == nil then
            patterns[#patterns+1] = nil
        elseif resolved_pattern["ismultipleiotas"] == true then
            for l, n in ipairs(resolved_pattern) do
                patterns[#patterns+1] = resolved_pattern[l]
            end
        else
            patterns[#patterns+1] = resolved_pattern
        end
    end
    patterns = tablecompresser(patterns)
    --printTable(patterns)
    return patterns
end

function patternresolver(pattern, recursion_check)
    if recursion_check == nil then recursion_check = 0 end
    --local matched_pattern = pattern_list[v]
    local matched_pattern = patkeymatcher(pattern)
    if matched_pattern == nil then
        local spechandleresult = specialhandlingfinder(pattern)
        if spechandleresult == nil then
            return nil
        else
            return spechandleresult
        end
    elseif matched_pattern ~= nil then
        if matched_pattern["isexternalfunction"] == true then
            local called_function = filereader(matched_pattern["functionlocation"])
            called_function = hexpattoanglesig(called_function, recursion_check + 1)
            called_function["ismultipleiotas"] = true
            return called_function
        elseif matched_pattern["ismultipleiotas"] == true then
            return matched_pattern
        elseif matched_pattern["ishexpattern"] == true then
            return matched_pattern
        else
            return nil
        end
    end
end

function patkeymatcher(value)
    local result = pattern_list[value]
    if result ~= nil then
        return result
    end
    for k, v in pairs(custom_syntax) do
        local match = string.match(value, k)
        if boolcoerce(match) then
            result = v
        end
    end
    return result
end

function hexpattoanglesig(hexpattern, recursion_check)
    local recursion_limit = 1
    if recursion_check == nil then recursion_check = 0 end
    if recursion_check > recursion_limit then error("Recursive function call detected, halting importation", 100) end

    local string_processed = hexpattrimmed(hexpattern)
    local anglesig_tabled = hextrimmedtopatterns(string_processed, recursion_check)
    return anglesig_tabled
end

-- Special Handler Functions:

function specialhandlingfinder(str) -- TODO: Put the special handlers in their own file when its time to handle inline lists
    local fallback_placeholder = {dir = "SOUTH_EAST", anglesig = "dwddwddwwawaaqddq", ishexpattern = true}
    local f, e = nil, nil
    if nonpatiotafinder(str) ~= nil then
        return nonpatiotahandler(str)
    end
    f, e = string.find(str, "Bookkeeper's Gambit:")
    if f ~= nil then
        local bookkeepers = trim(string.sub(str, e+1, -1))
        return bookkeepermaker(bookkeepers)
    end
    f, e = string.find(str, "Numerical Reflection:")
    if f ~= nil then
        local number = trim(string.sub(str, e+1, -1))
        local pre_gen_number = pattern_list[number]
        if pre_gen_number == nil then
            return illegalnumgen(number)
            --return fallback_placeholder
        elseif pre_gen_number ~= nil then
            pre_gen_number["ishexpattern"] = true
            return pre_gen_number
        end
    end
    f, e = string.find(str, "Consideration:")
    if f ~= nil then
        return considerationhandler(trim(string.sub(str, e+1, -1)))
    end
    return nil
end

function bookkeepermaker(str)
    str = trim(str)
    local dir = ""
    local anglesig = ""
    if string.sub(str, 1, 1) == "v" then
        dir = "SOUTH_EAST"
        anglesig = "a"
    elseif string.sub(str, 1, 1) == "-" then
        dir = "EAST"
        anglesig = ""
    end
    local remaining_string = string.sub(str, 2, -1)
    for i = 1, string.len(remaining_string), 1 do
        if string.sub(remaining_string, i, i) == "v" then
            if string.sub(anglesig, -1, -1) == "a" then
                anglesig = anglesig .. "da"
            elseif string.sub(anglesig, -1, -1) == "w" then
                anglesig = anglesig .. "ea"
            else
                anglesig = anglesig .. "ea"
            end
        elseif string.sub(remaining_string, i, i) == "-" then
            if string.sub(anglesig, -1, -1) == "a" then
                anglesig = anglesig .. "e"
            elseif string.sub(anglesig, -1, -1) == "w" then
                anglesig = anglesig .. "w"
            else
                anglesig = anglesig .. "w"
            end
        end
    end
    return {dir = dir, anglesig = anglesig, ishexpattern = true}
end

function illegalnumgen(num)
    local tail = ""
    local return_sig = {dir = "", anglesig = "", ishexpattern = true}
    if string.sub(num, 1, 1) == "-" then
        return_sig["anglesig"] = "dedd"
        return_sig["dir"] = "NORTH_EAST"
        num = string.sub(num, 2, -1)
    elseif string.sub(num, 1, 1)  ~= "-" then
        return_sig["anglesig"] = "aqaa"
        return_sig["dir"] = "SOUTH_EAST"
        num = string.sub(num, 1, -1)
    end
    num = math.abs(num + 0) -- To convert the string to a number
    local mantissa, exponent = floattobinary(num)
    for i = 1, string.len(mantissa), 1 do
        if string.sub(mantissa, i, i) == "1" then
            tail = tail .. "wa"
        elseif string.sub(mantissa, i, i) == "0" then --and i ~= string.len(mantissa)
            tail = tail .. "a"
        end
    end
    local exp_limit = 20000
    if math.abs(exponent) > exp_limit  then -- This is the sneakiest bug I have ever seen, what the fuck.
        exponent = 0
    end
    local exp_mod = (string.len(mantissa) - (exponent - 1))
    for i = 1, exp_mod, 1 do
        tail = tail .. "d"
    end
    return_sig["anglesig"] = return_sig["anglesig"] .. tail
    return return_sig
end

function considerationhandler(pattern)
    local considered_pattern = patternresolver(trim(pattern))
    if considered_pattern == nil then return pattern_list["Consideration"] end
    local result = {ismultipleiotas = true, [1] = pattern_list["Consideration"], [2] = considered_pattern}
    ---[[ -- The hexpattern addon syntax wise, this should never be used, but it exists now I guess.
    if considered_pattern["ismultipleiotas"] == true then
        result[2] = nil
        for l, n in ipairs(considered_pattern) do
            result[#result+1] = considered_pattern[l]
        end
    end
    --]]
    return result
end

function nonpatiotafinder(str)
    str = trim(str)
    return string.match(str,"%<.*%>")
end

function nonpatiotahandler(str)
    --error("Unsupported iota encountered in .hexpattern", 100)
    return {dir = "EAST", anglesig = "", ishexpattern = true}
end

-- Utility Functions:

function stringsplitter(str, splitter)
    local string_list = {}
    for i = 1, 500, 1 do
        local split_start, split_end = string.find(str, splitter)
        if split_start ~= nil then
            string_list[#string_list + 1] = string.sub(str, 1, (split_start - 1))
            str = string.sub(str, (split_end + 1), -1)
        elseif split_start == nil then
            string_list[#string_list + 1] = string.sub(str, 1, -1)
            break
        end
    end
    return string_list
end

function tablecompresser(table)
    local max = 0
    local new_table = {}
    local current_index = 0
    for k, v in pairs(table) do
        if type(k) == "number" then
            max = math.max(max,k)
        end
    end
    for i = 1, max, 1 do
        if table[i] == nil then
            table[i] = "traversable nil"
        end
    end
    for i, v in ipairs(table) do
        if v ~= "traversable nil" then
            current_index = current_index + 1
            new_table[current_index] = v
        end
    end
    return new_table
end

function trim(s) -- What the fuck is this thing. Stack overflow magic istg
    return s:match( "^%s*(.-)%s*$" )
end

function floattobinary(number)
    local exponent = math.floor(math.log(number,2)+1)
    local _, frac = math.modf(number/1)
    for i = 1, 200, 1 do
        if not (frac ~= 0) then break end
        number = number * 2
        _, frac = math.modf(number/1)
    end
    return inttobinary(number), exponent
end

function inttobinary(int)
    int = math.floor(int)
    local number = ""
    for i = 1, 200, 1 do
        if not (int > 0) then break end
        number = tostring(int % 2) .. number
        int = math.floor(int / 2)
    end
    return number
end

function boolcoerce(value)
    return not not value
end

-- Storage:

--[[
{
    [1] = {dir = "EAST", anglesig = "", ishexpattern = true},
    [2] = {dir = "EAST", anglesig = "", ishexpattern = true},
    ["ismultipleiotas"] = true,
    ["n"] = 2,
}

, ismultipleiotas = true, n = 1
]]