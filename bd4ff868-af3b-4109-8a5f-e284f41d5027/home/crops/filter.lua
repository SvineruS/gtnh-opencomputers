local scanner = require('scanner')
local component = require('component')
local sides = require('sides')
local config = require('config')
local serialization = require('serialization')
local io = require('io')

local geolyzer = component.geolyzer
local inv = component.inventory_controller
local utils = require('utils')


local function dumpInventory()
    -- mapping cropName => array of top 10 scores
    local topSeeds = {}


    --local item2 = inv.getStackInSlot(sides.bottom, 1286)
    --print(serialization.serialize(item2))


    for j=1, 10 do

        local invSize = inv.getInventorySize(sides.bottom)
        local i = invSize

        while i > 0 do
            local item = inv.getStackInSlot(sides.bottom, i)
            if item ~= nil and item.crop ~= nil and item.name == 'IC2:itemCropSeed' then
                local cropName = item.crop.name
                local cropScore = scanner.calcCropScore(item.crop.growth, item.crop.gain, item.crop.resistance)

                if topSeeds[cropName] == nil then
                    topSeeds[cropName] = {-9999, -9999, -9999, -9999, -9999, -9999, -9999, -9999, -9999, -9999}
                end

                local higherThan = utils.findLessThan(topSeeds[cropName], cropScore)
                if higherThan == 0 then
                    -- alreadu have this seed, do nothing
                    print("keep " .. cropName .. " " .. cropScore)
                elseif higherThan == -1 then
                    -- all saved seeds are better than this one
                    print("drop " .. cropName .. " " .. cropScore .. " coz all better")
                    inv.suckFromSlot(sides.bottom, i)
                    inv.dropIntoSlot(sides.top, inv.getInventorySize(sides.top))
                else
                    -- there is a seed that is worse than this one
                    print(cropName .. " now top  " .. cropScore .. " coz > " .. topSeeds[cropName][higherThan])
                    topSeeds[cropName][higherThan] = cropScore
                end

            end
            i = i - 1
            print(i)
        end

        print("Done, waiting for input")
        io.read()

    end

    local count = 0
    for _ in pairs(topSeeds) do
        count = count + 1
    end
    print("Total seed types: " .. count)

    print("Waste size: " .. inv.getInventorySize(sides.top))

end

dumpInventory()
