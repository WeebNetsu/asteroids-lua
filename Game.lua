require "globals"

local Asteroids = require "Asteroids"
local Text = require "Text"

function Game(save_data)
    return {
        level = 1,
        state = {
            menu = true,
            paused = false,
            running = false,
            ended = false
        },
        score = 0,
        high_score = save_data.high_score or 0,
        screen_text = {},

        saveGame = function (self)
            writeJSON("save", {
                high_score = self.high_score
            })
        end,

        gameOver = function (self)
            self.screen_text = {Text(
                "GAME OVER",
                0,
                love.graphics.getHeight() * 0.4,
                "h1",
                true,
                true,
                love.graphics.getWidth(),
                "center"
            )}

            self:saveGame()
        end,

        changeGameState = function (self, state)
            self.state.menu = state == "menu"
            self.state.paused = state == "paused"
            self.state.running = state == "running"
            self.state.ended = state == "ended"

            if state == "ended" then
               self:gameOver()
            end
        end,

        draw = function (self) 
            for index, text in pairs(self.screen_text) do
                text:draw(self.screen_text, index)
            end

            -- Text that should always be on screen
            Text(
                "SCORE: " .. self.score,
                -20,
                10,
                "h4",
                false,
                false,
                love.graphics.getWidth(),
                "right",
                0.6
            ):draw()

            Text(
                "HIGH SCORE: " .. self.high_score,
                0,
                10,
                "h5",
                false,
                false,
                love.graphics.getWidth(),
                "center",
                0.5
            ):draw()
        end,

        startNewGame = function (self, player)
            if player.lives <= 0 then
                self:changeGameState("ended")
                return
            else
                -- TODO: Make below work, self isn't responding
                -- TODO: You can try to move Menu.lua to main.lua
                self:changeGameState("running")
            end
        
            local num_asteroids = 0
            asteroids = {}
            self.screen_text = {Text(
                "Level " .. self.level,
                0,
                love.graphics.getHeight() * 0.25,
                "h1",
                true,
                true,
                love.graphics.getWidth(),
                "center"
            ),
            }
        
            for i = 1, num_asteroids + self.level do
                local as_x
                local as_y
        
                repeat
                    as_x = math.floor(math.random(love.graphics.getWidth()))
                    as_y = math.floor(math.random(love.graphics.getHeight()))
                until calculateDistance(player.x, player.y, as_x, as_y) > ASTEROID_SIZE * 2 + player.radius -- make sure asteroids doesn't appear on player
        
                table.insert(asteroids, i, Asteroids(as_x, as_y, ASTEROID_SIZE, self.level, show_debugging))
            end
        end
    }
end

return Game