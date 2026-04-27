-- Captures:

local input_capture = "[Ii]nput%s+([^%s]*);"
local constant_capture = "[Cc]onstant%s+([^%s]*)%s*:%s*(%<[^;]*%>);"
local import_capture = "[Ii]mport%s+([^%s]*)%s*:%s*%<%\"([^;]*)%\"%>;"
local function_capture = "[Ff]unction%s+([^%s]*)%s%(%s*i%s*=%s?(%d+)%s*,%s*o%s*=%s?(%d+)%s*,?%s*[Rr]?[Mm]?%s*=%s*([gl]?)%s*%)%s?:%s?%[([^;]*)%];"

local macro_capture = "[Mm]acro%s+([^%s]*)%s*:%s*%[([^;]*)%];"
local embed_capture = "[Ee]mbed%s+([^%s]*)%s*:%s*(%<[^;]*%>);"
local include_capture = "[Ii]nclude%s+([^%s]*)%s*:%s*%<%\"([^;]*)%\"%>;"

-- Internal Macros:

local function_macro = "" .. 
    "Introspection \r\n" ..
    "%s \r\n" .. -- RM Saver
    "%s \r\n" .. -- Function
    "%s \r\n" .. -- RM Saver
    "Retrospection \r\n"

local rm_saver_start = "" ..
    "Numerical Reflection: %d \r\n" ..
    "Flock's Gambit \r\n" ..
    "Muninn's Reflection \r\n" ..
    "Jester's Gambit \r\n" ..
    "Flock's Disintegration \r\n"

local rm_saver_end = "" ..
    "Numerical Reflection: %d \r\n" ..
    "Flock's Gambit \r\n" ..
    "Jester's Gambit \r\n" ..
    "Huginn's Gambit \r\n" ..
    "Flock's Disintegration \r\n"

local macro_embed = "" ..
    "Introspection \r\n" ..
    "%s \r\n" ..
    "Retrospection \r\n"

local iota_embed = "" ..
    "Introspection \r\n" ..
    "%s \r\n" ..
    "Retrospection \r\n" ..
    "Flock's Disintegration \r\n"

local call_init_value = "" ..
    "Flock's Reflection \r\n" ..
    "Numerical Reflection: %d \r\n" ..
    "Subtractive Distillation \r\n" ..
    "Fisherman's Gambit II \r\n"

local spacer = "" ..
    "\r\n" ..
    "%s" ..
    "\r\n"

-- Main Functions:

local function replacecalls(str, call_table, unroll_table)
    for i, v in ipairs(call_table) do
        str = string.gsub(str, "%[" .. v["name"] .. "%]%(%)", string.format(spacer, string.format(call_init_value, i) .. "\r\nHermes' Gambit"))
        str = string.gsub(str, "%[" .. v["name"] .. "%]", string.format(spacer, string.format(call_init_value, i)))
    end
    for i, v in pairs(unroll_table) do
        str = string.gsub(str, "%[" .. v["name"] .. "%]%(%)", string.format(spacer, string.format(v["embed_type"], v["value"]) .. "\r\nHermes' Gambit"))
        str = string.gsub(str, "%[" .. v["name"] .. "%]", string.format(spacer, string.format(v["embed_type"], v["value"])))
    end
    return str
end

local function unrollmacros(str, unroll_table)
    local macro_depth_limit = 10
    for i = 1, macro_depth_limit + 1, 1 do
        if i == (macro_depth_limit + 1) then error("Macro unroll depth reached, increase limit or reduce unroll depth") end
        local old_str = str
        str = replacecalls(str, {}, unroll_table)
        if old_str == str then break end
    end
    return str
end

local function inittables(str)

    local call_table = {}
    local unroll_table = {}

    for name in string.gmatch(str, input_capture) do
        if name ~= "" then
        call_table[#call_table+1] = {
            type = "input", 
            name = name
        }
        end
    end
    for name, constant in string.gmatch(str, constant_capture) do
        if name ~= "" then
        call_table[#call_table+1] = {
            type = "constant", 
            name = name, 
            value = constant,
        }
        end
    end
    for name, import in string.gmatch(str, import_capture) do
        if name ~= "" then
        local unrolled_function = filereader(import) -- Add pcall here
        call_table[#call_table+1] = {
            type = "import", 
            name = name, 
            value = unrolled_function,
        }
        end
    end
    for name, input_count, output_count, ravenmind_status, func in string.gmatch(str, function_capture) do
        if name ~= "" then
        call_table[#call_table+1] = {
            type = "function", 
            name = name, 
            I = input_count, 
            O = output_count, 
            RM = ravenmind_status, 
            value = func,
        }
        end
    end

    for name, constant in string.gmatch(str, embed_capture) do
        if name ~= "" then
        unroll_table[#unroll_table+1] = {
            type = "embed", 
            name = name, 
            value = constant,
            embed_type = iota_embed
        }
        end
    end
    for name, import in string.gmatch(str, include_capture) do
        if name ~= "" then
        local unrolled_function = filereader(import) -- Add pcall here
        unroll_table[#unroll_table+1] = {
            type = "include", 
            name = name, 
            value = unrolled_function,
            embed_type = macro_embed
        }
        end
    end
    for name, macro in string.gmatch(str, macro_capture) do
        if name ~= "" then
        unroll_table[#unroll_table+1] = {
            type = "macro", 
            name = name, 
            value = macro,
            embed_type = macro_embed
        }
        end
    end

    return call_table, unroll_table
end

local function parseinit(call_table)
    local init = ""

    for i, v in ipairs(call_table) do
        if v["type"] == "input" then
            
        elseif v["type"] == "function" then
            local func = ""
            if v["RM"] == "l" then
                func = string.format(function_macro, string.format(rm_saver_start, v["I"]), v["value"], string.format(rm_saver_end, v["O"]))
            elseif v["RM"] == "g" then
                func = string.format(function_macro, "", v["value"], "")
            end
            init = init .. func
        elseif v["type"] == "import" then
            init = init .. string.format(macro_embed, v["value"])
        else
            init = init .. string.format(iota_embed, v["value"])
        end
    end

    return init
end

local function preparse(str)
    str = string.gsub(str, "%/%/.-\r", "\r\n")
    str = string.gsub(str, "%/%/.-\n", "\r\n")
    str = string.gsub(str, "%/%/.-\r\n", "\r\n")
    str = string.gsub(str, "%/%/.-\n\r", "\r\n")
    return str
end

local function findsections(str)
    local init, main = string.match(str, "(.*)<MAIN>:(.*)")
    return init, main
end

function hexassemble(str)
    str = preparse(str)
    local init, main = findsections(str)
    local call_table, unroll_table = inittables(init)
    local hex_init = parseinit(call_table)
    local result = hex_init .. "\r\n" .. main
    result = replacecalls(result, call_table, {})
    result = unrollmacros(result, unroll_table)
    --print(result)
    return result
end

-- Utility Functions:

function filereader(str)
    return file:readString(str, "utf8")
end
