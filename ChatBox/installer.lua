if fs.exists("startup.lua") then
    shell.run("rm", "startup.lua")
end
shell.run("wget https://raw.githubusercontent.com/Gobgob30/RanLuaStuff/main/ChatBox/startup.lua")
if fs.exists("subs_startup.lua") then
    shell.run("rm", "subs_startup.lua")
end
shell.run("wget https://raw.githubusercontent.com/Gobgob30/RanLuaStuff/main/ChatBox/subs_startup.lua")
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
        if fs.exists("commands/" .. command.name) then
            shell.run("rm", "commands/" .. command.name)
        end
        shell.run("wget", "https://raw.githubusercontent.com/Gobgob30/RanLuaStuff/main/ChatBox/Commands/" .. command.name, "commands/" .. command.name)
    end
    sleep(1)
end
os.reboot()
