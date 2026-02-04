local component = require("component")
local sides = require("sides")
local serialization = require("serialization")

local tr = component.proxy(component.get("a46d7b38", "transposer"), "transposer")




function main()
    while true do
        checkLp()
        os.sleep(60)
    end
end


function checkLp()

    local item = tr.getStackInSlot(sides.east, 1)

    local lp = item["networkEssence"]
    local maxLp = item["maxNetworkEssence"]

    local needCharge = lp / maxLp < 0.8

    print("LP: " .. lp .. "/" .. maxLp .. " (" .. (lp / maxLp * 100) .. "%), needCharge: " .. tostring(needCharge))

    if needCharge then
        -- try move from chest east slot 2 to chest top slot 1
        tr.transferItem(sides.east, sides.up, 64, 2)
    else
        -- try move from chest top slot 1 to chest east slot 2
        tr.transferItem(sides.up, sides.east, 64, 1)
    end
end

return { main = main }
