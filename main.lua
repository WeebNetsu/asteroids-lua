-- sudo luarocks install lunajson
require "globals"

local Player = require "Player"
local Game = require "Game"
local Menu = require "Menu"
local SFX = require "SFX"

math.randomseed(os.time()) -- randomize game

function love.load()
    love.mouse.setVisible(false)
    local save_data = readJSON("save")
    
    sfx = SFX()
    player = Player(3, sfx, show_debugging)
    game = Game(save_data, sfx)
    menu = Menu(game, player, sfx)
    
    sfx.playBGM()
end

-- KEYBINDINGS --

function love.keypressed(key)
    if game.state.running then
        if key == "w" or key == "up" or key == "kp8" then
            player.thrusting = true
        end

        if key == "space" or key == "down" or key == "kp5" then
            player:shootLazer()
        end

        if key == "escape" then
            game:changeGameState("paused")
        end
    elseif game.state.paused then
        if key == "escape" then
            game:changeGameState("running")
        end
    end
end

function love.keyreleased(key)
    if key == "w" or key == "up" or key == "kp8" then
        player.thrusting = false
    end
end

function love.mousepressed(x, y, button, istouch, presses)
    if button == 1 then
        if game.state.running then
            player:shootLazer()
        else
            clickedMouse = true
        end
    end
end

-- KEYBINDINGS --
mouse_x, mouse_y = 0, 0
function love.update(dt)
    mouse_x, mouse_y = love.mouse.getPosition()
    if game.state.running then
        player:movePlayer(dt)

        for ast_index, asteroid in pairs(asteroids) do
            -- if the player is not exploading and not invincible
            if not player.exploading and not player.invincible then
                if calculateDistance(player.x, player.y, asteroid.x, asteroid.y) < player.radius + asteroid.radius then
                    -- check if ship and asteroid colided
                    player:expload()
                    destroy_ast = true
                end
            else
                player.expload_time = player.expload_time - 1
    
                if player.expload_time == 0 then
                    if player.lives - 1 <= 0 then
                        game:changeGameState("ended")
                        return
                    end
                    player = Player(player.lives - 1, sfx, show_debugging)
                end
            end
    
            for _, lazer in pairs(player.lazers) do
                if calculateDistance(lazer.x, lazer.y, asteroid.x, asteroid.y) < asteroid.radius then
                    lazer:expload() -- delete lazer
                    asteroid:destroy(asteroids, ast_index, game)
                end
            end

            if destroy_ast then
                if player.lives - 1 <= 0 then
                    if player.expload_time == 0 then
                        -- wait for player to finish exploading before destroying any asteroids
                        destroy_ast = false
                        asteroid:destroy(asteroids, ast_index, game) -- delete asteroid and split into more asteroids
                    end
                else
                    destroy_ast = false
                    asteroid:destroy(asteroids, ast_index, game) -- delete asteroid and split into more asteroids
                end
            end

            asteroid:move(dt)
        end

        if #asteroids == 0 then
            game.level = game.level + 1
            game:startNewGame(player)
        end
    elseif game.state.menu then
        menu:run(clickedMouse)
        clickedMouse = false
    elseif game.state.paused then
        
    end
end

function love.draw()
    -- believe me, this if statement solves a ton of issues
    if game.state.running or game.state.paused then
        player:drawLives(game.state.paused)
        player:draw(game.state.paused)

        for _, asteroid in pairs(asteroids) do
            asteroid:draw(game.state.paused)
        end

        game:draw(game.state.paused)
    elseif game.state.menu then
        menu:draw()
    elseif game.state.ended then
        game:draw()
    end

    love.graphics.setColor(1, 1, 1, 1)
    
    if not game.state.running then
        love.graphics.circle("fill", mouse_x, mouse_y, 10)
    end

    love.graphics.print(love.timer.getFPS(), 10, 10)
end