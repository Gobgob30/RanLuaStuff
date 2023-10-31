local hasPerlin, perlin = pcall(require, "perlin")
if not hasPerlin then
    shell.run("wget", "https://raw.githubusercontent.com/Gobgob30/RanLuaStuff/main/Perlin/perlin.lua", "perlin.lua")
    hasPerlin, perlin = pcall(require, "perlin")
    if not hasPerlin then
        error("Failed to load perlin\n" .. tostring(perlin))
    end
end
local args = { ... }
local x_size = args[1] or 3
local y_size = args[2] or 4
local scale = args[3] or 10
local octaves = args[4] or 2
local persistance = args[5] or 0.5
local lacunarity = args[6] or 2
local used = {}
for i = 1, x_size * y_size do
    table.insert(used, i)
end
for i = 1, y_size do
    local line = {}
    for j = 1, x_size do
        local index = perlin.helpers.map(perlin.perlin_2d(j, i, scale, octaves, persistance, lacunarity), -1, 1, 1, #used)
        -- local index = math.random(#used)
        -- print(index)
        local value = table.remove(used, index < 0 and #used or index)
        table.insert(line, value)
    end
    print(table.concat(line, " "))
end
