-- Init:
if client.isModLoaded("mediatransport") then

function server_packets.transport_received(data)
    local output = parseMT(data)
    printTable(output)
    data:close()
end

function server_packets.transport_external_received(data)
    local output = parseMT(data)
    printTable(output)
    data:close()
end

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
            print("No handler found")
            break
        end
        local result = handler(buff)
        output[#output+1] = result
    end

    return output
end

local function listnester(list)
    local output = {}
    local iota_limit = 1024
    local index = 1
    for i = 1, iota_limit, 1 do
        local iota = list[index]
        if iota == nil then
            break
        end
        if list[index]["type"] == "list" then
            local length = list[index]["length"]
            local handled_list = table.pack(table.unpack(list, index+1, index+length))
            iota = listnester(handled_list)
            iota["type"], iota["length"] = "list", length
            index = index + length
        end
        output[#output+1] = iota
        index = index + 1
    end
    return output
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
    [80] = stringhandler, -- Text iotas have the same format as string iotas
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
    return iota
end

function doublehandler(buff)
    local num = buff:readDouble()
    local iota = {type = "double", value = num}
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
    return iota
end

function vectorhandler(buff)
    local x = buff:readDouble()
    local y = buff:readDouble()
    local z = buff:readDouble()
    local iota = {type = "vector", x = x, y = y, z = z}
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
    for i = 1, rows, 1 do
        iota[#iota+1] = {}
        for j = 1, columns, 1 do
            iota[i][j] = flat_table[((i-1)*columns)+j]
        end
    end
    return iota
end

function garbagehandler(buff)
    local iota = {type = "garbage"}
    return iota
end

function nullhandler(buff)
    local iota = {type = "null"}
    return iota
end

function truehandler(buff)
    local iota = {type = "bool", value = true}
    return iota
end

function falsehandler(buff)
    local iota = {type = "bool", value = false}
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