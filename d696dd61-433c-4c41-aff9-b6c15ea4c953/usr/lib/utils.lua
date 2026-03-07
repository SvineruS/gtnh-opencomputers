local utils = {}

function utils.metricParser(value)
    local units = {' ', 'K', 'M', 'G', 'T', 'P', 'E', 'Z', 'Y'}
    for i = 1, #units do
        if value < 1000 or i == #units then
            return string.format('%.1f%s', value, units[i])
        end
        value = value / 1000
    end
end

return utils
