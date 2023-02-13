--[[
    reference:
    https://en.wikipedia.org/wiki/Perlin_noise
]]
local yieldTime -- variable to store the time of the last yield
function yield()
    if yieldTime then -- check if it already yielded
        if os.clock() - yieldTime > 2 then -- if it were more than 2 seconds since the last yield
            os.queueEvent("someFakeEvent") -- queue the event
            os.pullEvent("someFakeEvent") -- pull it
            yieldTime = nil -- reset the counter
        end
    else
        yieldTime = os.clock() -- store the time
    end
end

local function interpolate(a0, a1, w)
    return (a1 - a0) * w + a0
end

local function randomGradient(ix, iy)
    local w = 8 * 32
    local s = w / 2
    local a = ix
    local b = iy
    a = a * 3284157443
    b = bit.bxor(b, bit.bor(bit.blshift(a, s), bit.brshift(a, w - s)))
    b = b * 1911520717
    a = bit.bxor(a, bit.bor(bit.blshift(b, s), bit.brshift(b, w - s)))
    a = a * 2048419325
    local random = a * (math.pi / -9223372036854775808)
    local v = { x = math.cos(random), y = math.sin(random) }
    return v
end

local function dotGridGradient(ix, iy, x, y)
    local gradient = randomGradient(ix, iy)
    local dx = x - ix
    local dy = y - iy
    return (dx * gradient.x + dy * gradient.y)
end

local function perlin2d(x, y)
    local x0 = math.floor(x)
    local x1 = x0 + 1
    local y0 = math.floor(y)
    local y1 = y0 + 1
    local sx = x - x0
    local sy = y - y0
    local n0, n1, ix0, ix1, value
    n0 = dotGridGradient(x0, y0, x, y)
    n1 = dotGridGradient(x1, y0, x, y)
    ix0 = interpolate(n0, n1, sx)
    n0 = dotGridGradient(x0, y1, x, y)
    n1 = dotGridGradient(x1, y1, x, y)
    ix1 = interpolate(n0, n1, sx)
    value = interpolate(ix0, ix1, sy)
    return value
end

local function perlin3d(x, y, z)
    local ab = perlin2d(x, y)
    local bc = perlin2d(y, z)
    local ac = perlin2d(x, z)

    local ba = perlin2d(y, x)
    local cb = perlin2d(z, y)
    local ca = perlin2d(z, x)

    local abc = ab + bc + ac + ba + cb + ca
    return abc / 6
end

local function generate_map_2d(startNeg, width, height, scale, octaves, persistance, lacunarity, normalize, movementV2)
    if width < 1 then
        width = 1
    end
    if height < 1 then
        height = 1
    end

    if octaves < 1 then
        octaves = 1
    end
    if persistance < 0.0000001 then
        persistance = 0.0000001
    elseif persistance > 1 then
        persistance = 1
    end
    if lacunarity < 1 then
        lacunarity = 1
    end
    local x, z = 0, 0
    if movementV2 and type(movementV2) == "table" then
        x = movementV2.x or 0
        z = movementV2.y or 0
    end
    local map = {}
    for i = startNeg and -width or 0, width do
        map[i] = {}
        for j = startNeg and -height or 0, height do
            local value = 0
            local frequency = 1
            local amplitude = 1
            local max = 0
            for k = 1, octaves do
                value = value + perlin2d((i + x) * scale * frequency, (j + z) * scale * frequency) * amplitude
                max = max + amplitude
                amplitude = amplitude / persistance
                frequency = frequency * lacunarity
            end
            if normalize then
                value = value / max
            end
            map[i][j] = value
            yield()
        end
        yield()
    end
    return map
end

local function generate_map_3d(startNeg, width, height, depth, scale, octaves, persistance, lacunarity, normalize, movementV3)
    if width < 1 then
        width = 1
    end
    if height < 1 then
        height = 1
    end
    if depth < 1 then
        depth = 1
    end

    if octaves < 1 then
        octaves = 1
    end
    if persistance < 0.0000001 then
        persistance = 0.0000001
    elseif persistance > 1 then
        persistance = 1
    end
    if lacunarity < 1 then
        lacunarity = 1
    end
    local x, y, z = 0, 0, 0
    if movementV3 and type(movementV3) == "table" then
        x = movementV3.x or 0
        y = movementV3.y or 0
        z = movementV3.z or 0
    end

    local map = {}
    for i = startNeg and -width or 0, width do
        map[i] = {}
        for j = startNeg and -height or 0, height do
            map[i][j] = {}
            for k = startNeg and -depth or 0, depth do
                local value = 0
                local frequency = 1
                local amplitude = 1
                local max = 0
                for l = 1, octaves do
                    value = value + perlin3d((i + x) * scale * frequency, (j + y) * scale * frequency, (k + z) * scale * frequency) * amplitude
                    max = max + amplitude
                    amplitude = amplitude / persistance
                    frequency = frequency * lacunarity
                end
                if normalize then
                    value = value / max
                end
                map[i][j][k] = value
                yield()
            end
            yield()
        end
        yield()
    end
    return map
end

local function perlin_2d(x, y, scale, octaves, persistance, lacunarity, normalize)
    local value = 0
    local frequency = 1
    local amplitude = 1
    local max = 0
    for i = 1, octaves do
        value = value + perlin2d(x * scale * frequency, y * scale * frequency) * amplitude
        max = max + amplitude
        amplitude = amplitude / persistance
        frequency = frequency * lacunarity
    end
    if normalize then
        value = value / max
    end
    return value
end

local function perlin_3d(x, y, z, scale, octaves, persistance, lacunarity, normalize)
    local value = 0
    local frequency = 1
    local amplitude = 1
    local max = 0
    for i = 1, octaves do
        value = value + perlin3d(x * scale * frequency, y * scale * frequency, z * scale * frequency) * amplitude
        max = max + amplitude
        amplitude = amplitude / persistance
        frequency = frequency * lacunarity
    end
    if normalize then
        value = value / max
    end
    return value
end

return {
    perlin_2d = perlin_2d,
    perlin_3d = perlin_3d,
    generate_map_2d = generate_map_2d,
    generate_map_3d = generate_map_3d,
}
