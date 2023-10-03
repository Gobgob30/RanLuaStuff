local x, y, z = commands.getBlockPosition()
local times = { { "iteration", "base", "exec", "exec_fail" } }
for i = 1, 100 do
    local time = os.epoch("utc") / 1000
    commands.setblock(x, y + 2, z, "stone")
    commands.setblock(x, y + 2, z, "air")
    local base_time = os.epoch("utc") / 1000 - time
    commands.say(string.format("base_Time: %f", base_time))
    time = os.epoch("utc") / 1000
    commands.execute("unless", "block", x, y + 2, z, "stone", "run", "setblock", x, y + 2, z, "stone")
    commands.execute("unless", "block", x, y + 2, z, "air", "run", "setblock", x, y + 2, z, "air")
    local exec_time = os.epoch("utc") / 1000 - time
    commands.say(string.format("exec_Time: %f", exec_time))
    time = os.epoch("utc") / 1000
    commands.execute("unless", "block", x, y + 2, z, "air", "run", "setblock", x, y + 2, z, "air")
    commands.execute("unless", "block", x, y + 2, z, "air", "run", "setblock", x, y + 2, z, "air")
    local exec_fail_time = os.epoch("utc") / 1000 - time
    commands.say(string.format("exec_failed_Time: %f", exec_fail_time))
    table.insert(times, { i, base_time, exec_time, exec_fail_time })
end

local f = fs.open("output.csv", "w")
for _, t in ipairs(times) do
    f.writeLine(string.format("%s,%s,%s,%s", tostring(t[1]), tostring(t[2]), tostring(t[3]), tostring(t[4])))
end
f.close()
