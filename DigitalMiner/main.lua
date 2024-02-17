local has_basalt, basalt = pcall(require, "basalt")
if not has_basalt then
    shell.run("wget run https://basalt.madefor.cc/install.lua release latest.lua")
    has_basalt, basalt = pcall(require, "basalt")
    if not has_basalt then
        error("Failed to load basalt\n" .. tostring(basalt))
    end
end

local function new_ore_class(name, spawn, sleep_time)
    return {
        name = name,
        spawn = spawn,
        sleep_time = sleep_time,
        enabled = false
    }
end
local ores = {}
local mined = settings.get("mined", {})
local csv_url = settings.get("csv_url", "https://raw.githubusercontent.com/Gobgob30/RanLuaStuff/main/returns.csv")
local csv, err = http.get(csv_url)
if not csv then
    error("Failed to get csv: " .. tostring(err))
end

local root = basalt.createFrame("root")
local statusBar = root:addFrame("statusBar"):setPosition(1, 1):setSize("{parent.w}", 1):setBackground(colors.lightGray)
local menuSelector = root:addFrame("menuSelector"):setPosition(1, 2):setSize(1, "{parent.h - 1}"):setBackground(colors.lightGray)
local scrollBar = root:addScrollbar("scrollBar"):setPosition("{parent.w-1}", 2):setSize(1, "{parent.h - 1}"):setBackground(colors.lightGray):setScrollAmount(1)
local spawnBox_frame = root:addFrame("spawnBox_frame"):setPosition(2, 2):setSize("{parent.w - 3}", "{parent.h - 1}"):setBackground(colors.black) --:setVisible(false)
local spawnBox_viewport
local spawnMenu_frame = spawnBox_frame:addFrame("spawnMenu_frame"):setPosition(1, 1):setSize("{parent.w}", "{parent.h}"):setBackground(colors.black):setVisible(false)
local spawnMenu_amount_close_button
local spawnMenu_amount_box
local spawnMenu_amount_up
local spawnMenu_amount_down
local spawnMenu_spawn_button
local mineBox_frame = root:addFrame("mineBox_frame"):setPosition(2, 2):setSize("{parent.w - 3}", "{parent.h - 1}"):setBackground(colors.black):setVisible(false)
local mineBox_viewport

local sleep_time = 0

parallel.waitForAny(basalt.autoUpdate, function()
    while true do
        sleep(sleep_time)
    end
end)
