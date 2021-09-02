local Lazer = require "Lazer"

function Player(num_lives, debugging)
    local SHIP_SIZE = 30
    local EXPLOAD_DUR = 3 -- how long the ship will expload (in seconds)
    local USABLE_BLINKS = 10 * 2 -- How many times the ship should blink before becoming vincible again (* 2 since it gets cut in half later)
    local LAZER_DISTANCE = 0.6 -- distance lazers can go before dissapearing (0.6 of screen width in this case)
    local MAX_LAZERS = 10 -- max amount of lazers on screen
    local VIEW_ANGLE = math.rad(90)

    debugging = debugging or false

    return {
        x = love.graphics.getWidth() / 2,
        y = love.graphics.getHeight() / 2,
        radius = SHIP_SIZE / 2,
        angle = VIEW_ANGLE, -- angle gets calculated as radian
        rotation = 0,
        expload_time = 0, -- if the ship crashed
        exploading = false,
        thrusting = false,
        invincible = true,
        invincible_seen = true,
        time_blinked = USABLE_BLINKS,
        lazers = {}, -- lazers x, y, x_velocity, y_velocity data
        thrust = {
            x = 0,
            y = 0,
            speed = 5,
            big_flame = false,
            flame = 2.0
        },
        lives = num_lives or 3,

        draw_flame_thrust = function (self, fillType, color)
            if self.invincible_seen then
                table.insert(color, 0.5)
            end
            love.graphics.setColor(color)

            love.graphics.polygon(
                fillType, -- flame outside ship
                -- the 4 / 3 and 2 / 3 is to find the center of the triangle correctly
                self.x - self.radius * (2 / 3 * math.cos(self.angle) + 0.5 * math.sin(self.angle)),
                self.y + self.radius * (2 / 3 * math.sin(self.angle) - 0.5 * math.cos(self.angle)),
                self.x - self.radius * self.thrust.flame * math.cos(self.angle),
                self.y + self.radius * self.thrust.flame * math.sin(self.angle),
                self.x - self.radius * (2 / 3 * math.cos(self.angle) - 0.5 * math.sin(self.angle)),
                self.y + self.radius * (2 / 3 * math.sin(self.angle) + 0.5 * math.cos(self.angle))
            )
        end,

        shootLazer = function (self)
            if (#self.lazers <= MAX_LAZERS) then
                -- lazer spawn from front of ship
                table.insert(self.lazers, Lazer(
                    self.x + ((4 / 3) * self.radius) * math.cos(self.angle),
                    self.y -  ((4 / 3) * self.radius) * math.sin(self.angle),
                    self.angle
                ))
            end
        end,

        destroyLazer = function (self, index)
            table.remove(self.lazers, index)
        end,
        
        draw = function (self)
            if not self.exploading then -- if the ship is not exploading
                if self.thrusting then
                    -- create flame resizing animation
                    if not self.thrust.big_flame then
                        self.thrust.flame = self.thrust.flame - 1 / love.timer.getFPS()
    
                        if self.thrust.flame < 1.5 then
                            self.thrust.big_flame = true
                        end
                    else
                        self.thrust.flame = self.thrust.flame + 1 / love.timer.getFPS()
    
                        if self.thrust.flame > 2.5 then
                            self.thrust.big_flame = false
                        end
                    end

                    self:draw_flame_thrust("fill", {255/255 ,102/255 ,25/255}) -- draw flame thrust
                    self:draw_flame_thrust("line", {1, 0.16, 0}) -- flame thrust outline
                end
                
                if debugging then
                    love.graphics.setColor(1, 0, 0)
    
                    love.graphics.rectangle( "fill", self.x - 1, self.y - 1, 2, 2 ) -- shows center of triangle
                    
                    love.graphics.circle("line", self.x, self.y, self.radius) -- the hitbox of the ship
                end
    
                if self.invincible_seen then
                    love.graphics.setColor(1, 1, 1, 0.5)
                else
                    love.graphics.setColor(1, 1, 1)
                end

                love.graphics.polygon(
                    "line", -- ship
                    -- the 4 / 3 and 2 / 3 is to find the center of the triangle correctly
                    self.x + ((4 / 3) * self.radius) * math.cos(self.angle),
                    self.y -  ((4 / 3) * self.radius) * math.sin(self.angle),
                    self.x - self.radius * (2 / 3 * math.cos(self.angle) + math.sin(self.angle)),
                    self.y + self.radius * (2 / 3 * math.sin(self.angle) - math.cos(self.angle)),
                    self.x - self.radius * (2 / 3 * math.cos(self.angle) - math.sin(self.angle)),
                    self.y + self.radius * (2 / 3 * math.sin(self.angle) + math.cos(self.angle))
                )

                -- draw lazers
                for _, lazer in pairs(self.lazers) do
                    lazer:draw()
                end
            else -- if the ship exploaded
                love.graphics.setColor(1, 0, 0)
                love.graphics.circle("fill", self.x, self.y, self.radius * 1.5)

                love.graphics.setColor(1, 158/255, 0)
                love.graphics.circle("fill", self.x, self.y, self.radius * 1)

                love.graphics.setColor(1, 234/255, 0)
                love.graphics.circle("fill", self.x, self.y, self.radius * 0.5)
            end
        end,

        drawLives = function (self)
            if self.lives == 2 then
                love.graphics.setColor(1, 1, 0.5, 1)
            elseif self.lives == 1 then
                love.graphics.setColor(1, 0.2, 0.2, 1)
            else
                love.graphics.setColor(1, 1, 1, 1)
            end
            
            local x_pos, y_pos = 45, 30
            for i = 1, self.lives do
                if self.exploading then
                    if i == self.lives then
                        love.graphics.setColor(1, 0, 0, 1)
                    end
                end

                love.graphics.polygon(
                    "line", -- ship
                    -- the 4 / 3 and 2 / 3 is to find the center of the triangle correctly
                    (i * x_pos) + ((4 / 3) * self.radius) * math.cos(VIEW_ANGLE), -- x location
                    y_pos -  ((4 / 3) * self.radius) * math.sin(VIEW_ANGLE), -- y location
                    (i * x_pos) - self.radius * (2 / 3 * math.cos(VIEW_ANGLE) + math.sin(VIEW_ANGLE)),
                    y_pos + self.radius * (2 / 3 * math.sin(VIEW_ANGLE) - math.cos(VIEW_ANGLE)),
                    (i * x_pos) - self.radius * (2 / 3 * math.cos(VIEW_ANGLE) - math.sin(VIEW_ANGLE)),
                    y_pos + self.radius * (2 / 3 * math.sin(VIEW_ANGLE) + math.cos(VIEW_ANGLE))
                )
            end
        end,

        movePlayer = function (self, dt)
            if self.invincible then
                self.time_blinked = self.time_blinked - dt * 2

                if math.ceil(self.time_blinked) % 2 == 0 then
                    self.invincible_seen = false
                else
                    self.invincible_seen = true
                end

                if self.time_blinked <= 0 then
                    self.invincible = false
                end
            else
                self.time_blinked = USABLE_BLINKS
                self.invincible_seen = false
            end

            self.exploading = self.expload_time > 0

            if not self.exploading then
                local FPS = love.timer.getFPS()
                local friction = 0.7 -- 0 = no friction

                -- basically turn 360 deg every second
                self.rotation = 360 / 180 * math.pi / FPS

                if love.keyboard.isDown("a") then -- rotate left
                    self.angle = self.angle + self.rotation
                end
                
                if love.keyboard.isDown("d") then -- rotate right
                    self.angle = self.angle - self.rotation
                end

                if self.thrusting then
                    self.thrust.x = self.thrust.x + self.thrust.speed * math.cos(self.angle) / FPS
                    self.thrust.y = self.thrust.y - self.thrust.speed * math.sin(self.angle) / FPS
                else
                    -- applies friction to stop the ship
                    if self.thrust.x ~= 0 or self.thrust.y ~= 0 then
                        self.thrust.x = self.thrust.x - friction * self.thrust.x / FPS
                        self.thrust.y = self.thrust.y - friction * self.thrust.y / FPS
                    end
                end

                self.x = self.x + self.thrust.x
                self.y = self.y + self.thrust.y

                -- make sure the ship can't go off screen
                if self.x + self.radius < 0 then
                    self.x = love.graphics.getWidth() + self.radius
                elseif self.x - self.radius > love.graphics.getWidth() then
                    self.x = -self.radius
                end

                if self.y + self.radius < 0 then
                    self.y = love.graphics.getHeight() + self.radius
                elseif self.y - self.radius > love.graphics.getHeight() then
                    self.y = -self.radius
                end
            end

            -- this will also move the lazer
            for index, lazer in pairs(self.lazers) do
                if (lazer.distance > LAZER_DISTANCE * love.graphics.getWidth()) and (lazer.exploading == 0) then
                    lazer:expload()
                   
                    -- ::continue:: -- * we don't need continue because lua handles the removal of items in an array for us with the pairs() loop
                end
                
                if lazer.exploading == 0 then -- 0 -> lazer not exploading
                    lazer:move()
                elseif lazer.exploading == 2 then -- 2 -> lazer is done exploading
                    self.destroyLazer(self, index)
                end
            end
        end,

        expload = function (self)
            self.expload_time = math.ceil(EXPLOAD_DUR * love.timer.getFPS())
        end
    }
end

return Player