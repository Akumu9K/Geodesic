-- Repos:

local Repos = {
    {"USER","REPO","GIT TOKEN (Optional)"},
}

-- Main Functions:

function githubrequestwrapper(path, git_token)
    local sent_headers = {}
    if git_token then
        sent_headers["Authorization"] = "Bearer " .. git_token
    end
    local data, headers, code = request(path, "GET", sent_headers, nil)
    local result = parseresponsedata(data, headers)
    data:close()
    return result
end

function githubmap(page, path, repobaseurl, repofilegeturl, git_token)
    path = whitespacereplacer(path)
    local crawled_data = parseJson(githubrequestwrapper(repobaseurl .. path .. "?ls", git_token)) -- .. "?ls"
    local dirs, files = {}, {}
    for i, v in ipairs(crawled_data) do
        if v["type"] == "dir" then
            table.insert(dirs,v)
        elseif v["type"] == "file" then
            table.insert(files,v)
        end
    end
    local prev_page = page
    for k, v in pairs(dirs) do
        local path_name = v["path"]
        local next_path = whitespacereplacer(v["path"])
        local next_page = action_wheel:newPage()
        local istraversedpreviously = false
        local page_shift = prev_page:getSlotsShift()
        local go_to_action = prev_page:newAction()
            :title(path_name)
            :item("chest")
            :onLeftClick(function()
                if istraversedpreviously == false then
                    --local csuccess, cerror = pcall()
                    local success, error = pcall(githubmap, next_page, next_path, repobaseurl, repofilegeturl, git_token)
                    if success == true then
                        istraversedpreviously = true
                    elseif success == false then
                        print("Traversal Failed")
                        local action_count = #next_page:getActions()
                        for i = 1, (action_count-1), 1 do
                            next_page:setAction((i+1), nil)
                        end
                        errorclick()
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
        local path_name = v["path"]
        local next_path = whitespacereplacer(v["path"])
        local fileext = string.sub(v["path"], string.find(v["path"], "%.") or 1, -1)
        local file_action = prev_page:newAction()
            :title(path_name)
            :item("paper")
            :onLeftClick(function()
                print("Incompatible File")
                failclick()
            end)
            :onRightClick(function()
                local success, ret = pcall(githubrequestwrapper, repofilegeturl .. next_path, git_token)
                if success then
                    reader(trim(ret),trim(next_path))
                    readfileclick()
                elseif not success then
                    errorclick()
                end
            end)
        if fileext == ".hexpattern" or fileext == ".txt" or fileext == ".json" then
            file_action:onLeftClick(function()
                local reqsucc, reqret = pcall(githubrequestwrapper, repofilegeturl .. next_path, git_token)
                if reqsucc == true then
                    local importsucc, callret = pcall(caller,reqret)
                    if importsucc == false then
                        print(callret)
                        errorclick()
                    elseif callret == true then
                        print(next_path)
                        print("Import Request Confirmed")
                        last_requested_hex = "§6Github Hex"
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
    end
end

-- Variables:

local baseurl = "https://api.github.com/repos/{USER}/{REPO}/contents/"
local filegeturl = "https://raw.githubusercontent.com/{USER}/{REPO}/main/"

-- Init:

local github_start_page = action_wheel:newPage()
local github_location = file_system_location

local github_interop_goto = github_location:newAction()
    :title("Geodesic: Github")
    :item("ink_sac")
    :onLeftClick(function()
        --[[
        if github_start_page:getAction(2) == nil then
            --local csuccess, cerror = pcall()
            local success, error = pcall(githubmap, github_start_page, "")
            if success == false then
                print("Traversal Failed")
                --print(error)
                errorclick()
            end
        end
        ]]
        action_wheel:setPage(github_start_page)
        pageclick()
    end)
local return_action = github_start_page:newAction()
    :title("Go Back")
    :item("firework_rocket")
    :onLeftClick(function()
        action_wheel:setPage(github_location)
        pageclick()
    end)

-- Procedural Repos:

for i, v in ipairs(Repos) do
    local repo_start_page = action_wheel:newPage()
    local repo_location = github_start_page
    local repobaseurl = string.gsub(string.gsub(baseurl, "{USER}", v[1]), "{REPO}", v[2])
    local repofilegeturl = string.gsub(string.gsub(filegeturl, "{USER}", v[1]), "{REPO}", v[2])

    local repo_interop_goto = repo_location:newAction()
        :title(v[1] .. "/" .. v[2])
        :item("wither_skeleton_skull")
        :onLeftClick(function()
            if repo_start_page:getAction(2) == nil then
                --local csuccess, cerror = pcall()
                local success, error = pcall(githubmap, repo_start_page, "", repobaseurl, repofilegeturl, v[3])
                if success == false then
                    print("Traversal Failed")
                    --print(error)
                    errorclick()
                end
            end
            action_wheel:setPage(repo_start_page)
            pageclick()
        end)
    local return_action = repo_start_page:newAction()
        :title("Go Back")
        :item("firework_rocket")
        :onLeftClick(function()
            action_wheel:setPage(repo_location)
            pageclick()
        end)
end

-- Utility Functions:

function whitespacereplacer(str)
    return string.gsub(str, " ", "%%20")
end