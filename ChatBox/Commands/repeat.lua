local args = { ... }
if #args < 2 then
    commands.say("Usage: repeat <file> <times> <...Additional arguments>")
    return
end
local require_2 = require("cc.require")
local _env = setmetatable({}, { __index = _ENV })
_env.require, _env.package = require_2.make(_env, "/")
local func = loadfile("commands/" .. args[1] .. ".lua", "bt", _env)
for i = 1, tonumber(args[2]) do
    local ret = { pcall(func, table.unpack(args, 3)) }
    local color = table.remove(ret, 1) and "green" or "red"
    if #ret > 0 then
        commands.tellraw("@p", { text = table.concat(ret, " "), color = color })
    end
end
