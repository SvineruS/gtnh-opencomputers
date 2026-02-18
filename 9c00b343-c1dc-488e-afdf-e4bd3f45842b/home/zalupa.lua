local robot_api = require("robot")
local component = require("component")
local sides = require("sides")
local serialization = require("serialization")


local inv = component.inventory_controller
print(inv.getInventorySize(sides.front))

print(serialization.serialize(inv.getStackInSlot(sides.front, 1)))
print(serialization.serialize(inv.getStackInSlot(sides.front, 2)))
