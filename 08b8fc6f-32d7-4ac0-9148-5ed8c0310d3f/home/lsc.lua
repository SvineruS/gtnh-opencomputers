local component = require("component")
local json = require("json")
local serialization = require("serialization")

local lsc = component.gt_machine


function main()
    while true do
        -- clear the screen
        print_sensor_info()
        os.sleep(1)
    end
end

function print_sensor_info()
    --    [2] = "EU Stored: 999,999,316 EU",
    --    [4] = "Used Capacity: 98.04%",
    --    [5] = "Total Capacity: 1,020,000,000 EU",
    --    [8] = "EU IN: 0 EU/t",
    --    [9] = "EU OUT: 32,768 EU/t",
    --    [10] = "Avg EU IN: 40 (last 5 seconds)",
    --    [11] = "Avg EU OUT: 12,206 (last 5 seconds)",
    --    [12] = "Avg EU IN: 12,477 (last 5 minutes)",
    --    [13] = "Avg EU OUT: 11,936 (last 5 minutes)",
    --    [14] = "Avg EU IN: 8,796 (last 1 hour)",
    --    [15] = "Avg EU OUT: 8,883 (last 1 hour)",
    --    [16] = "Time to Empty: 1.14 hours",
    --    [17] = "Maintenance Status: §aWorking perfectly§r",
    local info = lsc.getSensorInformation()
    print(info[2])
    print(info[4])
    print(info[5])
    print(info[8])
    print(info[9])
    print(info[10])
    print(info[11])
    print(info[12])
    print(info[13])
    print(info[14])
    print(info[15])
    print(info[16])
    print(info[17])
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

