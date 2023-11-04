-- A tool to use while shopping
local shopping_list_mt = {
    __index = {
        add_item = function(self, item, price, quantity)
            if not item or not price then
                error("Item and price are required")
            end
            self[item] = {
                price = price,
                quantity = quantity or 1
            }
        end,
        get_sub_total = function(self)
            local total = 0
            for item, data in pairs(self) do
                if item ~= "tax_rate" then
                    total = total + data.price * data.quantity
                end
            end
            return total
        end,
        get_total = function(self)
            return self:get_sub_total() * (1 + self.tax_rate)
        end
    }
}
local shopping_lists = {}
local save_shopping_lists = function()
    local file = fs.open("shopping_lists.json", "w")
    file.write(textutils.serialise(shopping_lists))
    file.close()
end
local shopping_lists_mt
shopping_lists_mt = {
    __index = {
        create = function(tax_rate)
            tax_rate = tax_rate or (8.52 / 100)
            local list = { tax_rate = tax_rate <= 1 and tax_rate or tax_rate / 100 }
            table.insert(shopping_lists, list)
            return setmetatable(list, shopping_list_mt)
        end,
        list = function()
            return shopping_lists
        end,
        save = save_shopping_lists,
        load = function()
            local file = fs.open("shopping_lists.json", "r")
            if not file then
                return
            end
            shopping_lists = textutils.unserialise(file.readAll())
            file.close()
            if not shopping_lists then
                shopping_lists = setmetatable({}, shopping_lists_mt)
                save_shopping_lists()
            else
                shopping_lists = setmetatable(shopping_lists, shopping_lists_mt)
                for _, list in ipairs(shopping_lists) do
                    list = setmetatable(list, shopping_list_mt)
                end
            end
        end
    }
}
return setmetatable(shopping_lists, shopping_lists_mt)
