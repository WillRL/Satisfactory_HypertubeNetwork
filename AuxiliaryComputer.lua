---
--- Created by Willis
--- DateTime: 14/12/2021 1:39 pm
---


function init(vertex, connections, name, location, NetworkCard)
    for i=1, #connections do
        NetworkCard:broadcast(00000, "connect", vertex, connections[i])
    end
    NetworkCard:broadcast(00000, "assign_location", vertex, location['x'], location['y'], location['z'])
    if name ~= nil then
        NetworkCard:broadcast(00000, "assign_name", vertex, name)
    end
end


function run(vertex, connections, vertex_name)
    local NetworkCard = computer.getPCIDevices(findClass("NetworkCard"))[1]
    local sign
    local panel
    local location = NetworkCard.Location

    if vertex_name ~= nil then
        sign = component.proxy(component.findComponent("Sign")[1])
        panel = component.proxy(component.findComponent("Panel")[1])
        button_left = panel:getModule(4, 10)
        button_right = panel:getModule(6, 10)
        generate_path = panel:getModule(5,5)
        button_left:setColor(0, 1, 0, 1)
        button_right:setColor(0, 1, 0, 1)
        event.listen(button_left)
        event.listen(button_right)
        event.listen(generate_path)
    end

    NetworkCard:open(00000)
    event.listen(NetworkCard)

    function extract_edges(path)
        counter = 0
        index = 0
        arr = {}
        for k in string.gmatch(path, '([^,]+)') do
            counter = counter + 1

            if tonumber(k) == vertex then
                index = counter
            end
            arr[counter] = k
        end
        if index ~= 0 then
            return arr[index-1], arr[index+1]
        end
    end



    init(vertex, connections, vertex_name, location, NetworkCard)


    while true do
        type, name, _, _, mode, data = event.pull()
        if mode == "reset" then
            print("Resetting Network")
            init(vertex, connections, vertex_name, location, NetworkCard)

        elseif mode == "new_path" then
            prev, after = extract_edges(data)

            if prev ~= nil or after ~= nil then
                if prev ~= nil then
                    switch = component.proxy(component.findComponent(tostring(prev))[1])
                    switch.isSwitchOn = true
                elseif after ~= nil then
                    switch = component.proxy(component.findComponent(tostring(after))[1])
                    switch.isSwitchOn = true
                end

            else
                for i=1, #connections do
                    switch = component.proxy(component.findComponent(tostring(connections[i]))[1])
                    switch.isSwitchOn = false
                end
            end


        elseif name == button_left then
            NetworkCard:broadcast(00000, "main", "button_left")
            print("Sending data: Button left")

        elseif name == button_right then
            NetworkCard:broadcast(00000, "main", "button_right")
            print("Sending data: Button Right")

        elseif name == generate_path then
            NetworkCard:broadcast(00000, "generate_path", vertex)
            print("Sending request to generate path")

        elseif mode == "auxiliary" and vertex_name ~= nil then
            prefab = sign:getPrefabSignData()
            prefab:setTextElement("Name", data)
            sign:setPrefabSignData(prefab)
            print("Receiving data for new destination: "..data)

        elseif mode == "update_software" then
            computer.reset()
            print("Updating Software")
        end
    end
end


