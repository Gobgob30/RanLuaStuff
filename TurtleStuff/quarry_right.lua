local fuel_items = settings.get("fuel_items", {})
local function refuel(has_no_fuel)
    has_no_fuel = has_no_fuel or false
    if turtle.getFuelLevel() > turtle.getFuelLimit() / 2 then
        return true
    end
    for i = 1, 16 do
        local item = turtle.getItemDetail(i)
        turtle.select(i)
        if turtle.refuel() and turtle.getFuelLevel() > turtle.getFuelLimit() / 2 then
            fuel_items[item.name] = true
            settings.set("fuel_items", fuel_items)
            settings.save()
            return not has_no_fuel
        end
    end
    return refuel(true)
end

local function check_inventory(limit)
    limit = limit or 16
    local amount = 0
    for i = 1, 16 do
        if turtle.getItemCount(i) > 0 then
            amount = amount + 1
        end
    end
    return amount >= limit
end

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

local STATE = settings.get("state", 1)
settings.set("state", STATE)
settings.save()
local break_k, move_k, y
local STATETABLE = {
    function()
        if check_inventory(14) then
            STATE = 4
            settings.set("state", STATE)
            settings.save()
            return
        end
        break_k = settings.get("break_k", 1)
        move_k = settings.get("move_k", 1)
        if move_k % break_k == 0 then
            turtle.turnRight()
        end
        if move_k >= 4 * break_k then
            move_k = 1
            settings.set("move_k", move_k)
            break_k = break_k + 1
            settings.set("break_k", break_k)
            if break_k == 16 then
                STATE = 5
                settings.set("state", STATE)
                settings.save()
                return
            end
        end
        while turtle.dig() do
        end
        if not turtle.forward() then
            if not refuel() then
                turtle.forward()
            end
        end
        STATE = 2
        settings.set("state", STATE)
        settings.save()
    end,
    function()
        y = settings.get("y", 1)
        while turtle.digDown() do
        end
        if not turtle.down() then
            if refuel() then
                STATE = 3
                settings.set("state", STATE)
                settings.save()
                return
            elseif not turtle.down() then
                STATE = 3
                settings.set("state", STATE)
                settings.save()
                return
            end
        end
        y = y + 1
        settings.set("y", y)
        settings.save()
    end,
    function()
        move_k = settings.get("move_k", 1)
        y = settings.get("y", 1)
        if y <= 1 then
            settings.unset("y")
            move_k = move_k + 1
            settings.set("move_k", move_k)
            STATE = 1
            settings.set("state", STATE)
            settings.save()
            return
        end
        while turtle.digUp() do
        end
        if not turtle.up() then
            if refuel() then
                STATE = 1
                settings.set("state", STATE)
                settings.save()
                return
            elseif not turtle.up() then
                STATE = 1
                settings.set("state", STATE)
                settings.save()
            end
        end
        y = y - 1
        settings.set("y", y)
        settings.save()
    end,
    function()
        local slot = find("advanced_alchemical_chest")
        if slot then
            turtle.select(slot)
            turtle.placeDown()
            for i = 1, 16 do
                local item = turtle.getItemDetail(i)
                if item and not fuel_items[item.name] then
                    turtle.select(i)
                    turtle.dropDown()
                end
            end
            turtle.select(slot)
            turtle.digDown()
            STATE = 1
            settings.set("state", STATE)
            settings.save()
        else
            turtle.digDown()
        end
    end,
    function()
        -- this is a stall function
        sleep(1)
    end
}

sleep(1)
while true do
    STATETABLE[STATE]()
end
