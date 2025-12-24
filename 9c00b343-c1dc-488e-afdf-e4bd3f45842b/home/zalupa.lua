local robot_api = require("robot")
local component = require("component")
local sides = require("sides")
local serialization = require("serialization")


local slot = 1
local item = component.inventory_controller.getStackInSlot(sides.bottom, 1)

if ~item then
    print(serialization.serialize(item))
	print("Item name: ", item.name)
	print("Item count: ", item.size)
	print("Item damage: ", item.damage)
else
	print("Slot " .. slot .. " is empty")
end
