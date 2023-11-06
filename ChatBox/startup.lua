local chat_box = peripheral.find("chatBox")
if not chat_box and not (commands.execute("if", "block", "~", "~-1", "~", "air") and commands.setblock("~", "~-1", "~", "advancedperipherals:chat_box") and sleep(.5) == nil) then error("Computer chat box not found", 2) end
chat_box = chat_box or peripheral.find("chatBox")
local owner_id = settings.get("owner_id")

local sub_z_index = settings.get("sub_index", 1)
local sub_x_index = settings.get("sub_x_index", 0)
local movement_bool = settings.get("movement_bool", true)
local base_cp_id = os.getComputerID()
local function summon_new_sub()
    local cp_id = base_cp_id + sub_z_index
    commands.setblock("~" .. sub_x_index, "~-1", "~" .. sub_z_index % 15 == 0 and 15 or sub_z_index % 15, "computercraft:computer_command{ComputerId" .. cp_id .. "} destroy")
    commands.setblock("~" .. sub_x_index, "~", "~" .. sub_z_index % 15 == 0 and 15 or sub_z_index % 15, "computercraft:wired_modem_full{PeripheralAccess:1b}")
    local disk
    repeat
        commands.setblock("~", "~", "~-1", "computercraft:disk_drive{Item:{id:\"computercraft:computer_normal\",Count:1b,tag:{ComputerId:" .. cp_id .. "}}} destroy")
        sleep(1)
        disk = peripheral.wrap("front")
    until disk and disk.isDiskPresent()
    local data_f = fs.open("subs_startup.lua", "r")
    local data = data_f.readAll()
    data_f.close()
    local f = fs.open(fs.combine(disk.getMountPath(), "startup.lua"), "w")
    f.write(data)
    f.close()
    f = fs.open(fs.combine(disk.getMountPath(), ".settings"), "w")
    f.write(textutils.serialize({
        modem_port = sub_z_index + 1,
        settings.get("owner_id"),
    }))
    f.close()
    commands.computercraft("turn-on", "#" .. cp_id)
    if sub_z_index % 15 == 0 then
        sub_x_index = sub_x_index + 1
    end
    sub_z_index = sub_z_index + 1
end

local function run_func(name, func, ...)
    local modem = peripheral.find("modem")
    if not modem then
        summon_new_sub()
        modem = peripheral.find("modem")
    end
    modem.open(1)
    local channel = 1
    repeat
        channel = channel + 1
        modem.transmit(channel, 1, "ready")
        local event, side, r_channel, replyChannel, message, distance
        parallel.waitForAny(function()
            event, side, r_channel, replyChannel, message, distance = os.pullEvent("modem_message")
        end, function()
            sleep(1)
        end)
    until message == "ready"
    local data = textutils.serialise({
        args = { ... },
        name = name,
        func = func,
    })
    modem.transmit(channel, 1, data)
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
    elseif not owner_id then
        commands.tellraw(username, { text = "Please register first", color = "red" })
    elseif uuid == owner_id then
        local args = {}
        for arg in message:gmatch("%S+") do
            table.insert(args, arg)
        end
        if fs.exists(fs.combine("commands", tostring(args[1]) .. ".lua")) then
            local f = fs.open(fs.combine("commands", tostring(args[1]) .. ".lua"), "r")
            local data = f.readAll()
            f.close()
            run_func(username, data)
        else
            run_func(username, message)
        end
    end
end
