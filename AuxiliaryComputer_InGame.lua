---
--- Created by Willis
--- DateTime: 14/12/2021 3:06 pm
---

local card = computer.getPCIDevices(findClass("FINInternetCard"))[1]

local VERTEX = nil
local CONNECTIONS = {}
local NAME = nil

local gpu = computer.getPCIDevices(findClass("GPUT1"))[1]
local screen = component.findComponent(findClass("Screen"))[1]


fs = filesystem

if fs.initFileSystem("/dev") == false then
    computer.panic("Cannot initialize /dev")
end

disk_uuid = fs.childs("/dev")[1]

fs.initFileSystem("/dev")
fs.makeFileSystem("tmpfs", "tmp")
fs.mount("/dev/"..disk_uuid,"/")

local req = card:request("https://raw.githubusercontent.com/WillaLR/Satisfactory_HypertubeNetwork/master/lib/auxiliary/AuxiliaryComputer.lua", "GET", "")
local _, libdata = req:await()

local file = fs.open("AuxiliaryComputer.lua", "w")
file:write(libdata)
file:close()
fs.doFile("AuxiliaryComputer.lua")

if screen and NAME then
    screen = component.proxy(screen)
    gpu:bindScreen(screen)
    event.listen(gpu)

    local req1 = card:request("https://raw.githubusercontent.com/WillaLR/Satisfactory_HypertubeNetwork/master/lib/auxiliary/Button.lua", "GET", "")
    local req2 = card:request("https://raw.githubusercontent.com/WillaLR/Satisfactory_HypertubeNetwork/master/lib/auxiliary/PageScroller.lua", "GET", "")
    local req3 = card:request("https://raw.githubusercontent.com/WillaLR/Satisfactory_HypertubeNetwork/master/lib/auxiliary/Boundary.lua", "GET", "")

    local _, libdata1 = req1:await()
    local _, libdata2 = req2:await()
    local _, libdata3 = req3:await()

    local file1 = fs.open("Button.lua", "w")
    file1:write(libdata1)
    file1:close()

    local file2 = fs.open("PageScroller.lua", "w")
    file2:write(libdata2)
    file2:close()

    local file3 = fs.open("Boundary.lua", "w")
    file3:write(libdata3)
    file3:close()

    fs.doFile("PageScroller.lua")
    fs.doFile("AuxiliaryComputer.lua")

    run_with_screen(VERTEX, CONNECTIONS, NAME, screen, gpu)
else
    run(VERTEX, CONNECTIONS, NAME)
end
