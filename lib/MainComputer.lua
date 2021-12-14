---
--- Created by Willis
--- DateTime: 14/12/2021 2:59 pm
---


filesystem.doFile("AdjacencyMatrix.lua")

function run()
    local NetworkCard = computer.getPCIDevices(findClass("NetworkCard"))[1]
    NetworkCard:open(00000)

    panel = component.proxy(component.findComponent("Panel")[1])
    reset_button = panel:getModule(0,0)
    generate_path = panel:getModule(3,0)
    update_software = panel:getModule(9,9)

    event.listen(NetworkCard)
    event.listen(reset_button)
    event.listen(generate_path)
    event.listen(update_software)
    event.clear()

    hyper_network = AdjacencyMatrix:new(nil, 10)
    hyper_network_names = {}
    hyper_network_dest_vertices = {}
    current_entrance = 1
    while true do
        type, name, _, _, mode, data1, data2, data3, data4 = event.pull()
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
            hyper_network_names[data1] = data2
            hyper_network_dest_vertices[#hyper_network_dest_vertices + 1] = data1
            print("Assigning vertex "..data1.." name: "..data2)


        elseif name == reset_button then
            hyper_network = AdjacencyMatrix:new(nil, 10)
            hyper_network_names = {}
            hyper_network_dest_vertices = {}
            current_entrance = 0
            NetworkCard:broadcast(00000, "reset")
            print("Resetting Network")


        elseif mode == "generate_path" then
            print("Genearting Path")
            print(data1)
            print(hyper_network_dest_vertices[current_entrance])
            path = hyper_network:generate_path(data1,hyper_network_dest_vertices[current_entrance])
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
            print("Cycling Destination: "..hyper_network_names[hyper_network_dest_vertices[current_entrance]])

            NetworkCard:broadcast(00000, "auxiliary", hyper_network_names[hyper_network_dest_vertices[current_entrance]])


        elseif name == update_software then
            print("Updating all auxiliary computer softwares")
            NetworkCard:broadcast(00000, "update_software")
        end

    end

end
