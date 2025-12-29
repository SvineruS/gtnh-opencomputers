local component = require('component')
local events = require('pd/events')

package.loaded['pd/lscHud'] = nil
local initLscHud = require('pd/lscHud')


local pd = {}

local gl = component.glasses


function pd.main()
    events.hookEvents()


    local lscHud = initLscHud(gl)

    -- ===== MAIN LOOP =====
    while not events.needExit() do
        res, err = pcall(lscHud.update)
        if not res then
            print("Error in LSC HUD update: " .. err)
        end
        os.sleep(1)
    end

    events.unhookEvents()
    gl.removeAll()

end

return pd
