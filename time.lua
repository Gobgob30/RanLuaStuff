local _time
local function start(time)
    _time = time or os.epoch("utc") / 1000
end

local function stop(time)
    return (time or os.epoch("utc") / 1000) - _time
end

local format_str = "%c"
local function _print(time)
    print(os.date(format_str, stop(time)))
end

local function set_format(str)
    format_str = str
end

return {
    start = start,
    stop = stop,
    print = _print,
    set_format = set_format
}
