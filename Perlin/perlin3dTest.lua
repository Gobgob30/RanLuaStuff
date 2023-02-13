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

local args = { ... }
local function parseArgs(arguments)
    if not arguments then
        return error("No arguments provided")
    elseif #arguments == 0 then
        return error("No arguments provided")
    elseif arguments[1] == "help" then
        print("Usage: perlin3dTest <size> <scale> <octaves> <persistance> <lacunarity> <x> <y> <z> <xMovement> <yMovement> <zMovement>")
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
        print("zMovement: the z movement of the map")
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
    local yMovement = tonumber(arguments[10]) or 0
    local zMovement = tonumber(arguments[11]) or 0
    if not x or not y or not z then
        return error("Invalid coordinates")
    end
    return size, scale, octaves, persistance, lacunarity, x, y, z, xMovement, yMovement, zMovement
end
local perlin = require("perlin")
local size, scale, octaves, persistance, lacunarity, x, y, z, xMovement, yMovement, zMovement = parseArgs(args)
if not size then return end
local map = perlin.generate_map_3d(true, size, size, size, scale, octaves, persistance, lacunarity, true, vector.new(xMovement, yMovement, zMovement))
local currCommands = 0
local maxCommands = 50
local oldExec = commands.exec
commands.exec = function(command)
    while currCommands >= maxCommands do
        os.pullEvent("task_complete")
    end
    yield()
    currCommands = currCommands + 1
    return commands.execAsync(command)
end
print("Starting")
local bool, err = pcall(parallel.waitForAny, function()
        for i = -size, size do
            for j = -size, size do
                for k = -size, size do
                    if map[i][j][k] > 0 then
                        local command = string.format("setblock %d %d %d %s", x + i, y + j, z + k, "stone")
                        local bool, err = commands.exec(command)
                        if not bool then
                            print(err[1])
                        end
                    else
                        local command = string.format("setblock %d %d %d %s", x + i, y + j, z + k, "air")
                        local bool, err = commands.exec(command)
                        if not bool then
                            print(err[1])
                        end
                    end
                end
            end
        end
    end, function()
        while true do
            os.pullEvent("task_complete")
            currCommands = currCommands - 1
        end
    end)
if not bool then
    printError(err)
end
commands.exec = oldExec
