local robot = require("robot")
local component = require("component")
local sides = require("sides")
local serialization = require("serialization")


local inv = component.inventory_controller
local totalSlots = robot.inventorySize()

local coolantSlots = { 1, 5, 8, 12, 17, 19, 24, 31, 36, 38, 43, 47, 50, 54}


function main()
    local side = sides.bottom
    local invSize = inv.getInventorySize(side)
    assert(invSize ~= nil, "No inventory detected on side " .. side)
    print("Inventory size: ", invSize)

    for i, slot in ipairs(coolantSlots) do
        local item = inv.getStackInSlot(side, slot)
        if item == nil then
            -- put coolant from internal inventory
            putCoolantToSlotWithRetries(slot)
        elseif not string.match(item.label, "Coolant")  then
            print("Removing non-coolant item from slot ", slot, ": ", item.label)
            local res = inv.suckFromSlot(side, slot, item.size)
            assert(res, "Failed to suck item from slot " .. slot .. " on side " .. side)
            putCoolantToSlotWithRetries(slot)
        else
            print(".")
        end


    end

end


function putCoolantToSlotWithRetries(slot)
    while true do
        success = putCoolantToSlot(slot)
        if success then
           return
        else
           print("Give me coolant! Retrying in 1 second...")
           os.sleep(1)
        end
    end
end

function putCoolantToSlot(slot)
    for i = 1, totalSlots do
        item = inv.getStackInInternalSlot(i)
        if item ~= nil and string.match(item.label, "Coolant") then
            robot.select(i)
            local res = inv.dropIntoSlot(sides.bottom, slot, item.size)
            assert(res, "Failed to drop item into slot " .. slot .. " on side " .. sides.bottom)
            return true
        end
    end
    return false
end



main()

--local analysis = anal.analyze(sides.back)
--print("Analysis: ", serialization.serialize(analysis))
