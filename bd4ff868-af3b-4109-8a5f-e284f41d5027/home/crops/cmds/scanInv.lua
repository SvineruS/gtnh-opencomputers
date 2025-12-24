local serialization = require('serialization')
local scanner = require('scanner')


local seed = scanner.scanInv(1)
print(serialization.serialize(seed))
print(scanner.isTargetCrop(seed))
