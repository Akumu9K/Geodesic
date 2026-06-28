-- Endpoint Init:

Endpoint_Table = {}

function events.entity_init()

local Mediatransport = { -- The default, thus all the relevant functions are defined as themselves
    sender = buffsender,
    partitioner = statpartitioner,
}
Endpoint_Table["Mediatransport"] = Mediatransport

local Moreiotas = { -- Moreiotas + Hexical
    sender = textsender,
    partitioner = dynpartitioner,
}
Endpoint_Table["Moreiotas"] = Moreiotas

local Hexparse = { -- To be made, just here as a reminder to make it

}
Endpoint_Table["Hexparse"] = Hexparse

end

local Hextweaks = { -- Copy of moreiotas with legalnumgen in it
    sender = textsender,
    partitioner = dynpartitioner,
    illegalnumgen = legalnumgenwrapper,
}
Endpoint_Table["Hextweaks"] = Hextweaks

-- Endpoints:

-- Mediatransport:

function statpartitioner(table)
    local partition_table = {}
    for i = 1, max_part, 1 do
        local partition = {}
        if table[((i-1)*part_size)+1] ~= nil then
            for j = 1, part_size, 1 do
                if table[((i-1)*part_size)+j] ~= nil then
                    partition[j] = table[((i-1)*part_size)+j]
                else
                    break
                end
            end
            partition_table[i] = partition
        else
            break
        end
    end
    return partition_table
end

function buffsender(part)
    local buffer = hexpatserializer(part)
    local length = buffer:getLength()
    server_packets:sendPacket("transport_send", buffer)
    buffer:close()
    return length
end

function hexpatserializer(list)
    --printTable(list)
    local buffer = data:createBuffer()
    local length = #list
    if length > 1 then
        buffer:write(8)
        buffer:writeInt(length)
    end
    local count_checker = 0
    for i, v in ipairs(list) do
        if v["ishexpattern"] == true then
            count_checker = count_checker + 1
            buffer:write(6)
            buffer:write(dir_convert[v["dir"]])
            local anglesig_seperate = singlesplitter(v["anglesig"])
            buffer:writeInt(#anglesig_seperate)
            for l, k in ipairs(anglesig_seperate) do
                buffer:write(angle_convert[k])
            end
        end
    end
    if length > 1 then
        buffer:setPosition(1)
        buffer:writeInt(count_checker)
    end
    buffer:setPosition(0)
    return buffer
end

-- Moreiotas:

function dynpartitioner(table)
    local partition_table = {}
    local index = 1
    for i = 1, max_part, 1 do
        if index > #table then break end
        local remaining_bytes = part_size
        partition_table[i] = {}
        for l = 1, part_size, 1 do
            if index > #table then break end
            local bytes = string.len(table[index]["anglesig"]) + 1 + 1
            if bytes > part_size then
                print(table[index])
                error("Pattern size exceeded max partition size at index: " .. index, 100)
            elseif bytes > remaining_bytes then
                break
            else
                remaining_bytes = remaining_bytes - bytes
                partition_table[i][l] = table[index]
                index = index + 1
            end
        end
    end
    return partition_table
end

function textsender(part)
    local sifters_prefix = "ß"
    local chatmsg = sifters_prefix
    local length = 0
    for i, v in ipairs(part) do
        if v["ishexpattern"] ~= true then return end
        chatmsg = chatmsg .. dir_convert[v["dir"]] .. v["anglesig"] .. " "
        length = length + string.len(v["anglesig"]) + 2
    end
    chatmsg = string.sub(chatmsg, 1, -2) -- To remove trailing space
    length = length - 1 -- To match the above
    host:sendChatMessage(chatmsg)
    return length
end

-- Constants:

dir_convert = {
    NORTH_EAST = 0,
    EAST = 1,
    SOUTH_EAST = 2,
    SOUTH_WEST = 3,
    WEST = 4,
    NORTH_WEST = 5,
}

angle_convert = {
    w = 0,
    e = 1,
    d = 2,
    s = 3,
    a = 4,
    q = 5,
}

-- Utility Functions:

function singlesplitter(str)
    local string_table = {}
    local limit = 10 --Because lua has a limit to how many matches it can get from a pattern
    for i = 1, math.ceil(string.len(str)/limit), 1 do
        local string_section = string.sub(str, ((i-1)*limit)+1, i*limit)
        local parts = table.pack( string_section:match( (string_section:gsub(".", "(.)")) ) ) --What the fuck
        for _, v in ipairs(parts) do
            string_table[#string_table+1] = v
        end
    end
    return string_table
end

-- Action Wheel:

-- To do: Make this switchable with a menu in the reparse list thing