-- Variables:

local baseurl = "http://copyparty2.chloes.media/users/"

-- Main Functions:

function request(uri,method,headers,body)
    if uri == nil then return end
    if method == nil then method = "GET" end
    if headers == nil then headers = {} end
    if body == nil then body = nil end

    local request = net.http:request(uri)
    request:method(method)
    for k, v in pairs(headers) do
        if type(v) == "string" then
            request:header(k, v)
        end
    end
    request:body(body)
    local response = request:send()

    local start_time = client.getSystemTime()
    local limit = 1000 -- In miliseconds
    local delimiter = 4000000 -- Just a fallback now
    for i = 1, delimiter, 1 do
        if response:isDone() == true then
            response = response:getValue()
            break
        end
        if (client.getSystemTime() - start_time) > limit then
            break
        end
    end

    local data = response:getData()
    local headers = response:getHeaders()
    local code = response:getResponseCode()
    return data, headers, code
end

function parseresponsedata(data, headers)
    local response_string = ""
    for i = 1, headers["content-length"][1], 1 do
        response_string = response_string .. string.char(data:read())
    end
    return response_string
end

function hexpartyrequestwrapper(path)
    local data, headers, code = request(path, "GET", {}, nil)
    local result = parseresponsedata(data, headers)
    data:close()
    return result
end

function hexpartymap(page, path)
    local crawled_data = parseJson(hexpartyrequestwrapper(baseurl .. path .. "?ls")) -- .. "?ls"
    local dirs, files = crawled_data["dirs"], crawled_data["files"]
    local prev_page = page
    for k, v in pairs(dirs) do
        local next_path = path .. v["href"]
        local next_page = action_wheel:newPage()
        local istraversedpreviously = false
        local page_shift = prev_page:getSlotsShift()
        local go_to_action = prev_page:newAction()
            :title(whitespaceenforcer(next_path))
            :item("chest")
            :onLeftClick(function()
                if istraversedpreviously == false then
                    --local csuccess, cerror = pcall()
                    local success, error = pcall(hexpartymap, next_page, next_path)
                    if success == true then
                        istraversedpreviously = true
                    elseif success == false then
                        print("Traversal Failed")
                        local action_count = #next_page:getActions()
                        for i = 1, (action_count-1), 1 do
                            next_page:setAction((i+1), nil)
                        end
                        errorclick()
                        --print(error)
                        return
                    end
                end
                action_wheel:setPage(next_page)
                page_shift = page:getSlotsShift()
                pageclick()
            end)
        local return_action = next_page:newAction()
            :title("Go Back")
            :item("firework_rocket")
            :onLeftClick(function()
                action_wheel:setPage(prev_page)
                prev_page:setSlotsShift(page_shift)
                page_shift = 1
                pageclick()
            end)
    end
    for k, v in pairs(files) do
        local next_path = path .. v["href"]
        local fileext = string.sub(v["href"], string.find(v["href"], "%.") or 1, -1)
        local file_action = prev_page:newAction()
            :title(whitespaceenforcer(next_path))
            :item("paper")
            :onLeftClick(function()
                print("Incompatible File")
                failclick()
            end)
            :onRightClick(function()
                local success, ret = pcall(hexpartyrequestwrapper, baseurl .. next_path)
                if success then
                    reader(trim(ret),trim(next_path))
                    readfileclick()
                elseif not success then
                    errorclick()
                end
            end)
        if fileext == ".hexpattern" then
            file_action:onLeftClick(function()
                local reqsucc, reqret = pcall(hexpartyrequestwrapper, baseurl .. next_path)
                if reqsucc == true then
                    local importsucc, callret = pcall(caller,reqret)
                    if importsucc == false then
                        print(callret)
                        errorclick()
                    elseif callret == true then
                        print(next_path)
                        print("Import Request Confirmed")
                        last_requested_hex = "§6Hexparty Hex"
                        infobuttonsetter()
                        importclick()
                    elseif callret == false then
                        print("Request Currently Full")
                        failclick()
                    end
                elseif reqsucc == false then
                    print(reqret)
                    errorclick()
                end
            end)
        elseif (fileext == ".png") or (fileext == ".mp4") or (fileext == ".sqlite") then
            file_action:onRightClick(function()
                print("Incompatible File")
                failclick()
            end)
        end
        -- Files for which we need functionality: .lua, .md, .txt, .hexpattern, .json
        -- .lua, .md, .txt and .hexpattern can all be just read, .json requires json parsing
        -- Additionally, .hexpattern has to be exportable
    end
end

-- Init:

local hexparty_start_page = action_wheel:newPage()
local hexparty_location = file_system_location

local hexparty_interop_goto = hexparty_location:newAction()
    :title("Geodesic: Hexparty")
    :item("golden_apple")
    :onLeftClick(function()
        if hexparty_start_page:getAction(2) == nil then
            --local csuccess, cerror = pcall()
            local success, error = pcall(hexpartymap, hexparty_start_page, "")
            if success == false then
                print("Traversal Failed")
                --print(error)
                errorclick()
            end
        end
        action_wheel:setPage(hexparty_start_page)
        pageclick()
    end)
local return_action = hexparty_start_page:newAction()
    :title("Go Back")
    :item("firework_rocket")
    :onLeftClick(function()
        action_wheel:setPage(hexparty_location)
        pageclick()
    end)

-- Utility Functions:

function whitespaceenforcer(str)
    return string.gsub(str, "%%20", " ")
end