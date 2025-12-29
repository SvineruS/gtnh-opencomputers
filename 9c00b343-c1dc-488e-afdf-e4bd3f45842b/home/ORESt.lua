local robot = require("robot")
local component = require("component")
local sides = require("sides")
local serialization = require("serialization")
local os = require("os")

local inv = component.inventory_controller

POS_CHARGER = 0

POS_PRIORITY_INPUT = 1
POS_BASE = 2

POS_MACERATOR = 6
POS_ORE_WASHER = 10
POS_CENTRIFUGE = 14
POS_CENTRIFUGE_JOPA = 15
POS_THERMAL_CENTRIFUGE = 18
POS_CHEM_BATH_BLUE_SHIT = 22
POS_CHEM_BATH_MERCURY = 26
POS_CHEM_BATH_MERCURY_JOPA = 27
POS_AUTOCLAVE = 30+1
POS_SIFTER = 34+1
POS_ELECTROLYZER = 38


UNKNOWN = -1

currentPos = POS_CHARGER




-- 1 - macerator
-- 2 - ore washer
-- 3 - thermal centrifuge
-- 4x - chemical bath mercury, then 2 or 3 or 6
-- 5x - chemical bath blue shit, then 2 or 3 or 6
-- 6 - sifter
L1_MACERATOR = 1
L2_WASHER_MACERATOR = 2
L3_WASHER_THERMAL = 3
L42_BATH_MERCURY_WASHER = 42
L43_BATH_MERCURY_THERMAL = 43
L46_BATH_MERCURY_SIFTER = 46
L52_BATH_NaSO_WASHER = 52
L53_BATH_NaSO_THERMAL = 53
L56_BATH_NaSO_SIFTER = 56
L6_SIFTER = 6







local currentSlot = 1
totalSlots = robot.inventorySize()
robot.select(currentSlot)


function main()
    cantMove = robot.detect()
    if cantMove then
        robot.turnRight()
        robot.turnRight()
    end

    while true do

        moveAndTransfer(POS_PRIORITY_INPUT, sides.top, nil)
        moveAndTransfer(POS_BASE, sides.top, sides.bottom)
        moveAndTransfer(POS_MACERATOR, sides.bottom, sides.top)
        moveAndTransfer(POS_ORE_WASHER, sides.bottom, sides.top)
        moveAndTransfer(POS_CENTRIFUGE, sides.bottom, sides.top)
        moveAndTransfer(POS_CENTRIFUGE_JOPA, nil, sides.top)
        moveAndTransfer(POS_THERMAL_CENTRIFUGE, sides.bottom, sides.top)
        moveAndTransfer(POS_CHEM_BATH_BLUE_SHIT, sides.bottom, sides.top)
        moveAndTransfer(POS_CHEM_BATH_MERCURY, sides.bottom, sides.top)
        moveAndTransfer(POS_CHEM_BATH_MERCURY_JOPA, nil, sides.top)
        moveAndTransfer(POS_AUTOCLAVE, sides.bottom, sides.top)
        moveAndTransfer(POS_SIFTER, sides.bottom, sides.top)
        moveAndTransfer(POS_ELECTROLYZER, sides.bottom, sides.top)

        moveAndTransfer(POS_SIFTER, sides.bottom, sides.top)
        moveAndTransfer(POS_AUTOCLAVE, sides.bottom, sides.top)
        moveAndTransfer(POS_CHEM_BATH_MERCURY_JOPA, nil, sides.top)
        moveAndTransfer(POS_CHEM_BATH_MERCURY, sides.bottom, sides.top)
        moveAndTransfer(POS_CHEM_BATH_BLUE_SHIT, sides.bottom, sides.top)
        moveAndTransfer(POS_THERMAL_CENTRIFUGE, sides.bottom, sides.top)
        moveAndTransfer(POS_CENTRIFUGE_JOPA, nil, sides.top)
        moveAndTransfer(POS_CENTRIFUGE, sides.bottom, sides.top)
        moveAndTransfer(POS_ORE_WASHER, sides.bottom, sides.top)
        moveAndTransfer(POS_MACERATOR, sides.bottom, sides.top)
        moveAndTransfer(POS_BASE, nil, sides.bottom)

        moveTo(POS_CHARGER)
        os.sleep(10)

    end
end



-- only crushed / purified ores
local customPaths = {
    {name = "Monazite", path = L1_MACERATOR},  -- thorium, neodymium, rare earth
    {name = "Tetrahedrite", path = L1_MACERATOR},  -- zinc, antimony, antimony
    {name = "Grossular", path = L1_MACERATOR},  -- yellow garnet, calcium, calcium
    {name = "Bastnasite", path = L1_MACERATOR},  -- neodymium, rare earth, rare earth
    {name = "Lepidolite", path = L1_MACERATOR},  -- lithium, caesium, caesium
    {name = "Pentlandite", path = L1_MACERATOR}, -- iron, sulfur, cobalt
    {name = "Neodymium", path = L1_MACERATOR}, -- monazite, rare earth, rare earth
    {name = "Emerald", path = L1_MACERATOR}, -- beryllium, alumina, alumina
    {name = "Lead", path = L1_MACERATOR},
    {name = "Ruby", path = L1_MACERATOR},
    {name = "Antimony", path = L1_MACERATOR},
    {name = "Silver", path = L1_MACERATOR},
    {name = "Lithium", path = L1_MACERATOR},
    {name = "Sodalite", path = L1_MACERATOR},
    {name = "Rare Earth %(I%)", path = L1_MACERATOR},
    {name = "Rare Earth %(II%)", path = L1_MACERATOR},


    {name = "Diatomite", path = L2_WASHER_MACERATOR}, -- banded iron, sapphire, sapphire
    {name = "Pyrite", path = L2_WASHER_MACERATOR}, -- sulfur, tricalcium phosphate, iron
    {name = "Nickel", path = L2_WASHER_MACERATOR}, -- cobalt, platinum, iron
    {name = "Salt", path = L2_WASHER_MACERATOR},
    {name = "Rock Salt", path = L2_WASHER_MACERATOR},
    {name = "Magnetite", path = L2_WASHER_MACERATOR},  -- iron, gold, gold
    {name = "Galena", path = L2_WASHER_MACERATOR},  -- sulfur, silver, lead
    {name = "Powellite", path = L2_WASHER_MACERATOR}, -- powellite (all)
    {name = "Molybdenite", path = L2_WASHER_MACERATOR}, -- molybdenum (all)
    {name = "Molybdenum", path = L2_WASHER_MACERATOR}, -- molybdenum (all)
    {name = "Wulfenite", path = L2_WASHER_MACERATOR}, -- wulfenite (all)
    {name = "Beryllium", path = L2_WASHER_MACERATOR}, -- emerald (all)
    {name = "Magnesite", path = L2_WASHER_MACERATOR},  -- magnesium (all)
    {name = "Aluminium", path = L2_WASHER_MACERATOR},  -- bauxite (all)
    {name = "Barite", path = L2_WASHER_MACERATOR},  -- barite (all)
    {name = "Cobaltite", path = L2_WASHER_MACERATOR},  -- cobalt (all)
    {name = "Graphite", path = L2_WASHER_MACERATOR},  -- carbon (all)
    {name = "Sulfur", path = L2_WASHER_MACERATOR},  -- sulfur (all)
    {name = "Mica", path = L2_WASHER_MACERATOR}, -- mica (all)
    --{name = "Coal", path = L2_WASHER_MACERATOR},  -- lignite coal, thorium, thorium
    {name = "Spessartine", path = L2_WASHER_MACERATOR},  -- red garnet, manganese
    {name = "Ilmenite", path = L2_WASHER_MACERATOR},  -- iron, rutile
    {name = "Uvarovite", path = L2_WASHER_MACERATOR},  -- yellow garnet, chrome, chrome
    {name = "Chromite", path = L2_WASHER_MACERATOR},  -- iron, chrome, chrome
    {name = "Spodumene", path = L2_WASHER_MACERATOR},  -- alumina, lithium, lithium
    {name = "Vanadium Magnetite", path = L2_WASHER_MACERATOR},  -- magnetite, vanadium, vanadium. MUST BE BEFORE MAGNETITE
    {name = "Arsenic", path = L2_WASHER_MACERATOR},
    {name = "Desh", path = L2_WASHER_MACERATOR},
    {name = "Basaltic Mineral Sand", path = L2_WASHER_MACERATOR},
    {name = "Yellow Limonite", path = L2_WASHER_MACERATOR},
    {name = "Brown Limonite", path = L2_WASHER_MACERATOR},
    {name = "Asbestos", path = L2_WASHER_MACERATOR},
    {name = "Roasted Nickel", path = L2_WASHER_MACERATOR},
    {name = "Electrotine", path = L2_WASHER_MACERATOR},
    {name = "Cassiterite Sand", path = L2_WASHER_MACERATOR},
    {name = "Cryolite", path = L2_WASHER_MACERATOR},
    {name = "Lazurite", path = L2_WASHER_MACERATOR},
    {name = "Bismuth", path = L2_WASHER_MACERATOR},
    {name = "Vyroxeres", path = L2_WASHER_MACERATOR},
    {name = "Wulfenite", path = L2_WASHER_MACERATOR},
    {name = "Oriharukon", path = L2_WASHER_MACERATOR},
    {name = "Tanzanite", path = L2_WASHER_MACERATOR},
    {name = "Mirabilite", path = L2_WASHER_MACERATOR},
    {name = "Uranium 238", path = L2_WASHER_MACERATOR},
    {name = "Copper", path = L2_WASHER_MACERATOR},  -- mercury bath, 70% gold + 11% gold
    {name = "Roasted Iron", path = L2_WASHER_MACERATOR},
    {name = "Perlite", path = L2_WASHER_MACERATOR},
    {name = "Garnet Sand", path = L2_WASHER_MACERATOR},
    {name = "Tungstate", path = L2_WASHER_MACERATOR},
    {name = "Naquadah", path = L2_WASHER_MACERATOR},
    {name = "Granitic Mineral Sand", path = L2_WASHER_MACERATOR},
    {name = "Rutile", path = L2_WASHER_MACERATOR},




    {name = "Redstone", path = L3_WASHER_THERMAL},  -- cinnabar, rare earth, glowstone
    {name = "Scheelite", path = L3_WASHER_THERMAL},  -- redstone, sulfur, glowstone
    {name = "Chalcopyrite", path = L3_WASHER_THERMAL},  -- gold + cadmium
    {name = "Pyrolusite", path = L3_WASHER_THERMAL},  -- gold + cadmium
    {name = "Fullers Earth", path = L3_WASHER_THERMAL},  -- gold + cadmium
    {name = "Palladium", path = L3_WASHER_THERMAL},  -- gold + cadmium
    {name = "Platinum", path = L3_WASHER_THERMAL},  -- gold + cadmium
    {name = "Sheldonite", path = L3_WASHER_THERMAL},  -- gold + cadmium



    {name = "Magnetite", path = L42_BATH_MERCURY_WASHER},  -- 70% gold + 11% gold
    {name = "Gold", path = L42_BATH_MERCURY_WASHER},  -- 70% gold + 10% nickel

    {name = "Meteoritic Iron", path = L43_BATH_MERCURY_THERMAL},  -- platinum + iridium


    {name = "Iron", path = L53_BATH_NaSO_THERMAL},  -- blue shit bath + macerator = nickel + tin
    {name = "Tantalite", path = L53_BATH_NaSO_THERMAL},  -- blue shit bath + thermal centrifuge
    {name = "Bauxite", path = L53_BATH_NaSO_THERMAL},  -- rutile + gallium
    {name = "Sphalerite", path = L53_BATH_NaSO_THERMAL},  -- zinc + gallium


    {name = "Thorium", path = L56_BATH_NaSO_SIFTER},  -- thorium, lead, radium 226



    {name = "Quartzite", path = L6_SIFTER},  -- sifter
    {name = "Certus Quartz", path = L6_SIFTER},
    {name = "Nether Quartz", path = L6_SIFTER},
    {name = "Coal", path = L6_SIFTER},  -- dohuya norm coal

    {name = "Amber", path = L6_SIFTER},
    {name = "Uraninite", path = L6_SIFTER},
    {name = "Pitchblende", path = L6_SIFTER},
    {name = "Diamond", path = L6_SIFTER},
    {name = "Lapis", path = L6_SIFTER},
    {name = "Cinnabar", path = L6_SIFTER},



}

local customPos = {

    {name = "Purified Galena Ore", pos = POS_BASE},  -- for indium
    {name = "Purified Sphalerite Ore", pos = POS_BASE}, -- for indium
    {name = "Purified Ilmenite Ore", pos = POS_BASE}, -- for washing in sulfuric acid to get more rutile

    {name = "Platinum Metallic Powder Dust", pos = POS_BASE}, -- platline
    {name = "Palladium Metallic Powder Dust", pos = POS_BASE}, -- platline


    {name = "Redstone", pos = POS_BASE},
    {name = "Glowstone Dust", pos = POS_BASE},
    {name = "Monazite", pos = POS_BASE},
    {name = "Yellow Garnet", pos = POS_BASE},
    {name = "Amber", pos = POS_BASE},
    {name = "Rock Salt", pos = POS_BASE},
    {name = "Salt", pos = POS_BASE},
    {name = "Lignite Coal", pos = POS_BASE},
    {name = "Rare Earth", pos = POS_BASE},
    {name = "Nether Quartz", pos = POS_BASE},
    {name = "Lapis Lazuli", pos = POS_BASE},
    {name = "Emerald", pos = POS_BASE},
    {name = "Pitchblende", pos = POS_BASE},
    {name = "Certus Quartz", pos = POS_BASE},
    {name = "Pure Certus Quartz Crystal", pos = POS_BASE},
    {name = "Quartzite", pos = POS_BASE},
    {name = "Flint", pos = POS_BASE},
    {name = "Cassiterite Sand", pos = POS_BASE},
    {name = "Basaltic Mineral Sand", pos = POS_BASE},
    {name = "Garnet Sand", pos = POS_BASE},

    {name = "Stone Dust", pos = POS_CENTRIFUGE_JOPA},
    --{name = "Cinnabar Dust", pos = POS_CHEM_BATH_MERCURY_JOPA},

    {regex = "Crushed (.*) Crystals", pos = POS_ORE_WASHER},
    {regex = "Purified (.*) Crystals", pos = POS_SIFTER},
    {regex = "(.*) Crystal Powder", pos = POS_BASE},
    {regex = "(.*) Shard", pos = POS_BASE},

    --{name = "Alumina Dust", pos = POS_ELECTROLYZER},  -- oxygen
    {name = "Magnetite Dust", pos = POS_ELECTROLYZER},  -- oxygen
    --{name = "Cassiterite Dust", pos = POS_ELECTROLYZER},  -- oxygen
    {name = "Banded Iron Dust", pos = POS_ELECTROLYZER},  -- oxygen
    {name = "Potassium Feldspar Dust", pos = POS_ELECTROLYZER},   -- oxygen

    {name = "Quartzite Dust", pos = POS_AUTOCLAVE},

    {name = "Impure Pile of Endstone Dust", pos = POS_CENTRIFUGE},
    --{name = "Endstone Dust", pos = POS_CENTRIFUGE},

}


function whereToPutItem(item)
    if item == nil then
        --print("Item is nil")
        return UNKNOWN
    end

    for _, i in ipairs(customPos) do
        if item.label == i.name or labelContains(item, i.regex) then
            return i.pos
        end
    end


    for _, i in ipairs(customPaths) do
        local ok, path = customPath(item, i.name, i.path)
        if ok then
            return path
        end
    end


    if item.name == "gregtech:gt.blockores" or labelContains(item, "Raw (.+) Ore") then  -- ore
        return POS_MACERATOR
    end

    if item.name == "gregtech:gt.metaitem.01" then
        if labelContains(item, "Impure Pile of", "Purified Pile of", "Impure ") then  -- impure pile
            return POS_CENTRIFUGE
        end

        if labelContains(item, "Centrifuged") then  -- centrifuged
            return POS_MACERATOR
        end

        if labelContains(item, "Dust") then  -- dust
            return POS_BASE
        end

    end

    if item.name == "gregtech:gt.metaitem.02" then

        if labelContains(item, "Chipped", "Flawed", "Flawless", "Exquisite") then  -- gem
            return POS_BASE
        end

    end



    print("Unknown item ", item.label)
    return UNKNOWN
end


function customPath(item, name, path)
    if labelContains(item, "Crushed "..name) or labelContains(item, "Ground "..name) then
        if (path == 1) then
            return true, POS_MACERATOR
        end
        if (path == 42 or path == 43) then
            return true, POS_CHEM_BATH_MERCURY
        end
        if (path == 52 or path == 53 or path == 56) then
            return true, POS_CHEM_BATH_BLUE_SHIT
        end
    end

    if labelContains(item, "Purified "..name) then
        if (path == 2 or path == 42 or path == 52) then
            return true, POS_MACERATOR
        end
        if (path == 3 or path == 43 or path == 53) then
            return true, POS_THERMAL_CENTRIFUGE
        end

        if (path == 6 or path == 56 or path == 56) then
            return true, POS_SIFTER
        end
    end

    return false, 0
end




function getFromChest(side)
    if (side == nil) then return false end

    print("get from chest")

    local invSize = inv.getInventorySize(side)
    if (invSize == nil) then
        print("No chest")
        return true
    end
    print("Inventory size: ", invSize)

    didSomething = false

    for i = 1, invSize do

        local item = inv.getStackInSlot(side, i)
        local isKnownItem = whereToPutItem(item) ~= UNKNOWN

        if (isKnownItem) then

            local res = inv.suckFromSlot(side, i, 64)
            if (res == false) then
                print("Probably robot is full")
                break
            else
                didSomething = true
            end
        end
    end

    return didSomething

end


function putAllToChest(side)
    if (side == nil) then return false end

    print("put to chest")

    local invSize = inv.getInventorySize(side)
    print("Inventory size: ", invSize)

    local startFromSlot = 1

    local didSomething = false

    for i = 1, totalSlots do
        robot.select(i)
        item = inv.getStackInInternalSlot(i)
        whereToPut = whereToPutItem(item)
        if (whereToPut == currentPos) then
            startFromSlot = putToChest(side, startFromSlot, invSize)

            if (startFromSlot == invSize or startFromSlot == nil) then
                print("Chest is full")
                break
            else
                didSomething = true
            end
        end
    end

    return didSomething


end



function putToChest(side, startFromSlot, invSize)
    for i = startFromSlot, invSize do
        local result = inv.dropIntoSlot(side, i, 64)
        if (result == true) then
            return i
        end
    end
end


function moveAndTransfer(pos, getFromSide, putToSide)
    moveTo(pos)
    while (true) do
        didPut = putAllToChest(putToSide)
        didGet = getFromChest(getFromSide)
        print("did put / get: ", didPut, didGet)
        if (not didPut or not didGet) then
            return
        end
    end

end


function moveTo(pos)
    print("move to ", pos)

    while (currentPos ~= pos) do

        if pos < currentPos then
            local result, err = robot.back()
            if result == true then
                currentPos = currentPos - 1
            end
        else
            local result, err = robot.forward()
            if result == true then
                currentPos = currentPos + 1
            end
        end
    end

end


function labelContains(item, ...)
    local args = {...}
    for i = 1, #args do
        if string.match(item.label, args[i]) then
            return true
        end
    end
    return false
end

main()
