local lunajson = require 'lunajson'

ASTEROID_SIZE = 100
show_debugging = false
destroy_ast = false -- this is so the level doesn't increase when the player crashes into the last asteroid and has 0 lives left
clickedMouse = false

function calculateDistance(x1, y1, x2, y2)
    return math.sqrt(((x2 - x1) ^ 2) + ((y2 - y1) ^ 2))
end

--[[ 
    DESCRIPTION
    Read a json file and return the contents as a lua table. This function will automatically search inside the data/ folder and add a '.json' to the file name.

    PARAMETERS
    -> file_name: string - name of file to read (required)
        example: "save"
        description: Will search for 'data/save.json'
 ]]
function readJSON(file_name)
    local file = io.open("data/" .. file_name .. ".json", "r")
    local data = file:read("*all")
    file:close()

    return lunajson.decode(data)
end

--[[ 
    DESCRIPTION
    Convert a table to JSON and save it in a file. This will overwrite the file if it already exists. This function will automatically search inside the data/ folder and add a '.json' to the file name.

    PARAMETERS
    -> file_name: string - name of file to write to (required)
        example: "save"
        NB: Will search for 'data/save.json'
    -> data: table - table to be converted to JSON and saved. (required)
        example: { name = "max" }
 ]]
function writeJSON(file_name, data)
    print(lunajson.encode(data))
    local file = io.open("data/" .. file_name .. ".json", "w")
    file:write(lunajson.encode(data))
    file:close()
end