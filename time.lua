local _time
local function start(time)
    _time = time or os.epoch("utc") / 1000
end

local function stop(time)
    return (time or os.epoch("utc") / 1000) - _time
end

local function _print(time)
    local time = stop(time)
    local hms = os.date("%H:%M:%S", time)
    local ms = string.format("%03d", time % 1 * 1000)
    print(hms .. ":" .. ms)
end

return {
    start = start,
    stop = stop,
    print = _print,
}
