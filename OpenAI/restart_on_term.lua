local args = { ... }
local has_terminated = false
while true do
    parallel.waitForAny(function()
        while true do
            local event = { os.pullEventRaw("terminate") }
            if event[1] == "terminate" then
                break
            else
                -- print(table.unpack(event))
            end
        end
    end, function()
        shell.run(table.unpack(args))
    end)
end
