local function make_block(x, y, z, id)
    commands.setblock(x, y, z, "computercraft:computer_command{ComputerId:" .. id .. "} destroy")
    commands.setblock(x, y + 1, z, "computercraft:wireless_modem_advanced[facing=down] destroy")
end
local x, y, z = commands.getBlockPosition()
local cp_id = math.random(999, 9998)
y = y - 1
commands.setblock(x, y, z, "computercraft:disk_drive{Item:{id:\"computercraft:computer_normal\",Count:1b,tag:{ComputerId:" .. cp_id .. "}}} destroy")
sleep(1)
y = y + 4
local drive = peripheral.wrap("bottom")
if not drive or not drive.isDiskPresent() then error("Computer drive not generated or disk is not present", 2) end
local f = fs.open(fs.combine(drive.getMountPath(), "startup.lua"), "w")
f.write("shell.run(\"gps host\", commands.getBlockPosition())")
f.close()
local height = 4
local width = height + 1
make_block(x, y, z, cp_id)
make_block(x, y + height, z, cp_id)
make_block(x, y, z + width, cp_id)
make_block(x + width, y, z, cp_id)
sleep(1)
commands.say(commands.computercraft("turn-on", "#" .. cp_id))
