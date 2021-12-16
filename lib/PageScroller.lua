---
--- Created by Will.
--- DateTime: 16/12/2021 9:57 pm
---
---

local UPDATED = "16/12/2021 11:07pm"
print("Initialising PageScroller.lua\nLast Update: "..UPDATED)

filesystem.doFile("Boundary.lua")
filesystem.doFile("Button.lua")

PageScroller = {}
PageScroller.__index = PageScroller
setmetatable(PageScroller, {__call = function(cls,...) return cls.new(...) end,})


function PageScroller.new(xMin, xMax, yMin, yMax)
    local self = setmetatable({}, PageScroller)

    self.boundary = Boundary(xMin, xMax, yMin, yMax)
    self.buttons = {}

    return self
end

function PageScroller:add_button(label, xMin, xMax, yMin, yMax, colourInit, func)
    local new_button = Button(label, xMin, xMax, yMin, yMax, colourInit, func)
    table.insert(self.buttons, new_button)
end

function PageScroller:add_button_sequential(dX, dY, colourInit, func)
    local min_max = self.buttons[#self.buttons]
    local new_button = Button(label, min_max.xMin + dX, min_max.dX, min_max.yMin + dY, min_max.yMax + dY, colourInit, func)
    table.insert(self.buttons, new_button)
end

function PageScroller:scroll(dX, dY)
    dX = dX or 0
    dY = dY or 0

    if self.check(self.buttons[1]) then
        dX = 0
    end

    if self.check(self.buttons[#self.buttons]) then
        dY = 0
    end

    for i=1, #self.buttons do
        self.buttons[i].move(dX, dY)
    end
end

function PageScroller:draw(gpu)
    for i=1, #self.buttons do
        local button = self.buttons[i]
        if self:check(button) then
            button:draw(gpu)
        end
    end
end


function PageScroller:check(button)
    local min_max = button:get_min_max()
    if self.boundary:check(min_max.xMin, min_max.yMin) and self.boundary:check(min_max.xMax, min_max.yMax) then
        return true
    else
        return false
    end
end