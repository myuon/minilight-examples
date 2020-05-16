local minilight = require("minilight")
minilight.init()

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

function onDraw()
    local figs = {}
    local pos = minilight.useMouseMove()
    local clicked = minilight.useMousePressed()
    local open = minilight.useState(arrayWith(width, height, false))

    if (clicked) then
        local ix = pos[1] // tileSize
        local iy = pos[2] // tileSize
        open.value[ix][iy] = true
        open.write(open.value)
    end

    for i = 1, width do
        for j = 1, height do
            if (open.value[i][j]) then
                table.insert(figs,
                             minilight.translate(i * tileSize, j * tileSize,
                                                 minilight.text("○",
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
