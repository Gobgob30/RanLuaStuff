---@class peripheral_inventory
---@field getItemDetail fun(slot: number | nil): peripheral_inventory_item_detail Retrieves detailed information about a specific item in the inventory.
---@field getItemLimit fun(slot: number | nil): number Retrieves the maximum limit of a specific item that can be stored in the inventory.
---@field size fun(): number Retrieves the size (number of slots) of the inventory.
---@field list fun(): table<number, peripheral_inventory_item_detail_limited> Retrieves a list of items present in the inventory.
---@field pushItems fun(name: string, fromSlot: number, limit: number | nil, toSlot: number | nil): number Pushes items from the inventory to another inventory.
---@field pullItems fun(name: string, fromSlot: number, limit: number | nil, toSlot: number | nil): number Pulls items from another inventory into this inventory.

---@class peripheral_inventory_itemGroup
---@field id string The ID of the item group.
---@field displayName string The display name of the item group.

---@class peripheral_inventory_item_enchantment
---@field level number The level of the enchantment.
---@field id string The ID of the enchantment.
---@field displayName string The display name of the enchantment.

---@class peripheral_inventory_item_detail
---@field displayName string The display name of the item.
---@field name string The id of the item.
---@field itemGroups table<number, peripheral_inventory_itemGroup> The item groups that the item belongs to.
---@field tags table<string, boolean> The tags associated with the item.
---@field count number The current count of the item.
---@field maxCount number The maximum count of the item.
---@field durability number | nil The durability of the item (ranging from 0 to 1 of the max durability), or nil if not applicable.
---@field damage number | nil The health of the item, or nil if not applicable.
---@field maxDamage number | nil The maximum health of the item, or nil if not applicable.
---@field nbt string | nil The NBT data of the item, or nil if not applicable.
---@field enchantments table<number, peripheral_inventory_item_enchantment> | nil The enchantments applied to the item, or nil if not applicable.

---@class peripheral_inventory_item_detail_limited
---@field name string the id of the item
---@field count number the count of the item
---@field nbt string | nil The NBT data of the item, or nil if not applicable.

