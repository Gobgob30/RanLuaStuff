local f = fs.open("Sea_of_the_Bass", "r")
local nodes = textutils.unserialise(f.readAll()) or {}
f.close()
local points_to_draw = {}

local function draw_spline_between(node, next_node, points_table)
    -- Todo: I want a to add a point every block in between.
    local distance = math.sqrt((node.x - next_node.x) ^ 2 + (node.y - next_node.y) ^ 2 + (node.z - next_node.z) ^ 2)

    -- Calculate the step size between each point
    local step_size = 1

    -- Calculate the number of points to add
    local num_points = math.floor(distance / step_size)

    -- Calculate the step vector
    local step_vector = {
        x = (next_node.x - node.x) / num_points,
        y = (next_node.y - node.y) / num_points,
        z = (next_node.z - node.z) / num_points,
    }
    -- Add the points to the points_table
    for i = 1, num_points do
        local point = {
            x = math.floor((node.x + step_vector.x * i) + .5),
            y = math.floor((node.y + step_vector.y * i) + .5),
            z = math.floor((node.z + step_vector.z * i) + .5),
        }
        table.insert(points_table, point)
    end
end

for i = 1, #nodes - 1 do
    local node = nodes[i]
    local next_node = nodes[i + 1]
    draw_spline_between(node, next_node, points_to_draw)
end
local cmds = {}
for i = 1, #points_to_draw - 1 do
    local point = points_to_draw[i]
    local next_point = points_to_draw[i + 1]
    table.insert(cmds, function()
        commands.tp("Sea_of_the_Bass", point.x, point.y + 10, point.z)
        commands.fill(point.x, point.y - 3, point.z, next_point.x, next_point.y + 13, next_point.z, "iron_bars")
    end)
end
require("run")(cmds, 128)
