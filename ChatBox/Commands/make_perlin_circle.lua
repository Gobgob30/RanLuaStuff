local hasPerlin, perlin = pcall(require, "perlin")
if not hasPerlin then
    shell.run("wget", "https://raw.githubusercontent.com/Gobgob30/RanLuaStuff/main/Perlin/perlin.lua", "perlin.lua")
    hasPerlin, perlin = pcall(require, "perlin")
    if not hasPerlin then
        error("Failed to load pearlin\n" .. tostring(perlin))
    end
end
local args = { ... }
if not #args == 7 or args[4] < args[5] then
    commands.say("Usage: fill <x> <y> <z> <min> <max> <block> <replace_blocks>")
    return
end

local x, y, z = args[1], args[2], args[3]
local min = args[4]
local max = args[5]
local block = args[6]
local cmds = {}
local blocks = {}
for t = 0, 98 do
    local move = y + t
    -- want to make the max w
    local max_tapered = max - (max - min) * (t ^ 2 / 1000)
    local min_tapered = min - (max - min) * (t ^ 2 / 1000)
    max_tapered = max_tapered < 0 and 0 or max_tapered
    min_tapered = min_tapered < 0 and 0 or min_tapered
    for a = 0, math.pi * 2, .01 do
        local x_offset = math.cos(a)
        local y_offset = math.sin(a)
        local radius = perlin.helpers.map(perlin.perlin_3d(x_offset, y_offset, t, 25, 3, .25, 2), -1, 1, min_tapered, max_tapered)
        local rad_x, rad_z = math.floor((x_offset * radius) + .5) + x, math.floor((y_offset * radius) + .5) + z
        blocks[rad_x] = blocks[rad_x] or {}
        blocks[rad_x][move] = blocks[rad_x][move] or {}
        blocks[rad_x][move][rad_z] = blocks[rad_x][move][rad_z] or true
        table.insert(cmds, function()
            commands.exec(string.format("setblock %d %d %d %s replace", rad_x, move, rad_z, block))
        end)
    end
    if max_tapered == 0 then
        break
    end
end
-- local file = fs.open("reset" .. os.date("%c", os.epoch("utc") / 1000):gsub("%s", "_") .. ".lua", "w")
-- file.writeLine("local blocks = " .. tostring(textutils.serialize(blocks)))
-- file.writeLine("return blocks")
-- file.close()
require("run")(cmds, 128)
