---
--- Created by Will.
--- DateTime: 16/12/2021 9:57 pm
---
---

local UPDATED = "18/12/2021 6:01pm"
print("Initialising PageScroller.lua\nLast Update: "..UPDATED)

filesystem.doFile("Button.lua")

PageScroller = {}
PageScroller.__index = PageScroller
setmetatable(PageScroller, {__call = function(cls,...) return cls.new(...) end,})


function PageScroller.new(xMin, xMax, yMin, yMax)
    local self = setmetatable({}, PageScroller)

    self.boundary = Boundary(xMin, xMax, yMin, yMax)
    self.buttons = {}
    self.drawn_buttons = {}

    return self
end

function PageScroller:add_button(label, xMin, xMax, yMin, yMax, colourBack, colourFore)
    local new_button = Button(label, xMin, xMax, yMin, yMax, colourBack, colourFore)
    table.insert(self.buttons, new_button)
end

function PageScroller:add_button_sequential(label, dX, dY, colourBack, colourFore)
    local min_max = self.buttons[#self.buttons]:get_min_max()
    local new_button = Button(label, min_max.xMin + dX, min_max.xMax + dX, min_max.yMin + dY, min_max.yMax + dY, colourBack, colourFore)
    table.insert(self.buttons, new_button)
end

function PageScroller:button_count()
    return #self.buttons
end

function PageScroller:scroll(mode ,dX, dY)
    dX = dX or 0
    dY = dY or 0


    if mode == "vertical" then
        if self:check(self.buttons[1]) and dY > 0 then
            print("Unable to scroll")
            dY = 0
        end

        if self:check(self.buttons[#self.buttons]) and dY < 0 then
            print("Unable to scroll")
            dY = 0
        end
    elseif mode == "horizontal" then
        if self:check(self.buttons[1]) and dX > 0 then
            dX = 0
        end

        if self:check(self.buttons[#self.buttons]) and dX < 0 then
            dX = 0
        end
    end
    if #self.buttons ~= 0 then
        for i=1, #self.buttons do
            self.buttons[i]:move(dX, dY)
        end
    end
end

function PageScroller:draw(gpu)
    self.drawn_buttons = {}
    for i=1, #self.buttons do
        local button = self.buttons[i]
        if self:check(button) then
            table.insert(self.drawn_buttons, button)
            button:draw(gpu)
        end
    end
end


function PageScroller:check(button)
    local min_max = button:get_min_max()
    return self.boundary:check(min_max.xMin, min_max.yMin) and self.boundary:check(min_max.xMax, min_max.yMax)
end


function PageScroller:execute(x,y, func, iterate_all)
    local buttons
    iterate_all = false or iterate_all
    if iterate_all then
        buttons = self.buttons
    else
        buttons = self.drawn_buttons
    end

    for i=1, #buttons do
        if self.boundary:check(x,y, 0, -1) then
            buttons[i]:execute(x, y, func)
        else
            func(button[i], false)
        end
    end
end

