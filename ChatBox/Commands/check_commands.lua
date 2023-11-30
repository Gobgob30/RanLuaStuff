local has_base64, base64 = pcall(require, "base64")
if not has_base64 then
    shell.run("wget https://raw.githubusercontent.com/iskolbin/lbase64/master/base64.lua")
    has_base64, base64 = pcall(require, "base64")
    if not has_base64 then
        error("Failed to download base64.")
    end
end

local function difference(file_name, old_content, content)
    local old_lines = {}
    local lines = {}
    for line in old_content:gmatch("[^\n]+") do
        table.insert(old_lines, line)
    end
    for line in content:gmatch("[^\n]+") do
        table.insert(lines, line)
    end
    local diff = {}
    for i, line in ipairs(lines) do
        local b, old_line_n = true, 0
        for j, old_line in ipairs(old_lines) do
            if line == old_line then
                b = false
                old_line_n = j
                break
            end
        end
        if b then
            table.insert(diff, { old = old_line_n, new = i })
        end
    end
    local output = "File: " .. file_name .. "\n"
    for _, line in ipairs(diff) do
        output = output .. "#" .. line.old .. " " .. old_lines[line.old] .. " -> " .. "#" .. line.new .. " " .. lines[line.new] .. "\n"
    end
    return output
end

local commands_folder = fs.combine(fs.getDir(shell.getRunningProgram()), "commands")
local commit_message = (print("Please enter a commit message: ") and read()) or "Update commands"
for _, file in ipairs(fs.list(commands_folder)) do
    local file_name = fs.combine(commands_folder, file)
    if not fs.isDir(file_name) then
        local file_handle = fs.open(file_name, "r")
        local old_content = file_handle.readAll()
        file_handle.close()
        local request, err = http.get("https://raw.githubusercontent.com/Gobgob30/RanLuaStuff/main/ChatBox/Commands/" .. file)
        if request then
            local content = request.readAll()
            request.close()
            if content ~= old_content then
                print("?cFile " .. file_name .. " is different from the one on GitHub. Do you want to update it?")
                local read_ = read()
                if read_:lower():match("y") then
                    local write_file_handle = fs.open(file_name, "w")
                    write_file_handle.write(content)
                    write_file_handle.close()
                end
            end
        elseif err ~= "Not Found" then
            print("Error while checking commands: " .. err)
        else
            print("File " .. file_name .. " not found on GitHub. Would you like to upload it?")
            local read_ = read()
            if read_:lower():match("y") then
                while not settings.get("GIT_HUB_TOKEN") do
                    print("Please enter your GitHub token: ")
                    local token = read()
                    if #token < #40 or #token > #40 then
                        print("Invalid token.")
                    else
                        settings.set("GIT_HUB_TOKEN", token)
                    end
                end
                local url = "https://api.github.com/repos/Gobgob30/RanLuaStuff/contents/ChatBox/Commands/" .. file
                -- local _, _, handle = http.post(url, textutils.serializeJSON({ message = "Update " .. file, content = base64.encode(old_content) }), { Authorization = "token " .. settings.get("GIT_HUB_TOKEN") })
                http.request {
                    url = url,
                    body = textutils.serializeJSON({ message = commit_message, content = base64.encode(old_content) }),
                    headers = { Authorization = "token " .. settings.get("GIT_HUB_TOKEN") },
                    method = "PUT"
                }
                local handle
                parallel.waitForAny(function()
                    _, _, handle = os.pullEvent("http_success")
                end, function()
                    _, _, handle = os.pullEvent("http_failure")
                end)
                local responseCode = handle.getResponseCode()
                local responseHeaders = handle.getResponseHeaders()
                local response = handle.readAll()
                handle.close()
                if responseCode == 200 or responseCode == 201 then
                    print("File " .. file_name .. " uploaded successfully.")
                elseif responseCode == 422 then
                    error("Validation failed.")
                else
                    error("Error while uploading file: " .. responseCode .. "\n" .. textutils.serialise(responseHeaders) .. "\n" .. response)
                end
            end
        end
    end
end
-- Doing the same but for the base files
local blacklist = { [".settings"] = true, ["run.lua"] = true, ["commands"] = true, ["base64.lua"] = true }
for _, file_name in ipairs(fs.list("/")) do
    if not fs.isDir(file_name) and not blacklist[file_name] then
        local file_handle = fs.open(file_name, "r")
        local old_content = file_handle.readAll()
        file_handle.close()
        local request, err = http.get("https://raw.githubusercontent.com/Gobgob30/RanLuaStuff/main/ChatBox/" .. file_name)
        if request then
            local content = request.readAll()
            request.close()
            if content ~= old_content then
                print("?cFile " .. file_name .. " is different from the one on GitHub. Do you want to update it?")
                local read_ = read()
                if read_:lower():match("y") then
                    local write_file_handle = fs.open(file_name, "w")
                    write_file_handle.write(content)
                    write_file_handle.close()
                end
            end
        elseif err ~= "Not Found" then
            print("Error while checking commands: " .. err)
        else
            print("File " .. file_name .. " not found on GitHub. Would you like to upload it?")
            local read_ = read()
            if read_:lower():match("y") then
                while not settings.get("GIT_HUB_TOKEN") do
                    print("Please enter your GitHub token: ")
                    local token = read()
                    if #token < #40 or #token > #40 then
                        print("Invalid token.")
                    else
                        settings.set("GIT_HUB_TOKEN", token)
                    end
                end
                local url = "https://api.github.com/repos/Gobgob30/RanLuaStuff/contents/ChatBox/" .. file_name
                -- local _, _, handle = http.post(url, textutils.serializeJSON({ message = "Update " .. file, content = base64.encode(old_content) }), { Authorization = "token " .. settings.get("GIT_HUB_TOKEN") })
                http.request {
                    url = url,
                    body = textutils.serializeJSON({ message = commit_message, content = base64.encode(old_content) }),
                    headers = { Authorization = "token " .. settings.get("GIT_HUB_TOKEN") },
                    method = "PUT"
                }
                local handle
                parallel.waitForAny(function()
                        _, _, handle = os.pullEvent("http_success")
                    end,
                    function()
                        _, _, handle = os.pullEvent("http_failure")
                    end)
                local responseCode = handle.getResponseCode()
                local responseHeaders = handle.getResponseHeaders()
                local response = handle.readAll()
                handle.close()
                if responseCode == 200 or responseCode == 201 then
                    print("File " .. file_name .. " uploaded successfully.")
                elseif responseCode == 422 then
                    error("Validation failed.")
                else
                    error("Error while uploading file: " .. responseCode .. "\n" .. textutils.serialise(responseHeaders) .. "\n" .. response)
                end
            end
        end
    end
end