local component = require("component")
local computer = require("computer")
local serialization = require("serialization")
local thread = require("thread")



function main()
    print("Main program start")
    local t1 = thread.create(function()
        --local newEnv = {}
        --setmetatable(newEnv, {__index = _G._ENV})
        --G._ENV = newEnv
        for k, v in pairs(_G) do
            print("k:", k)
        end

        while true do
            print("Hello, World! 1")
            print(_ENV)
            os.sleep(1)
        end

    end)
    local t2 = thread.create(function()
        while true do
            print("Hello, World! 2")
            print(_ENV)

            os.sleep(1)
        end

    end)
    local t3 = thread.create(function()

        while true do
            print("Main program heartbeat")
            os.sleep(1)
        end
    end)




    thread.waitForAny({t1, t2, t3})
    print("Main program ending, killing other threads")
    t1.kill()
    t2.kill()
    t3.kill()
    print("Main program end")

end


main()
