local args = { ... }
if #args < 4 then
    commands.say("Usage: recreateBlockData <block_name> <x> <y> <z>")
    return
elseif #args > 4 then
    commands.say("Usage: recreateBlockData <block_name> <x> <y> <z>")
    return
end
local block_name = args[1]
local data = require("blocks." .. block_name)
local size = 5
local x = tonumber(args[2]) - math.floor(size / 2)
local y = tonumber(args[3])
local z = tonumber(args[4]) - math.floor(size / 2)

local inc = 1
commands.say(x - size, y - size, z - size, x + size, y + size, z + size, "Size")
for i = 1, size do
    for j = 1, size do
        for k = 1, size do
            if data[inc] then
                commands.setblock(x + j, y + i, z + k, data[inc].name .. textutils.serialiseJSON(data[inc].state, true))
            end
            inc = inc + 1
        end
    end
end
