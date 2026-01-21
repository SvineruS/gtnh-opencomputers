local sides = require("sides")
local component = require("component")
local text = require("text")

package.loaded["OREst/config"] = nil
local config = require("OREst/config")





--- @type transposer
local T1 = component.proxy(config.addr_t1, "transposer")
local T2 = component.proxy(config.addr_t2, "transposer")
local T3 = component.proxy(config.addr_t3, "transposer")

function main()

    while true do
        checkTransposer(T1, 1)
        checkTransposer(T2, 2)
        checkTransposer(T3, 3)

        os.sleep(1)

        -- reload config
        package.loaded["OREst/config"] = nil
        config = require("OREst/config")
    end
end



---@param tr transposer
function checkTransposer(tr, trIndex)
    --print("   Scanning T".. trIndex)


    local inputSide = sides.east -- input always EAST
    local invSize = tr.getInventorySize(inputSide)
    assert(invSize ~= nil, "No inv")


    for j = 1, invSize do
        os.sleep(0)
        local i = invSize - j + 1  -- reverse order

        local item = tr.getStackInSlot(inputSide, i)
        if item == nil then
            -- empty slot
            goto continue_loop
        end

        local itemTarget, reason, count = whereToPutItem(item)
        count = count or item.size

        local needTrIndex, side = parseTarget(itemTarget)
        if needTrIndex == trIndex then
            transfer(tr, inputSide, side, i, count)
            print(reason .. text.padRight(item.label .. "\27[40m", 35) .."-> ".. config.targetToName[itemTarget] .. " x" .. count)
        elseif needTrIndex > trIndex then
            -- send to next transposer
            transfer(tr, inputSide, sides.west, i, count)
        else -- needTrIndex < trIndex
            assert(false, "Item ".. item.label .." should be processed earlier, skipping")
        end

        ::continue_loop::
    end

    return didSomething

end







function whereToPutItem(item)
    assert(item ~= nil, "Item is nil")

    for _, i in ipairs(config.specialTarget) do
        if item.label == i.name or labelContains(item, i.regex) then
            local count = nil
            if i.multipleOf ~= nil then
                count = math.floor(item.size / i.multipleOf) * i.multipleOf
            end

            return i.pos, "\27[42m", count
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

    if contains(item.name, "gregtech:gt%.metaitem", "bartworks:gt%.bwMetaGenerated") then
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



--- @param tr transposer
function transfer(tr, fromSide, toSide, fromSlot, count)
    if count == 0 then
        -- less than multipleOf
        -- transfer to fromSide again to stack with itself
        -- to prevent similar items blocking many slots
        num, err = tr.transferItem(fromSide, fromSide, 64, fromSlot)
        --print("   \27[33mSkipping transfer of less than multipleOf, stacking item with itself\27[37m")
        assert(err == nil, "Transfer to same side error: ", err)
        return true
    end
    num, err = tr.transferItem(fromSide, toSide, count, fromSlot)
    if err ~= nil then
        assert(false, "Transfer error: ", err)
    end
    if num == 0 then
        print("\27[31mCHEST IS FULL\27[37m")
        return false
    end
    return true
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




function parseTarget(pos)
    local x = math.floor(pos / 10)
    local y = pos % 10
    return x, y
end


return {main = main}
