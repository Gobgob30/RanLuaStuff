local x, y, z = 151, 80, -128
local size = 500
local run_t = {}
for i = 1, size do
    table.insert(run_t, function()
        -- /summon pneumaticcraft:micromissile ~ ~ ~ {Motion:[0d,-1d,0d],filter:"Visitor",explostionScaling:1f,turnSpeed:1f,topSpeedSq:2.9f,Rotation:[0f,0f]}
        commands.summon("pneumaticcraft:micromissile", x, y, z, textutils.serialiseJSON({
            Motion = { 0, -.5, 0 },
            Rotation = { 0, 0 },
            turnSpeed = 1.0,
            topSpeedSq = 6.25,
            explotionScaling = 1,
            filter = "Visitor",
        }, true))
    end)
end
require("run")(run_t)
