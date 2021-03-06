---
--- Created by Will.
--- DateTime: 16/12/2021 10:12 pm
--- Class to represent a boundary.
---

local UPDATED = "17/12/2021 12:21am"
print("Initialising Boundary.lua\nLast Update: "..UPDATED)

Boundary = {}
Boundary.__index = Boundary
setmetatable(Boundary, {__call = function(cls,...) return cls.new(...) end,})

function Boundary.new(xMin, xMax, yMin, yMax)
    local self = setmetatable({}, Boundary)
    self.label = label

    self.xMax = xMax
    self.yMax = yMax
    self.xMin = xMin
    self.yMin = yMin

    self.dX = xMax - xMin
    self.dY = yMax - yMin
    return self
end

function Boundary:move(dX, dY)
    self.xMax = self.xMax + dX
    self.xMin = self.xMin + dX

    self.yMax = self.yMax + dY
    self.yMin = self.yMin + dY
end

function Boundary:check(x,y, offsetX, offsetY)
    offsetX = offsetX or 0
    offsetY = offsetY or 0
    if(x >= self.xMin and x <= (self.xMax + offsetX)) and (y >= self.yMin and y <= (self.yMax + offsetY)) then
        return true
    else
        return false
    end
end

function Boundary:get_min_max()
    return {xMin=self.xMin, xMax = self.xMax, yMin = self.yMin, yMax = self.yMax, dX = self.dX, dY = self.dY}
end
