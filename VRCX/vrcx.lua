-- -- vrc_lib.Authentication.check_user("email", "displayName", "userId", "excludeUsetId")
-- local bool_or_2fa, cookie = vrc_lib.Authentication.login("SeaAsterLab", "Abc1999!")
-- if not bool_or_2fa then
--     error(cookie)
-- end
-- if type(bool_or_2fa) == "table" then
--     print("Select one", table.unpack(bool_or_2fa))
--     local input = read(nil, bool_or_2fa):lower()
--     write("Code here: ")
--     local bool, err = vrc_lib.Authentication.Auth2fa(read(), cookie, input)
--     if bool == nil then
--         error(err)
--     end
-- elseif bool_or_2fa == true then
--     print("Logged in")
-- end
local has_basalt, basalt = pcall(require, "basalt")
if not has_basalt then
    shell.run("wget run https://basalt.madefor.cc/install.lua release latest.lua")
    has_basalt, basalt = pcall(require, "basalt")
    if not has_basalt then
        error("Failed to load basalt\n" .. tostring(basalt))
    end
end
local vrc_lib        = require("vrc_lib")
local main_frame     = basalt.createFrame("main_frame")
-- #region Login
local login_frame    = main_frame:addFrame("login_frame")
local username_input = login_frame:addInput("username_input")
local username_label = login_frame:addLabel("username_label")
local password_input = login_frame:addInput("password_input")
local password_label = login_frame:addLabel("password_label")
local login_button   = login_frame:addButton("login_button")
local _2fa_frame     = main_frame:addFrame("2fa_frame")
local _2fa_list      = _2fa_frame:addList("2fa_list")
local _2fa_input     = _2fa_frame:addInput("2fa_input")
local _2fa_label     = _2fa_frame:addLabel("2fa_label")
local _2fa_button    = _2fa_frame:addButton("2fa_button")
local function check_loged_in(self)
    if vrc_lib.Authentication.is_logged_in() then
        self:hide()
    end
end
login_frame
    :setPosition("{parent.w / 4}", "{parent.h / 4}")
    :setSize("{parent.w / 2}", "{parent.h / 2}")
    :onGetFocus(check_loged_in)
    :onLoseFocus(check_loged_in)
    :show()
username_input
    :setPosition("{(parent.w / 2 - self.w / 2)}", "{(parent.h / 3 - self.h / 3) * 1 - (parent.h / 3 - self.h / 3) / 2}")
    :setSize("{parent.w - 3}", "{ parent.h / 3 - 4 }")
    :setBackground(colors.black)
    :setForeground(colors.white)
username_label
    :setPosition("{(parent.w / 2 - self.w / 2)}", "{((parent.h / 3 - self.h / 3) * 1 - (parent.h / 3 - self.h / 3) / 2) - 2}")
    :setSize("{parent.w - 3}", "{ parent.h / 6 - 4 }")
    :setForeground(colors.white)
    :setText("Username")
password_input
    :setInputType("password")
    :setPosition("{(parent.w / 2 - self.w / 2)}", "{(parent.h / 3 - self.h / 3) * 2 - (parent.h / 3 - self.h / 3) / 2}")
    :setSize("{parent.w - 3}", "{ parent.h / 3 - 4 }")
    :setBackground(colors.black)
    :setForeground(colors.white)
password_label
    :setPosition("{(parent.w / 2 - self.w / 2)}", "{((parent.h / 3 - self.h / 3) * 2 - (parent.h / 3 - self.h / 3) / 2) - 3}")
    :setSize("{parent.w - 3}", "{ parent.h / 6 - 4 }")
    :setForeground(colors.white)
    :setText("Password")
login_button
    :setPosition("{(parent.w / 2 - self.w / 2)}", "{(parent.h / 3 - self.h / 3) * 3 - (parent.h / 3 - self.h / 3) / 2}")
    :setSize("{parent.w - 3}", "{ parent.h / 3 - 4 }")
    :setBackground(colors.black)
    :setForeground(colors.white)
    :setText("Login")
_2fa_frame
    :setPosition("{parent.w / 4}", "{parent.h / 4}")
    :setSize("{parent.w / 2}", "{parent.h / 2}")
    :onGetFocus(check_loged_in)
    :onLoseFocus(check_loged_in)
    :hide()
-- :show()

-- #endregion


basalt.autoUpdate()
