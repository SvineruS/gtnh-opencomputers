local component = require("component")
local event = require("event")
local sides = require("sides")
local serialization = require("serialization")

-- Button layout
local rows, cols = 8, 2
local startX, startY = 0, 1
local buttons = {}

local gpu = component.gpu
local transposer = component.transposer

local screenW, screenH = gpu.getResolution()
--local buttonW, buttonH = math.floor(screenW / cols), math.floor(screenH / rows)
local buttonW, buttonH = math.floor(screenW / cols), 1

function main()

    -- Screen setup
    gpu.setBackground(0x000000)
    gpu.fill(1, 1, screenW, screenH, " ")

    local teleposers = scanTeleposers()
    --print("Found " .. #teleposers .. " teleposers in the transposer.")

    -- Draw buttons
    local index = 1
    for r = 1, rows do
        for c = 1, cols do
            local x = startX + (c - 1) * (buttonW + 1)
            local y = startY + (r - 1) * (buttonH + 1)

            buttons[index] = {
                x1 = x,
                y1 = y,
                x2 = x + buttonW - 1,
                y2 = y + buttonH - 1
            }

            local btnText = teleposers[index] or ""

            gpu.setBackground(0xFFFFFF)
            gpu.fill(x, y, buttonW, buttonH, " ")
            gpu.setForeground(0x000000)
            gpu.set(x + 3, y, btnText)

            index = index + 1
        end
    end

    -- Touch handler
    while true do
        local _, _, tx, ty = event.pull("touch")

        for i, b in ipairs(buttons) do
            if tx >= b.x1 and tx <= b.x2 and ty >= b.y1 and ty <= b.y2 then
                onButtonPress(i)
                break
            end
        end
    end


end

function scanTeleposers()
    local teleposers = {}
    local s = transposer.getInventorySize(sides.top)
    for i = 1, s do
        local item = transposer.getStackInSlot(sides.top, i)
        if item and item.name == "AWWayofTime:telepositionFocus" then
            table.insert(teleposers, i, item.label)
        end
    end

    return teleposers
end


-- Function called when a button is pressed
function onButtonPress(index)
    --gpu.set(1, screenH, "Button pressed: " .. index .. "   ")
    transposer.transferItem(sides.up, sides.south, 1, index)
    os.sleep(5) -- Simulate some processing time
    transposer.transferItem(sides.south, sides.up, 1, 1)
end

main()
