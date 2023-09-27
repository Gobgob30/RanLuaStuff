local hasPixelBox, pixelBox = pcall(require, "pixelBox")
if not hasPixelBox then
    shell.run("wget", "https://raw.githubusercontent.com/9551-Dev/apis/main/pixelbox_lite.lua", "pixelBox.lua")
    hasPixelBox, pixelBox = pcall(require, "pixelBox")
    if not hasPixelBox then
        error("Failed to load pixelBox\n" .. tostring(pixelBox))
    end
end
local hasPerlin, perlin = pcall(require, "perlin")
if not hasPerlin then
    shell.run("wget", "https://raw.githubusercontent.com/Gobgob30/RanLuaStuff/main/Perlin/perlin.lua", "perlin.lua")
    hasPerlin, perlin = pcall(require, "perlin")
    if not hasPerlin then
        error("Failed to load pearlin\n" .. tostring(perlin))
    end
end

local box = pixelBox.new(term.current())
local s_x, s_y = term.getSize()
local t = 1
local max = s_x < s_y and s_x or s_y
local min = max - 10
local width, height = box.width * 2, box.height * 3
while true do
    s_x, s_y = term.getSize()
    if s_x ~= box.width or s_y ~= box.height then
        box = pixelBox.new(term.current())
        max = s_x > s_y and s_x or s_y
        min = max - 10
    end
    for x = 1, box.width * 2 do
        for y = 1, box.height * 3 do
            box:set_pixel(x, y, colors.black)
        end
    end
    box:render()
    local tapered_max = max - (max - min) * t ^ 3 / 100
    local tapered_min = min - (max - min) * t ^ 3 / 100
    for a = 0, math.pi * 2, .01 do
        local x_offset = math.cos(a)
        local y_offset = math.sin(a)
        local radius = perlin.helpers.map(perlin.perlin_3d(x_offset, y_offset, t, 25, 3, .25, 2), -1, 1, tapered_min, tapered_max)
        local x, y = math.floor((x_offset * radius) + .5), math.floor((y_offset * radius) + .5)
        box:set_pixel(x + math.floor(width / 2 + .5), y + math.floor(height / 2 + .5), colors.white)
    end
    box:render()
    t = t + 1
    if tapered_max < 0 then
        t = 1
    end
    sleep(.25)
end
