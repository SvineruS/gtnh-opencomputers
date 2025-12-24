
local component = require('component')
local term = require('term')

local serialization = require('serialization')
local json = require('json')



local glasses = {}


local pd = {}


function pd.main()

    ---- Initialization
    --term.clear()
    --
    for address in component.list('glasses') do
        table.insert(glasses, component.proxy(component.get(address)))
    end


    print(json.encode(glasses))


    glassesTerminal = require("component").glasses
    print(json.encode(glassesTerminal.getBindPlayers()))

    --glassesTerminal.removeAll()
    --
    --print(json.encode(glassesTerminal))
    ----
    --
    --text = glassesTerminal.addTextLabel()
    --text.setText("Hello World!")
    --text.setPosition(100, 100)
    --
    --Widget_ItemIcon = glassesTerminal.addItem()
    --Widget_ItemIcon.setItem("gregtech:gt.blockmachines", 11)
    --Widget_ItemIcon.setPosition(100, 100)
    --
    --print(json.encode(Widget_ItemIcon))

    --Widget_ItemIcon.addTranslation(50, 50, 0) -- modifier #1
    --Widget_ItemIcon.addScale(40, 40, 40)        -- modifier #2
    --Widget_ItemIcon.addRotation(180, 1, 0, 0)   -- modifier #3


end

pd.main()

return pd
