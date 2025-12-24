
function isBee(table)
    return table.individual
end
function isNatural(table)
    return table.individual.isNatural
end
function isAnalyzed(table)
    return table.individual.isAnalyzed
end
function isDrone(table)
    return string.find(table.label, "Drone")
end
function isPrincess(table)
    return string.find(table.label, "Princess")
end
function isQueen(table)
    return string.find(table.label, "Queen")
end
function isPure(table)
    return table.individual.isAnalyzed and table.individual.active.species == table.individual.inactive.species
end
function isUnpure(table)
    return table.individual.isAnalyzed and table.individual.active.species ~= table.individual.inactive.species
end
function isSpecie(table, specie)
    return string.lower(specie) == string.lower(table.individual.displayName)
end
function isAl1(table, specie)
    return string.lower(specie) == string.lower(table.individual.active.species)
end
function isAl2(table, specie)
    return string.lower(specie) == string.lower(table.individual.inactive.species)
end

function isAlx(table, specie)
    return string.lower(specie) == string.lower(table.individual.active.species) or string.lower(specie) == string.lower(table.individual.inactive.species)
end
function isPureSpec(table, specie)
    return string.lower(specie) == string.lower(table.individual.active.species) and string.lower(specie) == string.lower(table.individual.inactive.species)
end

function isVanilla(table)
    return isSpecie(table, "meadows") or isSpecie(table, "forest")
end
function canFind(string1, string2)
    return string.find(string1, string2)
end


function isType(table, type)
    -- "drone" or "princess" or "queen"
    if string.lower(type) == "drone" then
        return isDrone(table)
    elseif string.lower(type) == "princess" then
        return isPrincess(table)
    elseif string.lower(type) == "queen" then
        return isQueen(table)
    else
        io.write("isType() - incorrect argument " .. tostring(type) .. " \n")
    end
end

function isPurity(table, purity)
    if string.lower(purity) == "pure" then
        return isPure(table)
    elseif string.lower(purity) == "unpure" then
        return isUnpure(table)
    else
        io.write("isPurity() - incorrect argument " .. tostring(purity) .. " \n")
    end
end



function isStrong(spec)
    return GET("pure", "princess", spec) >= const.strongPrincessCount and GET("pure", "drone", spec) >= const.strongCount
end
