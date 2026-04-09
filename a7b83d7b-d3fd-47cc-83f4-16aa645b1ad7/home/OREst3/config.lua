local sides = require("sides")

--ExportBuses MID:
--North = OUTPUT

--ExportBuses BOT:
--North = TARGET_MACERATOR
--East = TARGET_ORE_WASHER
--South = TARGET_CENTRIFUGE
--West = TARGET_SIFTER

--ExportBuses TOP:
--North = TARGET_CHEM_BATH_BLUE_SHIT
--East = TARGET_ELECTROLYZER
--South = TARGET_CHEM_BATH_MERCURY
--West = TARGET_THERMAL_CENTRIFUGE



-- enum Pos


TARGET_MACERATOR = 10 + sides.north
TARGET_ORE_WASHER = 10 + sides.east
TARGET_CENTRIFUGE = 10 + sides.south
TARGET_SIFTER = 10 + sides.west

TARGET_OUTPUT = 20 + sides.north
TARGET_UNKNOWN = 0

TARGET_CHEM_BATH_BLUE_SHIT = 30 + sides.north
TARGET_ELECTROLYZER = 30 + sides.east
TARGET_CHEM_BATH_MERCURY = 30 + sides.south
TARGET_THERMAL_CENTRIFUGE = 30 + sides.west


-- enum Wash
WASH_NONE = 0
WASH_WATER = 1
WASH_MERCURY = 2
WASH_NaSO4 = 3

-- enum Path
PATH_MACERATOR = 1
PATH_THERMAL = 2
PATH_SIFTER = 6  -- only washed ores!!



-- enum Line
L1_MACERATOR = {wash = WASH_NONE, path = PATH_MACERATOR}
L2_WASHER_MACERATOR = {wash = WASH_WATER, path = PATH_MACERATOR}
L3_WASHER_THERMAL = {wash = WASH_WATER, path = PATH_THERMAL}
L6_SIFTER = {wash = WASH_WATER, path = PATH_SIFTER}
L42_BATH_MERCURY_WASHER = {wash = WASH_MERCURY, path = PATH_MACERATOR}
L43_BATH_MERCURY_THERMAL = {wash = WASH_MERCURY, path = PATH_THERMAL}
L46_BATH_MERCURY_SIFTER = {wash = WASH_MERCURY, path = PATH_SIFTER}
L52_BATH_NaSO_WASHER = {wash = WASH_NaSO4, path = PATH_MACERATOR}
L53_BATH_NaSO_THERMAL = {wash = WASH_NaSO4, path = PATH_THERMAL}
L56_BATH_NaSO_SIFTER = {wash = WASH_NaSO4, path = PATH_SIFTER}


local targetToName = {
    [TARGET_OUTPUT] = "\27[35mOutput\27[37m",
    [TARGET_MACERATOR] = "\27[33mMacerator\27[37m",
    [TARGET_CENTRIFUGE] = "\27[35mCentrifuge\27[37m",

    [TARGET_ORE_WASHER] = "\27[34mOre Washer\27[37m",
    [TARGET_THERMAL_CENTRIFUGE] = "\27[35mThermal centrifuge\27[37m",
    [TARGET_SIFTER] = "\27[33mSifter",

    [TARGET_UNKNOWN] = "\27[31mUNKNOWN\27[37m",
    [TARGET_ELECTROLYZER] = "\27[96mElectrolyzer\27[37m",
    [TARGET_CHEM_BATH_BLUE_SHIT] = "\27[94mChemBath NaSO\27[37m",
    [TARGET_CHEM_BATH_MERCURY] = "\27[90mChemBath Mercury\27[37m"
}



local config = {}



-- only crushed / purified ores
local customPaths = {
    {name = "Tetrahedrite", path = L1_MACERATOR},  -- zinc, antimony, antimony
    {name = "Grossular", path = L1_MACERATOR},  -- yellow garnet, calcium, calcium
    {name = "Pentlandite", path = L1_MACERATOR}, -- iron, sulfur, cobalt
    {name = "Lead", path = L1_MACERATOR},
    {name = "Ruby", path = L1_MACERATOR},
    {name = "Antimony", path = L1_MACERATOR},
    {name = "Silver", path = L1_MACERATOR},
    {name = "Lithium", path = L1_MACERATOR},
    {name = "Sodalite", path = L1_MACERATOR},
    {name = "Plutonium 239", path = L1_MACERATOR},
    {name = "Red Zircon", path = L1_MACERATOR},
    {name = "Fayalite", path = L1_MACERATOR},
    {name = "Rare Earth %(I%)", path = L1_MACERATOR},
    {name = "Rare Earth %(II%)", path = L1_MACERATOR},
    {name = "Rare Earth %(III%)", path = L1_MACERATOR},
    {name = "Mytryl", path = L1_MACERATOR},
    {name = "Thorium", path = L1_MACERATOR},  -- thorium, lead, radium 226
    {name = "Uraninite", path = L1_MACERATOR},
    {name = "Deep Iron", path = L1_MACERATOR},
    {name = "Iron", path = L1_MACERATOR},  -- blue shit bath + macerator = nickel + tin
    {name = "Hedenbergite", path = L1_MACERATOR},  -- blue shit bath + macerator = nickel + tin
    {name = "Chrome", path = L1_MACERATOR},
    {name = "Certus Quartz", path = L1_MACERATOR},
    {name = "Forsterite", path = L1_MACERATOR},
    {name = "Manganese", path = L1_MACERATOR},



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
    {name = "Magnesium", path = L2_WASHER_MACERATOR},  -- magnesium (all)
    {name = "Aluminium", path = L2_WASHER_MACERATOR},  -- bauxite (all)
    {name = "Barite", path = L2_WASHER_MACERATOR},  -- barite (all)
    {name = "Cobaltite", path = L2_WASHER_MACERATOR},  -- cobalt (all)
    {name = "Cobalt", path = L2_WASHER_MACERATOR},
    {name = "Ardite", path = L2_WASHER_MACERATOR},
    {name = "Graphite", path = L2_WASHER_MACERATOR},  -- carbon (all)
    {name = "Sulfur", path = L2_WASHER_MACERATOR},  -- sulfur (all)
    {name = "Mica", path = L2_WASHER_MACERATOR}, -- mica (all)
    --{name = "Coal", path = L2_WASHER_MACERATOR},  -- lignite coal, thorium, thorium
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
    {name = "Kyanite", path = L2_WASHER_MACERATOR},
    {name = "Banded Iron", path = L2_WASHER_MACERATOR},
    {name = "Titanium", path = L2_WASHER_MACERATOR},
    {name = "Green Fuchsite", path = L2_WASHER_MACERATOR},
    {name = "Red Fuchsite", path = L2_WASHER_MACERATOR},
    {name = "Apatite", path = L2_WASHER_MACERATOR},
    {name = "Gold", path = L2_WASHER_MACERATOR},
    {name = "Magnetite", path = L2_WASHER_MACERATOR},  -- 70% gold + 11% gold
    {name = "Ledox", path = L2_WASHER_MACERATOR},
    {name = "Opal", path = L2_WASHER_MACERATOR},
    {name = "Rubracium", path = L2_WASHER_MACERATOR},
    {name = "Orichalcum", path = L2_WASHER_MACERATOR},
    {name = "Callisto Ice", path = L2_WASHER_MACERATOR},
    {name = "Blue Topaz", path = L2_WASHER_MACERATOR},
    {name = "Alduorite", path = L2_WASHER_MACERATOR},
    {name = "Ceruclase", path = L2_WASHER_MACERATOR},
    {name = "Vulcanite", path = L2_WASHER_MACERATOR},
    {name = "Mithril", path = L2_WASHER_MACERATOR},
    {name = "Quantium", path = L2_WASHER_MACERATOR},
    {name = "Amethyst", path = L2_WASHER_MACERATOR},
    {name = "Firestone", path = L2_WASHER_MACERATOR},
    {name = "Calcite", path = L2_WASHER_MACERATOR},
    {name = "Enriched Naquadah", path = L2_WASHER_MACERATOR},
    {name = "Tricalcium Phosphate", path = L2_WASHER_MACERATOR},
    {name = "Lepidolite", path = L2_WASHER_MACERATOR},  -- lithium, caesium, caesium
    {name = "Soapstone", path = L2_WASHER_MACERATOR},  -- lithium, caesium, caesium
    {name = "Adamantium", path = L2_WASHER_MACERATOR},
    {name = "Gypsum", path = L2_WASHER_MACERATOR},  -- lithium, caesium, caesium
    {name = "Garnierite", path = L2_WASHER_MACERATOR},  -- lithium, caesium, caesium
    {name = "Draconium", path = L2_WASHER_MACERATOR},  -- lithium, caesium, caesium
    {name = "Shadow Iron", path = L2_WASHER_MACERATOR},  -- lithium, caesium, caesium
    {name = "Shadow Metal", path = L2_WASHER_MACERATOR},  -- lithium, caesium, caesium
    {name = "Alunite", path = L2_WASHER_MACERATOR},  -- lithium, caesium, caesium
    {name = "Neodymium", path = L2_WASHER_MACERATOR}, -- monazite, rare earth, rare earth
    {name = "Bauxite", path = L2_WASHER_MACERATOR},
    {name = "Scheelite", path = L2_WASHER_MACERATOR},
    {name = "Infused Gold", path = L2_WASHER_MACERATOR},
    {name = "Stibnite", path = L2_WASHER_MACERATOR},
    {name = "Sphalerite", path = L2_WASHER_MACERATOR},
    {name = "Leach Residue", path = L2_WASHER_MACERATOR},
    {name = "Crude Rhodium", path = L2_WASHER_MACERATOR},
    {name = "Rarest Metal Residue", path = L2_WASHER_MACERATOR},
    {name = "Fluor%-Buergerite", path = L2_WASHER_MACERATOR},
    {name = "Olenite", path = L2_WASHER_MACERATOR},
    {name = "Bornite", path = L2_WASHER_MACERATOR},
    {name = "Chromo%-Alumino%-Povondraite", path = L2_WASHER_MACERATOR},
    {name = "Vanadio%-Oxy%-Dravite", path = L2_WASHER_MACERATOR},
    {name = "Vinteum", path = L2_WASHER_MACERATOR},
    {name = "Tungsten", path = L2_WASHER_MACERATOR},
    {name = "Raw Silicon Ore", path = L2_WASHER_MACERATOR},
    {name = "Pitchblende", path = L2_WASHER_MACERATOR},
    {name = "Redstone", path = L2_WASHER_MACERATOR},  -- cinnabar, rare earth, glowstone
    {name = "Bastnasite", path = L2_WASHER_MACERATOR},  -- neodymium, rare earth, rare earth
    {name = "Neutronium", path = L2_WASHER_MACERATOR},
    {name = "Tantalite", path = L2_WASHER_MACERATOR},
    {name = "Mysterious Crystal", path = L2_WASHER_MACERATOR},
    {name = "Niobium", path = L2_WASHER_MACERATOR},
    {name = "Yttrium", path = L2_WASHER_MACERATOR},
    {name = "Naquadria", path = L2_WASHER_MACERATOR},
    {name = "Gallium", path = L2_WASHER_MACERATOR},
    {name = "Plutonium 241", path = L2_WASHER_MACERATOR},
    {name = "Uranium 235", path = L2_WASHER_MACERATOR},
    {name = "Black Plutonium", path = L2_WASHER_MACERATOR},
    {name = "Borax", path = L2_WASHER_MACERATOR},
    {name = "Cosmic Neutronium", path = L2_WASHER_MACERATOR},
    {name = "Lutetium", path = L2_WASHER_MACERATOR},
    {name = "Europium", path = L2_WASHER_MACERATOR},
    {name = "Infinity Catalyst", path = L2_WASHER_MACERATOR},
    {name = "Americium", path = L2_WASHER_MACERATOR},
    {name = "Bismutite", path = L2_WASHER_MACERATOR},
    {name = "Indium", path = L2_WASHER_MACERATOR},
    {name = "Ytterbium", path = L2_WASHER_MACERATOR},
    {name = "Dysprosium", path = L2_WASHER_MACERATOR},
    {name = "Holmium", path = L2_WASHER_MACERATOR},
    {name = "Erbium", path = L2_WASHER_MACERATOR},
    {name = "Quartzite", path = L2_WASHER_MACERATOR},
    {name = "Fluxed Electrum", path = L2_WASHER_MACERATOR},
    {name = "Electrum", path = L2_WASHER_MACERATOR},
    {name = "Wittichenite", path = L2_WASHER_MACERATOR},
    {name = "Barium", path = L2_WASHER_MACERATOR},
    {name = "Cadmium", path = L2_WASHER_MACERATOR},
    {name = "Scandium", path = L2_WASHER_MACERATOR},
    {name = "Red Descloizite", path = L2_WASHER_MACERATOR},
    {name = "Awakened Draconium", path = L2_WASHER_MACERATOR},
    {name = "Bedrockium", path = L2_WASHER_MACERATOR},
    {name = "Tiberium", path = L2_WASHER_MACERATOR},
    {name = "Cosmic Neutronium", path = L2_WASHER_MACERATOR},







    {name = "Chalcopyrite", path = L3_WASHER_THERMAL},  -- gold + cadmium
    {name = "Pyrolusite", path = L3_WASHER_THERMAL},  -- gold + cadmium
    {name = "Pyrochlore", path = L3_WASHER_THERMAL},  -- gold + cadmium
    {name = "Fullers Earth", path = L3_WASHER_THERMAL},  -- gold + cadmium
    {name = "Palladium", path = L3_WASHER_THERMAL},  -- gold + cadmium
    {name = "Platinum", path = L3_WASHER_THERMAL},  -- gold + cadmium
    {name = "Sheldonite", path = L3_WASHER_THERMAL},  -- gold + cadmium
    {name = "Cinnabar", path = L3_WASHER_THERMAL},  -- glowstone
    {name = "Iridium", path = L3_WASHER_THERMAL},
    {name = "Pollucite", path = L3_WASHER_THERMAL},  -- Rubidium
    {name = "Meteoric Iron", path = L3_WASHER_THERMAL},
    {name = "Osmium", path = L3_WASHER_THERMAL},
    {name = "Monazite", path = L3_WASHER_THERMAL},  -- thorium, neodymium, rare earth









    {name = "Tin", path = L6_SIFTER}, -- zirconium
    {name = "Cassiterite", path = L6_SIFTER}, -- zirconium
    {name = "Emerald", path = L6_SIFTER},
    {name = "Sapphire", path = L6_SIFTER},


    {name = "Yellow Garnet", path = L6_SIFTER},  -- sifter
    --{name = "Nether Quartz", path = L6_SIFTER},
    {name = "Coal", path = L6_SIFTER},  -- dohuya norm coal
    {name = "Nether Star", path = L6_SIFTER},
    {name = "Amber", path = L6_SIFTER},
    {name = "Diamond", path = L6_SIFTER},
    {name = "Lapis", path = L6_SIFTER},
    {name = "Jasper", path = L6_SIFTER},
    {name = "Olivine", path = L6_SIFTER},
    {name = "Thorianite", path = L6_SIFTER},
    --{name = "Cinnabar", path = L6_SIFTER},



}

local customPos = {
    {name = "Crushed Grossular Ore", pos = TARGET_OUTPUT},  -- grossular froth

    {name = "Crushed Indium Ore", pos = TARGET_OUTPUT},  -- indium combs

    {name = "Purified Molybdenum Ore", pos = TARGET_OUTPUT},  -- rhenium
    {name = "Purified Molybdenite Ore", pos = TARGET_OUTPUT},
    {name = "Purified Scheelite Ore", pos = TARGET_OUTPUT},

    {name = "Raw Meteoric Iron Ore", pos = TARGET_OUTPUT},  -- just dohuya

    {name = "Crushed Spessartine Ore", pos = TARGET_OUTPUT},  -- froth
    {name = "Crushed Sphalerite Ore", pos = TARGET_OUTPUT}, -- for indium (froth)

    {name = "Purified Galena Ore", pos = TARGET_OUTPUT},  -- for indium
    {name = "Purified Sphalerite Ore", pos = TARGET_OUTPUT}, -- for indium



    {name = "Crushed Lead Ore", pos = TARGET_OUTPUT},  -- for tellurium

    {name = "Crushed Monazite Ore", pos = TARGET_OUTPUT},  -- for lanthanide line

    {name = "Purified Ilmenite Ore", pos = TARGET_OUTPUT}, -- for washing in sulfuric acid to get more rutile

    --{name = "Purified Chalcopyrite Ore", pos = TARGET_OUTPUT}, -- platline
    {name = "Purified Tetrahedrite Ore", pos = TARGET_OUTPUT}, -- platline
    {name = "Purified Sheldonite Ore", pos = TARGET_OUTPUT}, -- platline
    {name = "Platinum Metallic Powder Dust", pos = TARGET_OUTPUT}, -- platline
    {name = "Palladium Metallic Powder Dust", pos = TARGET_OUTPUT}, -- platline


    {name = "Raw Oilsands Ore", pos = TARGET_OUTPUT},  -- centrifuge for oil
    {name = "Oilsands Ore", pos = TARGET_OUTPUT},

    {name = "Sodalite Dust", pos = TARGET_OUTPUT},
    {name = "Redstone", pos = TARGET_OUTPUT},
    {name = "Glowstone Dust", pos = TARGET_OUTPUT},
    {name = "Monazite", pos = TARGET_OUTPUT},
    {name = "Yellow Garnet", pos = TARGET_OUTPUT},
    {name = "Amber", pos = TARGET_OUTPUT},
    {name = "Rock Salt", pos = TARGET_OUTPUT},
    {name = "Salt", pos = TARGET_OUTPUT},
    {name = "Lignite Coal", pos = TARGET_OUTPUT},
    {name = "Rare Earth", pos = TARGET_OUTPUT},
    {name = "Nether Quartz", pos = TARGET_OUTPUT},
    {name = "Lapis Lazuli", pos = TARGET_OUTPUT},
    {name = "Emerald", pos = TARGET_OUTPUT},
    {name = "Pitchblende", pos = TARGET_OUTPUT},
    {name = "Certus Quartz", pos = TARGET_OUTPUT},
    {name = "Pure Certus Quartz Crystal", pos = TARGET_OUTPUT},
    {name = "Charged Certus Quartz Crystal", pos = TARGET_OUTPUT},
    {name = "Quartzite", pos = TARGET_OUTPUT},
    {name = "Flint", pos = TARGET_OUTPUT},
    {name = "Cassiterite Sand", pos = TARGET_OUTPUT},
    {name = "Basaltic Mineral Sand", pos = TARGET_OUTPUT},
    {name = "Granitic Mineral Sand", pos = TARGET_OUTPUT},
    {name = "Garnet Sand", pos = TARGET_OUTPUT},
    {name = "Coal", pos = TARGET_OUTPUT},
    {name = "Quicksilver", pos = TARGET_OUTPUT},
    {name = "Electrotine", pos = TARGET_OUTPUT},
    {name = "Beeswax", pos = TARGET_OUTPUT},
    {name = "Propolis", pos = TARGET_OUTPUT},
    {name = "Fullers Earth", pos = TARGET_OUTPUT},
    {name = "Malachite", pos = TARGET_OUTPUT},
    {name = "Sugar", pos = TARGET_OUTPUT},
    {name = "Wood Pulp", pos = TARGET_OUTPUT},

    --{name = "Stone Dust", pos = TARGET_CENTRIFUGE_JOPA},
    --{name = "Cinnabar Dust", pos = TARGET_CHEM_BATH_MERCURY_JOPA},

    {regex = "Crushed (.*) Crystals", pos = TARGET_ORE_WASHER},
    {regex = "Purified (.*) Crystals", pos = TARGET_SIFTER},
    {regex = "(.*) Crystal Powder", pos = TARGET_OUTPUT},
    {regex = "(.*) Shard", pos = TARGET_OUTPUT},



    --{name = "Alumina Dust", pos = TARGET_ELECTROLYZER},  -- oxygen
    --{name = "Magnetite Dust", pos = TARGET_ELECTROLYZER},  -- oxygen
    --{name = "Cassiterite Dust", pos = TARGET_ELECTROLYZER},  -- oxygen
    --{name = "Banded Iron Dust", pos = TARGET_ELECTROLYZER},  -- oxygen
    --{name = "Sodalite Dust", pos = TARGET_ELECTROLYZER, multipleOf=11},   -- chlorine, alum, sodium, silicon
    --{name = "Potassium Feldspar Dust", pos = TARGET_ELECTROLYZER, multipleOf=26},   -- oxygen
    --{name = "Red Zircon Dust", pos = TARGET_ELECTROLYZER, multipleOf=6},   -- zirconium
    --{name = "Bauxite Dust", pos = TARGET_ELECTROLYZER, multipleOf=39},
    --{name = "Chromite Dust", pos = TARGET_ELECTROLYZER, multipleOf=7},
    --{name = "Bastnasite Dust", pos = TARGET_ELECTROLYZER, multipleOf=6},

    --{name = "Quartzite Dust", pos = TARGET_AUTOCLAVE},

    --{name = "Uraninite Dust", pos = TARGET_CENTRIFUGE, multipleOf=3},  -- uranium 238
    {name = "Sheldonite Dust", pos = TARGET_CENTRIFUGE, multipleOf=6},   -- platinum metallic powder dust

    {name = "Fluorite (F) Ore", pos = TARGET_MACERATOR},   -- platinum metallic powder dust
    {name = "Purified Crushed Fluorite (F) Ore", pos = TARGET_THERMAL_CENTRIFUGE},   -- platinum metallic powder dust


    {name = "Impure Pile of Endstone Dust", pos = TARGET_CENTRIFUGE},
    --{name = "Endstone Dust", pos = TARGET_CENTRIFUGE},

}



config.selectedPath = customPaths
config.specialTarget = customPos
config.targetToName = targetToName

return config
