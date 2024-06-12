local m_settings = 1
local s_settings = 2

local m_ready_channel = 9
local s_ready_channel = 10

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
modem.open(s_ready_channel)
modem.open(s_settings)
if not os.getComputerLabel() then
    os.setComputerLabel("SubCommandPC")
end

local defualt_prefixes = { "bios", "edit", "list", "lua", "motd", "paint", "shell", "modem_port" }
local function is_default(name)
    for i, v in ipairs(defualt_prefixes) do
        if name:match("^" .. v) then
            return true
        end
    end
    return false
end

local function print_function(...)
    for i, v in ipairs({ ... }) do
        commands.say(tostring(v))
    end
end
local function write_function(...)
    local a = { ... }
    for i, v in ipairs(a) do
        a[i] = tostring(v)
    end
    commands.say(table.concat(a, " "))
end

local function null_func()
    return
end

local function print_dot(print_string, start, stop)
    local x, y = term.getCursorPos()
    if x == stop then
        term.setCursorPos(1, y)
        term.clearLine()
        term.write(print_string)
    end
    term.write(".")
end

local event_handlers = {
    ["default"] = function(...)
        print("unknown event", ...)
    end,
    ["modem_message"] = function(...)
        local event, side, channel, replyChannel, message, distance = ...
        if channel == port then
            local data = textutils.unserializeJSON(message)
            if not data then
                return
            end
            os.queueEvent("run", data)
        elseif channel == s_settings then
            local data = textutils.unserializeJSON(message)
            if not data then
                return
            end
            os.queueEvent("grab_settings", data)
        elseif channel == s_ready_channel then
            modem.transmit(replyChannel, port, "ready")
        end
    end,
    ["run"] = function(...)
        local name, data = ...
        data.func = data.func or "return \"No function provided\""
        data.name = data.name or "@a"
        data.args = data.args or {}
        local _env = setmetatable({}, { __index = _ENV })
        _env.require, _env.package = r.make(_env, "/")
        _env.print = print_function
        _env.write = write_function
        local str = "Running function for " .. data.name
        write(str)
        local func, err = load(data.func, "=ChatExec", "t", _env)
        if not func then
            commands.tellraw(data.name, { text = err, color = "red" })
        else
            local start = term.getCursorPos()
            local stop = term.getSize()
            parallel.waitForAny(function()
                    local ret = { pcall(func, table.unpack(data.args)) }
                    if not table.remove(ret) then
                        for i, v in ipairs(ret) do
                            ret[i] = tostring(v)
                        end
                        commands.tellraw(data.name, { text = table.concat(ret), color = "red" })
                    end
                end,
                function()
                    while true do
                        sleep(.25)
                        print_dot(str, start, stop)
                    end
                end)
        end
        print(". Done!!!")
    end,
    ["redraw"] = function(...)
        term.setCursorPos(1, 1)
        term.clearLine()
        print("ID is:", os.getComputerID())
        term.clearLine()
        print("Current Port is:", port)
    end,
    ["grab_setting"] = function(...)
        local data = ...
        for i, v in ipairs(settings.getNames()) do
            if not is_default(v) then
                settings.unset(v)
            end
        end
        for i, v in pairs(data) do
            if not is_default(i) then
                settings.set(i, v)
            end
        end
        settings.save()
    end,
    ["push_settings"] = function(...)
        local setting = {}
        for k, v in ipairs(settings.getNames()) do
            if banned_settings[v] then
                settings.unset(v)
            end
            if not is_default(v) then
                setting[v] = settings.get(v)
            end
        end
        modem.transmit(m_settings, port, textutils.serializeJSON(setting))
    end,
    ["timer"] = null_func,
    ["alarm"] = null_func,
    ["char"] = null_func,
    ["computer_command"] = null_func,
    ["disk"] = null_func,
    ["disk_eject"] = null_func,
    ["file_transfer"] = null_func,
    ["http_check"] = null_func,
    ["http_failure"] = null_func,
    ["http_success"] = null_func,
    ["key"] = null_func,
    ["key_up"] = null_func,
    ["monitor_resize"] = null_func,
    ["monitor_touch"] = null_func,
    ["mouse_click"] = null_func,
    ["mouse_drag"] = null_func,
    ["mouse_scroll"] = null_func,
    ["mouse_up"] = null_func,
    ["paste"] = null_func,
    ["peripheral"] = null_func,
    ["peripheral_detach"] = null_func,
    ["rednet_message"] = null_func,
    ["redstone"] = null_func,
    ["speaker_audio_empty"] = null_func,
    ["task_complete"] = null_func,
    ["term_resize"] = null_func,
    ["terminate"] = null_func,
    ["turtle_inventory"] = null_func,
    ["websocket_closed"] = null_func,
    ["websocket_failure"] = null_func,
    ["websocket_message"] = null_func,
    ["websocket_success"] = null_func,
    ["setting_changed"] = null_func,
}

local function event_handler_func()
    local event = { os.pullEvent() }
    local handler = event_handlers[event[1]] or event_handlers["default"]
    local b, err = pcall(handler, table.unpack(event))
    if not b then
        print("Error in event handler", err)
    end
end
term.clear()
os.queueEvent("redraw")
local x_max, y_max = term.getSize()
while true do
    event_handler_func()
    local x, y = term.getCursorPos()
    if y == y_max then
        os.queueEvent("redraw")
    end
end
