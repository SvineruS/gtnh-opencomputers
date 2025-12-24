local component = require('component')
local sides = require('sides')
local config = require('config')

local geolyzer = component.geolyzer
local inv = component.inventory_controller

local function calcCropScore(gr, ga, re)
    local dGr = gr - config.needGrowth
    local dGa = ga - config.needGain
    local dRe = re - config.needResistance

    return 5000 - (dGr * dGr + dGa * dGa + dRe * dRe)
end

local function constructCrop(name, gr, ga, re, isGrown)
    local isTarget = name == config.targetCrop
    return {
        isCrop = true,
        isTarget = isTarget,
        name = name,
        score = isTarget and calcCropScore(gr, ga, re) or 0,
    }
end

local function scanBlock()
    local rawResult = geolyzer.analyze(sides.down)

    -- AIR
    if rawResult.name == 'minecraft:air' then
        return { isEmpty = true }
    end

    -- RANDOM BLOCK
    if rawResult.name ~= 'IC2:blockCrop' then
        return { name = 'block' }
    end

    local cropName = rawResult['crop:name']

    -- EMPTY CROP STICK
    if cropName == nil then
        return { isCropStick = true }
    end

    -- WEED
    if cropName == 'weed' or cropName == 'Grass' or cropName == 'venomilia' then
        return { isWeed = true }
    end


    -- FILLED CROP STICK
    local crop = constructCrop(cropName, rawResult['crop:growth'], rawResult['crop:gain'], rawResult['crop:resistance'])
    crop.isGrown = rawResult['crop:size'] == rawResult['crop:maxSize']
    return crop

end

local function scanInv(slot)
    local rawResult = inv.getStackInInternalSlot(slot)
    if rawResult == nil then
        return nil
    end

    if rawResult.name == 'IC2:blockCrop' then
        return { isCropStick = true }
    end

    if rawResult.name == 'IC2:itemCropSeed' then
        return constructCrop(rawResult.crop.name, rawResult.crop.growth, rawResult.crop.gain, rawResult.crop.resistance)
    end

    return { name = rawResult.name }

end

return {
    scanBlock = scanBlock,
    scanInv = scanInv,
    calcCropScore = calcCropScore
}
