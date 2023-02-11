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
local range = 128
local highest, lowest = 300, 64
local x, y, z = 300, 64, 300
x = x + math.random( -range, range)
z = z + math.random( -range, range)
y = math.random(lowest, highest)
local size = math.random(2, 128)
local mapScale, mapPer, mapLac, mapOct = ranNum(.5, .000001), ranNum(.25, .875), ranNum(0, 10), 5
local map = perlin.noise_octave_2d(true, size, size, mapScale, mapOct, mapPer, mapLac, true)
local surfaceScale, surfacePer, surfaceLac, surfaceOct = ranNum(.05, .000001), ranNum(.25, .875), ranNum(0, 10), 2
local surface = perlin.noise_octave_2d(true, size, size, surfaceScale, surfaceOct, surfacePer, surfaceLac, true, { x = math.random(0, 100000), y = math.random(0, 100000) })
commands.exec(string.format('/tellraw Sea_of_the_Bass [{"text":"Starting at: ","color":"dark_blue","bold":true,"italic":true},{"text":"%d %d %d","clickEvent":{"action":"run_command","value":"/tp @s %d %d %d"}}]', x, y, z, x, y + 10, z))
commands.exec(string.format("/tp Sea_of_the_Bass %d %d %d", x, y + 2.5, z))
commands.exec(string.format("/execute positioned %d %d %d as @p[distance=..%d] at @s run tp @s ~ ~%d ~", x, y, z, size, size * 3))
local currCommands = 0
local maxCommands = 100
local oldExec = commands.exec
commands.exec = function(command)
    currCommands = currCommands + 1
    while currCommands >= maxCommands do
        os.pullEvent("task_complete")
        currCommands = currCommands - 1
    end
    os.queueEvent("TAST")
    os.pullEvent("TAST")
    return commands.execAsync(command)
end
local filename = ""
local function ranString()
    local str = ""
    for i = 1, math.random(10, 35) do
        str = str .. string.char(math.random(0, 1) == 1 and math.random(65, 90) or math.random(97, 122))
    end
    return str
end
filename = ranString()
while fs.exists(filename) do
    filename = ranString()
end
local file = fs.open(filename .. ".txt", "w")
file.writeLine(string.format("x: %f, y: %f, z: %f,\nsize: %f,\nmapScale: %f, mapPer: %f, mapLac: %f, mapOct: %f,\nsurfaceScale: %f, surfacePer: %f, surfaceLac: %f surfaceOct: %f", x, y, z, size, mapScale, mapPer, mapLac, mapOct, surfaceScale, surfacePer, surfaceLac, surfaceOct))
file.close()
parallel.waitForAny(function()
    for i = -size, size do
        for j = -size, size do
            local distance = math.sqrt(i ^ 2 + j ^ 2)
            if distance <= size then
                local height = math.floor(map[i][j] * 10) + math.random(3, 20)
                local surfaceHeight = math.floor(surface[i][j] * 10) / 1.25
                -- print(surface[i][j])
                local X = x + i
                local Z = z + j
                local Y = y - height
                local PY = y + surfaceHeight
                -- print(string.format("x:%d,y:%d:%d,z:%d,height:%d,surfaceHeight:%d", X, Y, PY, Z, height, surfaceHeight))
                -- set bottom layer to dirt
                local command = string.format("setblock %d %d %d %s", X, PY + 1, Z, "grass_block")
                local bool, err = commands.exec(command)
                -- fill the rest with sand
                command = string.format("fill %d %d %d %d %d %d %s", X, Y, Z, X, PY, Z, "dirt")
                bool, err = commands.exec(command)
                -- if middle of island, add a sign with the coords, mapPer, mapLac, mapOct, surfacePer, surfaceLac
                if i == 0 and j == 0 then
                    command = string.format([[/setblock %d %d %d oak_sign{Text1:'{"text":"~~~~~~~~~~~~~~~~~~"}',Text2:'{"text":"File"}',Text3:'{"text":"%s","color":"dark_blue"}',Text4:'{"text":"~~~~~~~~~~~~~~~~~~"}'} replace]], X, PY + 2, Z, filename)
                    bool, err = commands.exec(command)
                end
                -- for k = -height, surfaceHeight do
                --     local block = k == -height and "grass_block" or "sand"
                --     local command = string.format("setblock %d %d %d %s", X, y + k, Z, block)
                --     local bool, err = commands.exec(command)
                --     -- commands.say(command)
                -- end
            end
        end
    end
    print("x:" .. x .. ", y:" .. y .. ", z:" .. z .. ", size:" .. size)
    print("mapScale:" .. mapScale .. ", mapPer:" .. mapPer .. ", mapLac:" .. mapLac .. ", mapOct:" .. mapOct)
    print("surfaceScale:" .. surfaceScale .. ", surfacePer:" .. surfacePer .. ", surfaceLac:" .. surfaceLac .. ", surfaceOct:" .. surfaceOct)
end, function()
    while true do
        os.pullEvent("task_complete")
        currCommands = currCommands - 1
    end
end)
commands.exec = oldExec
