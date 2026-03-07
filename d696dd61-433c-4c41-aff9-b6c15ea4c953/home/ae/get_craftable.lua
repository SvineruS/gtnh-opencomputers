local component = require("component")
local json = require("json")
local serialization = require("serialization")
local text = require("text")

package.loaded["stock"] = nil
local STOCKING = require("stock")

local me = component.me_interface




function main()

    local oldCraftables = {}
    for i, craftable in ipairs(STOCKING) do
        oldCraftables[id(craftable)] = craftable.stock
    end


    local craftables = me.getCraftables()
    print("local STOCKING = {")
    for i, craftable in ipairs(craftables) do
        local item = craftable.getItemStack()
        process(item, oldCraftables)
    end
    print("}")
    print("return STOCKING")

end


function process(item, oldCraftables)
    if item.name == "bartworks:gt.bwMetaGeneratedcell" or item.fluid_hasTag ~= nil then
        return nil
    end
    local struct = nil;

    if item.fluidDrop ~= nil then
        return nil
        --struct = {
        --    label = item.fluidDrop.label,
        --    stock = item.fluidDrop.amount,
        --    is_fluid = true,
        --    name = item.fluidDrop.name,
        --    damage = item.fluidDrop.damage or 0
        --}
    else
        struct = {
            label = item.label,
            stock = item.maxSize,
            name = item.name,
            damage = item.damage or 0
        }
    end

    local id_ = id(item)
    if oldCraftables[id_] ~= nil then
        struct.stock = oldCraftables[id_]
    end

    local s = serialization.serialize(struct)
    s = string.format("\t%s,", s)

    if oldCraftables[id_] == nil then
        s = " -- " .. s
    end

    print(s);
end


function id(item)
    return item.name .. "/" .. item.damage
end


main()
