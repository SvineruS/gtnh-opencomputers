package.loaded.config = nil
package.loaded.graphics = nil

local graphics = require('pd/graphics')
local config = require('pd/config')
local events = require('pd/events')
local utils = require('pd/utils')


local component = require('component')
local term = require('term')



local lsc = component.gt_machine
local last = 0
local glasses = {}


local pd = {}

function pd.main()

    -- Initialization
    term.clear()
    graphics.fox()

    for address in component.list('glasses') do
        table.insert(glasses, component.proxy(component.get(address)))
    end

    -- Configure Graphics
    local l = config.length
    local h = config.height
    local b1 = config.borderBottom
    local b2 = config.borderTop
    local y = config.yPos

    --if not config.fullscreen then
    --  y = y - graphics.calcOffset(config.GUIscale)
    --end

    for i = 1, #glasses do
        local gl = glasses[i]


        gl.removeAll()

        -- Draw Static Shapes
        graphics.quad(gl, { 0, y - b1 }, { 3.5 * h + l + b2 + 1, y - b1 }, { 2.5 * h + l + 1, y - b1 - h - b2 }, { 0, y - b1 - h - b2 }, config.borderColor)
        graphics.quad(gl, { 0, y }, { 3.5 * h + l + b2 + 1, y }, { 3.5 * h + l + b2 + 1, y - b1 }, { 0, y - b1 }, config.borderColor)
        graphics.quad(gl, { 3.5 * h, y - b1 }, { 3.5 * h + l, y - b1 }, { 2.5 * h + l, y - b1 - h }, { 2.5 * h, y - b1 - h }, config.secondaryColor)

        -- Draw Energy Bar
        gl.energyBar = graphics.quad(gl, { b2 + 3.25 * h, y - b1 }, { b2 + 3.25 * h, y - b1 }, { b2 + 2.25 * h, y - b1 - h }, { b2 + 2.25 * h, y - b1 - h }, config.primaryColor)
        gl.textPercent = graphics.text(gl, 'X.X%', { 0.5 * h, y - b1 - h / 1.8 - config.fontSize }, config.fontSize, config.primaryColor)

        -- Draw Optional Values
        gl.textCurr = graphics.text(gl, '', { b2 + 3.25 * h + 1, y - b1 - h / 2 - config.fontSize }, config.fontSize / 1.3, config.textColor)
        gl.textMax = graphics.text(gl, '', { -2.25 * h + l, y - b1 - h / 2 - config.fontSize }, config.fontSize / 1.3, config.textColor)
        gl.textMaintenance = graphics.text(gl, '', { b2, y - b1 - b2 - h - 3 * config.fontSize }, config.fontSize, config.issueColor)
    end

    -- Stand Ready for Exit Command
    events.hookEvents()

    -- ===== MAIN LOOP =====
    while true do

        -- Retrieve LSC data
        scan = lsc.getSensorInformation()

        if config.wirelessMode then
            power = scan[23]:gsub('%D', '')
            power = tonumber(power)
            capacity = config.wirelessMax
        else
            power = lsc.getEUStored()
            capacity = lsc.getEUMaxStored()
        end

        local percentage = math.min(power / capacity, 1)

        -- Adjust Values
        if config.showCurrentEU then
            curr = utils.metricParser(power)
        else
            curr = ''
        end

        if config.showRate then
            rate = graphics.calcRate(percentage, last, config.rateThreshold)
            last = percentage
        else
            rate = ''
        end

        for i = 1, #glasses do
            local gl = glasses[i]

            -- Adjust Energy Bar
            gl.energyBar.setVertex(2, b2 + 3.25 * h + l * percentage, y - b1)
            gl.energyBar.setVertex(3, b2 + 2.25 * h + l * percentage, y - b1 - h)

            if percentage > 0.999 then
                gl.textPercent.setText('100%')
                gl.textPercent.setPosition(b2 + 2.1 * h - 2 * config.fontSize * (#gl.textPercent.getText()), y - b1 - h / 1.8 - config.fontSize)
            else
                gl.textPercent.setText(string.format('%.1f%%', percentage * 100))
                gl.textPercent.setPosition(b2 + 2 * h - 2 * config.fontSize * (#gl.textPercent.getText() - 1), y - b1 - h / 1.8 - config.fontSize)
            end

            gl.textCurr.setText(curr .. ' ' .. rate)

            if config.showMaxEU then
                gl.textMax.setText(graphics.metricParser(capacity))
                gl.textMax.setPosition(2.25 * h + l - 1.5 * config.fontSize * (#gl.textMax.getText() - 1), y - b1 - h / 2 - config.fontSize)
            end

            -- Detect Maintenance Issues
            if #scan[17] < 43 then
                gl.textMaintenance.setText('Has Problems!')
            else
                gl.textMaintenance.setText('')
            end
        end

        -- Terminal Condition
        if events.needExit() then
            break
        end

        -- Pause
        os.sleep(config.sleep)
    end

    events.unhookEvents()
    for i = 1, #glasses do
        glasses[i].removeAll()
    end

end

return pd
