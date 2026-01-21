local component = require("component")
local json = require("json")
local serialization = require("serialization")

package.loaded["ae/stock"] = nil
local STOCKING = require("ae/stock")

package.loaded["ae/aeHud"] = nil
local aeHud = require("ae/aeHud")

local me = component.me_interface

local CPUS_TO_USE = {
    cpu1 = { },
    cpu2 = { },
    cpu3 = { },
    cpu4 = { },
    cpu5 = { },
    cpu6 = { },
}  -- names of CPUs to use for crafting

local failedToCraft = {}
local failedToCraftGui = nil

function main()

    failedToCraftGui = aeHud.createFailedToCraftList(1, 100)
    --aeHud.gui.clearAll()

    local i = 0
    for cpuName, cpuValue in pairs(CPUS_TO_USE) do
        CPUS_TO_USE[cpuName].icon = aeHud.createCpuIcon(1, 120 + 16 * i)
        i = i + 1
    end

    while true do
        local cpus = me.getCpus()
        for _, meCpu in ipairs(cpus) do
            local cpuConfig = CPUS_TO_USE[meCpu.name]
            if cpuConfig then

                local cpu = getCpuData(meCpu)

                --print(serialization.serialize(cpu))
                if not cpu.isBusy then
                    while true do
                        local item = getNextStockingItem()
                        local crafting = checkItem(item, cpu.name)
                        if crafting == "crafting" then
                            break
                        elseif crafting == "fail" then
                            updateFailedToCraft(item)
                        end
                        os.sleep(0)
                    end
                end

                local final = cpu.finalOutput
                if final == nil and #cpu.pendingItems > 0 then
                    final = cpu.pendingItems[#cpu.pendingItems]
                end
                if final == nil and #cpu.activeItems > 0 then
                    final = cpu.activeItems[1]
                end
                --cpuConfig.icon.updateFinal(cpu.finalOutput or cpu.pendingItems[#cpu.pendingItems])
                cpuConfig.icon.updateFinal(final)
                cpuConfig.icon.updateActive(cpu.activeItems)

            end
        end

        os.sleep(2)
    end

end

function checkItem(item, cpuName)
    local available = getItemAmount(item.name, item.damage)
    if available >= item.stock then
        print(string.format("Skipping %s | %d > %d", item.label, available, item.stock))

        return "no"
    end

    print(string.format("Crafting %s | %d -> %d", item.label, available, item.stock))

    local craftable = getCraftable(item)

    local craftAmount = item.stock - available
    while craftAmount > 0 do
        local tracking = craftable.request(craftAmount, false, cpuName)

        local hasFailed, reason = tracking.hasFailed()
        local isCanceled = tracking.isCanceled()

        if not (hasFailed and isCanceled) then
            return "crafting"
        end

        craftAmount = math.floor(craftAmount / 2)
        print("\27[31mFailed: " .. reason .. ", retrying x" .. craftAmount .. "\27[37m")
    end

    return "fail"

end

local currentIndex = 0
function getNextStockingItem()
    currentIndex = currentIndex + 1
    if currentIndex > #STOCKING then
        currentIndex = 1

        os.sleep(5)
        -- reload stocking list
        package.loaded["ae/stock"] = nil
        STOCKING = require("ae/stock")
    end
    return STOCKING[currentIndex]
end

function updateFailedToCraft(item)
    local lastFailed = failedToCraft[#failedToCraft]
    if lastFailed and lastFailed.name == item.name and lastFailed.damage == item.damage then
        return
    end
    table.insert(failedToCraft, item)
    if #failedToCraft > 5 then
        table.remove(failedToCraft, 1)
    end
    --print(serialization.serialize(failedToCraft))
    failedToCraftGui.update(failedToCraft)
end

function getItemAmount(name, damage)
    local item = me.getItemInNetwork(name, damage)
    if item == nil then
        return 0
    end
    return item.size
end


function getCraftable(item)
    if item.is_fluid then
        return getCraftableFluid(item.name)
    else
        return getCraftableItem(item.name, item.damage or 0)
    end
end


function getCraftableItem(name, damage)
    local craftables = me.getCraftables({ name = name, damage = damage })
    assert(#craftables == 1, "Expected exactly one craftable for " .. name .. ":" .. damage .. ", got " .. #craftables)

    return craftables[1]
end

function getCraftableFluid(name)
    local craftablesAll = me.getCraftables({ name = "ae2fc:fluid_drop"})
    local craftables = {}
    for i, craftable in ipairs(craftablesAll) do
        local item = craftable.getItemStack()
        if item.fluidDrop and item.fluidDrop.name == name then
            table.insert(craftables, craftable)
        end
    end
    assert(#craftables == 1, "Expected exactly one craftable for " .. name .. ":" .. ", got " .. #craftables)

    return craftables[1]
end



--- @param cpu AECpuMetadata
function getCpuData(cpu)
    return {
        name = cpu.name,
        isBusy = cpu.cpu.isBusy(),
        --isActive = isActive,
        finalOutput = cpu.cpu.finalOutput(),
        pendingItems = cpu.cpu.pendingItems(),
        activeItems = cpu.cpu.activeItems(),
        --storedItems = cpu.cpu.storedItems(),
    }
end

return { main = main }
