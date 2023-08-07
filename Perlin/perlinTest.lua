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
    shell.run("wget", "https://raw.githubusercontent.com/Gobgob30/RanLuaStuff/main/perlin.lua", "perlin.lua")
    hasPerlin, perlin = pcall(require, "perlin")
    if not hasPerlin then
        error("Failed to load pearlin\n" .. tostring(perlin))
    end
end

local args = { ... }
local c = {
    colors.white,
    colors.lightGray,
    colors.gray,
    colors.black,
    colors.brown,
    colors.orange,
    colors.yellow,
    colors.lime,
    colors.green,
    colors.cyan,
    colors.lightBlue,
    colors.blue,
    colors.purple,
    colors.magenta,
    colors.pink
}
local box = pixelBox.new(term.current())
local scale = 25
local octaves = 2
local persistence = .25
local lacunarity = 2
local function draw(xMovement, yMovement)
    for i = 1, box.width * 2 do
        for j = 1, box.height * 3 do
            local value
            if args[1] == "1" then
                value = perlin.perlin_3d(i, j, yMovement, scale, octaves, persistence, lacunarity)
            else
                value = perlin.perlin_2d(i + xMovement, j + yMovement, scale, octaves, persistence, lacunarity)
            end
            box.CANVAS[j][i] = c[math.floor(perlin.helpers.map(value, -1, 1, 1, 15))]
        end
        box:render()
    end
end
local yMovement = 0
local xMovement = 0
while true do
    draw(xMovement, yMovement)
    yMovement = yMovement + 1
    -- xMovement = xMovement + 1
end
