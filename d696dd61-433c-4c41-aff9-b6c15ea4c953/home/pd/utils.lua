local utils = {}

function utils.calcRate(percentage, last, threshold)
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

function utils.metricParser(value) -- Creds: Vlamonster
    local units = {' ', 'K', 'M', 'G', 'T', 'P', 'E', 'Z', 'Y'}
    for i = 1, #units do
        if value < 1000 or i == #units then
            return string.format('%.1f%s', value, units[i])
        end
        value = value / 1000
    end
end

function utils.scientificParser(value)
    value = string.format('%.2e', value)
    value = string.sub(value, 0, -4) .. string.sub(value, -2, -1)
    return value
end

return utils
