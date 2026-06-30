-- Init:

local staff = peripheral.wrap("back")
local methods = peripheral.getMethods("back")
local type = peripheral.getType(staff)

if type ~= "wand" then
    print("Error")
end

-- Main Functions:

dir_convert_inv = {
    ["0"] = "NORTH_EAST",
    ["1"] = "EAST",
    ["2"] = "SOUTH_EAST",
    ["3"] = "SOUTH_WEST",
    ["4"] = "WEST",
    ["5"] = "NORTH_WEST",
}

function deserializer(str)
    local patterns = splitter(str)
    local output = {}

    for i, v in ipairs(patterns) do
        local dir = string.sub(v, 1, 1)
        local anglesig = string.sub(v, 2, -1)
        output[i] = {["dir"] = dir_convert_inv[dir], ["anglesig"] = anglesig}
    end

    return output
end

function hexifier(list)
    staff.clearStack()
    staff.runPattern("WEST", "qqq") -- Introspection
    for i, v in ipairs(list) do
        staff.runPattern(v["dir"], v["anglesig"])
    end
    staff.runPattern("EAST", "eee") -- Retrospection
end

function splitter(istr)
    local sep = "%s"
    local t = {}
    for str in string.gmatch(istr, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end

-- Variables:

local clock = 0
local clock_limit = 12
local importing = false

local old_data = ""

local result = {}

staff.runPattern("EAST", "waqa") -- Whisper Ref.
old_data = staff.getStack()[1]

-- Running Portion:

os.startTimer(0)
while true do
    local event = os.pullEvent("timer")
    staff.clearStack()

    -- Get Data Stream
    staff.runPattern("EAST", "waqa") -- Whisper Ref.
    local new_data = staff.getStack()[1] or old_data

    if new_data ~= old_data then
        -- Start Importation
        importing = true
        clock = clock_limit
        old_data = new_data
        -- Handle Data
        local section = deserializer(new_data)
        for i, v in ipairs(section) do
            result[#result+1] = v
        end
    end

    if importing == true then
        clock = clock - 1
    end

    if importing == true and clock == 0 then
        -- Output Result
        hexifier(result)
        staff.runPattern("NORTH_EAST", "deeeee") -- Scribes Gambit
        -- Reset
        importing = false
        clock = 0
        result = {}
    end

    os.startTimer(0)
end