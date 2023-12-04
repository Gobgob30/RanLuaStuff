local function track(sleep_time)
    commands.say(commands.computercraft.track.start())
    sleep(sleep_time)
    commands.say(commands.computercraft.track.stop())
end
Testing()
track(5)
track(10)
track(15)
