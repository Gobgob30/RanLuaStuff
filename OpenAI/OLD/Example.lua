local openAI = require("OpenAI")
openAI.authorization:set_token(settings.get("openAI_token"))

local messages = {
    openAI.chat:generate_message("You are a joke bot", openAI.chat.roles["system"])
}
local model = openAI.chat.models["gpt-3.5-turbo"]
while true do
    local message = read()
    if message:lower() == "reload" then
        messages = {
            openAI.chat:generate_message("You are a joke bot", openAI.chat.roles["system"])
        }
    else
        table.insert(messages, openAI.chat:generate_message(message))
        local ret, err = openAI.chat.generate_response(model, messages)
        if not ret then
            print(err)
        else
            table.insert(messages, ret.choices[1].message)
        end
    end
    for i, v in ipairs(messages) do
        write(v.role .. ":")
        print(v.content)
    end
end
