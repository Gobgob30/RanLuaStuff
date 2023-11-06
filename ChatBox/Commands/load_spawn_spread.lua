local x, y, z = commands.getBlockPosition()
local size, increment, time = 8 * 1024, 32, .25
commands.team.add("ChunkLoader")
local cmds = {}
for x_m = -size, size, increment do
    for z_m = -size, size, increment do
        table.insert(cmds, function()
            commands.summon("armor_stand ~ ~ ~ {Marker:1,Invisible:1,NoGravity:1,Invulnerable:1,Team:\"ChunkLoader\"}")
            commands.spreadplayers(x_m + x, z_m + z, increment, increment, false, "@e[type=armor_stand,team=ChunkLoader]")
            sleep(time)
            commands.kill("@e[type=armor_stand,team=ChunkLoader]")
        end)
    end
end
local has_run, run = pcall(require, "run")
if not has_run then
    shell.run("wget", "https://raw.githubusercontent.com/Gobgob30/RanLuaStuff/main/run.lua", "run.lua")
    has_run, run = pcall(require, "run")
    if not has_run then
        error("Failed to load run\n" .. tostring(run))
    end
end
run(cmds, 32)
commands.say(commands.team.remove("ChunkLoader"))
