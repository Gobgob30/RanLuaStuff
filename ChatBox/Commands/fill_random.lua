local has_perlin, perlin = pcall(require, "perlin")
if not has_perlin then
    shell.run("wget", "https://raw.githubusercontent.com/Gobgob30/RanLuaStuff/main/Perlin/perlin.lua", "perlin.lua")
    has_perlin, perlin = pcall(require, "perlin")
    if not has_perlin then
        error("Failed to load pearlin\n" .. tostring(perlin))
    end
end
local args = { ... }
if #args <= 11 then
    commands.say("Usage: fill <start> <end> <fill_with> <percentages> <operation> <type> <replace_blocks>")
    return
end
local start = vector.new(args[1], args[2], args[3])
local end_ = vector.new(args[4], args[5], args[6])
local fill_with = { args[7] }
if fill_with[1]:find(";") then
    local split_str = fill_with[1]
    fill_with = {}
    for str in split_str:gmatch("[^;]+") do
        table.insert(fill_with, str)
    end
end
local percentages = { args[8] }
if percentages[1]:find(";") then
    local split_str = percentages[1]
    percentages = {}
    for str in split_str:gmatch("[^;]+") do
        table.insert(percentages, str)
    end
end
if #percentages ~= #fill_with then
    error("Invalid number of percentages")
end
for i = 1, #percentages do
    percentages[i] = tonumber(percentages[i])
end
local operation = args[9]
local _type = args[10]
local replace_blocks = { args[11] }
if replace_blocks[1]:find(";") then
    local split_str = replace_blocks[1]
    replace_blocks = {}
    for str in split_str:gmatch("[^;]+") do
        table.insert(replace_blocks, str)
    end
end
local simulate = false
local handler
if _type == "perlin" then
    if args[16] then
        simulate = true
    end
    handler = function(x, y, z)
        return perlin.perlin_3d(x, y, z, args[12] or 25, args[13] or 2, args[14] or .5, args[15] or 2)
    end
elseif _type == "random" then
    if args[12] then
        simulate = true
    end
    handler = function(x, y, z)
        return math.random(-1, 1)
    end
else
    error("Invalid type: " .. tostring(_type))
end
local cmds = {}
for x = start.x, end_.x, start.x > end_.x and -1 or 1 do
    for z = start.z, end_.z, start.z > end_.z and -1 or 1 do
        for y = start.y, end_.y, start.y > end_.y and -1 or 1 do
            table.insert(cmds, function()
                local place = false
                for i = 1, #replace_blocks do
                    if commands.execute("if", "block", x, y, z, replace_blocks[i]) then
                        place = true
                    end
                end
                if place then
                    local chance = perlin.helpers.map(handler(x, y, z), -1, 1, 0, 100)
                    if simulate then
                        commands.say(x, y, z, "chance: " .. tostring(chance))
                    end
                    for i = 1, #fill_with do
                        if chance <= percentages[i] and not simulate then
                            commands.setblock(x, y, z, fill_with[i], operation)
                            break
                        end
                    end
                end
            end)
        end
    end
end
require("run")(cmds, 64)
