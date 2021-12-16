--- Created by Willis.
--- DateTime: 16/12/2021 4:10pm
--- Class to represent Buttons


local UPDATED = "16/12/2021 9:40pm"
print("Initialising Button.lua\nLast Update: "..UPDATED)

Button = {}
Button.__index = Button
setmetatable(Button, {__call = function(cls,...) return cls.new(...) end,})

function Button.new(label, xMax, xMin, yMax, yMin, colourInit, func)
    local self = setmetatable({}, Button)

    self.label = label

    self.xMax = xMax
    self.yMax = yMax
    self.xMin = xMin
    self.yMin = yMin

    self.dX = xMax - xMin
    self.dY = yMax - yMin

    self.colourInit = colourInit
    self.func = func
    return self
end

function Button:draw(gpu)
    gpu:setBackground(self.colourInit[1], self.colourInit[2], self.colourInit[3], self.colourInit[4])
    gpu:fill(self.xMin, self.yMin, self.dX, self.dY, " ")

    local midX = math.ceil( (self.xMax - self.xMin-1)/2) + self.xMin
    local midY = math.floor((self.yMax - self.yMin-1)/2) + self.yMin

    local label_len = string.len(self.label)
    local label_mid = math.ceil(label_len/2)
    local label_start = midX-label_len+label_mid

    gpu:setText(label_start, midY, self.label)
end

function Button:check(x,y)
    if(x >= self.xMin and x <= (self.xMax - 1)) and (y >= self.yMin and y <= (self.yMax - 1)) then
        return true
    else
        return false
    end
end


function Button:click(x,y)
    print(self:check(x,y))
    if(self:check(x,y)) then
        self.func(self)
        return true
    end
    return false
end

