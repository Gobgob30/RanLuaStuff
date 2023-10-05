function turtle:find(str)
    local output = {}
    for i = 1, 16 do
        local item = self.getItemDetail(i)
        if item and item.name:find(str) then
            table.insert(output, i)
        end
    end
    return table.unpack(output)
end

local fuel_items = settings.get("fuel_items", {})
local function refuel(has_no_fuel)
    has_no_fuel = has_no_fuel or false
    if turtle.getFuelLevel() > turtle.getFuelLimit() / 2 then
        return true
    end
    for i = 1, 16 do
        local item = turtle.getItemDetail(i)
        if item then
            turtle.select(i)
            if turtle.refuel() and turtle.getFuelLevel() > turtle.getFuelLimit() / 2 then
                fuel_items[item.name] = true
                settings.set("fuel_items", fuel_items)
                settings.save()
                return not has_no_fuel
            end
        end
    end
    return refuel(true)
end

local black_list = {
    ["turtle"] = true,
    ["advanced_alchemical_chest"] = true,
    ["stable_wormhole"] = true,
    ["fuel"] = true,
    ["coal"] = true,
    ["blaze_cake"] = true,
    ["disk_drive"] = true,
}
local function check_inventory()
    local amount = 0
    for i = 1, 16 do
        local item = turtle.getItemDetail(i)
        if item then
            amount = amount + 1
        end
    end
    if amount >= 14 then
        for i = 1, 16 do
            local item = turtle.getItemDetail(i)
            if item then
                local drop = true
                for k, v in pairs(black_list) do
                    if item.name:find(k) then
                        drop = false
                    end
                end
                if drop then
                    turtle.select(i)
                    turtle.dropDown()
                end
            end
        end
    end
end

for i = 1, 8 do
    for y = 1, 8 do
        local turtle_slot, other_turtle_slot = turtle:find("turtle")
        if turtle_slot then
            turtle.select(other_turtle_slot or turtle_slot)
            if turtle.detectUp() then
                while turtle.digUp() do
                end
            end
            if turtle.placeUp() then
                sleep(1)
                peripheral.call("top", "turnOn")
                turtle.digUp()
                turtle_slot, other_turtle_slot = turtle:find("turtle")
                if other_turtle_slot then
                    turtle.select(other_turtle_slot)
                end

                local drive = turtle:find("disk_drive")
                if drive then
                    turtle.select(drive)
                    if turtle.placeUp() then
                        turtle.select(other_turtle_slot or turtle_slot)
                        turtle.dropUp(1)
                        peripheral.wrap("top")
                        local data = fs.open("quarry_right.lua", "r")
                        local code = data.readAll()
                        data.close()
                        data = fs.open(fs.combine(peripheral.call("top", "getMountPath"), "startup.lua"), "w")
                        data.write(code)
                        data.close()
                        fs.delete(fs.combine(peripheral.call("top", "getMountPath"), ".settings"))
                        turtle.digUp()
                        turtle.placeUp()
                        local output = turtle:find("advanced_alchemical_chest") or turtle:find("stable_wormhole")
                        if output then
                            turtle.select(output)
                            turtle.dropUp(1)
                        end
                        local fuel = turtle:find("fuel") or turtle:find("coal") or turtle:find("blaze_cake")
                        if fuel then
                            turtle.select(fuel)
                            turtle.dropUp(16)
                        end
                        peripheral.call("top", "turnOn")
                    end
                end
            end
        end
        turtle.turnRight()
        for ii = 1, 16 do
            check_inventory()
            while turtle.dig() do
                turtle.digDown()
            end
            if not turtle.forward() then
                if not refuel() then
                    turtle.forward()
                end
            end
        end
        turtle.turnLeft()
    end
    turtle.turnRight()
    turtle.turnRight()
    for y = 1, 16 do
        check_inventory()
        while turtle.dig() do
            turtle.digDown()
        end
        if not turtle.forward() then
            if not refuel() then
                turtle.forward()
            end
        end
    end
    turtle.turnRight()
    for y = 1, 16 * 8 do
        check_inventory()
        while turtle.dig() do
            turtle.digDown()
        end
        if not turtle.forward() then
            if not refuel() then
                turtle.forward()
            end
        end
    end
    turtle.turnRight()
end
