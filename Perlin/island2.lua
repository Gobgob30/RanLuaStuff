local yieldTime                            -- variable to store the time of the last yield
function yield()
    if yieldTime then                      -- check if it already yielded
        if os.clock() - yieldTime > 2 then -- if it were more than 2 seconds since the last yield
            os.queueEvent("someFakeEvent") -- queue the event
            os.pullEvent("someFakeEvent")  -- pull it
            yieldTime = nil                -- reset the counter
        end
    else
        yieldTime = os.clock() -- store the time
    end
end

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
        tonumber(arguments[5]) or .00354684,
        tonumber(arguments[6]) or 4,
        tonumber(arguments[7]) or .5,
        tonumber(arguments[8]) or 2,
        tonumber(arguments[1]),
        tonumber(arguments[2]),
        tonumber(arguments[3])
end

local size, scale, octaves, persistance, lacunarity, x, y, z = parseArgs(args)
print("size: " .. size .. ", scale: " .. scale .. ", octaves: " .. octaves .. ", persistance: " .. persistance .. ", lacunarity: " .. lacunarity .. ", x: " .. x .. ", y: " .. y .. ", z: " .. z)
local command = { function() commands.say(string.format("fill %s %s %s %s %s %s air", x + size, y + size, z + size, x - size, y - size, z - size)) end }

local blocks = {}
for i = -size, size do
    for j = -size, size do
        local height = math.floor(perlin.helpers.map(perlin.perlin_2d(i, j, scale, octaves, persistance, lacunarity), -1, 1, 1, 25))
        local surface = math.floor(perlin.helpers.map(perlin.perlin_2d(i, j, scale, octaves, persistance, lacunarity), -1, 1, 1, 6))
        table.insert(blocks, { height = height, surface = surface })
        -- local distance = math.sqrt(i ^ 2 + j ^ 2)
        -- if distance <= size then
        --     for k = -height, surface do
        --         -- if perlin.perlin_3d(i, k, j, scale / 100000, octaves, persistance, lacunarity) > 0 then
        --         blocks[x + i] = blocks[x + i] or {}
        --         blocks[x + i][y + k] = blocks[x + i][y + k] or {}
        --         blocks[x + i][y + k][z + j] = blocks[x + i][y + k][z + j] or true
        --         yield()
        --         -- end
        --     end
        -- end
    end
end
local f = fs.open("perl.json", "w")
f.write(json.encode(blocks))
f.close()
-- for i = -size, size do
--     for k = -size, size do
--         local has_grassed = false
--         local dirts = 0
--         for j = size, -size, -1 do
--             if blocks[x + i] and blocks[x + i][y + j] and blocks[x + i][y + j][z + k] then
--                 if not has_grassed then
--                     has_grassed = true
--                     table.insert(command, function()
--                         commands.setblock(x + i, y + j, z + k, "minecraft:grass_block")
--                     end)
--                 elseif has_grassed and dirts < 3 then
--                     table.insert(command, function()
--                         commands.setblock(x + i, y + j, z + k, "minecraft:dirt")
--                     end)
--                     dirts = dirts + 1
--                 else
--                     table.insert(command, function()
--                         commands.setblock(x + i, y + j, z + k, "minecraft:stone")
--                     end)
--                 end
--             end
--         end
--     end
-- end
run(command)
