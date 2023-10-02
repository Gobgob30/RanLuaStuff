local has_openAI, openAI = pcall(require, "OpenAI")
if not has_openAI then
    error("Failed to load OpenAI\n" .. tostring(openAI))
end
openAI.authorization:set_token(settings.get("openAI_token"))
local chat_box = peripheral.find("chatBox")
if not chat_box then
    error("Computer chat box not found", 2)
end

local messages = {
    openAI.chat:generate_message("You are a joke bot", openAI.chat.roles["system"])
}

while true do
    local event, username, message = os.pullEvent("chat")
    if message:lower() == "reload" then
        messages = {
            openAI.chat:generate_message("You are a joke bot", openAI.chat.roles["system"])
        }
    else
        table.insert(messages, openAI.chat:generate_message(message))
        local ret, err = openAI.chat:generate_response(openAI.chat.models["gpt-3.5-turbo"], messages, nil, nil,nil, )
        if not ret then
            print(err)
        else
            local responce = ret.choices[1].message
            for split in responce.content:gmatch("[^\n]+") do
                chat_box.sendMessage(split)
                for split_space in split:gmatch("[^%s]+") do
                    os.setComputerLabel(split_space)
                    sleep(.5)
                end
                sleep(1)
            end
            os.setComputerLabel()
        end
    end
end
