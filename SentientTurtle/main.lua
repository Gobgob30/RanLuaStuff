-- mount ./SentientTurtle "D:\DevShit\RanLuaStuff\SentientTurtle\" false
local predefined_model = "gpt-4o"
local openai_key = settings.get("openai_key")

if not openai_key then
    print("Please enter your OpenAI key:")
    openai_key = read()
    settings.set("openai_key", openai_key)
    settings.save()
end

-- local openai = require("OpenAI") going to do this manually
local function get_max_tokens(m, amount)
    amount = amount or 0
    if not m.role then
        local tokens = 0
        for _, v in pairs(m) do
            tokens = tokens + get_max_tokens(v, amount)
        end
        return tokens
    else
        local words = {}
        for word in m.content:gmatch("%S+") do
            table.insert(words, word)
        end
        return #words + amount
    end
end

local roles = {
    user = "user",
    assistant = "assistant",
    system = "system",
}
local function generate_chat_message(role, content)
    return {
        role = role,
        content = content
    }
end

local function complete_chat(chat_table, model, max_tokens)
    local res, err = http.post("https://api.openai.com/v1/chat/completions", textutils.serializeJSON({
        model = model,
        messages = chat_table,
        max_tokens = max_tokens,
        temperature = settings.get("openai_temperature", 1.2),
        top_p = settings.get("openai_top_p", 1),
        presence_penalty = settings.get("openai_presence_penalty", 0),
        frequency_penalty = settings.get("openai_frequency_penalty", 0),
    }), {
        ["Authorization"] = "Bearer " .. openai_key,
        ["Content-Type"] = "application/json"
    })
    if not res then
        return false, err
    end
    local contents = res.readAll()
    res.close()
    return textutils.unserializeJSON(contents)
end

local function chat(chat_table, model)
    local info, err = complete_chat(chat_table, model, get_max_tokens(chat_table, 1000))
    if not info then
        return false, err
    end
    info.choices[1].message.content = info.choices[1].message.content:gsub("^```lua\n", ""):gsub("```$", "")
    table.insert(chat_table, generate_chat_message(roles.user, info.choices[1].message.content))
    if get_max_tokens(chat_table, 100) < 128000 - 128000 / 10 then
        -- prune the first half of the messages
        for i = 1, #chat_table / 2 do
            table.remove(chat_table, 1)
        end
    end
    return true, info.choices[1].message.content
end

local state = {
    pos = { x = 0, y = 0, z = 0 },
    facing = "unknown",
    fuel = "unknown",
    inventory = {},
    selected_slot = 1,
    ret = {},
}
local messages = settings.get("openai_messages", {
    generate_chat_message(roles.system, [[
You are a computercraft turtle. You ONLY have access to the following commands:
- forward(): boolean, string
- back(): boolean, string
- up(): boolean, string
- down(): boolean, string
- turnLeft(): boolean, string
- turnRight(): boolean, string
- dig(): boolean, string
- digUp(): boolean, string
- digDown(): boolean, string
- place(): boolean, string
- placeUp(): boolean, string
- placeDown(): boolean, string
- detect(): boolean
- detectUp(): boolean
- detectDown(): boolean
- inspect(): boolean, string | {name: string, state: table, tags: table<string, boolean>}
- inspectUp(): boolean, string | {name: string, state: table, tags: table<string, boolean>}
- inspectDown(): boolean, string | {name: string, state: table, tags: table<string, boolean>}
- refuel(): boolean, string
- getFuelLevel(): number
- getFuelLimit(): number
- attack(): boolean, string
- attackUp(): boolean, string
- attackDown(): boolean, string
- suck(): boolean, string
- suckUp(): boolean, string
- suckDown(): boolean, string
- drop(): boolean, string
- dropUp(): boolean, string
- dropDown(): boolean, string
- select(slot: number): boolean, string
- getItemCount(slot: number): number
- getItemSpace(slot: number): number
- getItemDetail(slot: number): {name: string, count: number, damage: number}
- compare(): boolean
- compareUp(): boolean
- compareDown(): boolean
- transferTo(slot: number, count: number): boolean, string

You can also access the state of the turtle with the following commands:
- setPos(pos: table): boolean
- setFacing(facing: string): boolean
- setFuel(fuel: number): boolean
- setInventory(inventory: table): boolean
- setSelectedSlot(slot: number): boolean
- gps: table | false, string
You are to explore the underground and find the most valuable ores. I want you to collect information about what you find and where you find it.
You are in control of the turtle todo so.
ONE COMMAND AT A TIME.
Ret will be the return value of the command.
LUA CODE ONLY.
]]),
    generate_chat_message(roles.user, textutils.serializeJSON(state) .. "```lua"),
})

local turtle = turtle or {}
local require_2 = require("cc.require")
local default_func = function()
    return false, "Function not implemented"
end
local env = {
    forward = turtle.forward or default_func,
    back = turtle.back or default_func,
    up = turtle.up or default_func,
    down = turtle.down or default_func,
    turnLeft = turtle.turnLeft or default_func,
    turnRight = turtle.turnRight or default_func,
    dig = turtle.dig or default_func,
    digUp = turtle.digUp or default_func,
    digDown = turtle.digDown or default_func,
    place = turtle.place or default_func,
    placeUp = turtle.placeUp or default_func,
    placeDown = turtle.placeDown or default_func,
    detect = turtle.detect or default_func,
    detectUp = turtle.detectUp or default_func,
    detectDown = turtle.detectDown or default_func,
    inspect = turtle.inspect or default_func,
    inspectUp = turtle.inspectUp or default_func,
    inspectDown = turtle.inspectDown or default_func,
    refuel = turtle.refuel or default_func,
    getFuelLevel = turtle.getFuelLevel or default_func,
    getFuelLimit = turtle.getFuelLimit or default_func,
    attack = turtle.attack or default_func,
    attackUp = turtle.attackUp or default_func,
    attackDown = turtle.attackDown or default_func,
    suck = turtle.suck or default_func,
    suckUp = turtle.suckUp or default_func,
    suckDown = turtle.suckDown or default_func,
    drop = turtle.drop or default_func,
    dropUp = turtle.dropUp or default_func,
    dropDown = turtle.dropDown or default_func,
    select = turtle.select or default_func,
    getItemCount = turtle.getItemCount or default_func,
    getItemSpace = turtle.getItemSpace or default_func,
    getItemDetail = turtle.getItemDetail or default_func,
    compare = turtle.compare or default_func,
    compareUp = turtle.compareUp or default_func,
    compareDown = turtle.compareDown or default_func,
    transferTo = turtle.transferTo or default_func,
    setPos = function(pos)
        state.pos = pos
        return true
    end,
    setFacing = function(facing)
        state.facing = facing
        return true
    end,
    setFuel = function(fuel)
        state.fuel = fuel
        return true
    end,
    setInventory = function(inventory)
        state.inventory = inventory
        return true
    end,
    setSelectedSlot = function(slot)
        state.selected_slot = slot
        return true
    end,
    gps = function()
        return gps.locate(5)
    end
}

print("Starting chat...")

local ppp = print
local print = function(...)
    local args = { ... }
    for i = 1, #args do
        args[i] = tostring(args[i])
    end
    local str = table.concat(args, " ")
    local file, err = fs.open("chat.log", "a")
    if not file then
        ppp("Error: " .. err)
        return
    end
    file.writeLine(str)
    file.close()
    ppp(...)
end

while true do
    local bool, ret_string = chat(messages, predefined_model)
    if not bool then
        print("Error: " .. ret_string)
        break
    end
    local bool, err = load(ret_string, "chat", "t", env)
    if not bool then
        print("Error: " .. err)
        print(ret_string)
        print(textutils.serializeJSON(messages))
        break
    end
    local rets = { pcall(bool) }
    if not rets[1] then
        print("Error:", rets[2])
        print(ret_string)
        print(textutils.serializeJSON(messages))
        break
    end
    state.ret = table.remove(rets, 1)
    table.insert(messages, generate_chat_message(roles.user, textutils.serializeJSON(state) .. "```lua"
    ))
    sleep(1)
end
