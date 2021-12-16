--- Created by Willis.
--- DateTime: 16/12/2021 4:10pm
--- Class to represent Buttons



local UPDATED = "17/12/2021 1:47am"
print("Initialising Button.lua\nLast Update: "..UPDATED)

filesystem.doFile("Boundary.lua")

Button = {}
Button.__index = Button
setmetatable(Button, {__call = function(cls,...) return cls.new(...) end,})


function Button.new(label, xMin, xMax, yMin, yMax, colourBack, colourFore, secondary_colourBack, secondary_colourFore)
    local self = setmetatable({}, Button)

    self.label = label
    self.secondary_colourBack = secondary_colourBack
    self.secondary_colourFore = secondary_colourFore
    self.clicked = false
    self.colourBack = colourBack
    self.colourFore = colourFore

    self.boundary = Boundary(xMin, xMax, yMin, yMax)
    return self
end


function Button:setBackground(rgba)
    self.colourBack = rgba
end

function Button:setForeground(rgba)
    self.colourFore = rgba
end


function Button:draw(gpu)
    local min_max = self.boundary:get_min_max()

    if self.clicked then
        gpu:setBackground(self.secondary_colourBack[1], self.secondary_colourBack[2], self.secondary_colourBack[3], self.secondary_colourBack[4])
        gpu:setForeground(self.secondary_colourFore[1], self.secondary_colourFore[2], self.secondary_colourFore[3], self.secondary_colourFore[4])
    else
        gpu:setBackground(self.colourBack[1], self.colourBack[2], self.colourBack[3], self.colourBack[4])
        gpu:setForeground(self.colourFore[1], self.colourFore[2], self.colourFore[3], self.colourFore[4])
    end

    gpu:fill(min_max.xMin, min_max.yMin, min_max.dX, min_max.dY, " ")

    local midX = math.ceil( (min_max.xMax - min_max.xMin-1)/2) + min_max.xMin
    local midY = math.floor((min_max.yMax - min_max.yMin-1)/2) + min_max.yMin

    local label_len = string.len(self.label)
    local label_mid = math.ceil(label_len/2)
    local label_start = midX-label_len+label_mid

    gpu:setText(label_start, midY, self.label)
    end


function Button:get_min_max()
    return self.boundary:get_min_max()
end

function Button:clicked()
    return self.clicked
end

function Button:set_clicked(bool)
    self.clicked = bool
end

function Button:execute(x,y, toggle, func)
    if(self.boundary:check(x,y, -1, -1)) then
        func(self, true)
        if toggle then
            self.clicked = not self.clicked
        end
        return true
    else
        func(self, false)
        return false
    end
end


function Button:move(dX, dY)
    self.boundary:move(dX, dY)
end

