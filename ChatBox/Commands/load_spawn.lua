local args = { ... }
local player_start_x, player_start_y, player_start_z = settings.get("player_start_x"), settings.get("player_start_y"), settings.get("player_start_z")
if not player_start_x or not player_start_y or not player_start_z then
    local _
    _, _, player_start_x = commands.data.get.entity(settings.get("owner_id"), "Pos[0]")
    _, _, player_start_y = commands.data.get.entity(settings.get("owner_id"), "Pos[1]")
    _, _, player_start_z = commands.data.get.entity(settings.get("owner_id"), "Pos[2]")
    settings.set("player_start_x", player_start_x)
    settings.set("player_start_y", player_start_y)
    settings.set("player_start_z", player_start_z)
    settings.save()
end
local x, y, z = commands.getBlockPosition()
local size, increment, time_stop, time_scale = 8 * 1024, 256, 100, 10
for time = settings.get("time", 0), time_stop, time_scale do
    settings.set("time", time)
    settings.save()
    for x_m = settings.get("start_x", -size), size, increment do
        settings.set("start_x", x_m)
        settings.save()
        for z_m = settings.get("start_z", -size), size, increment do
            settings.set("start_z", z_m)
            settings.save()
            commands.tp(settings.get("owner_id"), x_m + x, y, z_m + z)
            sleep(time)
        end
        settings.unset("start_z")
        settings.save()
    end
    settings.unset("start_x")
    settings.save()
end
settings.unset("time")
commands.tp(settings.get("owner_id"), player_start_x, player_start_y, player_start_z)
settings.unset("player_start_x")
settings.unset("player_start_y")
settings.unset("player_start_z")
settings.save()
