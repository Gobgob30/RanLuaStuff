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

local p = {}

local function set_seed(seed)
    math.randomseed(seed)
    for i = 1, 256 * 2 do
        p[i] = math.random(0, 255)
    end
end
math.randomseed(os.time(), math.random(9999, 99999))
set_seed(math.random(9999, 99999))

local function fade(t)
    --	fade graph: https://www.desmos.com/calculator/d5cgqlrmem
    return t * t * t * (t * (t * 6 - 15) + 10)
end

local function lerp(t, a, b)
    return a + t * (b - a)
end

local function grad(hash, x, y, z)
    local h = hash % 16
    local cases = {
        x + y,
        -x + y,
        x - y,
        -x - y,

        x + z,
        -x + z,
        x - z,
        -x - z,

        y + z,
        -y + z,
        y - z,
        -y - z,

        y + x,
        -y + z,
        y - x,
        -y - z,
    }
    return cases[h + 1]
end

local function noise(x, y, z)
    local a, b, c = math.floor(x) % 256, math.floor(y) % 256, math.floor(z) % 256 -- values in range [0, 255]
    local xx, yy, zz = x % 1, y % 1, z % 1
    local u, v, w = fade(xx), fade(yy), fade(zz)
    local a0 = p[a + 1] + b
    local a1, a2 = p[a0 + 1] + c, p[a0 + 2] + c
    local b0 = p[a + 2] + b
    local b1, b2 = p[b0 + 1] + c, p[b0 + 2] + c
    local k1 = grad(p[a1 + 1], xx, yy, zz)
    local k2 = grad(p[b1 + 1], xx - 1, yy, zz)
    local k3 = grad(p[a2 + 1], xx, yy - 1, zz)
    local k4 = grad(p[b2 + 1], xx - 1, yy - 1, zz)
    local k5 = grad(p[a1 + 2], xx, yy, zz - 1)
    local k6 = grad(p[b1 + 2], xx - 1, yy, zz - 1)
    local k7 = grad(p[a2 + 2], xx, yy - 1, zz - 1)
    local k8 = grad(p[b2 + 2], xx - 1, yy - 1, zz - 1)
    return lerp(w,
        lerp(v, lerp(u, k1, k2), lerp(u, k3, k4)),
        lerp(v, lerp(u, k5, k6), lerp(u, k7, k8)))
end

local function perlin_3d(x, y, z, scale, octaves, persistance, lacunarity)
    local xs, ys, zs = x / scale, y / scale, z / scale
    persistance = 2.0 ^ -persistance
    local value = 0
    local frequency = 1
    local amplitude = 1
    local max = 0
    for i = 1, octaves do
        value = value + noise(xs * frequency, ys * frequency, zs * frequency) * amplitude
        max = max + amplitude
        amplitude = amplitude * persistance
        frequency = frequency * lacunarity
        yield()
    end
    return value / max
end

local function perlin_2d(x, y, scale, octaves, persistance, lacunarity)
    return perlin_3d(x, y, 1, scale, octaves, persistance, lacunarity)
end

local function perlin(x, scale, octaves, persistance, lacunarity)
    return perlin_2d(x, 1, scale, octaves, persistance, lacunarity)
end

function map(value, fromLow, fromHigh, toLow, toHigh)
    return (value - fromLow) * (toHigh - toLow) / (fromHigh - fromLow) + toLow
end

return {
    set_seed = set_seed,
    perlin = perlin,
    perlin_2d = perlin_2d,
    perlin_3d = perlin_3d,
    helpers = {
        map = map,
    },
}
