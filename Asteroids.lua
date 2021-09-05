require "globals"

function Asteroids(x, y, ast_size, level, sfx, debugging)
    debugging = debugging or false

    local ASTEROID_VERT = 10 -- average verticies... how many edges it will gave
    local ASTEROID_JAG = 0.4 -- asteroid jaggedness (less round)
    local ASTEROID_SPEED = math.random(50) + (level * 2)

    local vert = math.floor(math.random(ASTEROID_VERT + 1) + ASTEROID_VERT / 2)
    local offset = {}
    for i = 1, vert + 1 do
        -- NOTE: the math.random() * ASTEROID_JAG should be like that and NOT math.random(ASTEROID_JAG)
        -- because math.random returns an INTEGER and not a FLOAT (and we want a float)
        table.insert(offset, math.random() * ASTEROID_JAG * 2 + 1 - ASTEROID_JAG)
    end
    
    local v = -1
    if math.random() < 0.5 then
        v = 1
    end
    
    return {
        x = x,
        y = y,
        x_vel = math.random() * ASTEROID_SPEED * v,
        y_vel = math.random() * ASTEROID_SPEED * v,
        radius = math.ceil(ast_size / 2),
        angle = math.rad(math.random(math.pi)), -- angle in radians
        vert = vert, -- verticies
        offset = offset,

        draw = function (self)
            love.graphics.setColor(186 / 255, 189 / 255, 182 / 255)

            local points = {self.x + self.radius * self.offset[1] * math.cos(self.angle), self.y + self.radius * self.offset[1] * math.sin(self.angle)}

            for i = 1, self.vert - 1 do
                -- print(self.offset[i + 1])
                table.insert(points, self.x + self.radius * self.offset[i + 1] * math.cos(self.angle + i * math.pi * 2 / self.vert))
                table.insert(points, self.y + self.radius * self.offset[i + 1] * math.sin(self.angle + i * math.pi * 2 / self.vert))
            end

            love.graphics.polygon(
                "line",
                points
            )

            if debugging then
                love.graphics.setColor(1, 0, 0)
                
                love.graphics.circle("line", self.x, self.y, self.radius) -- the hitbox of the asteroid
            end
        end,

        move = function (self, dt)
            self.x = self.x + self.x_vel * dt
            self.y = self.y + self.y_vel * dt

            -- Make sure the asteroid doesn't leave the screen
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
        end,

        destroy = function (self, asteroids_tbl, index, game)
            local MIN_ASTEROID_SIZE = math.ceil(ASTEROID_SIZE / 8)
        
            -- split asteroid if it's still bigger than the min size
            if self.radius > MIN_ASTEROID_SIZE then
                -- size will automatically half, since radius is / 2 when converted to new radius
                table.insert(asteroids_tbl,  Asteroids(self.x, self.y, self.radius, game.level, sfx))
                table.insert(asteroids_tbl,  Asteroids(self.x, self.y, self.radius, game.level, sfx))
            end
        
            if self.radius >= ASTEROID_SIZE / 2 then -- large asteroid
                game.score = game.score + 20
            elseif self.radius <= MIN_ASTEROID_SIZE then -- small asteroid
                game.score = game.score + 100
            else -- medium asteroid
                game.score = game.score + 50
            end

            if game.score > game.high_score then
                game.high_score = game.score
            end
        
            sfx:playFX("asteroid_explosion")
            table.remove(asteroids_tbl, index) -- remove ourself
        end
    }
end

return Asteroids