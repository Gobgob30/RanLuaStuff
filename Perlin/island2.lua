local hasYield, yield = pcall(require, "yield")
if not hasYield then
    shell.run("wget", "https://raw.githubusercontent.com/Gobgob30/RanLuaStuff/main/yield.lua", "yield.lua")
    hasYield, yield = pcall(require, "yield")
    if not hasYield then
        error("Failed to load yield\n" .. tostring(yield))
    end
end
yield = yield.yield

local function run(run_table)
    if #run_table > 64 * 1 then
        local run_new_tbl = {}
        for i = 1, 64 * 1 do
            table.insert(run_new_tbl, table.remove(run_table, 1))
        end
        parallel.waitForAll(table.unpack(run_new_tbl))
        return run(run_table)
    else
        parallel.waitForAll(table.unpack(run_table))
    end
end

local hasPerlin, perlin = pcall(require, "perlin")
if not hasPerlin then
    shell.run("wget", "https://raw.githubusercontent.com/Gobgob30/RanLuaStuff/main/perlin.lua", "perlin.lua")
    hasPerlin, perlin = pcall(require, "perlin")
    if not hasPerlin then
        error("Failed to load pearlin\n" .. tostring(perlin))
    end
end
local function ranNum(lower_bound, upper_bound)
    return lower_bound + math.random() * (upper_bound - lower_bound)
end

local function help()
    print("Usage: island2 <size> <scale> <octaves> <persistance> <lacunarity> <x> <y> <z>")
    print("size: the size of the map, default: 25")
    print("scale: the scale of the map, default: 0.0295843")
    print("octaves: the number of octaves, default: 3")
    print("persistance: the persistance of the map, default: .5")
    print("lacunarity: the lacunarity of the map, default: 1.2568")
    print("x: the x coordinate of the center of the map")
    print("y: the y coordinate of the center of the map")
    print("z: the z coordinate of the center of the map")
    return false
end

local args = { ... }
local function parseArgs(arguments)
    if not arguments then
        help()
        return error("No arguments provided")
    elseif #arguments == 0 then
        help()
        return error("No arguments provided")
    elseif arguments[1] == "help" then
        return help()
    end
    if not tonumber(arguments[1]) or not tonumber(arguments[2]) or not tonumber(arguments[3]) then
        return error(string.format("No coordinates provided %s %s %s", arguments[1], arguments[2], arguments[3]))
    end
    return tonumber(arguments[4]) or 25,
        tonumber(arguments[5]) or 25,
        tonumber(arguments[6]) or 5,
        tonumber(arguments[7]) or .5,
        tonumber(arguments[8]) or 2,
        tonumber(arguments[1]),
        tonumber(arguments[2]),
        tonumber(arguments[3])
end
local seed = math.random()
local size, scale, octaves, persistance, lacunarity, x, y, z = parseArgs(args)
print("size: " .. size .. ", scale: " .. scale .. ", octaves: " .. octaves .. ", persistance: " .. persistance .. ", lacunarity: " .. lacunarity .. ", x: " .. x .. ", y: " .. y .. ", z: " .. z)
local command = { function() commands.say(string.format("fill %s %s %s %s %s %s air", x + size, y + size, z + size, x - size, y - size, z - size)) end }
local blocks = {}
for i = -size, size do
    for j = -size, size do
        local bottom_height = math.floor(perlin.helpers.map(perlin.perlin_2d(i, j, scale, octaves * 2, persistance, lacunarity, seed), -1, 1, 1, 25))
        local surface = math.floor(perlin.helpers.map(perlin.perlin_2d(i, j, scale, octaves, persistance, lacunarity, seed), -1, 1, 1, 15))
        table.insert(blocks, { height = bottom_height, surface = surface })
        local distance = math.sqrt(i ^ 2 + j ^ 2)
        if distance <= perlin.helpers.map(perlin.perlin_2d(i, j, scale, octaves, persistance, lacunarity, seed), -1, 1, 1, size) then
            local has_grassed = false
            local should_dirt = true
            local dirts = 0
            for k = surface, -bottom_height, -1 do
                if perlin.perlin_3d(i, k, j, scale, octaves / 2, persistance, lacunarity, seed) > 0 then
                    if not has_grassed then
                        has_grassed = true
                        table.insert(command, function()
                            commands.setblock(x + i, y + k, z + j, "minecraft:grass_block")
                        end)
                        if math.random() > 0.95 then
                            table.insert(command, function()
                                commands.setblock(x + i, y + k + 1, z + j, "minecraft:oak_sapling")
                            end)
                        end
                    elseif has_grassed and should_dirt and dirts < 3 then
                        dirts = dirts + 1
                        table.insert(command, function()
                            commands.setblock(x + i, y + k, z + j, "minecraft:dirt")
                        end)
                    else
                        table.insert(command, function()
                            commands.setblock(x + i, y + k, z + j, "minecraft:stone")
                        end)
                    end
                elseif should_dirt and dirts < 3 then
                    should_dirt = false
                end
                yield()
            end
        end
    end
end
-- for i = -size, size do
--     for k = -size, size do
--         local has_grassed = false
--         local should_dirt = true
--         local dirts = 0
--         for j = size, -size, -1 do
--             if blocks[x + i] and blocks[x + i][y + j] and blocks[x + i][y + j][z + k] then
--                 if not has_grassed then
--                     has_grassed = true
--                     table.insert(command, function()
--                         commands.setblock(x + i, y + j, z + k, "minecraft:grass_block")
--                     end)
--                 elseif has_grassed and should_dirt and dirts < 3 then
--                     table.insert(command, function()
--                         commands.setblock(x + i, y + j, z + k, "minecraft:dirt")
--                     end)
--                     dirts = dirts + 1
--                 else
--                     table.insert(command, function()
--                         commands.setblock(x + i, y + j, z + k, "minecraft:stone")
--                     end)
--                 end
--             elseif should_dirt and dirts < 3 then
--                 should_dirt = false
--             end
--         end
--     end
-- end
run(command)
