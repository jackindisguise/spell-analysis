---@meta

---@alias EventItemLoot
--- Fired when the game attempts to autobind bind-on-equip items.
--- | "AUTOEQUIP_BIND_CONFIRM"
---
--- Fired when the player attempts to equip bind on equip loot.
--- | "EQUIP_BIND_CONFIRM"

---@alias EventItemUnit
--- Fired when the player equips or unequips an item. This is also be called if your target, mouseover, or party member changes equipment (untested for hostile targets).
--- This event is also raised when a new item is placed in the player's inventory, taking up a new slot. If the new item(s) are placed onto an existing stack or when two stacks already in the inventory are merged, the event is not raised. When an item is moved inside the inventory or to the bank, the event is not raised. The event *is* raised when an existing stack is split inside the player's inventory.
--- arg1 UnitId The [UnitID](lua://UnitId) affected, ex. "player".
--- | "UNIT_INVENTORY_CHANGED"

---@alias EventItem
--- | EventItemLoot
--- | EventItemUnit
---
--- Fired when a bag is closed
--- arg1 BagId
--- | "BAG_CLOSED"
---
--- Fired when a bag (NOTE: This is NOT fired for player containers, it's for those bag-like objects that you can remove items from but not put items into) is opened.
--- arg1 BagId
--- | "BAG_OPEN"
---
--- Fired when a bags inventory changes
--- arg1 BagId
--- | "BAG_UPDATE"
---
--- Fired when a cooldown update call is sent to a bag
--- arg1 BagId
--- | "BAG_UPDATE_COOLDOWN"
---
--- Fired when Enchanting an unbound item.
--- | "BIND_ENCHANT"
---
--- Fired when the player attempts to destroy an item.
--- arg1 string Item name
--- | "DELETE_ITEM_CONFIRM"
---
--- | "ITEM_LOCK_CHANGED"
---
--- Fired when an item is pushed onto the "inventory-stack". For instance when you manufacture something with your trade skills or picks something up.
--- arg1 number The stack size (i.e. how many copies of this item fit in a single inventory slot)
--- arg2 string The path to the item's icon
--- | "ITEM_PUSH"
---
--- Fired when an items text begins displaying
--- | "ITEM_TEXT_BEGIN"
---
--- Fired when the items text has completed its viewing and is done.
--- | "ITEM_TEXT_CLOSED"
---
--- Fired when the item's text can continue and is ready to be scrolled.
--- | "ITEM_TEXT_READY"
---
--- Fired when an item is in the process of being translated.
--- | "ITEM_TEXT_TRANSLATION"
---
--- Fired when the player must confirm an enchantment replacement.
--- arg1 string Enchantment name
--- arg2 string Item name
--- | "REPLACE_ENCHANT"
---
--- Fires whenever an item's durability status becomes yellow (low) or red (broken). Signals that the durability frame needs to be updated. May also fire on any durability status change, even if that change doesn't require an update to the durability frame.
--- - Wiki also includes this as a Player event, but that doesn't seem relevant.
--- | "UPDATE_INVENTORY_ALERTS"
---
--- | "USE_BIND_CONFIRM"
