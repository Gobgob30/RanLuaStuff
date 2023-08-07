local chat_box = peripheral.find("chatBox")
if not chat_box then error("Computer chat box not found", 2) end
local owner_id = settings.get("owner_id")
local r = require "cc.require"
local _env = setmetatable({}, { __index = _ENV })
_env.require, _env.package = r.make(_env, "/")
while true do
    local event, username, message, uuid, isHidden = os.pullEvent("chat")
    if not owner_id and message:match("register") then
        owner_id = uuid
        settings.set("owner_id", owner_id)
        settings.save()
        commands.tellraw(username, { text = "Registered as " .. owner_id, color = "green" })
    end
    if uuid == owner_id then
        local func, err = load("return " .. message, owner_id, "bt", _env)
        if not func then
            commands.tellraw(username, { text = "Error: " .. err, color = "red" })
        else
            local ret = { pcall(func) }
            local bool = table.remove(ret, 1)
            for i, v in ipairs(ret) do
                if type(v) == "table" then
                    ret[i] = textutils.serialize(v)
                else
                    ret[i] = tostring(v)
                end
            end
            if bool then
                commands.tellraw(username, { text = table.concat(ret, " "), color = "green" })
            else
                commands.tellraw(username, { text = table.concat(ret, " "), color = "red" })
            end
        end
    end
end
