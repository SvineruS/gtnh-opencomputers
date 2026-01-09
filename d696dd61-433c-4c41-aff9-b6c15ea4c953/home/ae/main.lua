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
    --cpu2 = { }
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

                --cpuConfig.icon.updateFinal(cpu.finalOutput or cpu.pendingItems[#cpu.pendingItems])
                cpuConfig.icon.updateFinal(cpu.finalOutput)
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

    local craftable = getCraftable(item.name, item.damage)
    local tracking = craftable.request(item.stock - available, false, cpuName)

    local hasFailed, reason = tracking.hasFailed()
    local isCanceled = tracking.isCanceled()

    if hasFailed and isCanceled then
        print("Crafting failed: " .. reason)
        return "fail"
    end
    return "crafting"
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

function getCraftable(name, damage)
    local craftables = me.getCraftables({ name = name, damage = damage })
    assert(#craftables == 1, "Expected exactly one craftable for " .. name .. ":" .. damage .. ", got " .. #craftables)

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
