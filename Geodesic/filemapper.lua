-- Custom Folder Icons:

local folder_icons = {
    ["FOLDER NAME"] = "item_id",
}

-- Main Functions:

function maphex(str)
    local start_path = str .. "/"
    local local_nodes = file:list(str)
    local full_map = {}
    for k, v in pairs(local_nodes) do
        if file:isFile(start_path .. v) and (nil ~= (string.find(v, ".hexpattern"))) then
            full_map[k] = {path = (start_path .. v), name = v, isHexpattern = true, isDirectory = false}
        elseif file:isDirectory((start_path .. v)) and (string.find(v, "%.") == nil) then
            local table_construct = {path = (start_path .. v), name = v, isHexpattern = false, isDirectory = true, files = nil}
            table_construct["files"] = maphex((start_path .. v))
            full_map[k] = table_construct
        end
    end
    return full_map
end

function map_onto_wheel(table,page)
    local local_nodes = table
    for k, v in pairs(local_nodes) do
        if v["isDirectory"] == true then
            local new_page = action_wheel:newPage()
            local page_shift = page:getSlotsShift()
            local goto_action = page:newAction()
                :title(v["name"])
                :item(folder_icons[v["name"]] or "book")
                :onLeftClick(function()
                    action_wheel:setPage(new_page)
                    page_shift = page:getSlotsShift()
                    pageclick()
                end)
            local return_action = new_page:newAction()
                :title("Go Back")
                :item("firework_rocket")
                :onLeftClick(function()
                    action_wheel:setPage(page)
                    page:setSlotsShift(page_shift)
                    page_shift = 1
                    pageclick()
                end)
            map_onto_wheel(v["files"],new_page)
        elseif v["isHexpattern"] == true then
            hexpat_list[v["name"]] = v["path"]
            hexpat_list_indexed[#hexpat_list_indexed+1] = v["name"]
            local import_caller = page:newAction()
                :title(v["name"])
                :item("paper")
                :onLeftClick(function()
                    local readsucc, readret = pcall(filereader, v["path"])
                    if readsucc == true then
                        local importsucc, callret = pcall(caller,readret)
                        if importsucc == false then
                            print(callret)
                            errorclick()
                        elseif callret == true then
                            print(v["name"])
                            print("Import Request Confirmed")
                            last_requested_hex = v["name"]
                            infobuttonsetter()
                            importclick()
                        elseif callret == false then
                            print("Request Currently Full")
                            failclick()
                        end
                    elseif readsucc == false then
                        print(readret)
                        errorclick()
                    end
                end)
                :onRightClick(function()
                    local filereadsucc, filereadret = pcall(filereader, v["path"])
                    if filereadsucc == true then
                        local readsucc, readerror = pcall(reader,filereadret,v["name"])
                        if readsucc == false then
                            print(readerror)
                            errorclick()
                        elseif readsucc == true then
                            readfileclick()
                        end
                    elseif filereadsucc == false then
                        print(filereadret)
                        errorclick()
                    end
                end)
        end
    end
end

function mapperwrapper(str,page)
    hexpat_list = {}
    hexpat_list_indexed = {}
    map_onto_wheel(maphex(str),page)
end

function initmap()
    mapperwrapper(Hex_repository,file_system)
    infobuttonsetter(tablesize(hexpat_list),last_requested_hex,isbusy)
end

function reader(str,filename)
    str = string.gsub(str, "\r\n", "\n")
    str = string.gsub(str, "\n\r", "\n")
    str = string.gsub(str, "\r", "\n")
    str = "\n" .. str 
    if string.match(str, "\n$") ~= nil then -- To get rid of leading newline
        str  = string.sub(str, 1, -2)
    end
    print(str)
    print(filename)
end


-- Init:

file_system = action_wheel:newPage()
Hex_repository = nil -- The name of the folder in figura/data which contains .hexpattern files to be imported
file_system_location = nil -- Action wheel page variable, where the geodesic page, and also the page for auxillaries, gets created

function events.entity_init()

geodesic_filemap_goto_action = file_system_location:newAction()
    :title("Project: Geodesic")
    :item("heart_of_the_sea")
    :onLeftClick(function()
        action_wheel:setPage(file_system)
        pageclick()
        -- To reduce init instruction count:
        if file_system:getAction(3) == nil then
            initmap()
        end
    end)

geodesic_filemap_return_action = file_system:newAction()
    :title("Go Back")
    :item("firework_rocket")
    :onLeftClick(function()
        action_wheel:setPage(file_system_location)
        pageclick()
    end)

geodesic_filemap_recalc_and_info = file_system:newAction()
    :title("Recalculate Map")
    :item("filled_map")
    :onLeftClick(function()
        recalcmap()
        action_wheel:setPage(file_system)
        buttonclick()
    end)

end

-- Map Recalculation:

function recalcmap()
    file_system = action_wheel:newPage()

    geodesic_filemap_return_action = file_system:newAction()
        :title("Go Back")
        :item("firework_rocket")
        :onLeftClick(function()
            action_wheel:setPage(file_system_location)
            pageclick()
        end)

    geodesic_filemap_recalc_and_info = file_system:newAction()
    :title("Recalculate Map")
    :item("filled_map")
    :onLeftClick(function()
        recalcmap()
        action_wheel:setPage(file_system)
        buttonclick()
    end)

    initmap()

    print("Filemap Recalculated")
end

-- Info Button System:

hexpat_list = {}
hexpat_list_indexed = {}

last_requested_hex = ""

function infobuttonsetter(filecount,lastrequestedhex,busystate)
    local fc = filecount or tablesize(hexpat_list)
    local duplicates = #hexpat_list_indexed - tablesize(hexpat_list)
    local lrh = lastrequestedhex or last_requested_hex
    local bs = busystate or isbusy
    local busy = ""
    if bs then
        busy = "§cBusy"
    else
        busy = "§aFree"
    end
    local lrht = ""
    if lrh ~= "" then
        lrht = "§b"	.. lrh
    else
        lrht = "§7N/A"
    end
    if duplicates ~= 0 then
        duplicates = " §f+ " .. "§c" .. duplicates
    elseif duplicates == 0 then
        duplicates = ""
    end
    local result = "§fClick to Recalculate Map\n\n" .. "§fFile Count: " .. "§9" .. fc .. duplicates .. "\n" .. "§fLast Requested Hex: " .. lrht .. "\n" .. "§fImporter Availability: " .. busy
    geodesic_filemap_recalc_and_info:title(result)
end

-- Utility Functions:

function tablesize(table)
    local size = 0
    for k, v in pairs(table) do
        size = size + 1
    end
    return size
end

