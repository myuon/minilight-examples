local minilight = require("minilight")
minilight.init()
math.randomseed(os.time())

local tileSize = 36
local width = 10
local height = 10
local bombCount = 10

function arrayWith(x, y, val)
    local arr = {}
    for i = 1, x do
        arr[i] = {}
        for j = 1, y do arr[i][j] = val end
    end

    return arr
end

function spreadBombs(x, y, count)
    local arr = arrayWith(x, y, false)

    local c = 0
    while c <= count do
        local px = math.floor(math.random() * x) % x + 1
        local py = math.floor(math.random() * y) % y + 1

        arr[px][py] = true
        c = c + 1
    end

    return arr
end

function calcNeighbors(bombArray)
    local size = sizeOf2DArray(bombArray)
    local width = size[1]
    local height = size[2]
    local neighbors = arrayWith(width, height, 0)

    for i = 1, width do
        for j = 1, height do
            local c = 0
            for _, n in ipairs(neighborOf(i, j)) do
                local ix = n[1]
                local iy = n[2]

                if 1 <= ix and ix <= width and 1 <= iy and iy <= height then
                    if bombArray[ix][iy] then c = c + 1 end
                end
            end

            neighbors[i][j] = c
        end
    end

    return neighbors
end

function print2DArray(arr)
    local s = ""

    for i, arr1 in ipairs(arr) do
        if i ~= 1 then s = s .. "\n" end
        s = s .. "["

        for j, v in ipairs(arr1) do
            if j ~= 1 then s = s .. "," end

            s = s .. string.format("%s", v)
        end

        s = s .. "]"
    end

    print(s)
end

function sizeOf2DArray(arr) return {#arr, #arr[1]} end

function neighborOf(x, y)
    local ns = {
        {-1, -1}, {0, -1}, {1, -1}, {-1, 0}, {1, 0}, {-1, 1}, {0, 1}, {1, 1}
    }
    local results = {}

    for _, n in ipairs(ns) do
        local ix = n[1] + x
        local iy = n[2] + y

        table.insert(results, {ix, iy})
    end

    return results
end

function contains(arr, val)
    for _, a in ipairs(arr) do
        if a[1] == val[1] and a[2] == val[2] then return true end
    end

    return false
end

function openChain(target, openState, neighborArr)
    local toOpen = {target}
    local history = {target}
    local size = sizeOf2DArray(neighborArr)
    local count = 0

    while #toOpen > 0 do
        h = table.remove(toOpen, 1)

        if neighborArr[h[1]][h[2]] == 0 then
            for _, pos in ipairs(neighborOf(h[1], h[2])) do
                if 1 <= pos[1] and pos[1] <= size[1] and 1 <= pos[2] and pos[2] <=
                    size[2] and not contains(history, pos) then
                    table.insert(toOpen, pos)
                    table.insert(history, pos)
                end
            end
        end
        openState.value[h[1]][h[2]] = true
        openState.write(openState.value)
        count = count + 1
    end

    return count
end

function onDraw()
    local figs = {}
    local pos = minilight.useMouseMove()
    local clicked = minilight.useMousePressed()
    local open = minilight.useState(arrayWith(width, height, false))
    local bombs = minilight.useState(spreadBombs(width, height, bombCount))
    local neighbors = minilight.useState(calcNeighbors(bombs.value))
    local openCount = minilight.useState(0)
    local state = minilight.useState("running")

    if (state.value == "win") then
        table.insert(figs, minilight.text("YOU WIN!!", {0, 0, 0, 0}))

        return figs
    elseif (state.value == "lose") then
        table.insert(figs, minilight.text("YOU LOSE!!", {0, 0, 0, 0}))

        return figs
    end

    if (clicked) then
        local ix = pos[1] // tileSize
        local iy = pos[2] // tileSize
        if 1 <= ix and ix <= width and 1 <= iy and iy <= height then
            if bombs.value[ix][iy] then
                state.write("lose")
            else
                local count = openChain({ix, iy}, open, neighbors.value)
                openCount.write(openCount.value + count)

                if openCount.value == width * height - bombCount then
                    state.write("win")
                end
            end
        end
    end

    for i = 1, width do
        for j = 1, height do
            if (open.value[i][j]) then
                table.insert(figs,
                             minilight.translate(i * tileSize, j * tileSize,
                                                 minilight.text(
                                                     math.floor(
                                                         neighbors.value[i][j]),
                                                     {0, 0, 0, 0})))
            else
                table.insert(figs,
                             minilight.translate(i * tileSize, j * tileSize,
                                                 minilight.text("■",
                                                                {0, 0, 0, 0})))
            end
        end
    end

    return figs
end

_G.onDraw = onDraw
