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
