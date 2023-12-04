local function update_startup(cp_id)
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
    f, errr = fs.open(fs.combine(disk.getMountPath(), ".settings"), "r")
    if f then
        data = f.readAll()
        f.close()
    else
        data = textutils.serialize({
            modem_port = cp_id - os.getComputerID() + 1,
            owner_id = settings.get("owner_id"),
        })
    end
    local u_data = textutils.unserialise(data)
    if not u_data then
        u_data = {
            modem_port = cp_id - os.getComputerID() + 1,
            owner_id = settings.get("owner_id"),
        }
    end
    u_data.owner_id = settings.get("owner_id")
    if not u_data.modem_port then
        u_data.modem_port = cp_id - os.getComputerID() + 1
    end
    f = fs.open(fs.combine(disk.getMountPath(), ".settings"), "w")
    f.write(textutils.serialise(u_data))
    f.close()
    commands.computercraft("shutdown", "#" .. cp_id)
    commands.computercraft("turn-on", "#" .. cp_id)
    commands.setblock("~", "~", "~-1", "air")
end

local sub_z_index = settings.get("sub_index", 1)
local base_cp_id = os.getComputerID()
for i = 1, sub_z_index do
    update_startup(base_cp_id + i)
end
os.reboot()