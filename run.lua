local function run(tasks, limit)
    limit = limit or 64
    if not tasks then
        return
    end
    if #tasks == 0 then
        return
    end
    if #tasks > limit then
        local cmds = {}
        for i = 1, limit do
            table.insert(cmds, table.remove(tasks))
        end
        parallel.waitForAll(table.unpack(cmds))
        return run(tasks, limit)
    else
        parallel.waitForAll(table.unpack(tasks))
    end
end

return run
