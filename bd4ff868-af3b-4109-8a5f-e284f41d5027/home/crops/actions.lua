local component = require('component')
local robot = require('robot')
local sides = require('sides')
local computer = require('computer')
local os = require('os')


local gps = require('gps')
local config = require('config')
local scanner = require('scanner')
local database = require('database')
local utils = require('utils')

local inventory_controller = component.inventory_controller




local function dumpInventory()
    print("Dumping Inventory")
    local topSeed = {-9999, -9999, -9999, -9999}
    local minI = 1

    for i=1, robot.inventorySize() do
        local item = scanner.scanInv(i)

        if item ~= nil then
            robot.select(i)

            if item.isCropStick then
                if not (config.stickSlotsBegin <= i  and i <= config.stickSlotsEnd) then
                    inventory_controller.dropIntoSlot(sides.down, 1)
                end
            elseif item.isTarget then
                if item.score > topSeed[minI] then
                    robot.transferTo(minI)
                    topSeed[minI] = item.score
                    minI = utils.findMin(topSeed)
                end
                if not (config.cropsSlotsBegin <= i and i <= config.cropsSlotsPremiumEnd) then
                    utils.dropShit()
                end
            else
                utils.dropShit()
            end
        end

    end

end


local function restockStick()
    print("Restocking Stick")
    local selectedSlot = robot.select()

    for i=config.stickSlotsBegin, config.stickSlotsEnd do
        local item = inventory_controller.getStackInInternalSlot(i)
        local needSuck = 64

        if item ~= nil and item.name == 'IC2:blockCrop' then
            needSuck = 64 - item.size
        end

        if needSuck > 0 then
            robot.select(i)
            inventory_controller.suckFromSlot(sides.down, 2, needSuck)
        end
    end

    robot.select(selectedSlot)
end



local function goToBase()
    gps.go({-1, 0})
    dumpInventory()
    restockStick()
    utils.charge()
end



local function placeCropStick(count)
    print("Placing Crop Stick")
    local stickSlot = utils.findSticks()
    if stickSlot == false then
        print("NO STICKS!!!!!")
        return
    end

    local selectedSlot = robot.select()
    robot.select(stickSlot)
    inventory_controller.equip()

    robot.useDown()
    if count == 2 then
        robot.useDown()
    end

    inventory_controller.equip()
    robot.select(selectedSlot)
end








local function harvest(isGrown)
    print("Harvesting / Deweeding")
    if isGrown == true then
        robot.swingDown()  -- left click
    else
        robot.useDown()  -- right click
    end
    robot.suckDown()
end

local function plantSeed(invSlot)
    print("Planting Seed")
    local selectedSlot = robot.select()
    robot.select(invSlot)
    inventory_controller.equip()

    robot.useDown()

    inventory_controller.equip()
    robot.select(selectedSlot)
end


local function swap(invSlot, farmSlot, farmCrop)
    gps.go1d(farmSlot)
    if farmCrop.isCrop then
        harvest(farmCrop.isGrown)
        if farmCrop.isGrown then
            placeCropStick()
        end
    end
    plantSeed(invSlot)

    local crop = scanner.scanBlock()
    database.saveField(farmSlot, crop)
end


function compareAndSwap()
    print("Trying to swap crops")

    local lowestCrop, lowestSlot, lowestStat = database.getLowestField()
    local highestCrop, highestSlot, highestStat = database.getHighestInv()

    if lowestCrop ~= nil and highestCrop ~= nil and highestStat > lowestStat then
        print('Swapping ' .. lowestStat .. ' -> ' .. highestStat)
        swap(highestSlot, lowestSlot, lowestCrop)
        return true
    else
       print("No candidates for swap :(")
    end
end

function compareAndSwapUntilFail()
    local success = true
    while success do
        success = compareAndSwap()
    end
end




local function ensureHasSpace()
    if utils.isHasFreeSpace(1) then return end

    print("Inventory is full, trying to plant something")
    compareAndSwapUntilFail()

    if utils.isHasFreeSpace(1) then return end
    print("Inventory is full, going to base")
    goToBase()

end






function plantHighestSeed()
    print('Planting highest seed')
    local highestCrop, highestSlot, highestStat = database.getHighestInv()
    if highestCrop == nil then
        print('No crops found')
        return false
    end

    plantSeed(highestSlot)
    crop = scanner.scanBlock()
    database.saveField(gps.getPos1d(), crop)

    return true
end


























return {
    placeCropStick = placeCropStick,
    plantSeed = plantSeed,
    harvest = harvest,
    ensureHasSpace = ensureHasSpace,
    plantHighestSeed = plantHighestSeed,
    compareAndSwapUntilFail = compareAndSwapUntilFail,
    goToBase = goToBase,
}
