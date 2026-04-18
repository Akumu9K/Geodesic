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
        local result = nil
        local iota_code = buff:read()
        local handler = iota_handlers[iota_code]
        if handler == nil then
            -- No handler found section here
            print("No handler found")
            break
        end
        buff, result = handler(buff)
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
    return buff, iota
end

function patternhandler(buff)
    local dir = buff:read()
    local length = buff:readInt()
    local anglesig = {}
    for i = 1, length, 1 do
        anglesig[#anglesig+1] = buff:read()
    end

    local iota = {type = "pattern", dir = dir, anglesig = anglesig}
    return buff, iota
end

function doublehandler(buff)
    local num = buff:readDouble()
    local iota = {type = "double", value = num}
    return buff, iota
end

function stringhandler(buff)
    local length = buff:readInt()
    local str = ""
    for i = 1, length, 1 do
        local char_num = buff:read()
        local char = string.char(char_num)
        str = str .. char
    end
    iota = {type = "string", value = str}
    return buff, iota
end

function vectorhandler(buff)
    local x = buff:readDouble()
    local y = buff:readDouble()
    local z = buff:readDouble()
    local iota = {type = "vector", x = x, y = y, z = z}
    return buff, iota
end

function garbagehandler(buff)
    local iota = {type = "garbage"}
    return buff, iota
end

function nullhandler(buff)
    local iota = {type = "null"}
    return buff, iota
end

function truehandler(buff)
    local iota = {type = "bool", value = true}
    return buff, iota
end

function falsehandler(buff)
    local iota = {type = "bool", value = false}
    return buff, iota
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
    return buff, result
end