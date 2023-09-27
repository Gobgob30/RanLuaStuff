-- Define the bit masks for encoding and decoding
local BITMASK = 0x1F
local SHIFT = 5

local function encode(coord, factor)
    coord = math.floor(coord * factor + 0.5)
    local invert = false
    coord = coord < 0 and bit32.bxor(bit32.lshift(coord, 1), 0xffffffff) or bit32.lshift(coord, 1)
    local output = ''
    while coord >= 0x20 do
        local val = bit32.bor(0x20, bit32.band(coord, BITMASK)) + 63
        output = output .. string.char(val)
        coord = bit32.rshift(coord, SHIFT)
    end
    output = output .. string.char(coord + 63)
    return output
end

local function encodePolyline(coords)
    if (#coords == 0) then return '' end
    local output = encode(coords[1][1], 1e5) .. encode(coords[1][2], 1e5)
    for i = 2, #coords do
        local a, b = coords[i], coords[i - 1]
        output = output
            .. encode(a[1] - b[1], 1e5)
            .. encode(a[2] - b[2], 1e5)
    end
    return output
end

-- Function to decode an encoded polyline
local function decodePolyline(encoded)
    if not encoded then return {} end
    local poly = {}
    local index, len = 1, #encoded
    local lat, lng = 0, 0
    while index < len do
        local shift, result, b = 0, 0
        repeat
            b = encoded:byte(index) - 63
            index = index + 1
            result = result + (b % 0x20) * 2 ^ shift
            shift = shift + 5
        until b < 0x20
        local hlat = bit32.rshift(result, 1)
        local dlat = result % 2 ~= 0 and -hlat or hlat
        lat = lat + dlat
        shift, result = 0, 0
        repeat
            b = encoded:byte(index) - 63
            index = index + 1
            result = result + (b % 0x20) * 2 ^ shift
            shift = shift + 5
        until b < 0x20
        local hlng = bit32.rshift(result, 1)
        local dlng = result % 2 ~= 0 and -hlng or hlng
        lng = lng + dlng
        poly[#poly + 1] = { lat / 1e5, lng / 1e5 }
    end
    return poly
end

local encodedCoordinates = encodePolyline({ { 38.5, -120.2 }, { 40.7, -120.95 }, { 43.252, -126.453 } })
local f = fs.open("test.txt", "a")
f.writeLine(encodedCoordinates)
f.close()
if encodedCoordinates ~= "_p~iF~ps|U_ulLnnqC_mqNvxq`@" then
    print("Failed to make a valid encoded polyline")
end
local decodedCoordinates = decodePolyline(encodedCoordinates)
for _, coord in ipairs(decodedCoordinates) do
    print(string.format("Lat: %.6f, Lon: %.6f", coord[1], coord[2]))
end
