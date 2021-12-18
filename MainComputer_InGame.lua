---
--- Created by Willis
--- DateTime: 14/12/2021 3:05 pm
---

local AUX_SCREEN = false
local SIZE = 20

local card = computer.getPCIDevices(findClass("FINInternetCard"))[1]
fs = filesystem

if fs.initFileSystem("/dev") == false then
    computer.panic("Cannot initialize /dev")
end

disk_uuid = fs.childs("/dev")[1]

fs.initFileSystem("/dev")
fs.makeFileSystem("tmpfs", "tmp")
fs.mount("/dev/"..disk_uuid,"/")

local req1 = card:request("https://raw.githubusercontent.com/WillaLR/Satisfactory_HypertubeNetwork/master/lib/main/AdjacencyMatrix.lua", "GET", "")
local req2 = card:request("https://raw.githubusercontent.com/WillaLR/Satisfactory_HypertubeNetwork/master/lib/main/PriorityQueue.lua", "GET", "")
local req3 = card:request("https://raw.githubusercontent.com/WillaLR/Satisfactory_HypertubeNetwork/master/lib/main/MainComputer.lua", "GET", "")

local _, libdata1 = req1:await()
local _, libdata2 = req2:await()
local _, libdata3 = req3:await()

local file1 = fs.open("AdjacencyMatrix.lua", "w")
file1:write(libdata1)
file1:close()

local file2 = fs.open("PriorityQueue.lua", "w")
file2:write(libdata2)
file2:close()

local file3 = fs.open("MainComputer.lua", "w")
file3:write(libdata3)
file3:close()


fs.doFile("MainComputer.lua")
run(SIZE, false, AUX_SCREEN)
