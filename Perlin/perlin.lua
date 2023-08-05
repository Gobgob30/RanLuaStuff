--[[
    reference:
    https://en.wikipedia.org/wiki/Perlin_noise
]]
local yieldTime                            -- variable to store the time of the last yield
function yield()
    if yieldTime then                      -- check if it already yielded
        if os.clock() - yieldTime > 2 then -- if it were more than 2 seconds since the last yield
            os.queueEvent("someFakeEvent") -- queue the event
            os.pullEvent("someFakeEvent")  -- pull it
            yieldTime = nil                -- reset the counter
        end
    else
        yieldTime = os.clock() -- store the time
    end
end

local permutation = { 151, 160, 137, 91, 90, 15,
    131, 13, 201, 95, 96, 53, 194, 233, 7, 225, 140, 36, 103, 30, 69, 142, 8, 99, 37, 240, 21, 10, 23,
    190, 6, 148, 247, 120, 234, 75, 0, 26, 197, 62, 94, 252, 219, 203, 117, 35, 11, 32, 57, 177, 33,
    88, 237, 149, 56, 87, 174, 20, 125, 136, 171, 168, 68, 175, 74, 165, 71, 134, 139, 48, 27, 166,
    77, 146, 158, 231, 83, 111, 229, 122, 60, 211, 133, 230, 220, 105, 92, 41, 55, 46, 245, 40, 244,
    102, 143, 54, 65, 25, 63, 161, 1, 216, 80, 73, 209, 76, 132, 187, 208, 89, 18, 169, 200, 196,
    135, 130, 116, 188, 159, 86, 164, 100, 109, 198, 173, 186, 3, 64, 52, 217, 226, 250, 124, 123,
    5, 202, 38, 147, 118, 126, 255, 82, 85, 212, 207, 206, 59, 227, 47, 16, 58, 17, 182, 189, 28, 42,
    223, 183, 170, 213, 119, 248, 152, 2, 44, 154, 163, 70, 221, 153, 101, 155, 167, 43, 172, 9,
    129, 22, 39, 253, 19, 98, 108, 110, 79, 113, 224, 232, 178, 185, 112, 104, 218, 246, 97, 228,
    251, 34, 242, 193, 238, 210, 144, 12, 191, 179, 162, 241, 81, 51, 145, 235, 249, 14, 239, 107,
    49, 192, 214, 31, 181, 199, 106, 157, 184, 84, 204, 176, 115, 121, 50, 45, 127, 4, 150, 254,
    138, 236, 205, 93, 222, 114, 67, 29, 24, 72, 243, 141, 128, 195, 78, 66, 215, 61, 156, 180
}

-- local p = {}
-- for x = 0, 1024 do
--     p[x] = permutation[x % 256 == 0 and 1 or x % 256]
-- end
-- local _repeat = -1

-- local function fade(t)
--     return t * t * t * (t * (t * 6 - 15) + 10)
-- end

-- local function increase(num)
--     num = num + 1
--     if (_repeat > 0) then
--         num = num % _repeat
--     end
--     return num
-- end

-- local function grad(hash, x, y, z)
--     local h = bit.band(hash, 15)
--     local u = h < 8 and x or y

--     local v
--     if h < 4 then
--         v = y
--     elseif h == 12 or h == 14 then
--         v = x
--     else
--         v = z
--     end

--     return (bit.band(h, 1) == 0 and u or -u) + (bit.band(h, 2) == 0 and v or -v)
-- end

-- local function lerp(a, b, x)
--     return a + x * (b - a)
-- end

-- local function cantor_pair(a, b)
--     local hash_a = (a >= 0 and a * 2 or a * -2 - 1)
--     local hash_b = (b >= 0 and b * 2 or b * -2 - 1)

--     local hash_c = ((hash_a >= hash_b) and hash_a ^ 2 + hash_a + hash_b or hash_a + hash_b ^ 2) / 2

--     return (a < 0 and b < 0 or a >= 0 and b >= 0) and hash_c or -hash_c - 1
-- end


-- local function cantor_pair_gradient(map_seed, x, y, z)
--     return cantor_pair(map_seed, cantor_pair(x, y) + cantor_pair(x, z) + cantor_pair(y, z))
-- end

-- local function perlin(seed, x, y, z)
--     if not y then
--         y = 1
--     end
--     if not z then
--         z = 1
--     end
--     if (_repeat > 0) then
--         x, y, z = x % _repeat, y % _repeat, z % _repeat
--     end
--     local xi = math.floor(x) % 256
--     local yi = math.floor(y) % 256
--     local zi = math.floor(z) % 256
--     local xf = x - math.floor(x)
--     local yf = y - math.floor(y)
--     local zf = z - math.floor(z)
--     local u = fade(xf)
--     local v = fade(yf)
--     local w = fade(zf)
--     local aaa = p[p[p[xi] + yi] + zi];
--     local aba = p[p[p[xi] + increase(yi)] + zi];
--     local aab = p[p[p[xi] + yi] + increase(zi)];
--     local abb = p[p[p[xi] + increase(yi)] + increase(zi)];
--     local baa = p[p[p[increase(xi)] + yi] + zi];
--     local bba = p[p[p[increase(xi)] + increase(yi)] + zi];
--     local bab = p[p[p[increase(xi)] + yi] + increase(zi)];
--     local bbb = p[p[p[increase(xi)] + increase(yi)] + increase(zi)];
--     local x1, x2, y1, y2
--     if seed then
--         x1 = lerp(cantor_pair_gradient(seed, xf, yf, zf),
--             cantor_pair_gradient(seed, xf - 1, yf, zf),
--             u);
--         x2 = lerp(cantor_pair_gradient(seed, xf, yf - 1, zf),
--             cantor_pair_gradient(seed, xf - 1, yf - 1, zf),
--             u);
--         y1 = lerp(x1, x2, v);

--         x1 = lerp(cantor_pair_gradient(seed, xf, yf, zf - 1),
--             cantor_pair_gradient(seed, xf - 1, yf, zf - 1),
--             u);
--         x2 = lerp(cantor_pair_gradient(seed, xf, yf - 1, zf - 1),
--             cantor_pair_gradient(seed, xf - 1, yf - 1, zf - 1),
--             u);
--         y2 = lerp(x1, x2, v);
--     else
--         x1 = lerp(grad(aaa, xf, yf, zf),
--             grad(baa, xf - 1, yf, zf),
--             u);
--         x2 = lerp(grad(aba, xf, yf - 1, zf),
--             grad(bba, xf - 1, yf - 1, zf),
--             u);
--         y1 = lerp(x1, x2, v);

--         x1 = lerp(grad(aab, xf, yf, zf - 1),
--             grad(bab, xf - 1, yf, zf - 1),
--             u);
--         x2 = lerp(grad(abb, xf, yf - 1, zf - 1),
--             grad(bbb, xf - 1, yf - 1, zf - 1),
--             u);
--         y2 = lerp(x1, x2, v);
--     end
--     return lerp(y1, y2, w)
-- end

local function interpolate(a0, a1, w)
    if 0 > w then
        return a0
    elseif 1 < w then
        return a1
    end
    -- return (a1 - a0) * w + a0
    --[[ Use this cubic interpolation [Smoothstep] instead, for a smooth appearance: ]]
    -- return (a1 - a0) * (3.0 - w * 2.0)
    -- Use [[Smootherstep]] for an even smoother result with a second derivative equal to zero on boundaries:
    return (a1 - a0) * ((w * (w * 6.0 - 15.0) + 10.0) * w * w * w) + a0
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

local function dotGridGradient(ix, iy, x, y, seed)
    local gradient = randomGradient(ix, iy)
    local dx = x - ix
    local dy = y - iy
    return (dx * gradient.x + dy * gradient.y)
end

local function perlin2d(x, y, seed)
    x, y = x + seed, y + seed
    local x0 = math.floor(x)
    local x1 = x0 + 1
    local y0 = math.floor(y)
    local y1 = y0 + 1
    local sx = x - x0
    local sy = y - y0
    local n0, n1, ix0, ix1
    n0 = dotGridGradient(x0, y0, x, y, seed)
    n1 = dotGridGradient(x1, y0, x, y, seed)
    ix0 = interpolate(n0, n1, sx)
    n0 = dotGridGradient(x0, y1, x, y, seed)
    n1 = dotGridGradient(x1, y1, x, y, seed)
    ix1 = interpolate(n0, n1, sx)
    return interpolate(ix0, ix1, sy)
end

local function perlin3d(x, y, z, seed)
    x, y = x + seed, y + seed
    local ab = perlin2d(x, y, seed)
    local bc = perlin2d(y, z, seed)
    local ac = perlin2d(x, z, seed)

    local ba = perlin2d(y, x, seed)
    local cb = perlin2d(z, y, seed)
    local ca = perlin2d(z, x, seed)

    local abc = ab + bc + ac + ba + cb + ca
    return abc / 6
end

local function perlin_2d(x, y, scale, octaves, persistance, lacunarity, normalize, seed)
    seed = seed and seed or math.random(1, 99999999)
    local value = 0
    local frequency = 1
    local amplitude = 1
    local max = 0
    for i = 1, octaves do
        value = value + perlin2d(x * scale * frequency, y * scale * frequency, seed) * amplitude
        max = max + amplitude
        amplitude = amplitude / persistance
        frequency = frequency * lacunarity
        yield()
    end
    if normalize then
        value = value / max
    end
    return value
end

local function perlin_3d(x, y, z, scale, octaves, persistance, lacunarity, normalize, seed)
    seed = seed and seed or 1
    local value = 0
    local frequency = 1
    local amplitude = 1
    local max = 0
    for i = 1, octaves do
        value = value + perlin3d(x * scale * frequency, y * scale * frequency, z * scale * frequency, seed) * amplitude
        max = max + amplitude
        amplitude = amplitude / persistance
        frequency = frequency * lacunarity
        yield()
    end
    if normalize then
        value = value / max
    end
    return value
end

function map(value, fromLow, fromHigh, toLow, toHigh)
    return (value - fromLow) * (toHigh - toLow) / (fromHigh - fromLow) + toLow
end

return {
    perlin_2d = perlin_2d,
    perlin_3d = perlin_3d,
    helpers = {
        map = map,
    },
}
