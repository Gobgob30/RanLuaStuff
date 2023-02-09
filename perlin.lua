--[[
    reference:
    https://en.wikipedia.org/wiki/Perlin_noise
]]
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

local function perlin(x, y)
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

local function noise_octave(startNeg, width, height, scale, octaves, persistance, lacunarity, normalize)
    if width < 1 then
        width = 1
    end
    if height < 1 then
        height = 1
    end
    local _, fraction = math.modf(scale)
    if fraction == 0 then
        scale = scale + math.random() * 0.0001
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
    local map = {}
    for i = startNeg and -width or 0, width do
        map[i] = {}
        for j = startNeg and -height or 0, height do
            local value = 0
            local frequency = 1
            local amplitude = 1
            local max = 0
            for k = 1, octaves do
                value = value + perlin((i - 1) * scale * frequency, (j - 1) * scale * frequency) * amplitude
                max = max + amplitude
                amplitude = amplitude / persistance
                frequency = frequency * lacunarity
            end
            if normalize then
                value = value / max
            end
            map[i][j] = value
        end
    end
    return map
end

return {
    noise_octave = noise_octave
}
