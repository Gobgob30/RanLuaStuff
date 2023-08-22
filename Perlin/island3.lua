local hasPerlin, perlin = pcall(require, "perlin")
if not hasPerlin then
    shell.run("wget", "https://raw.githubusercontent.com/Gobgob30/RanLuaStuff/main/Perlin/perlin.lua", "perlin.lua")
    hasPerlin, perlin = pcall(require, "perlin")
    if not hasPerlin then
        error("Failed to load pearlin\n" .. tostring(perlin))
    end
end

-- local _empty_str = ""
-- local _space_str = " "
-- local cmd_blck = peripheral.find("command")
-- if not cmd_blck then error("Command block not found", 2) end
-- function cmd_blck:make_command(options, ...)
--     options = options or {}
--     local serialize_nbt = options.serializeNBTJSON
--     local serialize_JSON = options.serializeNBTJSON and nil or options.serializeJSON
--     local args = { ... }
--     for i = 1, #args do
--         if type(args[i]) == "table" then
--             if serialize_nbt then
--                 args[i] = textutils.serializeJSON(args[i], true)
--             elseif serialize_JSON then
--                 args[i] = textutils.serialiseJSON(args[i])
--             else
--                 args[i] = textutils.serialize(args[i])
--             end
--         else
--             args[i] = tostring(args[i])
--         end
--     end
--     return function()
--         self.setCommand(table.concat(args, " "))
--         self.runCommand()
--     end
-- end

local function help()
    print("Usage: island_cmd_peri <size> <scale> <octaves> <persistance> <lacunarity> <x> <y> <z>")
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
        tonumber(arguments[6]) or 2,
        tonumber(arguments[7]) or .5,
        tonumber(arguments[8]) or 2,
        tonumber(arguments[1]),
        tonumber(arguments[2]),
        tonumber(arguments[3])
end
local run = require("run")
local size, scale, octaves, persistance, lacunarity, x, y, z = parseArgs(args)
local seeds = { math.random(99999, 999999), math.random(99999, 999999), math.random(99999, 999999), math.random(99999, 999999), math.random(99999, 999999) }
local commands_to_run = {}
-- local ta, tb = cmd_blck:make_command({}, "say", string.format("fill %s %s %s %s %s %s air", x + size, y + size, z + size, x - size, y - size, z - size))
-- table.insert(commands, ta)
-- table.insert(commands, tb)
local surface_max, surface_min = 15, 1
local bottom_max, bottom_min = 25, 1
local dirt_max, dirt_min = 6, 3
table.insert(commands_to_run, function()
    commands.say(string.format("fill %s %s %s %s %s %s air", x + size, y + bottom_max, z + size, x - size, y - surface_max, z - size))
end)
for i = -size, size do
    for j = -size, size do
        perlin.seed.set(seeds[1])
        if math.sqrt(i ^ 2 + j ^ 2) <= perlin.helpers.map(perlin.perlin_2d(i, j, scale, octaves, persistance, lacunarity), -1, 1, 1, size) then
            perlin.seed.set(seeds[2])
            local top_height = math.floor(perlin.helpers.map(perlin.perlin_2d(i, j, scale, octaves, persistance, lacunarity), -1, 1, surface_min, surface_max))
            perlin.seed.set(seeds[3])
            local bottom_height = math.floor(perlin.helpers.map(perlin.perlin_2d(i, j + size, scale, octaves * 3, persistance, lacunarity), -1, 1, bottom_min, bottom_max))
            perlin.seed.set(seeds[4])
            local dirts_max = math.floor(perlin.helpers.map(perlin.perlin_2d(i, j, scale, octaves, persistance, lacunarity), -1, 1, dirt_min, dirt_max))
            local grassed = false
            local stop_dirting = false
            local dirts = 0
            -- print(top_height, bottom_height, dirts_max)
            for k = top_height, -bottom_height, -1 do
                perlin.seed.set(seeds[5])
                if perlin.perlin_3d(i, k, j, scale + k, octaves, persistance, lacunarity) > 0 then
                    local block
                    if not grassed then
                        grassed = true
                        block = "grass_block"
                    elseif not stop_dirting and dirts < dirts_max then
                        dirts = dirts + 1
                        block = "dirt"
                    else
                        block = "stone"
                    end
                    -- print(table.concat({ "setblock", math.floor(x + i + .5), math.floor(y + k + .5), math.floor(z + j + .5), block }, " "))
                    -- local a, b = cmd_blck:make_command({}, "setblock", math.floor(x + i + .5), math.floor(y + k + .5), math.floor(z + j + .5), block)
                    -- table.insert(commands, a)
                    -- table.insert(commands, b)
                    table.insert(commands_to_run, function()
                        commands.setblock(math.floor(x + i), math.floor(y + k), math.floor(z + j), block)
                    end)
                end
                yield()
            end
        end
    end
end
run(commands_to_run, 128)
