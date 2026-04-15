function events.entity_init()

local per_world_config = (parseJson(file:readString("perworldconfig.json", "utf8")))
local server_ip = client:getServerData()["ip"]
local server_name = client:getServerData()["name"]
local server_data = {}

if per_world_config[server_ip] ~= nil then
    server_data = per_world_config[server_ip]
elseif per_world_config[server_name] ~= nil then
    server_data = per_world_config[server_name]
else
    if server_ip ~= nil then
        server_data = per_world_config["SERVER_DEFAULT"]
    else
        server_data = per_world_config["SINGLEPLAYER_DEFAULT"]
    end
end

if server_data == {} then
    error("Something went wrong during the per world config loading process")
end

for k, v in pairs(server_data["patterns"]) do
    local replacement = v
    replacement["ishexpattern"] = true
    pattern_list[k] = replacement
end

max_part = server_data["config"]["max_part"] or max_part
part_size = server_data["config"]["part_size"] or part_size
part_delay = server_data["config"]["part_delay"] or part_delay
batch_size = server_data["config"]["batch_size"] or batch_size
return_delay = server_data["config"]["return_delay"] or return_delay

for k, v in pairs(Endpoint_Table[server_data["endpoint"]] or {}) do
    if v == nil then return end
    changevar(k, v)
end

end

-- Utility Functions:

function changevar(variable, state)
    local func = [[
    function tempfunc(state)
        VAR = state
    end
    ]]
    func = string.gsub(func, "VAR", variable)
    local f = loadstring(func)
    f()
    tempfunc(state)
    tempfunc = nil
end

-- Runtime Functions:

function loadendpoint(str)
    if Endpoint_Table[str] == nil then error("Endpoint does not exist") end
    for k, v in pairs(Endpoint_Table[str]) do
        if v == nil  then return end
        changevar(k, v)
    end
end