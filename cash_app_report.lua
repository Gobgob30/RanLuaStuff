local function date_to_time(dateString, time_pattern, type_and_pos)
    if not dateString then
        return nil, "dateString is required"
    end
    if time_pattern and not type_and_pos then
        return nil, "type_and_pos is required when time_pattern is provided"
    end
    time_pattern = time_pattern or "(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+) (%a+)"
    type_and_pos = type_and_pos or { year = 1, month = 2, day = 3, hour = 4, min = 5, sec = 6, timezone = 7 }
    local values = { dateString:match(time_pattern) }

    local months = {
        Jan = 1,
        Feb = 2,
        Mar = 3,
        Apr = 4,
        May = 5,
        Jun = 6,
        Jul = 7,
        Aug = 8,
        Sep = 9,
        Oct = 10,
        Nov = 11,
        Dec = 12
    }

    local timezoneOffsets = {
        CST = -6, -- Central Standard Time
        CDT = -5, -- Central Daylight Time
        EST = -5, -- Eastern Standard Time
        EDT = -4, -- Eastern Daylight Time
        MST = -7, -- Mountain Standard Time
        MDT = -6, -- Mountain Daylight Time
    }
    local timestamp = os.time({
        year = tonumber(type_and_pos.year and values[type_and_pos.year]),                            -- year
        month = tonumber(type_and_pos.month and values[type_and_pos.month]),                         -- month
        day = tonumber(type_and_pos.day and values[type_and_pos.day]),                               -- day
        hour = tonumber(type_and_pos.hour and values[type_and_pos.hour]),                            -- hour
        min = tonumber(type_and_pos.min and values[type_and_pos.min]),                               -- min
        sec = tonumber(type_and_pos.sec and values[type_and_pos.sec]),                               -- sec
        isdst = type_and_pos.timezone and values[type_and_pos.timezone]:find("DT") and true or false -- is daylight savings time
    })
    return timestamp
end

local function get_pay_periods(lines)
    local pay_end = 0
    local pay_start = 0
    local pay_periods = {}
    for i, v in ipairs(lines) do
        local type_ = v["Transaction Type"]
        local amount = v["Amount"]
        local date = v["Date"]
        local time = date_to_time(date)
        local notes = v["Notes"]
        if type_ == "Direct Deposit" and amount > 250 then
            -- print(i, type_, amount, type(amount), date, time, notes)
            pay_start = pay_end + 1
            pay_end = i
            local pay_period = {}
            for j = pay_start, pay_end do
                lines[j]["Date"] = date_to_time(lines[j]["Date"])
                table.insert(pay_period, lines[j])
            end
            table.insert(pay_periods, pay_period)
        end
    end
    return pay_periods
end

local cash_symbols = { "%$", "€", "£", "¥", "₣", "₹", "د.ك", "د.إ", "₻", "₽", "₾", "₺", "₼", "₸", "₴", "₷", "฿", "원", "₫", "₮", "₯", "₱", "₳", "₵", "₲", "₪", "₰" }
local function process_line(line, delimiter, remove_quotes, headers)
    local values = {}
    local amount = 0
    for j in string.gmatch(line, "[^" .. delimiter .. "]+") do
        amount = amount + 1
        for i, v in ipairs(cash_symbols) do
            if j:match(v) then
                j = j:gsub(v, "")
                break
            end
        end
        if headers and headers[amount] then
            values[headers[amount]] = tonumber((j:gsub("\"", ""))) or remove_quotes and (j:gsub("\"", ""))
        else
            table.insert(values, tonumber((j:gsub("\"", ""))) or remove_quotes and (j:gsub("\"", "")))
        end
    end
    return values
end

local function parse_csv(file_name, delimiter, options)
    delimiter = delimiter or ','
    local f, err = fs.open(file_name, "r")
    if not f then
        return nil, err
    end
    local lines = {}
    local headers = options.headers and process_line(f.readLine(), delimiter, true)
    repeat
        local line = f.readLine()
        if line ~= nil then
            table.insert(lines, process_line(line, delimiter, true, headers))
        end
    until line == nil
    f.close()
    return lines
end
local file_name = "cash_app_report.csv"
local delimiter = ','
local options = { headers = true }
local lines, err = parse_csv(file_name, delimiter, options)
if not lines then
    error(err)
end

local spacer = " "

local has_basalt, basalt = pcall(require, "basalt")
if not has_basalt then
    shell.run("wget run https://basalt.madefor.cc/install.lua release latest.lua")
    has_basalt, basalt = pcall(require, "basalt")
    if not has_basalt then
        error("Failed to load basalt\n" .. tostring(basalt))
    end
end

local main_frame = basalt.createFrame()
if not main_frame then
    error("Failed to create main frame")
end
local pay_periods_frame = main_frame:addFrame():setPosition("{parent.x + 1}", "{parent.y + 1}"):setSize("{parent.width / 2 - 5}", "{parent.height - 5}")
local pay_period_frame = main_frame:addFrame():setPosition("{parent.x + parent.width / 2 + 1}", "{parent.y + 1}"):setSize("{parent.width / 2 - 5}", "{parent.height - 5}")
local pay_periods_list = pay_periods_frame:addList():setSize("{parent.width}", "{parent.height}")
local pay_period_details = pay_period_frame:addList():setSize("{parent.width}", "{parent.height}")
local pay_periods = get_pay_periods(lines)
local pay_periods_sizes = {}
for i, v in ipairs(pay_periods) do
    for j, k in ipairs(v) do
        for l, m in pairs(k) do
            if not pay_periods_sizes[l] then
                pay_periods_sizes[l] = 0
            end
            if #tostring(m) > pay_periods_sizes[l] then
                pay_periods_sizes[l] = #tostring(m)
            end
        end
    end
end
for i, v in ipairs(pay_periods) do
    pay_periods_list:addItem(table.concat({ os.date("%m/%d/%Y", v[1]["Date"]), os.date("%m/%d/%Y", v[#v]["Date"]) }, spacer), nil, nil, v)
    if i == 1 then
        pay_period_details:addItem(table.concat({ "Transaction Type" .. string.rep(" ", pay_periods_sizes["Transaction Type"] - #"Transaction Type"), "Amount" .. string.rep(" ", pay_periods_sizes["Amount"] - #"Amount"), "Date" .. string.rep(" ", pay_periods_sizes["Date"] - #"Date"), "Notes" }, spacer), nil, nil, v)
        for j, k in ipairs(v) do
            pay_period_details:addItem(table.concat({ k["Transaction Type"] .. string.rep(" ", pay_periods_sizes["Transaction Type"] - #k["Transaction Type"]), k["Amount"] .. string.rep(" ", pay_periods_sizes["Amount"] - #tostring(k["Amount"])), os.date("%m/%d/%Y", k["Date"]) .. string.rep(" ", pay_periods_sizes["Date"] - #os.date("%m/%d/%Y", k["Date"])), k["Notes"] }, spacer), nil, nil, v)
        end
    end
end
pay_periods_list:onSelect(function(self, event, item)
    if not item.args[1] then return end
    pay_period_details:clear()
    local largest_size = {}
    for i, v in ipairs(item.args[1]) do
        for j, k in pairs(v) do
            if not largest_size[j] then
                largest_size[j] = 0
            end
            if #tostring(k) > largest_size[j] then
                largest_size[j] = #tostring(k)
            end
        end
    end
    for i, v in ipairs(item.args[1]) do
        if i == 1 then
            pay_period_details:addItem(table.concat({ "Transaction Type" .. string.rep(" ", largest_size["Transaction Type"] - #"Transaction Type"), "Amount" .. string.rep(" ", largest_size["Amount"] - #"Amount"), "Date" .. string.rep(" ", largest_size["Date"] - #"Date"), "Notes" }, spacer), nil, nil, v)
        end
        pay_period_details:addItem(table.concat({ v["Transaction Type"] .. string.rep(" ", largest_size["Transaction Type"] - #v["Transaction Type"]), v["Amount"] .. string.rep(" ", largest_size["Amount"] - #tostring(v["Amount"])), os.date("%m/%d/%Y", v["Date"]) .. string.rep(" ", largest_size["Date"] - #os.date("%m/%d/%Y", v["Date"])), v["Notes"] }, spacer), nil, nil, v)
    end
end)

basalt.autoUpdate()
