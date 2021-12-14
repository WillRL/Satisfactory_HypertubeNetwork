--- Created by Willis.
--- DateTime: 11/12/2021 11:39 pm
--- Class to represent Adjacency Matrix
local UPDATED = "14/12/2021 4:22pm"
print("Initialising AdjacencyMatrix.lua\nLast Update:"..UPDATED)

filesystem.doFile("PriorityQueue.lua")

AdjacencyMatrix = {size}



local min_comparator = function(a, b)
    return b < a
end

function AdjacencyMatrix:new(o, n, debug)
    --- Constructor for Adjacency matrix
    ---@param n number: The size (n by n) of the matrix
    o = {} or o
    setmetatable(o, self)
    self.__index = self
    self.size = n
    self.mapping = {}
    self.__debug = debug

    matrix = {}
    for i=1,n do
        matrix[i] = {}
        for j=1,n do
            matrix[i][j] = 0
        end
    end

    self.__adjacency_matrix = matrix
    return o
end

function AdjacencyMatrix:add_vertex()
    --- Adds a new vertex with a given weight
    self.size = self.size + 1

    self.__adjacency_matrix[self.size] = {}

    for i=1, self.size do
        self.__adjacency_matrix[i][self.size] = 0
        self.__adjacency_matrix[self.size][i] = 0
    end


    return self.size
end

function AdjacencyMatrix:connect(vert1, vert2, directed)
    --- Connect two vertices with an edge
    ---@param vert1 number: The first vertex
    ---@param vert2 number: The second vertex

    assert(AdjacencyMatrix:check_exist(vert1) and AdjacencyMatrix:check_exist(vert2), "One of the vertices do not exist")
    self.__adjacency_matrix[vert1][vert2] = 1
    if not directed then
        self.__adjacency_matrix[vert2][vert1] = 1
    end
end

function AdjacencyMatrix:assign_location(vert, location)
    --- Assigns a location to the vertex
    ---@param vert number: value of the vertex
    ---@param location table: Table representation of x,y,z coordinates.
    self.mapping[vert] = location
end

function AdjacencyMatrix:get_neighbours(vert)
    --- Get the weight between two vertices
    ---@param vert number: The vertex
    ---@return {vertex number, weight number}: Table with vertex-weight as key-value pair.
    neighbours = {}
    counter = 1
    for i, value in ipairs(self.__adjacency_matrix[vert]) do
        if value == 1 then
            neighbours[counter] = i
            counter = counter + 1
        end
    end

    return neighbours
end

function AdjacencyMatrix:check_exist(vert)
    --- Checks if a vertex exists
    ---@param vert number: The vertex in question

    return self.__adjacency_matrix[vert] ~= nil
end

function AdjacencyMatrix:euclidean_dist(vert1, vert2)
    --- Calculates the euclidean distance between two vertices
    ---@param vert1 number: The first vertex
    ---@param vert2 number: The second vertex
    ---@return number: The euclidean distance
    if self.__debug then
        print(vert1)
        print(vert2)
    end

    vert1 = self.mapping[vert1]
    vert2 = self.mapping[vert2]
    if self.__debug then
        print(vert1)
        print(vert2)
    end
    return math.sqrt((vert1["x"] + vert2["x"])^2+(vert1["y"] + vert2["y"])^2+(vert1["z"] + vert2["z"])^2)
end

function AdjacencyMatrix:generate_path(origin, target)
    --- Generates the shortest path to connect origin and target.
    ---@param origin number: The origin vertex
    ---@param target number: The end target vertex
    ---@return table: The vertices that connect origin to target (In reverse order)

    local previousNodes = AdjacencyMatrix:A_star(origin, target)
    local path = {target}
    local current = target
    while previousNodes[current] ~= nil do
        current = previousNodes[current]
        path[#path + 1] = current
    end
    return path

end

function AdjacencyMatrix:A_star(start, goal)
    --- Implements A* algorithm by use of pseudocode (https://en.wikipedia.org/wiki/A*_search_algorithm#Implementation_details)
    ---@param start number: The starting vertex
    ---@param goal number: The final destination
    ---@return table: A list that keeps track of all the previous nodes visited.

    local openSet = PriorityQueue.new(min_comparator)

    local previousNodes = {}
    local gScore = {}
    local fScore = {}
    setmetatable(gScore, {__index = function () return math.huge end})
    setmetatable(fScore, {__index = function () return math.huge end})

    gScore[start] = 0
    fScore[start] = AdjacencyMatrix:euclidean_dist(start, goal)

    openSet:Add(start, fScore[start])

    while openSet:Size() ~= 0 do
        local current = openSet:Pop()
        if current == goal then
            return previousNodes
        end

        local neighbours = AdjacencyMatrix:get_neighbours(current)

        for _, neighbour in ipairs(neighbours) do
            local tentative_gScore = gScore[current] + AdjacencyMatrix:euclidean_dist(current, neighbour)
            if tentative_gScore < gScore[neighbour] then
                previousNodes[neighbour] = current
                gScore[neighbour] = tentative_gScore
                fScore[neighbour] = tentative_gScore + AdjacencyMatrix:euclidean_dist(neighbour, goal)
                if not openSet:contains(neighbour) then
                    openSet:Add(neighbour, fScore[neighbour])
                end
            end
        end

    end
    return previousNodes
end

function AdjacencyMatrix:print()
    --- Prints the matrix out nicely
    local spacer = "  "
    local col_header_format = "     "
    for i = 1, AdjacencyMatrix.size do
        col_header_format = col_header_format..i..spacer
    end
    print(col_header_format)

    for row in pairs(self.__adjacency_matrix) do
        local row_format = spacer
        row_format = row_format..row..spacer
        for _, value in ipairs(self.__adjacency_matrix[row]) do
            row_format = row_format..value..spacer
        end
        print(row_format)
    end
end




