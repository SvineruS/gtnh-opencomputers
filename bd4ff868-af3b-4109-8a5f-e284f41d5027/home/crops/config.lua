local config = {
    targetCrop = 'Space Plant',
    needGrowth = 22,
    needGain = 31,
    needResistance = 10,

    width = 6,
    height = 6,

    cropsSlotsBegin = 1,
    cropsSlotsPremiumEnd = 4,
    cropsSlotsEnd = 14,
    stickSlotsBegin = 16,
    stickSlotsEnd = 16,

}
config.farmSize = config.width * config.height - 1

return config
