---
--- Created by Willis
--- DateTime: 14/12/2021 2:59 pm
---
local UPDATED = "17/12/2021 10:19pm"
print("Initialising MainComputer.lua\nLast Update:"..UPDATED)

filesystem.doFile("AdjacencyMatrix.lua")

function run(size, debug, aux_screen)
    --- Main function to run the loop.
    ---
    local NetworkCard = computer.getPCIDevices(findClass("NetworkCard"))[1]

    local panel = component.proxy(component.findComponent("Panel")[1])
    local reset_button = panel:getModule(0,0)
    local update_software = panel:getModule(9,9)

    local hyper_network = AdjacencyMatrix(size, debug)
    local hyper_network_vertex_name = {}
    local hyper_network_name_vertex = {}
    local hyper_network_dest_vertices = {}
    local current_entrance = 1

    NetworkCard:open(00000)
    event.listen(NetworkCard)
    event.listen(reset_button)
    event.listen(update_software)
    event.clear()


    while true do
        local _, name, _, _, mode, data1, data2, data3, data4 = event.pull()
        if mode == "connect" then
            if data1 > hyper_network.size then
                hyper_network:add_vertex()
                hyper_network:add_vertex()
            end

            hyper_network:connect(data1, data2)
            print("Connecting: "..data1.." to "..data2)


        elseif mode == "assign_location" then
            hyper_network:assign_location(data1, {x=data2, y=data3, z=data4})
            print("Assigning Location: "..data1.." with x:"..data2.." y: "..data3.." z: "..data4)


        elseif mode == "assign_name" then
            hyper_network_vertex_name[data1] = data2
            if aux_screen then
                print("Aux screen")
                hyper_network_name_vertex[data2] = data1
                NetworkCard:broadcast(00000, "auxiliary", data2)
                print("Name to vertex")
                for i,k in ipairs(hyper_network_name_vertex) do
                    print(i,k)
                end
            end

            hyper_network_dest_vertices[#hyper_network_dest_vertices + 1] = data1
            print("Assigning Name: "..data1.. " with "..data2)


        elseif name == reset_button then
            hyper_network = AdjacencyMatrix(10, debug)
            hyper_network_vertex_name = {}
            hyper_network_dest_vertices = {}
            current_entrance = 0
            NetworkCard:broadcast(00000, "reset")
            print("Resetting Network")


        elseif mode == "generate_path" then
            local origin = data1
            local destination = hyper_network_dest_vertices[current_entrance]

            if aux_screen then
                destination = hyper_network_dest_vertices[hyper_network_name_vertex[data2]]
            end
            print(data2)
            for i,k in ipairs(hyper_network_vertex_name) do
                print(i,k)
            end
            print("Name to vertex")
            for i,k in ipairs(hyper_network_name_vertex) do
                print(i,k)
            end

            print("Generating Path: "..origin.."to"..destination)

            local path = hyper_network:generate_path(data1,hyper_network_dest_vertices[current_entrance])
            local path_string
            if #path ~= 0 then
                path_string = path[1]
                for i=2,#path do
                    path_string = path_string..","..path[i]
                end

            else
                path_string = "Failed"
            end

            print("Path: "..path_string)
            NetworkCard:broadcast(00000, "new_path", path_string)


        elseif (data1 == "button_left" or data1 == "button_right") and mode == "main" then
            if data1 == "button_left" then
                current_entrance = current_entrance - 1
                if current_entrance < 1 then
                    current_entrance = #hyper_network_dest_vertices
                end
            else
                current_entrance = current_entrance + 1
                if current_entrance > #hyper_network_dest_vertices then
                    current_entrance = 1
                end
            end
            print("Cycling Destination: ".. hyper_network_vertex_name[hyper_network_dest_vertices[current_entrance]])

            NetworkCard:broadcast(00000, "auxiliary", hyper_network_vertex_name[hyper_network_dest_vertices[current_entrance]])


        elseif name == update_software then
            print("Updating all auxiliary computers software and resetting")
            hyper_network = AdjacencyMatrix(10, debug)
            hyper_network_vertex_name = {}
            hyper_network_dest_vertices = {}
            current_entrance = 0
            NetworkCard:broadcast(00000, "update_software")
        end

    end

end
