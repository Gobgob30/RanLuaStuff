local args = { ... }
local blocks = require(args[1])
local block = args[2]
local cmds = {}
for i, x in pairs(blocks) do
    for j, z in pairs(x) do
        for k, y in pairs(z) do
            table.insert(cmds, function()
                commands.exec(string.format("setblock %d %d %d %s replace", i, j, k, block or "air"))
            end)
        end
    end
end
require("run")(cmds, 128)




fs.delete(args[1] .. ".lua")
