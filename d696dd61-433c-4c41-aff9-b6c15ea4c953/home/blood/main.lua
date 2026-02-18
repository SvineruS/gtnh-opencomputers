local component = require("component")
local sides = require("sides")
local serialization = require("serialization")

local tr = component.transposer;


local SIDE_1 = sides.south
local SIDE_2 = sides.up

function main()
    while true do
        checkLp()
        os.sleep(60)
    end
end


function checkLp()

    local item = tr.getStackInSlot(SIDE_1, 1)

    local lp = item["networkEssence"]
    local maxLp = item["maxNetworkEssence"]

    local needCharge = lp / maxLp < 0.8

    print("LP: " .. lp .. "/" .. maxLp .. " (" .. (lp / maxLp * 100) .. "%), needCharge: " .. tostring(needCharge))

    if needCharge then
        -- try move from chest east slot 2 to chest top slot 1
        tr.transferItem(SIDE_1, SIDE_2, 64, 2)
    else
        -- try move from chest top slot 1 to chest east slot 2
        tr.transferItem(SIDE_2, SIDE_1, 64, 1)
    end
end

return { main = main }
