local robot = require('robot')
local config = require('config')
local math = require('math')
local sides = require('sides')

local nowFacing = sides.north
local nowPos = { -1, 0 }

--local function slotToPos(d)
--    local r = math.floor(math.sqrt(d))
--    local m = d - r * r
--
--    if r == 0 then
--        return 0, 0
--    end
--
--    if r % 2 == 0 then
--        -- Counter-clockwise
--        if m <= r then
--            return r, m
--        else
--            return 2 * r - m, r
--        end
--    else
--        -- Clockwise
--        if m <= r then
--            return m, r
--        else
--            return r, 2 * r - m
--        end
--    end
--end
--
--local function posToSlot(x, y)
--    local r = math.max(x, y)
--    local m
--
--    if r % 2 == 1 then
--        -- Counter-clockwise
--        if y == r then
--            m = x
--        else
--            m = 2 * r - y
--        end
--    else
--        -- Clockwise
--        if x == r then
--            m = y
--        else
--            m = 2 * r - x
--        end
--    end
--
--    return r * r + m
--end

local function slotToPos(index)
    local row = math.floor(index / config.width)
    local col = index % config.width

    if row % 2 == 1 then
        col = config.width - 1 - col
    end

    return col, row
end

local function posToSlot(col, row)
    if row % 2 == 1 then
        col = config.width - 1 - col
    end
    return row * config.width + col
end

local function getFacing()
    return nowFacing
end

local function getPos()
    return nowPos
end

local function getPos1d()
    return posToSlot(nowPos[1], nowPos[2])
end


local function isParent()
    return (nowPos[1] % 2) == (nowPos[2] % 2)
end

local function turnTo(facing)
    if facing == sides.north and nowFacing == sides.west then
        robot.turnLeft()
        nowFacing = sides.north
    elseif facing == sides.west and nowFacing == sides.north then
        robot.turnRight()
        nowFacing = sides.west
    else
        print("Invalid turn: " .. nowFacing .. " -> " .. facing)
    end
end

local function moveDir(dir)
    local success
    repeat
        if dir > 0 then
            success = robot.forward()
        else
            success = robot.back()
        end
    until success
end

local function moveAxis(axis, target)
    while target > nowPos[axis] do
        moveDir(1)
        nowPos[axis] = nowPos[axis] + 1
    end
    while target < nowPos[axis] do
        moveDir(-1)
        nowPos[axis] = nowPos[axis] - 1
    end
end

local function go(target)
    print("GO TO " .. target[1] .. ", " .. target[2]    )
    if nowPos[1] == target[1] and nowPos[2] == target[2] then
        return
    end

    if not (nowFacing == sides.north or nowFacing == sides.west) then
        print("Invalid facing: " .. nowFacing)
    elseif (nowFacing == sides.north) then
        moveAxis(1, target[1])
        if nowPos[2] ~= target[2] then
            turnTo(sides.west)
            moveAxis(2, target[2])
        end
    elseif (nowFacing == sides.west) then
        moveAxis(2, target[2])
        if nowPos[1] ~= target[1] then
            turnTo(sides.north)
            moveAxis(1, target[1])
        end
    end

end

local function go1d(target)
    x, y = slotToPos(target)
    go({ x, y })
end

local function down(distance)
    if distance == nil then
        distance = 1
    end
    for _ = 1, distance do
        robot.down()
    end
end

local function up(distance)
    if distance == nil then
        distance = 1
    end
    for _ = 1, distance do
        robot.up()
    end
end

return {
    workingSlotToPos = slotToPos,
    getFacing = getFacing,
    getPos = getPos,
    getPos1d = getPos1d,
    isParent = isParent,
    go = go,
    go1d = go1d,
    down = down,
    up = up
}
