-- mount ./OpenAI "D:\DevShit\RanLuaStuff\OpenAI\" false
local urls = {
    models = {
        list = "https://api.openai.com/v1/models",
        retrieve = "https://api.openai.com/v1/models/%s",
        delete_fine_tune = "https://api.openai.com/v1/models/%s",
    },
    audio = {
        speech = "https://api.openai.com/v1/audio/speech",
        transcription = "https://api.openai.com/v1/audio/transcriptions",
        translation = "https://api.openai.com/v1/audio/translations",
    },
    chat = {
        completions = "https://api.openai.com/v1/chat/completions",
    },
    -- embeddings = "https://api.openai.com/v1/embeddings",
    fine_tuning = {
        jobs = "https://api.openai.com/v1/fine_tuning/jobs",
        fine_tune_events = "https://api.openai.com/v1/fine_tuning/jobs/%s/events",
        fine_tune_checkpoints = "https://api.openai.com/v1/fine_tuning/jobs/%s/checkpoints",
        fine_tune_retrieve = "https://api.openai.com/v1/fine_tuning/jobs/%s/",
        fine_tune_cancel = "https://api.openai.com/v1/fine_tuning/jobs/%s/cancel",
    },
    batch = {
        batches = "https://api.openai.com/v1/batches",
        batch_retrieve = "https://api.openai.com/v1/batches/%s",
        batch_cancel = "https://api.openai.com/v1/batches/%s/cancel",
    },
    file = {
        files = "https://api.openai.com/v1/files",
        file_from_id = "https://api.openai.com/v1/files/%s",
        file_content_from_id = "https://api.openai.com/v1/files/%s/content",
    },
    images = {
        generate = "https://api.openai.com/v1/images/generations",
        edit = "https://api.openai.com/v1/images/edits",
        variations = "https://api.openai.com/v1/images/variations",
    },
    moderation = {
        create = "https://api.openai.com/v1/moderation/",
    }
}

local class_properties = {
    open_ai_token = "Undefined",
    model = "",
    roles = {
        user = "user",
        assistant = "assistant",
        system = "system",
    }
}

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

local class_methods = {
    get_max_tokens = get_max_tokens,
    get_models = function(self)
        local res, err = http.get(urls.models.list, {
            ["Authorization"] = "Bearer " .. self:get_token(),
            ["Content-Type"] = "application/json"
        })
        if not res then
            return false, err
        end
        return textutils.unserializeJSON(res.readAll())
    end,
    set_model = function(self, model, value)
        self.model = value
    end,
    set_token = function(self, token, name)
        self.open_ai_token = token
    end,
    get_token = function(self)
        return self.open_ai_token
    end,
    chat_generate_message = function(self, message, role)
        role = role or self.roles["user"]
        if not self.roles[role] then
            error(string.format("Invalid role: %s", role))
        end
        return {
            role = role,
            content = message
        }
    end,
    chat_complete = function(self, model, messages, temperature, top_p, n, stop, max_tokens, presence_penalty, frequency_penalty, logit_bias, user)
        if not model then
            return false, "No model"
        end
        if not messages then
            return false, "No messages"
        end
        temperature = temperature or 0.5
        top_p = top_p or 1
        n = n or 1
        stop = stop or nil
        max_tokens = max_tokens or get_max_tokens(messages, 100)
        presence_penalty = presence_penalty or 0
        frequency_penalty = frequency_penalty or 0
        logit_bias = logit_bias or {}
        user = user or self.roles["user"]

        local res, err = http.post(urls.chat.completions, textutils.serializeJSON({
            model = model,

            messages = messages,
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
            ["Authorization"] = "Bearer " .. self:get_token(),
            ["Content-Type"] = "application/json"
        })
        if not res then
            return false, err
        end
        return textutils.unserializeJSON(res.readAll())
    end,
}

local class_metatable = {
    __index = class_methods,
    __newindex = function(self, key, value)
        error(string.format("Cannot set %s", key))
    end,
}

return setmetatable(class_properties, class_metatable)
