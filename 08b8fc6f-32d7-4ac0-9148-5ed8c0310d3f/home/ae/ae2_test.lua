local component = require("component")
local json = require("json")
local serialization = require("serialization")

local me = component.me_interface


function main()
    local cpus  = me.getCpus()
    for i, cpu1 in ipairs(cpus) do

        if cpu1 == nil then
            print("No CPU found at index ", i)
        else
            print("CPU 1 info:")
            local isBusy = cpu1.cpu.isBusy()
            local pendingItems = cpu1.cpu.pendingItems()
            local isActive = cpu1.cpu.isActive()
            local activeItems = cpu1.cpu.activeItems()
            local storedItems = cpu1.cpu.storedItems()
            local finalOutput = cpu1.cpu.finalOutput()
            local cpu1_info = {
                name = cpu1.name,
                isBusy = isBusy,
                pendingItems = pendingItems,
                isActive = isActive,
                activeItems = activeItems,
                storedItems = storedItems,
                finalOutput = finalOutput,
            }
            --print(print_r(cpu1_info))
            print(print_r(cpu1))

        end



    end




end

function print_r(tt, indent, done)
    -- Initialize parameters on the first call
    done = done or {}
    indent = indent or 0
    local original_indent = indent
    local function_output = ""

    if type(tt) == "table" then
        -- Check if the table has already been visited (cycle detection)
        if done[tt] then
            return string.format("{... *CYCLE* %s}\n", tostring(tt))
        end
        -- Mark this table as visited
        done[tt] = true

        function_output = function_output .. string.format("{\n")
        indent = indent + 4

        for key, value in pairs(tt) do
            function_output = function_output .. string.rep(" ", indent) .. "[" .. tostring(key) .. "] = "
            local value_type = type(value)

            if value_type == "table" then
                -- Recursively call the function for nested tables
                function_output = function_output .. print_r(value, indent, done)
            elseif value_type == "string" then
                function_output = function_output .. string.format("%q", value) .. ",\n"
            else
                -- Handle numbers, booleans, etc.
                function_output = function_output .. tostring(value) .. ",\n"
            end
        end

        indent = indent - 4
        function_output = function_output .. string.rep(" ", indent) .. "}\n" .. string.rep(" ", indent-4)
        -- If this is the top-level call, add a final newline for clean output
        if original_indent == 0 then
            function_output = function_output .. "\n"
        end
    else
        -- Handle non-table values for the initial call
        function_output = tostring(tt) .. "\n"
    end

    return function_output
end


main()
