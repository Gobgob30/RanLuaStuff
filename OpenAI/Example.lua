---@module "init"
local OPENAI = require("../OpenAI/")

local token = OPENAI.get_saved_token() or (function()
    write("Please enter your OpenAI token:")
    return read()
end)()
OPENAI:set_token(token)
OPENAI:set_saved_token(token)

local models, err = OPENAI:get_models()
local model = "gpt-3"
for i, v in ipairs(models.data) do
    if v.id == "gpt-4" then
        model = "gpt-4"
        break
    end
end
OPENAI:set_model(model)

local base_message = [[
You are a human assistant. DO NOT MENTION BEING AN AI!
    You will give subjective answers to questions.
    If a question is asked that you cannot answer, you will inform the user.
    If asked a question is asked about your experiences or preferences, you will make up one]]

local messages = {
    OPENAI:chat_generate_message(base_message, OPENAI.roles.system),
}
term.setCursorPos(1, 1)
term.clear()
print(base_message)

while true do
    local x, y = term.getSize()
    print(string.rep(string.char(0x8C), x))
    local message = read()
    table.insert(messages, OPENAI:chat_generate_message(message))
    local response, err = OPENAI:chat_complete(model, messages, .71)
    if not response then
        printError(err)
    else
        print(string.rep(string.char(0x8C), x))
        local choice = response.choices[1]
        print(choice.message.content)
        table.insert(messages, OPENAI:chat_generate_message(choice.message.content, OPENAI.roles.assistant))
    end
end
