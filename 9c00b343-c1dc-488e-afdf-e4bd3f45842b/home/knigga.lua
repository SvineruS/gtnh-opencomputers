local robot = require("robot")
local component = require("component")
local sides = require("sides")
local serialization = require("serialization")


local inv = component.inventory_controller



local SLOT_INK = 1
local SLOT_PLATE = 2
local SLOT_BOOK = 3
local SLOT_OUTPUT = 4

local SIDE_PRESS = sides.front
local SIDE_FIXER = sides.up


function main()

    -- if ink empty - stop
    -- if book empty - stop
    -- if plate damage >= 1 - fix it
    -- if output slot full - take it
    -- else wait 10 sec

    while true do
        local ink = inv.getStackInSlot(SIDE_PRESS, SLOT_INK)
        if ink == nil then
            print("Out of ink, stopping")
            break
        end
        print("Ink amount: " .. ink.size)

        local book = inv.getStackInSlot(SIDE_PRESS, SLOT_BOOK)
        if book == nil then
            print("Out of books, stopping")
            break
        end
        print("Books amount: " .. book.size)

        local plate = inv.getStackInSlot(SIDE_PRESS, SLOT_PLATE)
        if plate == nil then
            print("No plate, stopping")
            break
        end
        if plate.damage >= 1 then
            print("Plate damaged (" .. plate.damage .. ") , fixing")
            fixPlate()
        end

        local output = inv.getStackInSlot(SIDE_PRESS, SLOT_OUTPUT)
        if output ~= nil then
            print("Output slot full, enabling hopper")
            outputBook()
        end


        print("Sleeping")
        os.sleep(10)
    end


end


function fixPlate()
    -- take plate
    robot.use(sides.top)

    local slotWithPlate = inv.getStackInInternalSlot(1)
    assert(slotWithPlate ~= nil and slotWithPlate.name == "BiblioCraft:item.EnchantedPlate", "Failed to take plate for fixing")

    -- place plate to fixer
    inv.dropIntoSlot(SIDE_FIXER, 1)
    -- wait for fixer
    os.sleep(2)
    -- take fixed plate
    -- check if fixed
    local fixedPlate = inv.getStackInSlot(SIDE_FIXER, 1)
    if fixedPlate == nil or fixedPlate.damage > 0 then
        error("Failed to fix plate")
    end
    inv.suckFromSlot(SIDE_FIXER, 1)

    local slotWithPlate = inv.getStackInInternalSlot(1)
    assert(slotWithPlate ~= nil and slotWithPlate.name == "BiblioCraft:item.EnchantedPlate", "Failed to take plate for fixing")


    -- place back to slot
    inv.equip()
    robot.use(sides.top)

end

function outputBook()
    robot.useDown(SIDE_LEVER)
    os.sleep(1)
    robot.useDown(SIDE_LEVER)

    local output = inv.getStackInSlot(SIDE_PRESS, SLOT_OUTPUT)
    assert(output == nil, "Failed to take output")
end


main()


--
--
--local size = inv.getInventorySize(sides.front)
--print("Inventory size: ", size)
--
--
--for i = 1, size do
--    local item = inv.getStackInSlot(sides.front, i)
--    if item ~= nil then
--        print(string.format("Slot %d: %s x%d (damage: %d)", i, item.name, item.size, item.damage))
--    else
--        print(string.format("Slot %d: empty", i))
--    end
--end
