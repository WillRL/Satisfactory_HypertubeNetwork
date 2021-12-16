--- Created by Willis.
--- DateTime: 16/12/2021 4:10pm
--- Class to represent Buttons



local UPDATED = "17/12/2021 12:26am"
print("Initialising Button.lua\nLast Update: "..UPDATED)

filesystem.doFile("Boundary.lua")

Button = {}
Button.__index = Button
setmetatable(Button, {__call = function(cls,...) return cls.new(...) end,})


function Button.new(label, xMin, xMax, yMin, yMax, colourInit)
    local self = setmetatable({}, Button)

    self.label = label
    self.colourInit = colourInit

    self.boundary = Boundary(xMin, xMax, yMin, yMax)
    return self
end


function Button:draw(gpu)
    local min_max = self.boundary:get_min_max()


    gpu:setBackground(self.colourInit[1], self.colourInit[2], self.colourInit[3], self.colourInit[4])
    gpu:fill(min_max.xMin, min_max.yMin, min_max.dX, min_max.dY, " ")

    local midX = math.ceil( (min_max.xMax - min_max.xMin-1)/2) + min_max.xMin
    local midY = math.floor((min_max.yMax - min_max.yMin-1)/2) + min_max.yMin

    local label_len = string.len(self.label)
    local label_mid = math.ceil(label_len/2)
    local label_start = midX-label_len+label_mid

    gpu:setText(label_start, midY, self.label)
end

function Button:setBackground(rgba)
    gpu:setBackground(rgba[1], rgba[2], rgba[3], rgba[4])
end


function Button:setForeground(rgba)
    gpu:setForeground(rgba[1], rgba[2], rgba[3], rgba[4])
end


function Button:get_min_max()
    return self.boundary:get_min_max()
end


function Button:execute(x,y, func1, func2)
    if(self.boundary:check(x,y, -1, -1)) then
        func1(self)
        return true
    else
        func2(self)
        return false
    end
end



function Button:move(dX, dY)
    self.boundary:move(dX, dY)
end

