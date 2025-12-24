local component = require("component")


local const = {
    strongPrincessCount = 3, -- >=
    strongCount = 10,
    strongCountRoof = 15,
    trashInterface = component.proxy("3292e570-c9b4-47b2-a943-33c79d7af1e4"),
    analyzerInterface = component.proxy("dd4b88b9-1baa-42c7-835a-02168c1b209e"),
    analyzerChestSide = "NORTH", -- relative to analyzerInterface
    exportSide = "WEST", -- side to export for test purposes
    houseSide = "SOUTH", -- side of apiary (relative to interface)
    trashSide = "WEST", -- side of chest (relative to intTrash (trashing interface)) to drop notNatural princesses
}

local int = {
    [1] = component.proxy("ce354e25-a660-409a-bb73-eacab2d0ba88"),
}

local apiary = {
    [1] = component.proxy("70b9944d-837c-462f-a438-965ec9a5ede9"),
}
