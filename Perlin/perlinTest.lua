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
        error("Failed to load perlin\n" .. tostring(perlin))
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
local scale = .00354684
local octaves = 5
local persistence = .5
local lacunarity = 2
local ranX, ranY = math.random(1, 100000), math.random(1, 100000)
local function draw(xMovement, yMovement)
    for i = 1, box.width * 2 do
        local shouldBreak = false
        for j = 1, box.height * 3 do
            if args[1] == "1" then
                local value = perlin.perlin_3d(i + ranX, j + ranY, yMovement, .00354684, 5, 0.5, 2, true)
                local a = math.floor(perlin.helpers.map(value, -1, 1, 1, #c))
                box.CANVAS[j][i] = c[a]
            elseif args[1] == "2" then
                local value = perlin.perlin_2d(i + ranX, (j + yMovement) + ranY, .00354684, 5, 0.5, 2, true)
                local a = math.floor(perlin.helpers.map(value, -1, 1, 1, #c))
                box.CANVAS[j][i] = c[a]
            else
                local value = math.random(1, #c)
                if not c[value] then
                    error("Value: " .. tostring(value))
                end
                box.CANVAS[j][i] = c[value]
            end
        end
    end
    box:render()
end
local yMovement = 0
while true do
    draw(0, yMovement)
    yMovement = yMovement + 1
end
