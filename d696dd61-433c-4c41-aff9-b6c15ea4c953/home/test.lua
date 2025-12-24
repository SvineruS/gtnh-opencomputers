local thread = require("thread")

package_path_backup = package.path
print(package.path)
package.path = "./pd/?.lua;" .. package.path
local pd = require("pd/hud")
package.path = package_path_backup


function main()
    print("Main program start")
    local t1 = thread.create(function()
        p1()
    end)
    local t2 = thread.create(function()
        p2()
    end)


    thread.waitForAll({t1, t2})
    print("Main program end")

end


function p1()
    while true do
        print("P1")
        os.sleep(1)
    end
end

function p2()
    while true do
        print("P2")
        os.sleep(1)
    end
end


main()
