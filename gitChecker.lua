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
    if #parts >= 2 and (parts[1] and parts[1]:find("github.com")) then
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
        return false, "Failed to parse GitHub URL.\n" .. tostring(url)
    end
    local githubApiUrl = "https://api.github.com/repos/" .. repoOwner .. "/" .. repoName .. "/commits?path=" .. filePath

    -- Make a GET request to the GitHub API to retrieve commit history for the file
    local response = http.get(githubApiUrl)

    if response and response.getResponseCode() == 200 then
        local responseData = response.readAll()                 -- Read the response data
        local commits = textutils.unserialiseJSON(responseData) -- Assuming you have a JSON decoding library

        if commits and #commits > 0 then
            -- The first commit in the list will be the latest one affecting the file
            local latestCommitSha = commits[1].sha

            -- Compare this commit SHA with the previously recorded one to check for updates
            -- You need to have some mechanism to store and retrieve the previous commit SHA

            -- If the SHAs are different, the file has been updated
            if latestCommitSha ~= settings.get("lastCommitSha", latestCommitSha) then
                settings.set("lastCommitSha", latestCommitSha)
                settings.save()
                return true
            else
                return false, "NO CHANGE"
            end
        else
            return false, "Failed to retrieve commit history."
        end
    else
        return false, "Failed to retrieve commit history."
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
            err("Failed to load " .. name .. "\n" .. tostring(return_module))
        end
    else
        error(error, 2)
    end
    return return_module
end

if #args > 0 then
    return get_module(args[1], args[2])
end

return {
    check_if_updated = check_if_updated,
    get_module = get_module
}
