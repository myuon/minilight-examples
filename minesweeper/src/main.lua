local minilight = require("minilight")
minilight.init()
math.randomseed(os.time())

local tileSize = 48
local width = 10
local height = 10

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
    local width = #bombArray
    local height = #bombArray[1]
    local neighbors = arrayWith(width, height, 0)

    for i = 1, width do
        for j = 1, height do
            local c = 0
            local ns = {
                {-1, -1}, {0, -1}, {1, -1}, {-1, 0}, {1, 0}, {-1, 1}, {0, 1},
                {1, 1}
            }

            for _, n in ipairs(ns) do
                local ix = n[1] + i
                local iy = n[2] + j

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

function onDraw()
    local figs = {}
    local pos = minilight.useMouseMove()
    local clicked = minilight.useMousePressed()
    local open = minilight.useState(arrayWith(width, height, false))
    local bombs = minilight.useState(spreadBombs(width, height, 10))
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
        open.value[ix][iy] = true
        open.write(open.value)
        openCount.write(openCount.value + 1)

        if bombs.value[ix][iy] then state.write("lose") end
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
