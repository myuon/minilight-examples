local minilight = require("minilight")
minilight.init()
math.randomseed(os.time())

function onDraw()
    local figs = {}
    local counter = minilight.useState(0)
    local clicked = minilight.useMousePressed()
    table.insert(figs, minilight.text("Button Counter", {255, 128, 0, 0}))
    table.insert(figs, minilight.translate(50, 50,
                                           minilight.text(
                                               "You've clicked " ..
                                                   math.floor(counter.value) ..
                                                   " times!", {0, 0, 0, 0})))

    if (clicked) then counter.write(counter.value + 2) end

    return figs
end

_G.onDraw = onDraw
