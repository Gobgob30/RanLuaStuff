local hasPixelBox, pixelBox = pcall(require, "pixelBox")
if not hasPixelBox then
    shell.run("wget", "https://raw.githubusercontent.com/9551-Dev/apis/main/pixelbox.lua", "pixelBox.lua")
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
local box = pixelBox.new(term.current())
local COLORS = {
    [ -15] = colors.black,
    [ -14] = colors.red,
    [ -13] = colors.green,
    [ -12] = colors.brown,
    [ -11] = colors.blue,
    [ -10] = colors.purple,
    [ -9] = colors.cyan,
    [ -8] = colors.lightGray,
    [ -7] = colors.gray,
    [ -6] = colors.pink,
    [ -5] = colors.lime,
    [ -4] = colors.yellow,
    [ -3] = colors.lightBlue,
    [ -2] = colors.magenta,
    [ -1] = colors.orange,
    [0] = colors.white,
    [1] = colors.black,
    [2] = colors.red,
    [3] = colors.green,
    [4] = colors.brown,
    [5] = colors.blue,
    [6] = colors.purple,
    [7] = colors.cyan,
    [8] = colors.lightGray,
    [9] = colors.gray,
    [10] = colors.pink,
    [11] = colors.lime,
    [12] = colors.yellow,
    [13] = colors.lightBlue,
    [14] = colors.magenta,
    [15] = colors.orange,
}

local function draw(xMovement, yMovement)
    local map = perlin.generate_map_2d(false, box.width * 2, box.height * 3, .00354684, 5, .5, 2, true, { x = xMovement, y = yMovement })
    for i = 1, box.width * 2 do
        local shouldBreak = false
        for j = 1, box.height * 3 do
            if not pcall(box.set_pixel, box, i, j, COLORS[math.floor(map[i][j] * 15)]) then
                error("Failed to set pixel at " .. tostring(i) .. ", " .. tostring(j))
            end
        end
    end
    box:push_updates()
    box:draw()
end
local yMovement = 0
while true do
    draw(0, yMovement)
    yMovement = yMovement + 10
    if yMovement > 100000 then
        break
    end
end
