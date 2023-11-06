local function run_func(name, func, ...)
    local args = { ... }
    commands.gamerule.commandBlockOutput(false)
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
            if uuid == settings.get("owner_id") and (message:match("cancel") or message:match("c") or message:match("stop") or message:match("s")) then
                break
            end
        end
    end)
    commands.gamerule.commandBlockOutput(true)
end
local r = require "cc.require"

local modem = peripheral.find("modem")
if not modem then
    error("No modem found", 2)
end
local port = settings.get("modem_port") or error("No modem port set", 2)
modem.open(port)
os.setComputerLabel(os.getComputerID() .. "_SubCommandPC")

local ready_bool = false
while true do
    local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
    if channel == port and message == "ready" and not ready_bool then
        ready_bool = true
        modem.transmit(port, port, "ready")
    elseif channel == port and ready_bool then
        ready_bool = false
        local data = textutils.unserialize(message)
        if data then
            local _env = setmetatable({}, { __index = _ENV })
            _env.require, _env.package = r.make(_env, "/")
            local func, err = load(data.func, data.name, "bt", _env)
            if not func then
                commands.tellraw(data.name, { text = "Error: " .. err, color = "red" })
            else
                run_func(data.name, func, table.unpack(data.args))
            end
        end
    end
end
