-- Init:

if client.isModLoaded("mediatransport") then

function server_packets.transport_received(data)
    local output = parseMT(data)
    print("Self Transport Received")
    if output["display"] then
        hexdisplay(output["display"])
    else
        printTable(output)
    end
    host:writeToLog(toJson(output))
    data:close()
end

function server_packets.transport_external_received(data)
    local output = parseMT(data)
    print("External Transport Received")
    if output["display"] then
        hexdisplay(output["display"])
    else
        printTable(output)
    end
    host:writeToLog(toJson(output))
    data:close()
end

end

-- Pretty Print:

local function parsehextext(str) -- Thank you, hexcasting. Whoever made the regex for the HexPattern[dir, anglesig] thing, for your safety, I hope you will never get to meet me.
    local text_list = {}
    local parser = "(.-)({.-:.-})(.*)"
    local parsed_text = str
    --local trail, hexpat, lead = "", "", ""
    for i = 1, string.len(str), 1 do
        local prev_lead = parsed_text
        local trail, hexpat, lead = string.match(parsed_text, parser)
        text_list[#text_list+1] = trail or ""
        text_list[#text_list+1] = hexpat or ""
        if (hexpat == nil) or (lead == nil) then
            text_list[#text_list+1] = prev_lead or ""
            break
        end
        parsed_text = lead
    end

    local index = 1
    for i = 1, #text_list, 1 do
        if text_list[index] == nil then
            break
        end
        if text_list[index] == "" then
            table.remove(text_list, index)
        else
            index = index + 1
        end
    end

    if #text_list == 0 then
        text_list[1] = str
    end
    return text_list
end

function hexdisplay(str)
    --str = string.gsub(str, "§5,§f{", " §5,§f\n{")
    str = string.gsub(str, "}§5,§f {", "}{") -- Section that removes commas between patterns, comment out if you want those
    local str_list = parsehextext(str)
    for i, v in ipairs(str_list) do
        printJson(v)
    end
end

local function listdisplay(list)
    local list_string = ""
    for i, v in ipairs(list) do
        list_string = list_string .. (v["display"] or "N/A") .. "§5,§f "
    end
    list_string = string.gsub(list_string, "§5,§f $", "")
    list_string = "§5[§f" .. list_string .. "§5]§f"
    return list_string
end

-- Main Functions:

local function preparser(buff)
    local output = {}
    local iota_limit = 1024

    for i = 1, iota_limit, 1 do
        if buff:getPosition() >= buff:getLength() then break end
        local iota_code = buff:read()
        local handler = iota_handlers[iota_code]
        if handler == nil then
            -- No handler found section here
            error("No handler found")
            break
        end
        local result = handler(buff)
        output[#output+1] = result
    end
    return output
end

local function listnester(list)
    local stack = {}
    local iota_limit = 1024
    local index = #list
    for i = 1, iota_limit, 1 do
        local iota = list[index]
        if iota == nil then
            break
        end
        if iota["type"] == "list" then
            local length = iota["length"]
            iota = table.pack(table.unpack(stack, 1, length))
            for i = 1, length, 1 do
                table.remove(stack, 1)
            end
            iota["type"], iota["length"], iota["n"] = "list", length, nil
            iota["display"] = listdisplay(iota)
        end
        table.insert(stack, 1, iota)
        index = index - 1
    end
    return stack
end

function parseMT(buff)
    return listnester(preparser(buff))[1]
end

-- Handler Registry:

function events.entity_init()

iota_handlers = {
    [8] = listhandler,
    [6] = patternhandler,
    [5] = doublehandler,
    [1] = stringhandler,
    [80] = texthandler,
    [64] = matrixhandler,
    [7] = vectorhandler,
    [255] = garbagehandler,
    [4] = nullhandler,
    [2] = truehandler,
    [3] = falsehandler,
    [254] = queryconfighandler,
}

end

-- Handlers:

function listhandler(buff)
    local length = buff:readInt()
    local iota = {type = "list", length = length}
    iota["display"] = "List Display Uninitialized"
    return iota
end

function patternhandler(buff)
    local dir = buff:read()
    local length = buff:readInt()
    local anglesig = {}
    for i = 1, length, 1 do
        anglesig[#anglesig+1] = buff:read()
    end

    dir = dir_convert_inv[dir]
    local anglesig_str = ""
    for i, v in ipairs(anglesig) do
        anglesig_str = anglesig_str .. angle_convert_inv[v]
    end

    local iota = {type = "pattern", dir = dir, anglesig = anglesig_str}
    iota["display"] = string.format("{%s:%s}", dir, anglesig_str)
    --iota["display"] = ""
    return iota
end

function doublehandler(buff)
    local num = buff:readDouble()
    local iota = {type = "double", value = num}
    iota["display"] = "§a"..string.format("%.2f", num).."§f"
    return iota
end

function stringhandler(buff)
    local length = buff:readInt()
    local str = ""
    for i = 1, length, 1 do
        local char_num = buff:read()
        local char = string.char(char_num)
        str = str .. char
    end
    local iota = {type = "string", value = str}
    iota["display"] = "§d\"" .. str .. "\"§f"
    return iota
end

function texthandler(buff) -- Minor display difference from stringhandler(), text and string iotas share the same format
    local length = buff:readInt()
    local str = ""
    for i = 1, length, 1 do
        local char_num = buff:read()
        local char = string.char(char_num)
        str = str .. char
    end
    local iota = {type = "string", value = str}
    iota["display"] = "§6“§f" .. str .. "§6”§f"
    return iota
end

function vectorhandler(buff)
    local x = buff:readDouble()
    local y = buff:readDouble()
    local z = buff:readDouble()
    local iota = {type = "vector", x = x, y = y, z = z}
    iota["display"] = "§c("..x..", "..y..", "..z..")§f"
    return iota
end

function matrixhandler(buff)
    local rows = buff:read()
    local columns = buff:read()
    local total_length = rows * columns
    local flat_table = {}
    for i = 1, total_length, 1 do
        flat_table[#flat_table+1] = buff:readDouble()
    end
    local iota = {type = "matrix"}
    iota["display"] = "§b[".."("..rows..", "..columns..") | "
    for i = 1, rows, 1 do
        iota[#iota+1] = {}
        for j = 1, columns, 1 do
            iota[i][j] = flat_table[((i-1)*columns)+j]
            iota["display"] = iota["display"].."§a"..string.format("%.2f", iota[i][j]).."§b, "
        end
        iota["display"] = string.gsub(iota["display"], ", $", "; ")
    end
    iota["display"] = string.gsub(iota["display"], "§b; $", "§b]§f")
    return iota
end

function garbagehandler(buff)
    local iota = {type = "garbage"}
    iota["display"] = "§8§karimfexendrapuse§f§r"
    return iota
end

function nullhandler(buff)
    local iota = {type = "null"}
    iota["display"] = "§7Null§f"
    return iota
end

function truehandler(buff)
    local iota = {type = "bool", value = true}
    iota["display"] = "§2True§f"
    return iota
end

function falsehandler(buff)
    local iota = {type = "bool", value = false}
    iota["display"] = "§4False§f"
    return iota
end

function queryconfighandler(buff)
    local version = buff:readShort()
    local max_send = buff:readInt()
    local max_inter = buff:readInt()
    local max_recv = buff:readInt()
    local max_power = buff:readDouble()
    local power_regen_rate = buff:readDouble()
    local inter_cost = buff:readDouble()
    local result = {type = nil,
        version = version,
        max_send = max_send,
        max_inter = max_inter,
        max_recv = max_recv,
        max_power = max_power,
        power_regen_rate = power_regen_rate,
        inter_cost = inter_cost,
    }
    result["display"] = nil
    return result
end

-- Constants:

dir_convert_inv = {
    [0] = "NORTH_EAST",
    [1] = "EAST",
    [2] = "SOUTH_EAST",
    [3] = "SOUTH_WEST",
    [4] = "WEST",
    [5] = "NORTH_WEST",
}

angle_convert_inv = {
    [0] = "w",
    [1] = "e",
    [2] = "d",
    [3] = "s",
    [4] = "a",
    [5] = "q",
}