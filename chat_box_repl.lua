local chat_box = peripheral.find("chatBox")
if not chat_box then error("Computer chat box not found", 2) end
local owner_id = settings.get("owner_id")
local r = require "cc.require"
local _env = setmetatable({}, { __index = _ENV })
_env.require, _env.package = r.make(_env, "/")

local function run_func(name, func, ...)
    local args = { ... }
    parallel.waitForAny(function()
        local ret = { pcall(func, table.unpack(args)) }
        local bool = ret[1]
        for i, v in ipairs(ret) do
            if type(v) == "table" then
                ret[i] = textutils.serialize(v)
            else
                ret[i] = tostring(v)
            end
        end
        if bool then
            commands.tellraw(name, { text = table.concat(ret, " "), color = "green" })
        else
            commands.tellraw(name, { text = table.concat(ret, " "), color = "red" })
        end
    end, function()
        while true do
            local event, username, message, uuid, isHidden = os.pullEvent("chat")
            if uuid == owner_id and (message:match("cancel") or message:match("c") or message:match("stop") or message:match("s")) then
                break
            end
        end
    end)
end
if not fs.exists("commands") then
    fs.makeDir("commands")
end
while true do
    local event, username, message, uuid, isHidden = os.pullEvent("chat")
    if not owner_id and message:match("register") then
        owner_id = uuid
        settings.set("owner_id", owner_id)
        settings.save()
        commands.tellraw(username, { text = "Registered as " .. owner_id, color = "green" })
    end
    if uuid == owner_id then
        local args = {}
        for arg in message:gmatch("%S+") do
            table.insert(args, arg)
        end
        if fs.exists(fs.combine("commands", tostring(args[1]) .. ".lua")) then
            local func, err = loadfile(fs.combine("commands", tostring(args[1]) .. ".lua"), "bt", _env)
            if not func then
                commands.tellraw(username, { text = "Error: " .. err, color = "red" })
            else
                run_func(username, func, table.unpack(args, 2))
            end
        else
            local func, err = load(message, owner_id, "bt", _env)
            if not func then
                commands.tellraw(username, { text = "Error: " .. err, color = "red" })
            else
                run_func(username, func)
            end
        end
    end
end
