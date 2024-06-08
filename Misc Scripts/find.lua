local function search(path, file_name, max_depth, depth, tbl)
    depth = depth or 0
    tbl = tbl or {}
    if depth > (max_depth or 10) then
        return #tbl > 0, tbl
    end
    local wild_card_tbl = {}
    for i = 1, depth do
        table.insert(wild_card_tbl, "*")
    end
    local find_tbl = fs.find(fs.combine(path, table.unpack(wild_card_tbl) or "", file_name))
    for i, v in ipairs(find_tbl) do
        local bool = true
        for ii, vv in ipairs(tbl) do
            if v == vv then
                bool = false
                break
            end
        end
        if bool then
            table.insert(tbl, v)
        end
    end
    return search(path, file_name, max_depth, depth + 1, tbl)
end

local args = { ... }
if not args[2] then
    args[2] = args[1]
end

local bool, values = search(args[1], args[2])
if bool then
    print("File found.")
    for i, v in ipairs(values) do
        print(v)
    end
else
    print("File not found.")
end
