-- Main Functions:

function partitioner(table, partition_size, max_partition)
    local max_partitions = max_partition or 1024
    local partition_length = partition_size or 250
    local partition_table = {}
    for i = 1, max_partitions, 1 do
        local partition = {}
        if table[((i-1)*partition_length)+1] ~= nil then
            for j = 1, partition_length, 1 do
                if table[((i-1)*partition_length)+j] ~= nil then
                    partition[j] = table[((i-1)*partition_length)+j]
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

function prepper(str)
    local anglesiglist = hexpattoanglesig(str)
    local partitioned_list = partitioner(anglesiglist,part_size,max_part)
    return partitioned_list
end

function filereader(str)
    return file:readString(str, "utf8")
end

function caller(str)
    if isbusy == true then
        return false
    elseif isbusy == false then
        request_partition = prepper(str)
        request_tick = world.getTime() + 1
        return true
    end
end

function sender(part)
    local buffer = hexpatserializer(part)
    local length = buffer:getLength()
    server_packets:sendPacket("transport_send", buffer)
    buffer:close()
    return length
end

-- Running Portion:

max_part = 1024 -- Max partitions allowed, somewhat useless
part_size = 250 -- Max size of an individual partition
part_delay = 1 -- Tick delay between each batch that gets sent
batch_size = 1 -- How many partitions should be sent each batch
return_delay = 8 -- Tick delay before the hexporter marks itself as ready to import again, after finishing the current importation

request_tick = -1
request_partition = {}
isbusy = false
return_time = -1

current_partition_list = {}
next_partition = -1

total_bytes_sent = -1
total_iotas_sent = -1

function events.tick()
    if (#request_partition ~= 0) and (isbusy == false) then
        -- Request Acceptor
        current_partition_list = request_partition
        request_partition = {}
        next_partition = 1
        request_tick = world.getTime()
        isbusy = true
        infobuttonsetter()
        total_bytes_sent = 0
        total_iotas_sent = 0
    end
    if (isbusy == true) then
        if (current_partition_list[next_partition] == nil) and (return_time < 0) then
            -- Resetter
            request_tick = -1
            request_partition = {}
            return_time = world.getTime() + return_delay
            current_partition_list = {}
            next_partition = -1
            print("Total Iotas & Bytes Sent: " .. total_iotas_sent .. " / " .. total_bytes_sent)
            total_bytes_sent = -1
            total_iotas_sent = -1
        end
        if (world.getTime() > return_time) and (return_time > 0) then
            -- Next request delay mechanism
            isbusy = false
            infobuttonsetter()
            return_time = -1
            print("Ready For Next Request")
        end
    end
    if (world.getTime() > request_tick) and (request_tick > 0) then
        -- Sender
        request_tick = request_tick + part_delay
        local batches = batch_size
        for i = 1, batches, 1 do
            if current_partition_list[next_partition] == nil then
                break
            end
            local success, ret = pcall(sender,current_partition_list[next_partition])
            if success == false then
                print(ret)
            else
                total_bytes_sent = total_bytes_sent + ret
                total_iotas_sent = total_iotas_sent + #current_partition_list[next_partition]
            end
            next_partition = next_partition + 1
        end
    end
end

-- Utility Functions:

function singlesplitter(str)
    local string_table = {}
    local limit = 10 --Because lua has a weird thing where gsub fails to work above a certain size.
    for i = 1, math.ceil(string.len(str)/limit), 1 do
        local string_section = string.sub(str, ((i-1)*limit)+1, i*limit)
        local parts = table.pack( string_section:match( (string_section:gsub(".", "(.)")) ) ) --What the fuck
        for _, v in ipairs(parts) do
            string_table[#string_table+1] = v
        end
    end
    return string_table
end

-- Variables:

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