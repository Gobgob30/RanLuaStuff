local yieldTime                                         -- variable to store the time of the last yield
local yieldTimeLimit = 1                                -- the time limit for the yield in seconds
local yieldTime                                         -- variable to store the time of the last yield
local yieldTimeLimit = 1                                -- the time limit for the yield in seconds
local function yield()
    if yieldTime then                                   -- check if it already yielded
        if os.clock() - yieldTime > yieldTimeLimit then -- if it were more than 2 seconds since the last yield
            os.queueEvent("someFakeEvent")              -- queue the event
            os.pullEvent("someFakeEvent")               -- pull it
            yieldTime = nil                             -- reset the counter
        end
    else
        yieldTime = os.clock() -- store the time
    end
end
local function set_limit(limit)
    yieldTimeLimit = limit
end

return {
    yield = yield,
    set_limit = set_limit
}
