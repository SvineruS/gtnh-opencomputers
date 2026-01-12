local config = {
    targetCrop = 'Quantaria',
    needGrowth = 22,
    needGain = 31,
    needResistance = 10,

    width = 4,
    height = 4,

    cropsSlotsBegin = 1,
    cropsSlotsPremiumEnd = 4,
    cropsSlotsEnd = 14,
    stickSlotsBegin = 16,
    stickSlotsEnd = 16,

}
config.farmSize = config.width * config.height - 1

return config
