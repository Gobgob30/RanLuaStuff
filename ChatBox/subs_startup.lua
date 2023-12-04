local r = require "cc.require"
local banned_settings = {
    ["GIT_HUB_TOKEN"] = true,
    ["sub_index"] = true,
    ["sub_x_index"] = true,
    ["movement_bool"] = true,
}

local modem = peripheral.find("modem")
if not modem then
    error("No modem found", 2)
end
local port = settings.get("modem_port") or error("No modem port set", 2)
modem.open(port)
if not os.getComputerLabel() then
    os.setComputerLabel("SubCommandPC")
end

local function run_func(name, func, ...)
    local args = { ... }
    if commands.gamerule.commandBlockOutput() then
        commands.gamerule.commandBlockOutput(false)
    end
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
            local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
            if channel == port and message == "suspend" then
                modem.transmit(replyChannel, port, "suspended")
                break
            end
        end
    end)
    if not commands.gamerule.commandBlockOutput() then
        commands.gamerule.commandBlockOutput(true)
    end
end

local defualt_prefixes = { "bios", "edit", "list", "lua", "motd", "paint", "shell", "modem_port" }
local function is_defualt(name)
    for i, v in ipairs(defualt_prefixes) do
        if name:match("^" .. v) then
            return true
        end
    end
    return false
end

local ready_bool = false
while true do
    local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
    if channel == port and message == "ready" and not ready_bool and replyChannel == 1 then
        ready_bool = true
        modem.transmit(replyChannel, port, "ready")
        write("Waiting... ")
    elseif channel == port and ready_bool and replyChannel == 1 then
        ready_bool = false
        local data = textutils.unserialize(message)
        if data then
            data.func = data.func or "return \"No function provided\""
            data.name = data.name or "@a"
            data.args = data.args or {}
            local _env = setmetatable({}, { __index = _ENV })
            _env.require, _env.package = r.make(_env, "/")
            local func, err = load(data.func, data.name, "bt", _env)
            if not func then
                commands.tellraw(data.name, { text = "Error: " .. err, color = "red" })
            else
                -- run_func(data.name, func, table.unpack(data.args))
                local ret = { pcall(func, table.unpack(data.args)) }
                if not ret[1] then commands.tellraw(data.name, { text = "Error: " .. ret[2], color = "red" }) end
                local setting = {}
                for k, v in ipairs(settings.getNames()) do
                    if banned_settings[v] then
                        settings.unset(v)
                    end
                    if not is_defualt(v) then
                        setting[v] = settings.get(v)
                    end
                end
                modem.transmit(replyChannel, port, textutils.serializeJSON(setting))
            end
        else
            write("no data ")
        end
        print("Done waiting!")
    elseif not ready_bool and channel == port and replyChannel == 1 then
        local setting = textutils.unserializeJSON(message)
        if setting then
            for k, v in ipairs(settings.getNames()) do
                if not is_defualt(v) then
                    settings.unset(v)
                end
            end
            for k, v in pairs(setting) do
                if not is_defualt(k) then
                    settings.set(k, v)
                end
            end
            settings.save()
        end
    end
end
