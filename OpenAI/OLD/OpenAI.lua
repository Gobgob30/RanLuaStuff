local authorization = setmetatable({
    token = ""
}, {
    __index = {
        set_token = function(self, token)
            self.token = token
        end,
        get_token = function(self)
            return self.token or "Need to set token"
        end,
    },
    __newindex = function(self, key, value)
        error(string.format("Cannot set %s", key))
    end,
})
local chat = setmetatable({
    models = {
        ["gpt-4"] = "gpt-4", ["gpt-4-0613"] = "gpt-4-0613", ["gpt-4-32k"] = "gpt-4-32k", ["gpt-4-32k-0613"] = "gpt-4-32k-0613", ["gpt-3.5-turbo"] = "gpt-3.5-turbo", ["gpt-3.5-turbo-0613"] = "gpt-3.5-turbo-0613", ["gpt-3.5-turbo-16k"] = "gpt-3.5-turbo-16k", ["gpt-3.5-turbo-16k-0613"] = "gpt-3.5-turbo-16k-0613",
    },
    roles = {
        ["system"] = "system",
        ["user"] = "user",
        ["assistant"] = "assistant",
        ["function"] = "function",
    },
}, {
    __index = {
        is_valid_model = function(self, model)
            return self.models[model] and true or false
        end,
        generate_message = function(self, message, role)
            role = role or self.roles["user"]
            if not self.roles[role] then
                error(string.format("Invalid role: %s", role))
            end
            return {
                role = role,
                content = message
            }
        end,
        generate_response = function(self, model, messages, functions, function_call, temperature, top_p, n, stop, max_tokens, presence_penalty, frequency_penalty, logit_bias, user)
            if not model then
                return false, "No model"
            end
            if not messages then
                return false, "No messages"
            end
            if not self:is_valid_model(model) then
                return false, "Invalid model"
            end
            local res, err = http.post("https://api.openai.com/v1/chat/completions", textutils.serializeJSON({
                model = model,
                messages = messages,
                functions = functions,
                function_call = function_call,
                temperature = temperature,
                top_p = top_p,
                n = n,
                stop = stop,
                max_tokens = max_tokens,
                presence_penalty = presence_penalty,
                frequency_penalty = frequency_penalty,
                logit_bias = logit_bias,
                user = user
            }), {
                ["Authorization"] = "Bearer " .. authorization:get_token(),
                ["Content-Type"] = "application/json"
            })
            if not res then
                return false, err
            end
            return textutils.unserializeJSON(res.readAll())
        end
    },
    __newindex = function(self, key, value)
        error(string.format("Cannot set %s", key))
    end,
})

return {
    authorization = authorization,
    chat = chat
}
