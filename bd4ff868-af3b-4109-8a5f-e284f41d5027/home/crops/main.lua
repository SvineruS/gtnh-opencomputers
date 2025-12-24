local component = require('component')
local serialization = require('serialization')
local sides = require('sides')
local os = require('os')

--local reloader = require('reloader')

local scanner = require('scanner')
local actions = require('actions')
local gps = require('gps')
local database = require('database')
local config = require('config')

--local geolyzer = component.geolyzer


function main()

    actions.goToBase()

    while true do
      loop()
    end

end

function loop()
    for i = 0, config.farmSize do
        gps.go1d(i)
        local harvestSomething = processCropBlock()
        if harvestSomething then
            actions.ensureHasSpace()
        end
    end

    actions.compareAndSwapUntilFail()

    actions.goToBase()
end





function processCropBlock()
    local isParent = gps.isParent()
    print('Scanning crop block ' .. (isParent and '(parent)' or '(child)'))

    local crop = scanner.scanBlock()
    print(serialization.serialize(crop))

    if crop.isWeed then
        print("Weed found")
        actions.harvest()
        if isParent then
            actions.plantHighestSeed()
        else
            actions.placeCropStick()
        end
        return true
    end

    if crop.isEmpty then
        print('Empty block found')
        if isParent then
            actions.placeCropStick()
            actions.plantHighestSeed()
        else
            actions.placeCropStick(2)
        end
        return
    end

    if crop.isCropStick then
        if isParent then
            print('Empty crop stick found')
            actions.plantHighestSeed()
            return
        end
    end

    if crop.isCrop then
        if isParent then
            database.saveField(gps.getPos1d(), crop)
        else
            if not crop.isTarget or crop.isGrown then
                actions.harvest(crop.isGrown)
                if crop.isGrown then
                    actions.placeCropStick(2)
                else
                    actions.placeCropStick()
                end
                return true
            end
        end
        return
    end


end





main()
