local thread = require("thread")


package.loaded["pd/main"] = nil
package.loaded["OREst/main"] = nil
package.loaded["ae/main"] = nil

local pd = require("pd/main")
local orest = require("OREst/main")
local ae = require("ae/main")


function main()
    print("Main program start")
    local t1 = thread.create(function()
        local _, err = pcall(pd.main)
        local f = io.open("/home/error.log", "w")
        f:write("PD thread error: " .. tostring(err) .. "\n")
        f:close()

    end)
    local t2 = thread.create(function()
        local _, err = pcall(orest.main)
        local f = io.open("/home/error.log", "w")
        f:write("OREST thread error: " .. tostring(err) .. "\n")
        f:close()
    end)
    local t3 = thread.create(function()
        local _, err = pcall(ae.main)
        local f = io.open("/home/error.log", "w")
        f:write("AE thread error: " .. tostring(err) .. "\n")
        f:close()
    end)


    isOk, err = thread.waitForAny({t1, t2, t3})
    print("Thread ended with:", isOk, err)
    print("Main program ending, killing other threads")
    t1.kill()
    t2.kill()
    t3.kill()
    print("Main program end")

end


main()
