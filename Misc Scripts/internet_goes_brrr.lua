-- local function create_(a,b,c,d)
local function create_(...)
    -- return {
    --     type(a) == "table" and a or {a},
    -- }
    local t = {}
    local a = { ... }
    for i = 1, #a do
        t[i] = type(a[i]) == "table" and a[i] or { a[i] }
    end
    return t
end
-- Lunch: billie eilish
local bpm = 126
local notes = {
    [""] = {
        create_(-1, -1, -1, { 8, 10 }),
        create_({ 11, 10 }, { 11, 8 }, 10, { 8, 8 }),
        create_({ 11, }, { 8, 10 }, 10, { 11, 10 }),
    }
}

local function play_sound(sound_table)
    for i = 1, #sound_table do
        local note = sound_table[i]
        if type(note) == "table" then
            speaker.playNote("harp", 1, note[1], note[2])
        else
            speaker.playNote("harp", 1, note)
        end
        sleep(60 / bpm)
    end

end

-- while true do
--     if http.get("https://www.google.com/") then
--         -- for i = 1, 24 do
--         --     while not speaker.playNote("harp", 1, i) do sleep() end
--         -- end
--         break
--     end
-- end
