local robot_api = require("robot")
local component = require("component")
local sides = require("sides")
local serialization = require("serialization")






local inv = component.inventory_controller
local anal = component.geolyzer


local CHEST_SIDE = sides.top
local REDSTONE_SIDE = sides.back
local ALTAR_SIDE = sides.front

local ITEMS = {
    {from = "Empty Cell", to = "Life Cell"},
    {from = "Arcane Slate", to = "Blank Slate"},
    {from = "Blank Slate", to = "Reinforced Slate"},
    {from = "Reinforced Slate", to = "Imbued Slate"},
    {from = "Thaumium Block", to = "Blood-Soaked Thaumium Block"},
    {from = "Smooth Sandstone", to = "Blood Stained Block"},

}


function main()
    while true do
        iter()
        os.sleep(0.5)
    end
end

function iter()
    --local blood_amount = get_blood_amount()
    --print("Blood amount: ", blood_amount)
    --
    --if blood_amount < 5 then
    --    print("Not enough blood in the altar!")
    --    return
    --end

    local item = get_item_in_altar()
    if item ~= nil then
        print("Item in altar: ", item.name)
        return
    end

    local itemStrategy = getFromChest()
    if itemStrategy ~= nil then
        print("Got item strategy: ", itemStrategy)

        -- place item in altar
        local success = inv.dropIntoSlot(ALTAR_SIDE, 1, itemStrategy.count)
        assert(success, "Failed to drop item into altar")

        while true do
            os.sleep(0.5)
            local item = get_item_in_altar()
            if item == nil then
                print("No item in altar, waiting...")
            elseif item.label == itemStrategy then
                print("Item transformed successfully to: ", item.name)
                inv.suckFromSlot(ALTAR_SIDE, 1, item.size)
                assert(putToChest(), "Failed to put item back to chest")
                break
            else
                print(item.label .. " != " .. itemStrategy .. ", waiting...")
            end
        end

    else
        print("No suitable item found in chest")
        return
    end





end



-- from 0 to 13
function get_blood_amount()
    -- analyze redstone signal from back side
    local analysis = anal.analyze(REDSTONE_SIDE)
    assert(analysis.name == "minecraft:redstone_wire", "No redstone wire detected on the back side.")
    return analysis.metadata
end


function get_item_in_altar()
    local item = inv.getStackInSlot(ALTAR_SIDE, 1)
    print(serialization.serialize(item))
    return item
end



function getFromChest()
    local side = CHEST_SIDE
    local invSize = inv.getInventorySize(side)
    assert(invSize ~= nil, "No inventory detected on side " .. side)
    print("Inventory size: ", invSize)

    for i = 1, invSize do

        local item = inv.getStackInSlot(side, i)
        print("Checking slot ", i, ": ", serialization.serialize(item))
        local itemStrategy = getItemStrategy(item)

        if (itemStrategy ~= nil) then
            local res = inv.suckFromSlot(side, i, 1)
            assert(res, "Failed to suck item from slot " .. i .. " on side " .. side)
            return itemStrategy
        end
    end

    return nil

end

function putToChest()
    local side = sides.top
    local invSize = inv.getInventorySize(side)
    local startFromSlot = 1

    for i = startFromSlot, invSize do
        local result = inv.dropIntoSlot(side, i, 64)
        if (result == true) then
            return i
        end
    end
end




function getItemStrategy (item)
    if item == nil then
        return nil
    end

    for _, v in ipairs(ITEMS) do
        if item.label == v.from then
            return v.to
        end
    end
    return nil
end





main()

--
--local item = inv.getStackInInternalSlot(1)
--print(serialization.serialize(item))
--
--local inv_size = inv.getInventorySize(sides.bottom)
--print("Inventory size: ", inv_size)
--
--
--local analysis = anal.analyze(sides.bottom)
--print("Analysis: ", serialization.serialize(analysis))
--
--local analysis = anal.analyze(sides.back)
--print("Analysis: ", serialization.serialize(analysis))
