---
--- Created by Willis
--- DateTime: 14/12/2021 3:06 pm
---

local card = computer.getPCIDevices(findClass("FINInternetCard"))[1]

local VERTEX = nil
local CONNECTIONS = {}
local NAME = nil

fs = filesystem

if fs.initFileSystem("/dev") == false then
    computer.panic("Cannot initialize /dev")
end

disk_uuid = fs.childs("/dev")[1]

fs.initFileSystem("/dev")
fs.makeFileSystem("tmpfs", "tmp")
fs.mount("/dev/"..disk_uuid,"/")

local req = card:request("https://raw.githubusercontent.com/WillaLR/Satisfactory_HypertubeNetwork/master/AuxiliaryComputer.lua", "GET", "")
local _, libdata = req:await()

local file = fs.open("AuxiliaryComputer.lua", "w")
file:write(libdata)
file:close()

fs.doFile("AuxiliaryComputer.lua")

run(VERTEX, CONNECTIONS, NAME)