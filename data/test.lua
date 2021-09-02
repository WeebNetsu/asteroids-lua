--[[ 
    local lunajson = require 'lunajson'
    local jsonstr = '{"Hello":["lunajson",1.5]}'
    local t = lunajson.decode(jsonstr)
    print(t.Hello[2]) -- prints 1.5
    print(lunajson.encode(t)) -- prints {"Hello":["lunajson",1.5]}
 ]]
local lunajson = require 'lunajson'

local file = io.open("save.json", "r")
local json = file:read("*all")
file:close()

print(lunajson.decode(json)["high_score"])
