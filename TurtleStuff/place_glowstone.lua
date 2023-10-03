local function find(str)
    local found = {}
    for i = 1, 16 do
        local item = turtle.getItemDetail(i)
        if item and item.name:find(str) then
            table.insert(found, i)
        end
    end
    return table.unpack(found)
end

local function refuel()
    if turtle.getFuelLevel() > turtle.getFuelLimit() / 2 then
        return true
    end
    for i = 1, 16 do
        local item = turtle.getItemDetail(i)
        turtle.select(i)
        if turtle.refuel() and turtle.getFuelLevel() > turtle.getFuelLimit() / 2 then
            return true
        end
    end
    return refuel()
end

for i = 1, 32 do
    for ii = 1, 32 do
        local o = 1
        while not turtle.detectDown() do
            turtle.down()
            o = o + 1
        end
        local bool, data = turtle.inspectDown()
        if not data.name:find("glowstone") then
            for iii = 1, 5 do
                turtle.up()
                o = o - 1
            end
            local glowstone = find("glowstone")
            if glowstone then
                if turtle.detectDown() then
                    turtle.digDown()
                end
                turtle.select(glowstone)
                turtle.placeDown()
            end
        end
        if o > 0 then
            for iii = 1, o - 1 do
                turtle.up()
            end
        else
            for iii = 1, o + 1, -1 do
                turtle.down()
            end
        end
        for iii = 1, 4 do
            while turtle.dig() do
            end
            if not turtle.forward() then
                if not refuel() then
                    turtle.forward()
                end
            end
        end
    end
    if i % 2 == 0 then
        turtle.turnLeft()
    else
        turtle.turnRight()
    end
    for ii = 1, 4 do
        while turtle.dig() do
        end
        if not turtle.forward() then
            if not refuel() then
                turtle.forward()
            end
        end
    end
    if i % 2 == 0 then
        turtle.turnLeft()
    else
        turtle.turnRight()
    end
end
