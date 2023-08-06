local args = { ... }
local function parseGitHubUrl(url)
    local repoOwner, repoName, filePath

    -- Remove protocol and trailing slashes from the URL
    local cleanedUrl = url:gsub("^https?://", ""):gsub("/$", "")

    -- Split the URL into parts based on "/"
    local parts = {}
    for part in cleanedUrl:gmatch("[^/]+") do
        table.insert(parts, part)
    end
    -- Check if the URL matches the GitHub repository pattern
    if #parts >= 2 and (parts[1] and parts[1]:find("github")) then
        repoOwner = parts[2]
        repoName = parts[3]

        -- Extract the file path from the remaining parts
        if #parts > 3 then
            filePath = table.concat(parts, "/", 4)
        end
    end

    return repoOwner, repoName, filePath
end

local function check_if_updated(url)
    local repoOwner, repoName, filePath = parseGitHubUrl(url)
    if not repoOwner or not repoName or not filePath then
        return false, "Failed to parse GitHub URL.\n" .. tostring(url) .. "\n" .. tostring(repoOwner) .. "\n" .. tostring(repoName) .. "\n" .. tostring(filePath)
    end
    local githubApiUrl = "https://api.github.com/repos/" .. repoOwner .. "/" .. repoName .. "/commits?path=" .. filePath

    -- Make a GET request to the GitHub API to retrieve commit history for the file
    local response, err = http.get(githubApiUrl, { headers = { ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.207.132.170 Safari/537.36" } })

    if response and response.getResponseCode() == 200 then
        local responseData = response.readAll()                 -- Read the response data
        local commits = textutils.unserialiseJSON(responseData) -- Assuming you have a JSON decoding library

        if commits and #commits > 0 then
            local latestCommitSha = commits[1].sha
            if latestCommitSha ~= settings.get(repoOwner .. "/" .. repoName .. "/" .. filePath) then
                settings.set("lastCommitSha", latestCommitSha)
                settings.save()
                return true
            else
                return false, "NO CHANGE"
            end
        elseif commits and #commits == 0 then
            return true
        else
            return false, table.concat({ tostring(err), tostring(commits) }, "\n")
        end
    else
        return false, err
    end
end

local function get_module(url, name)
    local return_module_bool, return_module
    local bool, err = check_if_updated(url)
    if bool then
        shell.run("rm", shell.dir() .. name)
        shell.run("wget", url, shell.dir() .. name)
        return_module_bool, return_module = pcall(require, shell.dir() .. name:gsub("%.lua$", ""))
        if not return_module_bool then
            error("Failed to load " .. name .. "\n" .. tostring(return_module), 2)
        end
    elseif err == "NO CHANGE" then
        if not fs.exists(shell.dir() .. name) then
            shell.run("wget", url, shell.dir() .. name)
        end
        return_module_bool, return_module = pcall(require, shell.dir() .. name:gsub("%.lua$", ""))
        if not return_module_bool then
            error("Failed to load " .. name .. "\n" .. tostring(return_module), 2)
        end
    else
        print(err)
        error(err, 2)
    end
    return return_module
end

return {
    check_if_updated = check_if_updated,
    get_module = get_module
}
