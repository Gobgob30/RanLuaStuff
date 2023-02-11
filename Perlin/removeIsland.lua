local x, y, z = 300, 64, 300
local size = 50
local x1, y1, z1 = x - size, y - size, z - size
local x2, y2, z2 = x + size, y + size, z + size
local command = string.format([[/tellraw Sea_of_the_Bass [{"text":"Removed Island at: "},{"text":"%d %d %d","clickEvent":{"action":"run_command","value":"/tp %d %d %d"}}] ]], x, y, z, x, y, z)
local bool, err = commands.exec(command)
command = string.format("fill %d %d %d %d %d %d %s", x1, y1, z1, x2, y2, z2, "air")
bool, err = commands.execAsync(command)
if not bool then
    print(err[1])
end
