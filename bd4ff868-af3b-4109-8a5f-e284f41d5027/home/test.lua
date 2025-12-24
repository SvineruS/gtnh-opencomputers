local robot_api = require("robot")
local component = require("component")
local sides = require("sides")
local serialization = require("serialization")






local inv = component.inventory_controller
local anal = component.geolyzer

local analysis = anal.analyze(sides.front)
print("Analysis: ", serialization.serialize(analysis))


--local item = inv.getStackInInternalSlot(1)
--print(item.label)
--
--function labelContains(item, ...)
--    local args = {...}
--    for i = 1, #args do
--        if string.match(item.label, args[i]) then
--            return true
--        end
--    end
--    return false
--end
--
--local name = "Rare Earth %(II%)"
--print(labelContains(item, name))
