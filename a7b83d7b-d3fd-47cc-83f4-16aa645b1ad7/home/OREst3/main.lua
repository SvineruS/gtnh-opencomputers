local component = require("component")
local serialization = require("serialization")
local text = require("text")

package.loaded["OREst3/config"] = nil
local config = require("OREst3/config")



local me = component.me_interface
local database = component.database


--- @type me_exportbus
local bus_1 = component.proxy(component.get("7de1", "me_exportbus"), "me_exportbus")
local bus_2 = component.proxy(component.get("2418", "me_exportbus"), "me_exportbus")
local bus_3 = component.proxy(component.get("3720", "me_exportbus"), "me_exportbus")
-- bot, mid, top


print(serialization.serialize(component.list("me_exportbus")))



function setExport(dst, item, slot)
    local bus, bus_side = parseTarget(dst)

    database.set(1, item.name, item.damage)
    bus.setExportConfiguration(bus_side, slot or 1, database.address, 1)
end

function parseTarget(pos)
    local x = math.floor(pos / 10)
    local y = pos % 10
    if x == 1 then
        return bus_1, y
    elseif x == 2 then
        return bus_2, y
    elseif x == 3 then
        return bus_3, y
    end
end












function main()
    while true do
        checkME()
        print("---")
        os.sleep(1)

        package.loaded["OREst3/config"] = nil
        config = require("OREst3/config")
    end
end


local MAX_SLOTS = {
    [TARGET_OUTPUT] = 5
    -- default 1
}



function checkME()
    local items = me.getItemsInNetwork()
    local slots = {}
    for i = #items, 1, -1 do
        local item = items[i]
        os.sleep(0)

        local itemTarget, reason = whereToPutItem(item)
        if itemTarget == TARGET_UNKNOWN then
            goto continue_loop
        end

        local takedSlots = slots[itemTarget] or 0
        local maxSlots = MAX_SLOTS[itemTarget] or 1
        if takedSlots < maxSlots then
            setExport(itemTarget, item, takedSlots + 1)
            print(reason .. text.padRight(item.label .. "\27[40m", 35) .."-> ".. config.targetToName[itemTarget])
            slots[itemTarget] = takedSlots + 1
        end

        ::continue_loop::
    end

end








function whereToPutItem(item)
    assert(item ~= nil, "Item is nil")

    for _, i in ipairs(config.specialTarget) do
        if item.label == i.name or labelContains(item, i.regex) then
            return i.pos, "\27[42m"
        end
    end

    for _, i in ipairs(config.selectedPath) do
        local ok, path = customPath(item, i.name, i.path)
        if ok then
            --print("Selected path")
            return path, "\27[44m"
        end
    end

    local defaultPath = defaultPath(item)
    if defaultPath ~= nil then
        --print("Default path")
        return defaultPath, ""
    end

    if contains(item.name, "gregtech", "bartworks") then
        if contains(item.label, "Cobblestone") then
            return TARGET_OUTPUT, "\27[41m"
        end
        return TARGET_UNKNOWN, "\27[41m"
    end

    return TARGET_OUTPUT, "\27[41m"
end


function customPath(item, name, path)
    local isCrushed = labelContains(item, "Crushed "..name, "Ground "..name)
    local isWashed = labelContains(item, "Purified "..name)


    if isCrushed and not isWashed then
        if path.wash == WASH_WATER then
            return true, TARGET_ORE_WASHER
        end
        if path.wash == WASH_MERCURY then
            return true, TARGET_CHEM_BATH_MERCURY
        end
        if path.wash == WASH_NaSO4 then
            return true, TARGET_CHEM_BATH_BLUE_SHIT
        end
        -- if path.wash == WASH_NONE - skip wash
    end

    if isCrushed or isWashed then
        if path.path == PATH_MACERATOR then
            return true, TARGET_MACERATOR
        end
        if path.path == PATH_THERMAL then
            return true, TARGET_THERMAL_CENTRIFUGE
        end
        if path.path == PATH_SIFTER and isWashed then
            return true, TARGET_SIFTER
        end
    end

    return false, 0
end



function defaultPath(item)
    if contains(item.name, "gregtech:gt%.blockores", "bartworks:bw%.blockores") or labelContains(item, "Raw (.+) Ore") then  -- ore
        return TARGET_MACERATOR
    end

    if contains(item.name, "miscutils:dustImpureRareEarth", "gregtech:gt%.metaitem", "bartworks:gt%.bwMetaGenerated") then
        if labelContains(item, "Impure Pile of ", "Purified Pile of ", "Impure ") then  -- impure pile
            return TARGET_CENTRIFUGE
        end

        if labelContains(item, "Centrifuged ") then  -- centrifuged
            return TARGET_MACERATOR
        end

    end

    if labelContains(item, " Dust") then  -- dust
        return TARGET_OUTPUT
    end

    if contains(item.name, "gregtech:gt%.metaitem%.02") then

        if labelContains(item, "Chipped", "Flawed", "Flawless", "Exquisite") then  -- gem
            return TARGET_OUTPUT
        end

    end

end




function labelContains(item, ...)
    return contains(item.label, ...)
end

function contains(payload, ...)
    local args = {...}
    for i = 1, #args do
        if string.match(payload, args[i]) then
            return true
        end
    end
    return false
end



return {main = main}
