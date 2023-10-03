local args = { ... }
if not args[1] or not args[2] or not args[3] or not args[4] or not args[5] or not args[6] or not args[7] or not args[8] or not args[9] then
    commands.say("Usage: fill <start> <end> <fill_with> <percentages> <operation> <type> <replace_blocks>")
    return
end
local start = vector.new(args[1], args[2], args[3])
local end_ = vector.new(args[4], args[5], args[6])
local fill_with = args[7]
local _type = args[8]
local replace_block = args[9]
local cmds = {}
for x = start.x, end_.x, start.x > end_.x and -1 or 1 do
    for z = start.z, end_.z, start.z > end_.z and -1 or 1 do
        for y = start.y, end_.y, start.y > end_.y and -1 or 1 do
            table.insert(cmds, function()
                -- commands.setblock(x, y, z, fill_with, _type)
                if replace_block ~= nil then
                    commands.execute("if", "block", x, y, z, replace_block, "run", "setblock", x, y, z, fill_with, _type)
                else
                    commands.setblock(x, y, z, fill_with, _type)
                end
            end)
        end
    end
end
require("run")(cmds, 128)
