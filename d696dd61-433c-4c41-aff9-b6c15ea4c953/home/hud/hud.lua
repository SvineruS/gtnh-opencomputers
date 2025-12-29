local event = require('event')
local component = require('component')
local term = require('term')

local serialization = require('serialization')
local json = require('json')

package.loaded.gui = nil
local gui = require('gui')



local pd = {}


local gt = component.glasses

local guiElements = {}


local icon = nil

function initHud()
    gt.removeAll()

    local btn = gui.button(gt, "Click me", 0.01, 0.9, 0.05, 0.02, {1, 1, 1})
    table.insert(guiElements, btn)
    icon = gui.icon(gt, "gregtech:gt.blockmachines", 584, 0.2, 0.2, 1)

end








function glasses_on(_, addr, who, w, h)
    print("Glasses on detected from " .. who .. " with resolution " .. w .. "x" .. h)
end
function interrupted()
    working = false
end
function hudClick(_, addr, who, x, y, btn)
    print("HUD click detected from " .. who .. " at (" .. x .. ", " .. y .. ") with button " .. btn)

    for _, element in ipairs(guiElements) do
        if element.isClicked and element.isClicked(x, y) then
            print("Button clicked!")
        end
    end

end

function pd.main()
    event.listen("glasses_on", glasses_on)
    event.listen("interrupted", interrupted)
    event.listen("hud_click", hudClick)
    working = true



    initHud()
    while working do
        os.sleep(1)
    end

    gt.removeAll()

    event.ignore("glasses_on", glasses_on)
    event.ignore("interrupted", interrupted)
    event.ignore("hud_click", hudClick)
end

pd.main()

return pd
