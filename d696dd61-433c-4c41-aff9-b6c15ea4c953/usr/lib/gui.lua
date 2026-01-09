local component = require("component")
local serialization = require("serialization")


local database = component.database
local gt = component.glasses

local W = 750
local H = 425

local gui = {gt = gt}


function gui.clearAll()
    gt.removeAll()
end

function gui.icon(item, pos, s)
    database.set(1, item.name, item.damage)

    local icon = gt.addItem()
    icon.setItem(database.address, 1)
    icon.setPosition(pos.x, pos.y)
    icon.setScale(s)

    function icon.setIcon(new_item)
        database.set(1, new_item.name, new_item.damage)
        icon.setItem(database.address, 1)
    end


    return icon

end
--
function gui.text(text_string, pos, s, color)

    Widget_Text = gt.addTextLabel()
    Widget_Text.setPosition(pos.x, pos.y)
    Widget_Text.setText(text_string)
    Widget_Text.setColor(color[1], color[2], color[3])
    Widget_Text.setAlpha(color[4] or 1)
    Widget_Text.setScale(s)
    return Widget_Text

end
--
--function gui.rect(x, y, w, h, color)
--
--    x = x * W
--    y = y * H
--    w = w * W
--    h = h * H
--
--    local Widget_Rect = gt.addRect()
--    Widget_Rect.setPosition(x, y)
--    Widget_Rect.setSize(h, w)
--    Widget_Rect.setColor(color[1], color[2], color[3])
--    Widget_Rect.setAlpha(color[4])
--    return Widget_Rect
--
--end
--
--function gui.button(text_string, x, y, w, h, color)
--
--    local rect = gui.rect(gt, x, y, w, h, { 0.5, 0.7, 0.5, 0.8 })
--    local text = gui.text(gt, text_string, x, y, 1, { 1, 1, 1 })
--
--    local boundingBox = {
--        x1 = x,
--        y1 = y,
--        x2 = x + w,
--        y2 = y + h
--    }
--    local button = {
--        rect = rect,
--        text = text,
--        box = boundingBox
--    }
--
--    function button.isClicked(clickX, clickY)
--        if clickX >= button.box.x1 and clickX <= button.box.x2 and
--                clickY >= button.box.y1 and clickY <= button.box.y2 then
--            return true
--        end
--        return false
--    end
--
--    return button
--
--end

return gui
