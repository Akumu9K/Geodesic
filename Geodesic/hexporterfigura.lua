-- Main Functions:

function partitioner(table, partition_size, max_partition) -- Placeholder for an endpoint
    return {}
end

function prepper(str) 
    local anglesiglist, type = formatfinder(str)
    local partitioned_list = partitioner(anglesiglist,part_size,max_part)
    return partitioned_list
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

function sender(part) -- Placeholder for an endpoint
    return 0
end

function filereader(str)
    return file:readString(str, "utf8")
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