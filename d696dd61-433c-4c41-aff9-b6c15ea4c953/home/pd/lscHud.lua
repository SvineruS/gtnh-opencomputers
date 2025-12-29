package.loaded["pd/graphics"] = nil
local graphics = require('pd/graphics')

local component = require('component')

local lsc = component.gt_machine




local rateThreshold = 0.003
-- View numbers in metric or scientic notation
local metric = true

local fontSize = 2


-- Colors (see below for options)
local primaryColor = graphics.colors.electricBlue
local secondaryColor = graphics.colors.orange
local textColor = graphics.colors.white
local issueColor = graphics.colors.red
local borderColor = graphics.colors.darkGray


-- Configure Graphics
local y = 392 -- vertical position, max 425

local w = 80
local h = 12
local b1 = 2  -- bottom
local b2 = 2  -- top



---@param gl glasses
function initHud(gl)
    local lscHud = {}

    gl.removeAll()


    --graphics.text(gl, "Loh", {250, 250}, 5, {1, 1, 1})

    lscHud.gl = gl
    lscHud.last = 0
    lscHud.lowPercentWarningIsRed = false

    -- Draw Static Shapes
    graphics.quad(gl,
            { 0, y },
            { 35 + w + b2 + 1, y },
            { 25 + w + 1, y - b1 - h - b2 },
            { 0, y - b1 - h - b2 },
            borderColor)
    lscHud.energyBarBG = graphics.quad(gl,
            { 35, y - b1 },
            { 35 + w, y - b1 },
            { 25 + w, y - b1 - h },
            { 25, y - b1 - h },
            secondaryColor)

    -- Draw Energy Bar
    lscHud.energyBar = graphics.quad(gl,
            { b2 + 32.5, y - b1 },
            { b2 + 32.5, y - b1 },
            { b2 + 22.5, y - b1 - h },
            { b2 + 22.5, y - b1 - h },
            primaryColor)

    lscHud.textPercent = graphics.text(gl, 'X.X%', { b2 + 20 - 8 * fontSize, y - b1 - h / 1.8 - fontSize }, fontSize, primaryColor)
    lscHud.textCurr = graphics.text(gl, '', { b2 + 32.5 + 1, y - b1 - h / 2 - fontSize }, fontSize / 1.3, textColor)
    lscHud.textMax = graphics.text(gl, '', { 22.5 + w - 6 * fontSize, y - b1 - h / 2 - fontSize }, fontSize / 1.3, textColor)
    lscHud.textMaintenance = graphics.text(gl, '', { b2, y - b1 - b2 - h - 3 * fontSize }, fontSize, issueColor)


    function lscHud.update()
        -- Retrieve LSC data
        local scan = lsc.getSensorInformation()

        --if config.wirelessMode then
        --power = scan[23]:gsub('%D', '')
        --power = tonumber(power)
        --capacity = config.wirelessMax

        local power = lsc.getEUStored()
        local capacity = lsc.getEUMaxStored()

        local percentage = math.min(power / capacity, 1)

        -- Adjust Values
        local curr = metricParser(power)
        local rate = calcRate(percentage, lscHud.last, rateThreshold)
        lscHud.last = percentage

        -- Adjust Energy Bar
        lscHud.energyBar.setVertex(2, b2 + 32.5 + w * percentage, y - b1)
        lscHud.energyBar.setVertex(3, b2 + 22.5 + w * percentage, y - b1 - h)

        lscHud.textPercent.setText(string.format('%.1f%%', percentage * 100))
        lscHud.textCurr.setText(curr .. ' ' .. rate)
        lscHud.textMax.setText(metricParser(capacity))

        local hasIssues = #scan[17] < 43
        -- Detect Maintenance Issues
        if hasIssues then
            lscHud.textMaintenance.setText('Has Problems!')
        else
            lscHud.textMaintenance.setText('')
        end


        if hasIssues or percentage < 0.7 then
            -- Flash Energy Bar Background Color
            if lscHud.lowPercentWarningIsRed then
                lscHud.energyBarBG.setColor(graphics.RGB(secondaryColor))
            else
                lscHud.energyBarBG.setColor(graphics.RGB(issueColor))
            end
            lscHud.lowPercentWarningIsRed = not lscHud.lowPercentWarningIsRed

        else
            lscHud.energyBarBG.setColor(graphics.RGB(secondaryColor))
        end

    end


    return lscHud

end




function calcRate(percentage, last, threshold)
    if percentage > last + 2*threshold then
        return '>>>'
    elseif percentage > last + threshold then
        return '>>'
    elseif percentage >= last then
        return '>'
    elseif percentage > last - threshold then
        return '<'
    elseif percentage > last - 2*threshold then
        return '<<'
    else
        return '<<<'
    end
end

function metricParser(value)
    local units = {' ', 'K', 'M', 'G', 'T', 'P', 'E', 'Z', 'Y'}
    for i = 1, #units do
        if value < 1000 or i == #units then
            return string.format('%.1f%s', value, units[i])
        end
        value = value / 1000
    end
end

function scientificParser(value)
    value = string.format('%.2e', value)
    value = string.sub(value, 0, -4) .. string.sub(value, -2, -1)
    return value
end






return initHud
