shell.run("wget https://raw.githubusercontent.com/Gobgob30/RanLuaStuff/main/ChatBox/chat_box_repl.lua startup.lua")
-- want to get all the command files in ChatBox/Commands and put it into ./commmands folder
local req, err = http.get("https://api.github.com/repos/Gobgob30/RanLuaStuff/contents/ChatBox/Commands")
if not req then
    error(err)
end
local data = textutils.unserializeJSON(req.readAll())
req.close()
if not data then
    error("failed to get commands")
end
if not fs.exists("commands") then
    fs.makeDir("commands")
end
for _, command in ipairs(data) do
    if command.type == "file" then
        shell.run("wget", "https://raw.githubusercontent.com/Gobgob30/RanLuaStuff/main/ChatBox/Commands/" .. command.name, "commands/" .. command.name)
    end
end
