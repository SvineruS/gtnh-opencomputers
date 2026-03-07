local component = require('component')

package.loaded['pd/lscHud'] = nil
local initLscHud = require('pd/lscHud')


local pd = {}

local gl = component.glasses


function pd.main()

    local lscHud = initLscHud(gl)

    -- ===== MAIN LOOP =====
    while true do
        res, err = pcall(lscHud.update)
        if not res then
            print("Error in LSC HUD update: " .. err)
        end
        os.sleep(1)
    end

    gl.removeAll()

end

return pd
