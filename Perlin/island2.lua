local yieldTime -- variable to store the time of the last yield
function yield()
    if yieldTime then -- check if it already yielded
        if os.clock() - yieldTime > 2 then -- if it were more than 2 seconds since the last yield
            os.queueEvent("someFakeEvent") -- queue the event
            os.pullEvent("someFakeEvent") -- pull it
            yieldTime = nil -- reset the counter
        end
    else
        yieldTime = os.clock() -- store the time
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
    print("Usage: island2 <size> <scale> <octaves> <persistance> <lacunarity> <x> <y> <z> <xMovement> <yMovement>")
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
    local size = tonumber(arguments[1]) or 25
    local scale = tonumber(arguments[2]) or 0.0295843
    local octaves = tonumber(arguments[3]) or 3
    local persistance = tonumber(arguments[4]) or .5
    local lacunarity = tonumber(arguments[5]) or 1.2568
    local x = tonumber(arguments[6])
    local y = tonumber(arguments[7])
    local z = tonumber(arguments[8])
    if not x or not y or not z then
        return error("No coordinates provided")
    end
    return size, scale, octaves, persistance, lacunarity, x, y, z
end

local size, scale, octaves, persistance, lacunarity, x, y, z = parseArgs(args)
local mapScale, mapPer, mapLac, mapOct = scale * 2, persistance * 2, lacunarity * 2, octaves * 2
local surfaceScale, surfacePer, surfaceLac, surfaceOct = scale, persistance, lacunarity, octaves
local randomX, randomY, randomZ = ranNum(0, 100000), ranNum(0, 100000), ranNum(0, 100000)
commands.exec(string.format('/tellraw Sea_of_the_Bass [{"text":"Starting at: ","color":"dark_blue","bold":true,"italic":true},{"text":"%d %d %d","clickEvent":{"action":"run_command","value":"/tp @s %d %d %d"}}]', x, y, z, x, y + 10, z))
commands.exec(string.format("/tp Sea_of_the_Bass %d %d %d", x, y + 2.5, z))
commands.exec(string.format("/execute positioned %d %d %d as @p[distance=..%d] at @s run tp @s ~ ~%d ~", x, y, z, size, size * 3))
commands.say(string.format("Size: %d", size))

for i = -size, size do
    commands.tp("Sea_of_the_Bass", i + x, y + 30, z)
    for j = -size, size do
        local height = math.floor(perlin.perlin_2d(i + randomX, j + randomY, mapScale, mapOct, mapPer, mapLac, true) * 25) + 10
        local surface = math.floor(perlin.perlin_2d(i + randomX, j + randomY, surfaceScale, surfaceOct, surfacePer, surfaceLac, true) * 8)
        local distance = math.sqrt(i ^ 2 + j ^ 2)
        -- print(i, j, height, surface)
        if distance <= size then
            local _command = {}
            for k = -height, surface + 3 do
                local block
                if k == surface + 3 then
                    block = "minecraft:grass_block"
                elseif k > surface then
                    block = "minecraft:dirt"
                else
                    block = "minecraft:stone"
                end
                -- print(perlin.perlin_3d(i + randomX, k + randomZ, j + randomY, ranNum(.05, .000001), 2, ranNum(.25, .875), ranNum(0, 10), true))
                if perlin.perlin_3d(i + randomX, k + randomZ, j + randomY, scale, octaves, persistance, lacunarity, true) < 0 then
                    block = "minecraft:air"
                end
                -- write(block .. " ")
                table.insert(_command, function()
                    commands.exec(string.format("/setblock %d %d %d %s", i + x, k + y, j + z, block))
                end)
                yield()
            end
            -- commands.tp("Sea_of_the_Bass", i + x, y + 30, j + z)
            parallel.waitForAll(table.unpack(_command))
        end
    end
end
