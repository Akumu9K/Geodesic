-- Init:

Endpoint_Table = {}

-- Endpoints:

if host:isHost() then
function events.entity_init()

Mediatransport = { -- The default, thus all the relevant functions are defined as themselves
    sender = sender,
    partitioner = partitioner,
    hexpatserializer = hexpatserializer,
    prepper = prepper,
}
Endpoint_Table["Mediatransport"] = Mediatransport

Moreiotas = { -- Moreiotas + Hexical
    sender = textsender,
    partitioner = dynpartitioner,
}
Endpoint_Table["Moreiotas"] = Moreiotas

Hexparse = { -- To be made, just here as a reminder to make it

}
Endpoint_Table["Hexparse"] = Hexparse

end
end

-- Endpoint Functions:

function dynpartitioner(table, partition_size, max_partition)
    local max_partitions = max_partition or 1024
    local part_size_byte = partition_size or 254
    local partition_table = {}
    local index = 1
    for i = 1, max_partitions, 1 do
        if index > #table then break end
        local remaining_bytes = part_size_byte
        partition_table[i] = {}
        for l = 1, part_size_byte, 1 do
            if index > #table then break end
            local bytes = string.len(table[index]["anglesig"]) + 1 + 1
            if bytes > part_size_byte then
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

-- Action Wheel:

-- To do: Make this switchable with a menu in the reparse list thing