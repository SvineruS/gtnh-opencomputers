local component = require('component')
local serialization = require("serialization")


print(serialization.serialize(component.list("me_interface")))
print(serialization.serialize(component.list("me_exportbus")))
