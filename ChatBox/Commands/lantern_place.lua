local has_run, run = pcall(require, "run")
if not has_run then
    shell.run("wget https://raw.githubusercontent.com/Gobgob30/RanLuaStuff/main/run.lua")
    has_run, run = pcall(require, "run")
    if not has_run then
        error("Failed to download run.")
    end
end

local has_yield, yield = pcall(require, "yield")
if not has_yield then
    shell.run("wget https://raw.githubusercontent.com/Gobgob30/RanLuaStuff/main/yield.lua")
    has_yield, yield = pcall(require, "yield")
    if not has_yield then
        error("Failed to download yield.")
    end
end
yield = yield.yield

local args = { ... }

local x_start, y_start, z_start, size = tonumber(args[1]), tonumber(args[2]), tonumber(args[3]), tonumber(args[4])
local block = args[5] or "torchmaster:feral_flare_lantern"
if not x_start or not y_start or not z_start or not size then
    print("Usage: fill_in <x> <y> <z> <size>")
    return
end

local x, z, dx, dz = 0, 0, 0, -1

commands.say("Starting lanterns at " .. x_start .. ", " .. y_start .. ", " .. z_start .. " with size " .. size)
commands.say("Using block " .. block)
local t = {}
while true do
    local px, py, pz = x_start + x * 16, y_start, z_start + z * 16
    table.insert(t, function()
        commands.execute(
            "positioned",
            px,
            py,
            pz,
            "if",
            "block",
            "~",
            "~",
            "~",
            "minecraft:air",
            "run",
            "setblock",
            "~",
            "~",
            "~",
            block
        )
    end)
    if x == z or (x < 0 and x == -x) or (x > 0 and x == 1 - z) or (x > 0 and x == z) or (x < 0 and x == -z) then
        dx, dz = -dz, dx
    end
    x, z = x + dx, z + dz
    if x > size or z > size or x < -size or z < -size then
        break
    end
end
run(t, 16)
commands.say("Finished placing lanterns")
