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

local args = { ... }
local function parseArgs(arguments)
    if not arguments then
        return error("No arguments provided")
    elseif #arguments == 0 then
        return error("No arguments provided")
    elseif arguments[1] == "help" then
        print("Usage: perlin2dTest <size> <scale> <octaves> <persistance> <lacunarity> <x> <y> <z> <xMovement> <yMovement>")
        print("size: the size of the map, default: 25")
        print("scale: the scale of the map, default: 0.0295843")
        print("octaves: the number of octaves, default: 3")
        print("persistance: the persistance of the map, default: .5")
        print("lacunarity: the lacunarity of the map, default: 1.2568")
        print("x: the x coordinate of the center of the map")
        print("y: the y coordinate of the center of the map")
        print("z: the z coordinate of the center of the map")
        print("xMovement: the x movement of the map")
        print("yMovement: the y movement of the map")
        return false
    end
    local size = tonumber(arguments[1]) or 25
    local scale = tonumber(arguments[2]) or 0.0295843
    local octaves = tonumber(arguments[3]) or 3
    local persistance = tonumber(arguments[4]) or .5
    local lacunarity = tonumber(arguments[5]) or 1.2568
    local x = tonumber(arguments[6])
    local y = tonumber(arguments[7])
    local z = tonumber(arguments[8])
    local xMovement = tonumber(arguments[9]) or 0
    local zMovement = tonumber(arguments[10]) or 0
    if not x or not y then
        return error("No x or y coordinate provided")
    end
    return size, scale, octaves, persistance, lacunarity, x, y, z, xMovement, zMovement
end

local perlin = require("perlin")
local size, scale, octaves, persistance, lacunarity, x, y, z, xMovement, yMovement = parseArgs(args)
if not size then return end
local seed = math.random(100000, 999999)
local colors = {
    [0] = "minecraft:white_wool",
    [1] = "minecraft:orange_wool",
    [2] = "minecraft:magenta_wool",
    [3] = "minecraft:light_blue_wool",
    [4] = "minecraft:yellow_wool",
    [5] = "minecraft:lime_wool",
    [6] = "minecraft:pink_wool",
    [7] = "minecraft:gray_wool",
    [8] = "minecraft:light_gray_wool",
    [9] = "minecraft:cyan_wool",
    [10] = "minecraft:purple_wool",
    [11] = "minecraft:blue_wool",
    [12] = "minecraft:brown_wool",
    [13] = "minecraft:green_wool",
    [14] = "minecraft:red_wool",
    [15] = "minecraft:black_wool",
    [-1] = "minecraft:orange_concrete",
    [-2] = "minecraft:magenta_concrete",
    [-3] = "minecraft:light_blue_concrete",
    [-4] = "minecraft:yellow_concrete",
    [-5] = "minecraft:lime_concrete",
    [-6] = "minecraft:pink_concrete",
    [-7] = "minecraft:gray_concrete",
    [-8] = "minecraft:light_gray_concrete",
    [-9] = "minecraft:cyan_concrete",
    [-10] = "minecraft:purple_concrete",
    [-11] = "minecraft:blue_concrete",
    [-12] = "minecraft:brown_concrete",
    [-13] = "minecraft:green_concrete",
    [-14] = "minecraft:red_concrete",
    [-15] = "minecraft:black_concrete",
}
local fun = {}
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
for i = -size, size do
    for j = -size, size do
        -- if map[i][j] > 0 then
        --     local command = string.format("setblock %d %d %d %s", x + i, y, z + j, "stone")
        --     local bool, err = commands.exec(command)
        --     if not bool then
        --         print(err[1])
        --     end
        -- else
        --     local command = string.format("setblock %d %d %d %s", x + i, y, z + j, "air")
        --     local bool, err = commands.exec(command)
        --     if not bool then
        --         print(err[1])
        --     end
        -- end
        print(perlin.perlin_2d(i + xMovement, j + yMovement, scale, octaves, persistance, lacunarity, true, seed))
        local color = colors[math.floor(perlin.perlin_2d(i + xMovement, j + yMovement, scale, octaves, persistance, lacunarity, true, seed) * 15)]
        local command = string.format("setblock %d %d %d %s", x + i, y, z + j, color)
        table.insert(fun, function()
            local bool, err = commands.exec(command)
            if not bool then
                print(err[1])
            end
        end)
    end
end
run(fun)
commands.exec(table.concat({ "say", "Finished:", scale, octaves, persistance, lacunarity }, " "))
