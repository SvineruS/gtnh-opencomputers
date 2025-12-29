local thread = require("thread")


package.loaded["pd/main"] = nil
package.loaded["OREst/main"] = nil

local pd = require("pd/main")
local orest = require("OREst/main")


function main()
    print("Main program start")
    local t1 = thread.create(function()
        pd.main()
    end)
    local t2 = thread.create(function()
        orest.main()
    end)


    thread.waitForAny({t1, t2})
    print("Main program ending, killing other threads")
    t1.kill()
    t2.kill()
    print("Main program end")

end


main()
