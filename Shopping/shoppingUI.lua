local has_basalt, basalt = pcall(require, "basalt")
if not has_basalt then
    shell.run("wget run https://basalt.madefor.cc/install.lua release latest.lua")
    has_basalt, basalt = pcall(require, "basalt")
    if not has_basalt then
        error("Failed to load basalt\n" .. tostring(basalt))
    end
end

local shopping = require("util.shopping")
local main_frame = basalt.createFrame("main_frame")
local shopping_lists_frame = main_frame:addFrame("shopping_list_frame"):setSize("{parent.w}", "{parent.h}"):setBackground(colors.black):setForeground(colors.white)
local shopping_lists_add_button = shopping_lists_frame:addButton("shopping_list_add_button")
    :setText("Add")
    :setPosition("{(parent.w / 3 - self.w / 3 + 3) * 1 - (parent.w / 3 - self.w / 3)}", 2) --* 1 - (parent.w / 3 - self.w / 3) / 1.125}", 2)
    :setSize("{parent.w / 3}", "{parent.h / 6}")
local shopping_lists_remove_button = shopping_lists_frame:addButton("shopping_list_remove_button")
    :setText("Remove")
    :setPosition("{(parent.w / 3 - self.w / 3 + 3) * 2 - (parent.w / 3 - self.w / 3)}", 2)
    :setSize("{parent.w / 3}", "{parent.h / 6}")
local shopping_lists_open_button = shopping_lists_frame:addButton("shopping_list_open_button")
    :setText("Open")
    :setPosition("{(parent.w / 3 - self.w / 3 + 3) * 3 - (parent.w / 3 - self.w / 3)}", 2)
    :setSize("{parent.w / 3}", "{parent.h / 6}")
-- local shopping_lists_list = shopping_lists_frame:addList("shopping_list_list")
--     :setPosition("{(parent.w / 3 - self.w / 3) - (parent.w / 3 - self.w / 3) + 1}", "{parent.h / 6 + 3}")

local shopping_list_frame = main_frame:addFrame("shopping_list_frame"):hide()
local shopping_list_item_input = shopping_list_frame:addInput("shopping_list_item_input")
local shopping_list_price_input = shopping_list_frame:addInput("shopping_list_price_input")
local shopping_list_add_button = shopping_list_frame:addButton("shopping_list_add_button")
local shopping_list_done_button = shopping_list_frame:addButton("shopping_list_done_button")
local shopping_list_list = shopping_list_frame:addList("shopping_list_list")

basalt.autoUpdate()
