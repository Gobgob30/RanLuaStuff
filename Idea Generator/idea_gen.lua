-- mount "./idea_gen" "D:\DevShit\RanLuaStuff\Idea Generator\"
local p_error = printError and function(...)
    local args = { ... }
    for k, v in ipairs(args) do args[k] = tostring(v) end
    printError(table.concat(args, " "))
end or function(...)
    local args = { ... }
    for k, v in ipairs(args) do args[k] = tostring(v) end
    print(table.concat(args, " "))
end
local args = { ... }
local file = fs.combine(fs.getDir(shell.getRunningProgram()), args[1] or "ideas.csv")
local file_handler, file_handler_err = fs.open(file, "r")
if not file_handler then
    p_error("Error opening file:", file_handler_err)
    return
end
local csv_string = file_handler.readAll()
file_handler.close()
local csv = {}
for line in csv_string:gmatch("[^\n]+") do
    local row = {}
    for value in line:gmatch("[^,]+") do
        table.insert(row, value)
    end
    table.insert(csv, row)
end

local function get_idea()
    math.randomseed(os.epoch("utc"))
    local row = csv[math.random(1, #csv)]
    local row_name = row[1]
    local value = row[math.random(2, #row)]
    return table.concat({ row_name, value }, ": ")
end


print(get_idea())
