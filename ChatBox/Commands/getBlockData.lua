-- local x, y, z =
local centers = {
    vector.new(173, 255, -37)
}
for _, center in ipairs(centers) do
    local cX, cY, cZ = center.x, center.y, center.z
    local data = commands.getBlockInfos(cX - 2, cY, cZ - 2, cX + 2, cY + 5, cZ + 2)
    local blocks = {}
    for key, block in ipairs(data) do
        if block.name ~= "minecraft:air" then
            -- table.insert(blocks, { name = block.name, state = block.state })
            blocks[key] = { name = block.name, state = block.state }
        end
    end
    blocks.length = #data
    local file = fs.open(string.format("blocks/block_%d_%d_%d.lua", cX, cY, cZ), "w")
    file.write("return " .. textutils.serialise(blocks))
    file.close()
end
