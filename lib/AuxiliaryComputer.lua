---
--- Created by Willis
--- DateTime: 15/12/2021 11:35 pm
---

local UPDATED = "17/12/2021 8:44pm"
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
    --- Extracts edges from a CSV formatted string
    ---@param path string: The CSV formatted path string
    ---@param vertex number: The vertex associated with this
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

function run_with_screen(vertex, connections, vertex_name, screen, gpu)
    local NetworkCard = computer.getPCIDevices(findClass("NetworkCard"))[1]
    NetworkCard:open(00000)
    event.listen(NetworkCard)
    init(vertex, connections, vertex_name, NetworkCard)

    local w, h = screen:getSize()
    local scale = 1.25

    local panel_scale = 0.7

    gpu:setSize(math.floor(scale * w * 32), math.floor(scale * h * 15))
    w, h = gpu:getSize()
    print(w, h)

    local panel_width = math.floor(w * panel_scale)
    local panel_x_mid = math.floor((panel_width) / 2) + 2

    local up_button = Button("  ↑", panel_x_mid - w / 10, panel_x_mid + w / 10 + 1, 3, 4, { 0, 0.2, 0, 1 }, { 1, 1, 1, 1 })
    local down_button = Button("  ↓", panel_x_mid - w / 10, panel_x_mid + w / 10 + 1, h - 4, h - 3, { 0, 0.2, 0, 1 }, { 1, 1, 1, 1 })

    local current_dest_label = Button("Current Location", panel_width + 2, w - 3, 3, 4, { 0.05, 0.05, 0.5, 1 }, { 1, 1, 1, 1 })
    local current_dest_text = Button(vertex_name, panel_width + 2, w - 3, 4, 5, { 0, 0, 0, 1 }, { 1, 1, 1, 1 })

    local routing_info_label = Button("Route Info", panel_width + 2, w - 3, 6, 7, { 0.05, 0.05, 0.5, 1 }, { 1, 1, 1, 1 })
    local routing_from_label = Button("From", panel_width + 2, w - 3, 7, 8, { 0, 0, 0, 1 }, { 1, 0.6, 0.2, 1 })
    local routing_to_label = Button("To", panel_width + 2, w - 3, 9, 10, { 0, 0, 0, 1 }, { 1, 0.6, 0.2, 1 })

    local routing_from_text = Button(vertex_name, panel_width + 2, w - 3, 8, 9, { 0, 0, 0, 1 }, { 1, 1, 1, 1 })
    local routing_to_text = Button("", panel_width + 2, w - 3, 10, 11, { 0, 0, 0, 1 }, { 1, 1, 1, 1 })

    local route_button = Button("Compute Route", panel_width + 2, w - 3, 12, 15, { 0, 0.25, 0, 1 }, { 1, 1, 1, 1 })

    local page = PageScroller(5, panel_width + 1, 4, h - 4)

    local function refresh()
        gpu:setBackground(0, 0, 0, 1)
        gpu:fill(0, 0, w, h, " ")

        gpu:setBackground(0.1, 0.1, 0.1, 1)
        gpu:fill(2, 1, w - 4, h - 2, " ")

        gpu:setBackground(0, 0, 0, 1)
        gpu:fill(2 + 2, 1 + 1, panel_width - 4, h - 4, " ")

        gpu:setBackground(0, 4, 0, 1)

        up_button:draw(gpu)
        down_button:draw(gpu)
        current_dest_label:draw(gpu)
        current_dest_text:draw(gpu)

        routing_info_label:draw(gpu)
        routing_from_label:draw(gpu)
        routing_to_label:draw(gpu)

        routing_from_text:draw(gpu)
        routing_to_text:draw(gpu)

        route_button:draw(gpu)

        page:draw(gpu)
    end

    local function scroll_up(_, bool)
        if bool then
            page:scroll("vertical", 0, 2)
        end

    end

    local function scroll_down(_, bool)
        if bool then
            page:scroll("vertical", 0, -2)
        end
    end

    local function hover(button, bool)
        if bool then
            button:setForeground({ 0, 1, 0, 1 })
        else
            button:setForeground({ 1, 1, 1, 1 })
        end
    end

    local function select(button, bool)
        if bool then
            button:setBackground({ 0, 0.1, 0, 1 })
            routing_to_text:set_label(button:get_label())
        else
            button:setBackground({ 0, 0, 0, 1 })
        end
    end

    local function route(_, bool)
        if bool then
            NetworkCard:broadcast(00000, "generate_path", vertex, routing_to_text:get_label())
        end
    end

    local button_back = { 0, 0, 0, 1 }
    local button_fore = { 1, 1, 1, 1 }
    local OFFSET = 1

    page:draw(gpu)

    refresh()
    gpu:flush()
    --page:add_button("New Destination", 5, panel_width - 1, 4, 5, button_back, { 1, 1, 1, 1 })
    while true do
        local e, _, x, y, mode, data = event.pull()
        if e == "OnMouseDown" then
            print(x, y)
            up_button:execute(x, y, scroll_up)
            down_button:execute(x, y, scroll_down)
            page:execute(x, y, select, false)
            route_button:execute(x, y, route)
            --gpu:setText(x, y, " ")
        elseif e == "OnMouseMove" then
            page:execute(x, y, hover)


        elseif mode == "new_path" then
            local prev, after = extract_edges(data, vertex)
            local switches, switch
            local switched = {}

            for i=1, #connections do
                switches = component.findComponent(tostring(connections[i]))
                print(connections[i], prev, after)
                for j=1, #switches do
                    switch = component.proxy(switches[j])
                    if connections[i] == tonumber(prev) or connections[i] == tonumber(after) then
                        switch.isSwitchOn = true
                        switched[switches[j]] = true

                    elseif switched[switches[j]] == nil then
                        switch.isSwitchOn = false
                    end
                end
            end

        elseif mode == "auxiliary" and vertex_name ~= nil then
            if page:button_count() == 0 then
                page:add_button(data, 5, panel_width - 1, 4, 5, button_back, { 1, 1, 1, 1 })
            else
                page:add_button_sequential(data, 0, OFFSET, button_back, button_fore)
            end
            page:draw(gpu)
            print("Receiving data for new destinations")

        elseif mode == "update_software" then
            computer.reset()
            print("Updating Software")
        end
        refresh()
        gpu:flush()
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
            local switches, switch
            local switched = {}

            for i=1, #connections do
                switches = component.findComponent(tostring(connections[i]))
                print(connections[i], prev, after)
                for j=1, #switches do
                    switch = component.proxy(switches[j])
                    if connections[i] == tonumber(prev) or connections[i] == tonumber(after) then
                        switch.isSwitchOn = true
                        switched[switches[j]] = true

                    elseif switched[switches[j]] == nil then
                        switch.isSwitchOn = false
                    end
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


