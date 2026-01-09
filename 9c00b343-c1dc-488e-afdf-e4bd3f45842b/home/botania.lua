local robot = require("robot")
local component = require("component")
local sides = require("sides")
local serialization = require("serialization")
local os = require("os")

local inv = component.inventory_controller


local OUTPUT_SIDE = sides.up
local SLOT_BONES_SHEARS = 1

function main()

    while true do

        isOk, err = pcall(checkSlots)
        if not isOk then
            print("Error in checkSlots: " .. err)
            break
        end

        local petalSlot = findPetals()
        if petalSlot == nil then
            print("Out of petals, stopping")
            break
        end


        robot.select(petalSlot)
        assert(robot.place(), "Failed to place petal")

        robot.use() -- bonemeal
        robot.select(SLOT_BONES_SHEARS)
        inv.equip()  -- swap for shears

        robot.swing()

        os.sleep(0)
    end

    robot.select(SLOT_BONES_SHEARS)
    inv.equip()  -- swap for shears

    dropLoot()

end


function findPetals()
    for slot = 1, 16 do
        local stack = inv.getStackInInternalSlot(slot)
        if stack ~= nil and stack.name == "Botania:petal" then
            return slot
        end
    end
    return nil
end

-- check slots, also swap main hand from shears to bone meal
function checkSlots()
    local s = inv.getStackInInternalSlot(SLOT_BONES_SHEARS)
    assert(s ~= nil and s.name == "minecraft:dye" and s.damage == 15, "Missing bone meal")

    robot.select(SLOT_BONES_SHEARS)
    inv.equip() -- swap; bone meal goes to hand

    local s = inv.getStackInInternalSlot(SLOT_BONES_SHEARS)
    assert(s ~= nil and s.name == "minecraft:shears", "Missing shears")
end


function dropLoot()
    print("Dropping loot")
    for slot = 1, 16 do
        local stack = inv.getStackInInternalSlot(slot)
        if stack ~= nil and (stack.name == "Botania:doubleFlower1" or stack.name == "Botania:doubleFlower2") then
            robot.select(slot)
            dropSlot()
        end
    end
end


local invSize = inv.getInventorySize(OUTPUT_SIDE)

function dropSlot()
    for i = 1, invSize do
        local success = inv.dropIntoSlot(OUTPUT_SIDE, i)
        if success then
            return
        end
    end
    error("No space in output inventory")
end


main()
