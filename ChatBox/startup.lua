local m_settings = 1
local s_settings = 2

local m_ready_channel = 9
local s_ready_channel = 10

local chat_box = peripheral.find("chatBox")
if not chat_box and not (commands.execute("if", "block", "~", "~-1", "~", "air") and commands.setblock("~", "~-1", "~", "advancedperipherals:chat_box") and sleep(.5) == nil) then error("Computer chat box not found and cannot create one", 2) end
chat_box = chat_box or peripheral.find("chatBox")
local owner_id = settings.get("self.owner_id")

local use_modem
local function find_modem()
    local modem = peripheral.find("modem")
    if not modem and not ((commands.execute("if", "block", "~", "~1", "~", "air") or commands.execute("if", "block", "~", "~1", "~", "computercraft:disk_drive")) and commands.setblock("~", "~1", "~", "computercraft:wired_modem_full{PeripheralAccess:1b}") and sleep(.5) == nil) then error("Computer modem not found and cannot create one", 2) end
    use_modem = modem or peripheral.find("modem")
    if use_modem then
        use_modem.open(m_settings)
        use_modem.open(m_ready_channel)
    end
    return use_modem and true or false
end

local increment = settings.get("self.increment", 1)
local base_id = os.getComputerID()
if not os.getComputerLabel() then
    os.setComputerLabel("MainCommandPC")
end

function spiralCoordinates(iteration)
    local x, z = 0, 0
    local dx, dz = 0, -1
    local currentIteration = 0

    while currentIteration < iteration do
        if x == z or (x < 0 and x == -x) or (x > 0 and x == 1 - z) or (x > 0 and x == z) or (x < 0 and x == -z) then
            dx, dz = -dz, dx
        end
        x, z = x + dx, z + dz
        currentIteration = currentIteration + 1
    end

    return x, z
end

local r_str = "~%d"
local function stage1(id, pos_x, pos_z)
    return {
        function()
            commands.setblock(r_str:format(pos_x), "~", r_str:format(pos_z), "computercraft:computer_command{ComputerId:" .. id .. "} destroy")
        end,
        function()
            commands.setblock(r_str:format(pos_x), "~1", r_str:format(pos_z), "computercraft:wired_modem_full{PeripheralAccess:1b}")
        end,
        function()
            commands.setblock("~", "~1", "~", "computercraft:disk_drive{Item:{id:\"computercraft:computer_normal\",Count:1b,tag:{ComputerId:" .. id .. "}}} destroy")
        end
    }
end

local function write_func(disk, port)
    local data_f = fs.open("subs_startup.lua", "r")
    local data = data_f.readAll()
    data_f.close()
    local f = fs.open(fs.combine(disk.getMountPath(), "startup.lua"), "w")
    f.write(data)
    f.close()
    f = fs.open(fs.combine(disk.getMountPath(), ".settings"), "w")
    f.write(textutils.serialize({
        ["self.modem_port"] = port,
        ["self.owner_id"] = settings.get("self.owner_id"),
    }))
    f.close()
    sleep(1)
end

local function stage2(id, pos_x, pos_z)
    return {
        function()
            commands.computercraft("turn-on", "#" .. id)
        end,
        function()
            commands.setblock("~", "~1", "~", "computercraft:wired_modem_full{PeripheralAccess:1b}")
        end,
        function()
            commands.kill("@e[distance=..5,type=item]")
        end,
    }
end

local default_prefixes = { "bios", "edit", "list", "lua", "motd", "paint", "shell", "modem_port", "self" }
local function is_default(name)
    for i, v in ipairs(default_prefixes) do
        if name:match("^" .. v) then
            return true
        end
    end
    return false
end

local banned_settings = {
    ["GIT_HUB_TOKEN"] = true,
}

local function null_func()
    return
end

local timer_funcs = {
    {
        is_active = true,
        id = os.startTimer(1),
        event = "push_setting",
        time = 1
    },
    {
        is_active = true,
        id = os.startTimer(1),
        event = "get_ready_ports",
        time = 1
    }
}

local hard_coded_functions = {
    ["cancel"] = function(...)
        os.queueEvent("terminate_subs", ...)
        return
    end,
    ["reset_settings"] = function()
        os.queueEvent("reset_settings")
    end,
}
local hard_coded_commands = {
    ["cancel"] = hard_coded_functions["cancel"],
    ["stop"] = hard_coded_functions["cancel"],
    ["reset_settings"] = hard_coded_functions["reset_settings"],
    ["set_r"] = hard_coded_functions["reset_settings"],
}

local tries = 0
local ready_ports = {}
local queuedRun_Events = {}
local event_handlers = {
    ["default"] = function(...)
        print("unknown event", ...)
    end,
    ["chat"] = function(...)
        local event, username, message, uuid, isHidden = ...
        if not owner_id then
            os.queueEvent("register", username, message, uuid)
        elseif uuid ~= owner_id then
            return
        end
        if message:sub(1, 1) == "!" then
            os.queueEvent("run", username, message:sub(2))
            return
        end
        os.queueEvent("parse", username, message)
    end,
    ["parse"] = function(...)
        local event, username, message = ...
        local args = {}
        for arg in message:gmatch("[^%s]+") do
            -- Remove any surrounding quotes
            arg = arg:gsub('^"', ''):gsub('"$', ''):gsub("^'", ''):gsub("'$", '')
            table.insert(args, arg)
        end
        if #args == 0 then
            table.insert(args, message)
            -- return
        end
        local name = table.remove(args, 1)
        local fn = fs.combine("commands", name .. ".lua")
        -- if name:lower() == "stop" or name:lower() == "cancel" then
        if hard_coded_commands[name] then
            hard_coded_commands[name](table.unpack(args))
        elseif fs.exists(fn) then
            local f = fs.open(fn, "r")
            local func = f.readAll()
            f.close()
            os.queueEvent("run", username, func, table.unpack(args))
        end
    end,
    ["modem_message"] = function(...)
        local event, side, channel, replyChannel, message, distance = ...
        if channel == m_ready_channel then -- Ready return channel
            os.queueEvent("receive_ready", replyChannel, message)
        elseif channel == m_settings then
            os.queueEvent("grab_setting", message)
        end
    end,
    ["register"] = function(...)
        local event, username, message, uuid = ...
        if message ~= "register" then
            commands.tellraw(username, { text = "Please register this computer with the owner by having them type 'register'", color = "red" })
            return
        end
        owner_id = uuid
        settings.set("self.owner_id", uuid)
    end,
    ["run"] = function(...)
        if not use_modem and not find_modem() then
            return
        end
        if #ready_ports == 0 then
            timer_funcs[2].is_active = true
            timer_funcs[2].id = os.startTimer(.01)
            table.insert(queuedRun_Events, { ... })
            return
        end
        local t = { ... }
        table.remove(t, 1)
        local username, func, args = t[1], t[2], { table.unpack(t, 3) }
        local port = table.remove(ready_ports)
        use_modem.transmit(port, 0, textutils.serializeJSON({
            func = func,
            name = username,
            args = args
        }))
    end,
    ["get_ready_ports"] = function(...)
        if not use_modem and not find_modem() then
            return
        end
        tries = tries + 1
        if tries > 10 then
            os.queueEvent("new_bot_pc")
            tries = 0
        end
        use_modem.transmit(s_ready_channel, m_ready_channel, "ready")
    end,
    ["receive_ready"] = function(...)
        local event, port, message = ...
        if message == "ready" then
            if timer_funcs[2].is_active then
                timer_funcs[2].is_active = false
                os.cancelTimer(timer_funcs[2].id)
            end
            table.insert(ready_ports, port)
            if #queuedRun_Events > 0 then
                for i = 1, #queuedRun_Events do
                    local t = table.remove(queuedRun_Events, 1)
                    os.queueEvent(table.unpack(t))
                end
            end
        end
    end,
    ["terminate_subs"] = function(...)
        local f = {}
        local ides = { ... }
        table.remove(ides, 1)
        if #ides == 0 then
            for i = 1, increment do
                table.insert(ides, base_id + i)
            end
        end
        for i, v in ipairs(ides) do
            table.insert(f, function()
                commands.computercraft("shutdown", "#" .. v)
                sleep(.1)
                commands.computercraft("turn-on", "#" .. v)
            end)
        end
        parallel.waitForAll(table.unpack(f))
    end,
    ["new_bot_pc"] = function()
        local x, z = spiralCoordinates(increment)
        local cp_id = base_id + increment
        local port = 10 + increment
        local disk
        repeat
            parallel.waitForAll(table.unpack(stage1(cp_id, x, z)))
            local _, side = os.pullEvent("peripheral")
            disk = peripheral.wrap(side)
        until disk and disk.isDiskPresent()
        write_func(disk, port)
        parallel.waitForAll(table.unpack(stage2(cp_id, x, z)))
        increment = increment + 1
        settings.set("self.increment", increment)
        settings.save()
        sleep(.5)
        find_modem()
        os.queueEvent("get_ready_ports")
        os.queueEvent("redraw")
    end,
    ["redraw"] = function(...)
        term.setCursorPos(1, 1)
        term.clearLine()
        print("Base ID is:", base_id)
        term.clearLine()
        print("Current Max is:", base_id + increment)
    end,
    ["timer"] = function(...)
        local event, id = ...
        for i, v in ipairs(timer_funcs) do
            if v.id == id then
                os.queueEvent(v.event)
                v.id = v.is_active and os.startTimer(v.time) or 0
                break
            end
        end
    end,
    ["grab_setting"] = function(...)
        local event, message = ...
        local data = textutils.unserializeJSON(message)
        if not data then
            return
        end
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
    ["push_setting"] = function(...)
        if not use_modem and not find_modem() then
            return
        end
        local names = settings.getNames()
        local setting = {}
        for i, v in ipairs(names) do
            if not is_default(v) and not banned_settings[v] then
                setting[v] = settings.get(v)
            end
        end
        local data = textutils.serializeJSON(setting)
        use_modem.transmit(s_ready_channel, 0, data)
    end,
    ["reset_settings"] = function(...)
        if not use_modem and not find_modem() then
            return
        end
        local names = settings.getNames()
        local setting = {}
        for i, v in ipairs(names) do
            if not is_default(v) then
                settings.unset(v)
            end
        end
        settings.save()
        local data = textutils.serializeJSON(setting)
        local ides = { ... }
        table.remove(ides, 1)
        if #ides == 0 then
            for i = 1, increment do
                table.insert(ides, 10 + i)
            end
        end
        use_modem.transmit(s_settings, 0, data)
    end,
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
    handler(table.unpack(event))
    -- local b, err = pcall(handler, table.unpack(event))
    -- if not b then
    --     print("Error in event handler", err)
    -- end
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
