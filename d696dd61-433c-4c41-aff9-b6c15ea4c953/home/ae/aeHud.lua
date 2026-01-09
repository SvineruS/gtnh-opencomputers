local serialization = require("serialization")

package.loaded["gui"] = nil
local gui = require("gui")


local aeHud = {gui = gui}



function aeHud.createCpuIcon(x, y)
    local cpuIcon = {}

    cpuIcon.finalItem = createItemWithSize(x, y, 1)
    cpuIcon.activeItems = {}
    for i=1,5 do
        local activeItem = createItemWithSize(x + 5 + (i)*8, y, 0.5)
        table.insert(cpuIcon.activeItems, activeItem)
    end

    function cpuIcon.updateFinal(item)
        cpuIcon.finalItem.update(item)
    end

    function cpuIcon.updateActive(items)
        for j, activeItem in ipairs(cpuIcon.activeItems) do
            activeItem.update(items[j])
        end
    end



    return cpuIcon

end



function aeHud.createFailedToCraftList(x, y)
    local failedToCraft = {}

    failedToCraft.items = {}
    for i=1,10 do
        local item = createItemWithSize(x + (i-1)*8, y, 0.5)
        table.insert(failedToCraft.items, item)
    end

    function failedToCraft.update(items)
        for j, item in ipairs(failedToCraft.items) do
            item.update(items[j])
        end
    end



    return failedToCraft

end




function createItemWithSize(x, y, s)
    local item = {}
    item.item = gui.icon(
            {name="appliedenergistics2:tile.BlockCraftingStorage", damage=0},
            {x=x, y=y},
            s * 1
    )
    item.size = gui.text(
            "0",
            {x=x + 10 + 4*s, y=y + 12},
            s * 0.5,
            {1, 1, 1, 1}
    )

    function item.setVisible(visible)
        item.item.setVisible(visible)
        item.size.setVisible(visible)
    end

    function item.update(new_item)
        if new_item == nil then
            item.setVisible(false)
            return
        end

        item.item.setIcon(new_item)
        item.size.setText(tostring(new_item.size or 0))

        item.setVisible(true)
    end

    item.setVisible(false)

    function item.remove()
        gui.gt.removeObject(item.item.getID())
        gui.gt.removeObject(item.size.getID())
    end
    return item
end




return aeHud
