-- A tool to use while shopping
local shopping_lists = {}
local shopping_list_mt
shopping_list_mt = {
    __index = {
        create = function(list_self, tax_rate)
            tax_rate = tax_rate or (8.52 / 100)
            tax_rate = tax_rate <= 1 and tax_rate or tax_rate / 100
            local list = {}
            table.insert(list_self, list)
            return setmetatable(list, {
                __index = {
                    add_item = function(self, item, price, quantity)
                        self[item] = {
                            price = price,
                            quantity = quantity or 1
                        }
                    end,
                    get_sub_total = function(self)
                        local total = 0
                        for item, data in pairs(self) do
                            total = total + data.price * data.quantity
                        end
                        return total
                    end,
                    get_total = function(self)
                        return self:get_sub_total() * (1 + tax_rate)
                    end
                }
            })
        end,
        list = function(self)
            return table.unpack(self or shopping_lists)
        end,
        save = function(self)
            local file = fs.open("shopping_lists.json", "w")
            file.write(textutils.serialise(self or shopping_lists))
            file.close()
        end,
        load = function(self)
            local file = fs.open("shopping_lists.json", "r")
            if not file then
                return
            end
            shopping_lists = textutils.unserialise(file.readAll())
            file.close()
            if not shopping_lists then
                shopping_lists = setmetatable({}, shopping_list_mt)
            else
                shopping_lists = setmetatable(shopping_lists, shopping_list_mt)
            end
        end
    }
}
return setmetatable(shopping_lists, shopping_list_mt)
