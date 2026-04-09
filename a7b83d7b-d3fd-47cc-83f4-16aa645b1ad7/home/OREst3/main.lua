local component = require("component")
local serialization = require("serialization")
local text = require("text")

package.loaded["OREst3/config"] = nil
local config = require("OREst3/config")

local me = component.me_interface
local database = component.database

print(serialization.serialize(component.list("me_interface")))
print(serialization.serialize(component.list("me_exportbus")))

--- @type me_interface
 local out_1 = component.proxy(component.get("d714", "me_interface"), "me_interface")
 local out_2 = component.proxy(component.get("6746", "me_interface"), "me_interface")
 local out_3 = component.proxy(component.get("37fa", "me_interface"), "me_interface")
 local out_4 = component.proxy(component.get("0d8d", "me_interface"), "me_interface")
 
local out_5 = component.proxy(component.get("2c23", "me_interface"), "me_interface")
local out_6 = component.proxy(component.get("3fe9", "me_interface"), "me_interface")
local out_7 = component.proxy(component.get("8686", "me_interface"), "me_interface")
--local out_out = component.proxy(component.get("9550", "me_interface"), "me_interface")


local POS = {
    [TARGET_MACERATOR] = out_macerator,
    [TARGET_ORE_WASHER] = out_washer,
    [TARGET_CENTRIFUGE] = out_centrifuge,
    [TARGET_SIFTER] = out_sifter,
    [TARGET_CHEM_BATH_BLUE_SHIT] = out_naso,
    [TARGET_THERMAL_CENTRIFUGE] = out_thermal,
    [TARGET_OUTPUT] = out_out,
}



function setExport(dst, item, slot)
    local interface = POS[dst]

    database.set(1, item.name, item.damage)
    interface.setInterfaceConfiguration(slot or 1, database.address, 1, 100)
end


function main()
    ---- set at least one item in each interface to prevent them from unloading
    setExport(TARGET_MACERATOR, { name = "minecraft:wool", damage = 1 }, 9)
    setExport(TARGET_ORE_WASHER, { name = "minecraft:wool", damage = 2 }, 9)
    setExport(TARGET_CENTRIFUGE, { name = "minecraft:wool", damage = 3 }, 9)
    setExport(TARGET_SIFTER, { name = "minecraft:wool", damage = 4 }, 9)
    setExport(TARGET_CHEM_BATH_BLUE_SHIT, { name = "minecraft:wool", damage = 5 }, 9)
    --setExport(TARGET_ELECTROLYZER, item, )
    --setExport(TARGET_CHEM_BATH_MERCURY, item, item)
    setExport(TARGET_THERMAL_CENTRIFUGE, { name = "minecraft:wool", damage = 6 }, 9)
    setExport(TARGET_OUTPUT, { name = "minecraft:wool", damage = 7 }, 9)



    --while true do
    --    checkME()
    --    os.sleep(0.5)
    --
    --    package.loaded["OREst3/config"] = nil
    --    config = require("OREst3/config")
    --end
end

local MAX_SLOTS = {
    [TARGET_OUTPUT] = 5,
    [TARGET_MACERATOR] = 5,
    [TARGET_ORE_WASHER] = 5,
    [TARGET_CENTRIFUGE] = 5,
    -- default 1
}

function checkME()
    local items = me.getItemsInNetwork()
    local slots = {}
    local doesSomething = false

    -- Sort items by their count/size descending so larger stacks are processed first.
    -- Different ME implementations may use 'size' or 'count' for stack quantity; handle both.
    table.sort(items, function(a, b)
        local asize = a.size or a.count or 0
        local bsize = b.size or b.count or 0
        if asize == bsize then
            -- fallback: keep original order by comparing labels to make deterministic
            return (a.label or "") < (b.label or "")
        end
        return asize > bsize
    end)

    for _, item in ipairs(items) do
        os.sleep(0)

        local itemTarget, reason = whereToPutItem(item)
        if itemTarget == TARGET_UNKNOWN then
            goto continue_loop
        end

        local takedSlots = slots[itemTarget] or 0
        local maxSlots = MAX_SLOTS[itemTarget] or 1
        if takedSlots < maxSlots then
            setExport(itemTarget, item, takedSlots + 1)
            print(reason .. text.padRight(item.label .. "\27[40m", 35) .. "-> " .. config.targetToName[itemTarget])
            slots[itemTarget] = takedSlots + 1
            doesSomething = true
        end

        :: continue_loop ::
    end

    if doesSomething then
        print("---")
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

    if contains(item.name, "gregtech", "bartworks", "miscutils") then
        if contains(item.label, "Cobblestone") then
            return TARGET_OUTPUT, "\27[41m"
        end
        return TARGET_UNKNOWN, "\27[41m"
    end

    return TARGET_OUTPUT, "\27[41m"
end

function customPath(item, name, path)
    local isCrushed = labelContains(item, "Crushed " .. name, "Ground " .. name)
    local isWashed = labelContains(item, "Purified " .. name)

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
    if contains(item.name, "gregtech:gt%.blockores", "bartworks:bw%.blockores") or labelContains(item, "Raw (.+) Ore") then
        -- ore
        return TARGET_MACERATOR
    end

    if contains(item.name, "miscutils:dustImpure", "miscutils:dustPure", "miscutils:crushedCentrifuged", "gregtech:gt%.metaitem", "bartworks:gt%.bwMetaGenerated") then
        if labelContains(item, "Impure Pile of ", "Purified Pile of ", "Impure ", "Purified ") then
            -- impure pile
            return TARGET_CENTRIFUGE
        end

        if labelContains(item, "Centrifuged ") then
            -- centrifuged
            return TARGET_MACERATOR
        end

    end

    if labelContains(item, " Dust") then
        -- dust
        return TARGET_OUTPUT
    end

    if contains(item.name, "gregtech:gt%.metaitem%.02") then

        if labelContains(item, "Chipped", "Flawed", "Flawless", "Exquisite") then
            -- gem
            return TARGET_OUTPUT
        end

    end

end

function labelContains(item, ...)
    return contains(item.label, ...)
end

function contains(payload, ...)
    local args = { ... }
    for i = 1, #args do
        if string.match(payload, args[i]) then
            return true
        end
    end
    return false
end

return { main = main }