local gps = require('gps')
local scanner = require('scanner')
local config = require('config')

local farm = {}

local function saveField(slot, crop)
    farm[slot] = crop
end

local function getLowestField()
    local lowestCrop = nil
    local lowestSlot = nil
    local lowestStat = 10000

    for slot in pairs(farm) do
        local crop = farm[slot]
        if crop.isCropStick then
            return crop, slot, 0
        end
        if crop.isCrop and (not crop.isTarget or crop.score < lowestStat) then
            lowestCrop = crop
            lowestSlot = slot
            lowestStat = crop.score
        end
    end

    return lowestCrop, lowestSlot, lowestStat

end

local function getHighestInv(startFrom)
    local highestCrop = nil
    local highestSlot = nil
    local highestStat = -10000

    if startFrom == nil then
        startFrom = config.cropsSlotsBegin
    end

    for slot = startFrom, config.cropsSlotsEnd do

        local crop = scanner.scanInv(slot)
        if crop ~= nil and crop.isTarget and crop.score > highestStat then
            highestCrop = crop
            highestSlot = slot
            highestStat = crop.score
        end

    end

    return highestCrop, highestSlot, highestStat
end

return {
    saveField = saveField,
    getHighestInv = getHighestInv,
    getLowestField = getLowestField,
}
