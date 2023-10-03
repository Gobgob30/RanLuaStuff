local args = { ... }
if #args < 4 then
    commands.say("Usage: recreateBlockData <x> <y> <z> <max_size> <?min_size>")
    return
elseif #args > 5 then
    commands.say("Usage: recreateBlockData <x> <y> <z> <max_size> <?min_size>")
    return
end
local has_perlin, perlin = pcall(require, "perlin")
if not has_perlin then
    shell.run("wget", "https://raw.githubusercontent.com/Gobgob30/RanLuaStuff/main/Perlin/perlin.lua", "perlin.lua")
    has_perlin, perlin = pcall(require, "perlin")
    if not has_perlin then
        error("Failed to load pearlin\n" .. tostring(perlin))
    end
end
local x, y, z = args[1], args[2], args[3]
local max_size = tonumber(args[4])
local min_size = tonumber(args[5]) or 0
local cmds = {}
for i = -max_size, max_size do
    for j = -max_size, max_size do
        for k = -max_size, max_size do
            local distance = math.sqrt(i * i + j * j + k * k)
            local new_max = math.floor(perlin.helpers.map(perlin.perlin_3d(x + j, y + i, z + k, 25, 5, .5, 2), -1, 1, min_size, max_size))
            if distance > min_size and distance < new_max then
                table.insert(cmds, function()
                    commands.exec(string.format("execute if block %d %d %d air run setblock %d %d %d %s", x + j, y + i, z + k, x + j, y + i, z + k, "connectedglass:borderless_glass"))
                end)
            end
        end
    end
end
require("run")(cmds)
