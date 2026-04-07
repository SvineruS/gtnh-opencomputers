local component = require("component")
local sides = require("sides")
local serialization = require("serialization")
local gui = require("gui")
local utils = require("utils")

local tr = component.transposer;
local gl = component.glasses


local SIDE_1 = sides.south
local SIDE_2 = sides.up

-- @
local hudText = nil

function main()

    hudText = gui.text("", {x=1, y=120}, 0.5, {0.7,0.3,0.3,1})

    while true do
        checkLp()
        os.sleep(10)
    end
end


function checkLp()

    local item = tr.getStackInSlot(SIDE_1, 1)

    local lp = item["networkEssence"]
    --local maxLp = item["maxNetworkEssence"]
    local maxLp = 130000000;

    local needCharge = lp < maxLp

    print("LP: " .. lp .. "/" .. maxLp .. " (" .. (lp / maxLp * 100) .. "%), needCharge: " .. tostring(needCharge))
    hudText.setText("LP: " .. utils.metricParser(lp) .. "/" .. utils.metricParser(maxLp))

    if needCharge then
        -- try move from chest east slot 2 to chest top slot 1
        tr.transferItem(SIDE_1, SIDE_2, 64, 2)
    else
        -- try move from chest top slot 1 to chest east slot 2
        tr.transferItem(SIDE_2, SIDE_1, 64, 1)
    end
end

return { main = main }
