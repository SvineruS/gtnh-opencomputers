local component = require("component")
local json = require("json")
local serialization = require("serialization")
local text = require("text")

local me = component.me_interface


function main()
    local craftables = me.getCraftables()
    print("local STOCKING = {")
    for i, craftable in ipairs(craftables) do
        local item = craftable.getItemStack()
        process(item)
    end
    print("}")

end


function process(item)
    if item.name == "bartworks:gt.bwMetaGeneratedcell" or item.fluid_hasTag ~= nil then
        return nil
    end
    if item.fluidDrop ~= nil then
        print(string.format("\t{label=\"%s\", stock=%d, is_fluid=true, name=\"%s\", damage=%d},",
                string.gsub(item.fluidDrop.label, '"', "'"), item.fluidDrop.amount, item.fluidDrop.name, item.fluidDrop.damage or 0))

        --return {
        --    label = item.fluidDrop.label,
        --    is_fluid = true,
        --    name = item.name,
        --    damage = item.damage,
        --    stock = item.fluidDrop.amount,
        --}
        return
    end
    print(string.format("\t{label=\"%s\", stock=%d, name=\"%s\", damage=%d},",
            string.gsub(item.label, '"', "'"), item.maxSize, item.name, item.damage))
    --return {
    --    label = item.label,
    --    name = item.name,
    --    damage = item.damage,
    --    stock = item.maxSize,
    --}
end

main()
