local component = require('component')
local robot = require('robot')
local sides = require('sides')
local computer = require('computer')
local os = require('os')


local gps = require('gps')
local config = require('config')
local scanner = require('scanner')
local database = require('database')

local inventory_controller = component.inventory_controller


local function findMin(array)
    local minI = 1
    for i = 2, #array do
        if array[i] < array[minI] then
            minI = i
        end
    end
    return minI
end

local function findLessThan(array, value)
    for i = 1, #array do
        if array[i] == value then
            return 0
        end
        if array[i] < value then
            return i
        end
    end
    return -1
end


local function charge()
    print("Charging")
    repeat
        os.sleep(0.1)
    until (computer.energy() / computer.maxEnergy() > 0.9)
end



local function isHasFreeSpace(minEmptySlots)
    local freeSpace = 0
    for i=config.cropsSlotsBegin, config.cropsSlotsEnd do
        if robot.count(i) == 0 then
            freeSpace = freeSpace + 1
            if freeSpace >= minEmptySlots then
                return true
            end
        end
    end
    return false
end

local function findSticks()
    for i=config.stickSlotsBegin, config.stickSlotsEnd do
        local item = inventory_controller.getStackInInternalSlot(i)
        if item ~= nil and item.name == 'IC2:blockCrop' then
            return i
        end
    end
    return false
end




local function dropShit()
    if robot.count() == 0 then
        return true
    end

    local invSize = inventory_controller.getInventorySize(sides.top)

    for j=1, 2 do
        for i=1, invSize do
            local success = inventory_controller.dropIntoSlot(sides.top, i)
            if success then
                return true
            end
        end
    end

    print("No space for shit")
    return false

end



return {
    charge = charge,
    isHasFreeSpace = isHasFreeSpace,
    findSticks = findSticks,
    findMin = findMin,
    findLessThan = findLessThan,
    dropShit = dropShit,
}
