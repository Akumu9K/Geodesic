-- Init:

local patterns_json = "patternsbig.json" -- This is the default name, change it if you use another json for this

pattern_list = config:load("pattern_list")
if pattern_list == nil then
    local patterns_raw = (parseJson(file:readString(patterns_json, "utf8")))
    local patterns_processed = {}
    for k, v in pairs(patterns_raw["patterns"]) do
        patterns_processed[v["name"]] = {dir = v["direction"], anglesig = v["signature"], ishexpattern = true}
    end
    --[[ // Will keep this section knocked out for now, it seems illegalnumgen is stable enough to replace pregen nums
    for k, v in pairs(patterns_raw["pregenerated_numbers"]) do
        patterns_processed[k] = {dir = v["direction"], anglesig = v["signature"]}
    end
    --]]
    config:save("pattern_list", patterns_processed)
    pattern_list = config:load("pattern_list")
end

-- Runtime Functions:

function emptypatlist()
    config:save("pattern_list", nil)
end

function reparsepatlist()
    local patterns_raw = (parseJson(file:readString(patterns_json, "utf8")))
    local patterns_processed = {}
    for k, v in pairs(patterns_raw["patterns"]) do
        patterns_processed[v["name"]] = {dir = v["direction"], anglesig = v["signature"], ishexpattern = true}
    end
    --[[
    for k, v in pairs(patterns_raw["pregenerated_numbers"]) do
        patterns_processed[k] = {dir = v["direction"], anglesig = v["signature"]}
    end
    --]]
    config:save("pattern_list", patterns_processed)
    pattern_list = config:load("pattern_list")
    --require("Hexcasting.Geodesic.perworldpats")
    --require("Hexcasting.Geodesic.custompatterns")
    require("./perworldconfig")
end