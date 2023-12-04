local function convert_array_to_uuid(array)
    return string.format("%08x-%04x-%04x-%04x-%04x%08x",
        bit32.band(array[1], 0xFFFFFFFF),
        bit32.band(bit32.rshift(array[2], 16), 0xFFFF),
        bit32.band(bit32.rshift(array[2], 0), 0xFFFF),
        bit32.band(bit32.rshift(array[3], 16), 0xFFFF),
        bit32.band(bit32.rshift(array[3], 0), 0xFFFF),
        bit32.band(array[4], 0xFFFFFFFF))
end

local function convert_uuid_to_array(uuid)
    local array = {}
    array[1] = tonumber(uuid:sub(1, 8), 16)
    array[2] = bit32.lshift(tonumber(uuid:sub(10, 13), 16), 16) + tonumber(uuid:sub(15, 18), 16)
    array[3] = bit32.lshift(tonumber(uuid:sub(20, 23), 16), 16) + tonumber(uuid:sub(25, 28), 16)
    array[4] = tonumber(uuid:sub(29, 36), 16)
    return array
end

local function create_uuid_array_string(uuid_str_or_array)
    if type(uuid_str_or_array) == "string" then
        uuid_str_or_array = convert_uuid_to_array(uuid_str_or_array)
    end
    return string.format("[I; %d, %d, %d, %d]", uuid_str_or_array[1], uuid_str_or_array[2], uuid_str_or_array[3], uuid_str_or_array[4])
end

math.randomseed(os.time())
local function random_uuid()
    return string.format("%08x-%04x-%04x-%04x-%04x%08x",
        math.floor(math.random() * 0xFFFFFFFF + .5),
        math.random(0xFFFF),
        math.random(0xFFFF),
        math.random(0xFFFF),
        math.random(0xFFFF),
        math.floor(math.random() * 0xFFFFFFFF + .5))
end

local function central_time_offset(now)
    now = now or os.epoch("utc") / 1000 -- Get the current time in seconds since epoch
    local t = os.date("*t", now)        -- Convert the current time to a table

    -- Check if the current time is within the DST period (second Sunday in March to first Sunday in November)
    local is_cst = (t.month > 3 and t.month < 11) or (t.month == 3 and t.day > 7) or (t.month == 11 and t.day < 8)
    if is_cst then
        return -(6 * 3600) -- CST (UTC - 6 hours)
    else
        return -(5 * 3600) -- CDT (UTC - 5 hours)
    end
end

local past_players = settings.get("past_players", {})
while true do
    local bool, list_of_players_uuid = commands.exec("execute as @p run data get entity @s UUID")
    if bool then
        local list_of_logged_in = {}
        for index, uuid in ipairs(list_of_players_uuid) do
            local username = uuid:match("^[^%s]+")
            local uuid_new = uuid:gsub("^[^:]+:%s", "")
            uuid_new = uuid_new:gsub("I;", "") or "Unable to get uuid"
            list_of_players_uuid[index] = textutils.unserialiseJSON(uuid_new)
            local uuid_string = convert_array_to_uuid(list_of_players_uuid[index])
            list_of_logged_in[uuid_string] = true
            local t = os.epoch("utc") / 1000
            if not past_players[uuid_string] then
                past_players[uuid_string] = {
                    uuid = uuid_string,
                    username = username,
                    first_login = t + central_time_offset(t),
                    last_login = t + central_time_offset(t),
                    sessions = {
                        {
                            login = t + central_time_offset(t),
                            logout = -1
                        }
                    },
                    logged_in_time = 0,
                    loggedin = true,
                }
                commands.tellraw(username, { text = "First login: " .. os.date("%c", past_players[uuid_string].first_login) })
            elseif not past_players[uuid_string].loggedin then
                past_players[uuid_string].loggedin = true
                past_players[uuid_string].last_login = t + central_time_offset(t)
                table.insert(past_players[uuid_string].sessions, {
                    login = t + central_time_offset(t),
                    logout = -1
                })
            end
            for k, v in pairs(past_players[uuid_string].sessions) do
                local end_time
                if v.logout == -1 then
                    t = os.epoch("utc") / 1000
                    end_time = t + central_time_offset(t)
                else
                    end_time = v.logout
                end
                past_players[uuid_string].logged_in_time = past_players[uuid_string].logged_in_time + (end_time - v.login)
            end
        end
        for k, v in pairs(past_players) do
            if not list_of_logged_in[k] and past_players[k].loggedin then
                local t = os.epoch("utc") / 1000
                past_players[k].loggedin = false
                past_players[k].sessions[#past_players[k].sessions].logout = t + central_time_offset(t)
            end
        end
        settings.set("past_players", past_players)
        settings.save()
        -- commands.say(list_of_players_uuid)
    end
    sleep()
end
