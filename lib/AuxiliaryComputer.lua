---
--- Created by Willis
--- DateTime: 14/12/2021 1:39 pm
---

local UPDATED = "14/12/2021 3:30pm"
print("Initialising AuxiliaryComputer.lua\nLast Update:"..UPDATED)

local function init(vertex, connections, name, NetworkCard)
    --- Initial function to initialise.
    ---@param vertex number: The vertex this aux computer represents
    ---@param connections table: Table of connections this vertex connects to
    ---@param name string: The name of this vertex
    ---@param location table: x,y,z coordinates
    ---

    local location = NetworkCard.Location
    for i=1, #connections do
        NetworkCard:broadcast(00000, "connect", vertex, connections[i])
    end
    NetworkCard:broadcast(00000, "assign_location", vertex, location['x'], location['y'], location['z'])
    if name ~= nil then
        NetworkCard:broadcast(00000, "assign_name", vertex, name)
    end
end

local function extract_edges(path, vertex)
    --- Extracts edges from a CSV
    ---@param path string: The CSV formatted path string
    ---
    local counter = 0
    local index = 0
    local arr = {}
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


function run(vertex, connections, vertex_name)
    --- Initial function to initialise.
    ---@param vertex number: The vertex this aux computer represents
    ---@param connections table: Table of connections this vertex connects to
    ---@param vertex_name string: The name of this vertex
    ---
    local NetworkCard = computer.getPCIDevices(findClass("NetworkCard"))[1]
    local sign
    local panel
    local button_left
    local button_right
    local generate_path

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

    init(vertex, connections, vertex_name, NetworkCard)


    while true do
        local _, name, _, _, mode, data = event.pull()
        if mode == "reset" then
            print("Resetting Network")
            init(vertex, connections, vertex_name, NetworkCard)

        elseif mode == "new_path" then
            local prev, after = extract_edges(data, vertex)
            local switch
            if prev ~= nil or after ~= nil then
                if prev ~= nil then
                    print(prev, after)
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
            local prefab = sign:getPrefabSignData()
            prefab:setTextElement("Name", data)
            sign:setPrefabSignData(prefab)
            print("Receiving data for new destination: "..data)

        elseif mode == "update_software" then
            computer.reset()
            print("Updating Software")
        end
    end
end


