player = {
    x = 400, y = 300,
    speed = 200,
    images = {},
    currentFrame = 1,
    frameTimer = 0,
    frameSpeed = 0.1,
    moving = false,
    direction = "right",
    health = 3,
    maxHealth = 3,
    damage = 1,
    isDead = false,
    deathTimer = 0,
    invulnerableTime = 0,
    comboHits = 0,
    comboDamage = 1,
    comboTimer = 0,
    shadowsPlaced = 0,
    maxShadows = 3,
    shadowCooldown = 0.3,
    shadowTimer = 0,
    coinsCollected = 0,
    hasDamagedEnemy = false,
    godMode = false,
    baseSpeed = 200,
    baseDamage = 1,
    pickupMessage = "",
    pickupMessageTimer = 0,
    hasCloak = false,
    canDash = true,
    dashCooldown = 10,
    dashCooldownTimer = 0,
    isDashing = false,
    dashDuration = 0.3,
    dashTimer = 0,
    dashSpeed = 600,







}

particles = {
    shadowBursts = {},
    glowTrail = {}
}

function resetGame()
    player.isDead = false
    player.health = 3
    player.maxHealth = 3
    player.coinsCollected = 0
    player.damage = player.baseDamage
    player.speed = player.baseSpeed
    player.comboHits = 0
    player.comboDamage = 1
    player.comboTimer = 0
    player.shadowsPlaced = 0
    player.shadowTimer = 0
    player.hasCloak = false
    player.canDash = true
    player.isDashing = false
    player.dashCooldownTimer = 0
    player.dashTimer = 0
    player.godMode = false
    player.invulnerableTime = 0
    player.pickupMessage = ""
    player.pickupMessageTimer = 0
    player.hasDamagedEnemy = false

    currentRoom = 1
    generateRooms(5)
    loadBossFrames()
    enterNextRoom()

    gameOverTimer = 0
    fadeAlpha = 0
    gameOverDelay = 5.0


end



shurikens = {}
shurikenSpeed = 600
shurikenCooldown = 0.3
shurikenTimer = 0
shurikenRotationSpeed = 10

enemies = {}
enemySightRadius = 400
enemySpeed = 100
enemyFrames = {}
enemyFrameCount = 4
enemyScale = 0.2
enemyDeathImage = nil
playerDeathImage = nil

backgroundImage = nil
doorImage = nil
currentRoom = 1

triggerZone = {
    x = 1220,
    y = 340,
    width = 5,
    height = 10
}

coins = {}

rooms = {}

shopItems = {}

bossFrames = {}

gameState = "start"
gameOverDelay = 1.0
gameOverTimer = 0
fadeAlpha = 0
itemFloatTimer = 0



function loadBossRoom()
shadowZones = {}
enemies = {}
coins = {}
shopItems = {}

boss = {
    x = 640,
    y = 360,
    width = 256,
    height = 256,
    speed = 120,
    health = 300,
    maxHealth = 300,
    phase = "chase",
    timer = 3,
    shootCooldown = 2,
    projectileSpeed = 300,
    projectiles = {},
    isDead = false,
    deathTimer = 0,

    frame = 1,
    frameTimer = 0,
    frameDuration = 0.15,
    direction = "left"
}

backgroundImage = love.graphics.newImage("images/bossarena.png")
player.x = 100
player.y = 300
end

function spawnShadowBurst(x, y)
    for i = 1, 15 do
        table.insert(particles.shadowBursts, {
            x = x,
            y = y,
            dx = math.cos(math.rad(i * 24)) * love.math.random(40, 80),
            dy = math.sin(math.rad(i * 24)) * love.math.random(40, 80),
            alpha = 1,
            life = 0.5
        })
    end
end


function loadShopRoom()
shadowZones = {}
enemies = {}

shopItems = {
    {
        x = 400, y = 300,
        cost = 5,
        collected = false,
        label = "sharp",
        image = love.graphics.newImage("images/sharp.png")
    },
    {
        x = 600, y = 300,
        cost = 10,
        collected = false,
        label = "potion",
        image = love.graphics.newImage("images/potion.png")
    },
    {
        x = 800, y = 300,
        cost = 15,
        collected = false,
        label = "boots",
        image = love.graphics.newImage("images/boots.png")
    }
}

if not player.hasDamagedEnemy then
    table.insert(shopItems, {
        x = 600, y = 400,
        cost = 0,
        collected = false,
        label = "cloak",
        image = love.graphics.newImage("images/cloak.png")
    })
end

player.x = 100
player.y = 300
end



function generateRooms(numRooms)
    for i = 1, numRooms do
        local room = {
            doorX = 1160, doorY = 260,
            shadows = {},
            enemies = {}
        }

        local numShadows = love.math.random(2, 4)
        for s = 1, numShadows do
            table.insert(room.shadows, {
                x = love.math.random(150, 1100),
                y = love.math.random(100, 600),
                radius = love.math.random(60, 120)
            })
        end

        local numEnemies = love.math.random(1, 3)
        local maxTries = 20
        
        for e = 1, numEnemies do
            local placed = false
            local tries = 0
            while not placed and tries < maxTries do
                local ex = love.math.random(900, 1180)
                local ey = love.math.random(150, 550)
                local inShadow = false
        
                for _, shadow in ipairs(room.shadows) do
                    local dx = ex - shadow.x
                    local dy = ey - shadow.y
                    if math.sqrt(dx * dx + dy * dy) < shadow.radius then
                        inShadow = true
                        break
                    end
                end
        
                if not inShadow then
                    table.insert(room.enemies, {
                        x = ex, y = ey,
                        health = 40 + love.math.random(0, 20),
                        speed = 160
                    })
                    placed = true
                end
        
                tries = tries + 1
            end
        end

        rooms[i] = room
    end
end

function loadBossFrames()
bossFrames = {}
for i = 1, 4 do
    bossFrames[i] = love.graphics.newImage("images/boss" .. i .. ".png")
end
end




shadowZones = {}

door = { x = 1160, y = 260, width = 64, height = 64, spawned = false }

function isPlayerInShadow()
    for _, shadow in ipairs(shadowZones) do
        local dx = (player.x + 16) - shadow.x
        local dy = (player.y + 16) - shadow.y
        local distance = math.sqrt(dx * dx + dy * dy)
        if distance < shadow.radius then
            return true
        end
    end
    return false
end

function checkDoorCollision()
if boss and boss.health > 0 then return false end

local pw = player.images[player.currentFrame]:getWidth()
local ph = player.images[player.currentFrame]:getHeight()
return player.x + pw > triggerZone.x and
       player.x < triggerZone.x + triggerZone.width and
       player.y + ph > triggerZone.y and
       player.y < triggerZone.y + triggerZone.height
end


function enterNextRoom()
currentRoom = currentRoom + 1

if currentRoom == 6 then
    loadShopRoom()
    return
elseif currentRoom == 7 then
    loadBossRoom()
    return
end

if not rooms[currentRoom] then
    currentRoom = 5
    return
end

    
    local room = rooms[currentRoom]
    door.x = room.doorX
    door.y = room.doorY
    shadowZones = room.shadows
    enemies = {}
    for _, e in ipairs(room.enemies or {}) do
        table.insert(enemies, {
            x = e.x, y = e.y,
            spawnX = e.x, spawnY = e.y,
            health = e.health,
            maxHealth = e.health,
            currentFrame = 1,
            frameTimer = 0,
            frameSpeed = 0.15,
            direction = "right",
            isDead = false,
            deathTimer = 0,
            timeSinceHit = 0,
            wanderTimer = 0,
            wanderTarget = {x = e.x, y = e.y},
            lastSeenPlayer = 0,
            chasing = false,
            speed = e.speed
        })
    end
    player.shadowsPlaced = 0
    player.shadowTimer = 0
    player.x = 100
    player.shadowsPlaced = 0
    player.y = 300
end

function love.load()
    generateRooms(5)
    love.graphics.setBackgroundColor(0.1, 0.1, 0.1)
    backgroundImage = love.graphics.newImage("images/background.png")
    doorImage = love.graphics.newImage("images/door.png")
    shurikenImage = love.graphics.newImage("images/shuriken.png")
    coinImage = love.graphics.newImage("images/coin.png")
    bossImage = love.graphics.newImage("images/boss.png")
    startScreenImage = love.graphics.newImage("images/title_screen.png")

sounds = {
    music = love.audio.newSource("sounds/music.wav", "stream"),
    shoot = love.audio.newSource("sounds/shoot.wav", "static"),
    enemyDie = love.audio.newSource("sounds/enemy_die.wav", "static"),
    pickup = love.audio.newSource("sounds/pickup.wav", "static"),
    hurt = love.audio.newSource("sounds/hurt.wav", "static")
}

sounds.music:setLooping(true)
sounds.music:setVolume(0.5)
sounds.music:play()




    for i = 1, 5 do
        player.images[i] = love.graphics.newImage("images/" .. i .. ".png")
    end
    for i = 1, 4 do
        enemyFrames[i] = love.graphics.newImage("images/skeleton" .. i .. ".png")
    end

    playerDeathImage = love.graphics.newImage("images/playerdeath.png")
    enemyDeathImage = love.graphics.newImage("images/skeletondeath.png")
    loadBossFrames()

    local room = rooms[currentRoom]
    door.x = room.doorX
    door.y = room.doorY
    shadowZones = room.shadows

    for _, e in ipairs(room.enemies or {}) do
        table.insert(enemies, {
            x = e.x, y = e.y,
            spawnX = e.x, spawnY = e.y,
            health = e.health,
            maxHealth = e.health,
            currentFrame = 1,
            frameTimer = 0,
            frameSpeed = 0.15,
            direction = "right",
            isDead = false,
            deathTimer = 0,
            timeSinceHit = 0,
            wanderTimer = 0,
            wanderTarget = {x = e.x, y = e.y},
            lastSeenPlayer = 0,
            chasing = false,
            speed = e.speed
    
        })
    end

end

function love.update(dt)
if gameState ~= "playing" then return end
itemFloatTimer = itemFloatTimer + dt
if player.isDead then
    player.deathTimer = player.deathTimer + dt
    gameOverTimer = gameOverTimer + dt

    
    fadeAlpha = math.min(1, gameOverTimer / gameOverDelay)

    
    if gameOverTimer >= gameOverDelay then
        gameState = "gameover"
    end

    return
end




player.moving = false
player.hidden = isPlayerInShadow()
player.alpha = player.invulnerableTime > 0 and (0.5 + 0.5 * math.sin(love.timer.getTime() * 20)) or (player.hidden and 0.2 or 1.0)

if player.invulnerableTime > 0 then
    player.invulnerableTime = player.invulnerableTime - dt
end

if shurikenTimer > 0 then
    shurikenTimer = shurikenTimer - dt
end

if player.isDashing then
    player.dashTimer = player.dashTimer - dt
    local dashDir = player.direction == "left" and -1 or 1
    player.x = player.x + dashDir * player.dashSpeed * dt

    if player.dashTimer <= 0 then
        player.isDashing = false
        player.dashCooldownTimer = player.dashCooldown
    end
elseif not player.canDash then
    player.dashCooldownTimer = player.dashCooldownTimer - dt
    if player.dashCooldownTimer <= 0 then
        player.canDash = true
    end
end


if love.keyboard.isDown("space") and not player.isDead and not player.hidden then
    if player.shadowsPlaced < player.maxShadows then
        player.shadowTimer = player.shadowTimer - dt
        if player.shadowTimer <= 0 then
            local newShadow = {
                x = player.x + player.images[player.currentFrame]:getWidth() / 2,
                y = player.y + player.images[player.currentFrame]:getHeight() / 2,
                radius = 50
            }
            table.insert(shadowZones, newShadow)
            player.shadowsPlaced = player.shadowsPlaced + 1
            player.shadowTimer = player.shadowCooldown
        end
    end
else
    player.shadowTimer = 0
end


if player.comboHits > 0 then
    player.comboTimer = player.comboTimer - dt
    if player.comboTimer <= 0 then
        player.comboHits = 0
        player.comboDamage = 1
    end
end

if love.keyboard.isDown("w") and player.y > 50 then
    player.y = player.y - player.speed * dt
    player.moving = true
end
if love.keyboard.isDown("s") and player.y + player.images[player.currentFrame]:getHeight() + 80 < love.graphics.getHeight() then
    player.y = player.y + player.speed * dt
    player.moving = true
end
if love.keyboard.isDown("a") and player.x > 80 then
    player.x = player.x - player.speed * dt
    player.moving = true
    player.direction = "left"
end
local playerRight = player.x + player.images[player.currentFrame]:getWidth()
local playerBottom = player.y + player.images[player.currentFrame]:getHeight()
local overlapsY = playerBottom > triggerZone.y and player.y < triggerZone.y + triggerZone.height
local hitRightWall = playerRight + 80 >= love.graphics.getWidth()
local canMoveRight = not hitRightWall or overlapsY
if love.keyboard.isDown("d") and canMoveRight then
    player.x = player.x + player.speed * dt
    player.moving = true
    player.direction = "right"
end

if player.moving then
    player.frameTimer = player.frameTimer + dt
    if player.frameTimer >= player.frameSpeed then
        player.frameTimer = 0
        player.currentFrame = (player.currentFrame % #player.images) + 1
    end
else
    player.currentFrame = 1
end

for i = #shurikens, 1, -1 do
    local s = shurikens[i]
    s.x = s.x + s.dx * dt
    s.y = s.y + s.dy * dt
    s.rotation = s.rotation + shurikenRotationSpeed * dt
    if s.x < 0 or s.x > love.graphics.getWidth() or s.y < 0 or s.y > love.graphics.getHeight() then
        table.remove(shurikens, i)
    end
end


for i = #enemies, 1, -1 do
    local e = enemies[i]
    if e.isDead then
        e.deathTimer = e.deathTimer + dt
        if e.deathTimer > 0.5 then table.remove(enemies, i) end
    else
        e.timeSinceHit = e.timeSinceHit + dt
        if e.timeSinceHit > 3 and e.health < e.maxHealth then
            e.health = math.min(e.health + 3.0 * dt, e.maxHealth)
        end

        local dx = player.x - e.x
        local dy = player.y - e.y
        local dist = math.sqrt(dx * dx + dy * dy)
        local canSeePlayer = dist < enemySightRadius and not player.hidden

        if canSeePlayer then
            e.lastSeenPlayer = 0
            e.chasing = true
        else
        e.lastSeenPlayer = e.lastSeenPlayer + dt
        if e.lastSeenPlayer > 0.3 then 
            e.chasing = false
        end
    end
        

        if e.chasing then
            local nx, ny = dx / dist, dy / dist
            local nextX = e.x + nx * e.speed * dt
            local nextY = e.y + ny * e.speed * dt
            local inShadow = false
            for _, shadow in ipairs(shadowZones) do
                local dxs = (nextX + 16) - shadow.x
                local dys = (nextY + 16) - shadow.y
                if math.sqrt(dxs * dxs + dys * dys) < shadow.radius then
                    inShadow = true
                    break
                end
            end
            if not inShadow then
                e.x = nextX
                e.y = nextY
            end
            e.direction = (dx < 0) and "left" or "right"
            e.frameTimer = e.frameTimer + dt
            if e.frameTimer >= e.frameSpeed then
                e.frameTimer = 0
                e.currentFrame = (e.currentFrame % enemyFrameCount) + 1
            end
        else
            e.wanderTimer = e.wanderTimer - dt
            if e.wanderTimer <= 0 then
                local angle = math.random() * 2 * math.pi
                local radius = 50
                e.wanderTarget.x = e.spawnX + math.cos(angle) * radius
                e.wanderTarget.y = e.spawnY + math.sin(angle) * radius
                e.wanderTimer = 2 + math.random() * 2
            end

            local dxW = e.wanderTarget.x - e.x
            local dyW = e.wanderTarget.y - e.y
            local distToTarget = math.sqrt(dxW * dxW + dyW * dyW)
            if distToTarget > 5 then
                local nx, ny = dxW / distToTarget, dyW / distToTarget
                local nextX = e.x + nx * (e.speed / 2) * dt
                local nextY = e.y + ny * (e.speed / 2) * dt
                local inShadow = false
                for _, shadow in ipairs(shadowZones) do
                    local dxs = (nextX + 16) - shadow.x
                    local dys = (nextY + 16) - shadow.y
                    if math.sqrt(dxs * dxs + dys * dys) < shadow.radius then
                        inShadow = true
                        break
                    end
                end
                if not inShadow then
                    e.x = nextX
                    e.y = nextY
                end
                e.direction = (nx < 0) and "left" or "right"
                e.frameTimer = e.frameTimer + dt
                if e.frameTimer >= e.frameSpeed then
                    e.frameTimer = 0
                    e.currentFrame = (e.currentFrame % enemyFrameCount) + 1
                end
            else
                e.currentFrame = 1
            end
        end

        local pw = player.images[player.currentFrame]:getWidth()
        local ph = player.images[player.currentFrame]:getHeight()
        if math.abs(player.x - e.x) < pw / 2 and math.abs(player.y - e.y) < ph / 2 then
            if player.invulnerableTime <= 0 then
                player.health = player.health - 1
                sounds.hurt:play()
                player.invulnerableTime = 1
                if player.health <= 0 then
                    player.isDead = true
                    player.deathTimer = 0
                    gameOverTimer = 0
                end
            end
        end

        for j = #shurikens, 1, -1 do
            local s = shurikens[j]
            if math.sqrt((s.x - e.x)^2 + (s.y - e.y)^2) < 35 then
                e.timeSinceHit = 0
                e.health = e.health - (player.comboDamage * player.damage)
                player.hasDamagedEnemy = true
                player.comboHits = player.comboHits + 1
                player.comboDamage = 1 + player.comboHits * 0.25
                player.comboTimer = 1.0
                table.remove(shurikens, j)
                if e.health <= 0 then
                    e.isDead = true
                    sounds.enemyDie:play()
                    e.deathTimer = 0
                
                    local numCoins = love.math.random(1, 2)
                    for c = 1, numCoins do
                        table.insert(coins, {
                            x = e.x + love.math.random(-10, 10),
                            y = e.y + love.math.random(-10, 10),
                            collected = false
                        })
                    end
                end
                break
            end
        end
    end
end

if boss then
    boss.timer = boss.timer - dt

    if boss.phase == "chase" and boss.timer <= 0 then
        boss.phase = "shoot"
        boss.timer = 3 
    elseif boss.phase == "shoot" and boss.timer <= 0 then
        boss.phase = "chase"
        boss.timer = 5 
    end

    
    
    
    if boss.phase == "chase" then
        local dx = player.x - boss.x
        local dy = player.y - boss.y
        local dist = math.sqrt(dx * dx + dy * dy)
        local nx, ny = dx / dist, dy / dist
        boss.x = boss.x + nx * boss.speed * dt
        boss.y = boss.y + ny * boss.speed * dt
    elseif boss.phase == "shoot" then
        boss.shootCooldown = boss.shootCooldown - dt
        if boss.shootCooldown <= 0 then
            local angle = math.atan2(player.y - boss.y, player.x - boss.x)
            table.insert(boss.projectiles, {
                x = boss.x,
                y = boss.y,
                dx = math.cos(angle) * boss.projectileSpeed,
                dy = math.sin(angle) * boss.projectileSpeed
            })
            boss.shootCooldown = 1.5
        end
    end

    for i = #boss.projectiles, 1, -1 do
        local p = boss.projectiles[i]
        p.x = p.x + p.dx * dt
        p.y = p.y + p.dy * dt

        if p.x < 0 or p.x > 1280 or p.y < 0 or p.y > 720 then
            table.remove(boss.projectiles, i)
        elseif math.abs(player.x - p.x) < 20 and math.abs(player.y - p.y) < 20 and player.invulnerableTime <= 0 then
            player.health = player.health - 1
            player.invulnerableTime = 1
            table.remove(boss.projectiles, i)
            if player.health <= 0 then
                player.isDead = true
                player.deathTimer = 0
            end
        end
    end
end

if boss and boss.health <= 0 and not door.spawned then
    door.x = 1160
    door.y = 260
    door.spawned = false
    door.spawned = true
end

if boss and boss.isDead then
    boss.deathTimer = boss.deathTimer + dt
    if boss.deathTimer >= 0.5 then
        boss = nil
    end
end

if boss and not boss.isDead then
    boss.frameTimer = boss.frameTimer + dt
    if boss.frameTimer >= boss.frameDuration then
        boss.frameTimer = 0
        boss.frame = (boss.frame % #bossFrames) + 1
    end
end

for _, item in ipairs(shopItems or {}) do
    if not item.collected then
        local dx = (player.x + player.images[player.currentFrame]:getWidth() / 2) - item.x
        local dy = (player.y + player.images[player.currentFrame]:getHeight() / 2) - item.y
        if math.sqrt(dx * dx + dy * dy) < 25 then
            if player.coinsCollected >= item.cost then
                item.collected = true
                sounds.pickup:play()
                player.coinsCollected = player.coinsCollected - item.cost

                
                if item.label == "sharp" then
                    player.damage = player.damage + 1.5
                    player.pickupMessage = "Sharpened Shurikens! Your attacks are stronger."
                elseif item.label == "potion" then
                    player.maxHealth = player.maxHealth + 1
                    player.health = player.maxHealth
                    player.pickupMessage = "Health Potion! Max health increased."
                elseif item.label == "boots" then
                    player.speed = player.speed + 50
                    player.pickupMessage = "Boots of Swiftness! You're faster now."
                elseif item.label == "cloak" then
                    player.hasCloak = true
                    player.pickupMessage = "Shadow Cloak! Press 'e' to dash."
                end
                
                player.pickupMessageTimer = 2.0
                

            end
        end
    end
end


for _, coin in ipairs(coins) do
    if not coin.collected then
        local dx = (player.x + player.images[player.currentFrame]:getWidth() / 2) - coin.x
        local dy = (player.y + player.images[player.currentFrame]:getHeight() / 2) - coin.y
        if math.sqrt(dx * dx + dy * dy) < 20 then
            coin.collected = true
            player.coinsCollected = player.coinsCollected + 1
        end
    end
end

if checkDoorCollision() then
    enterNextRoom()
end
if player.pickupMessageTimer > 0 then
    player.pickupMessageTimer = player.pickupMessageTimer - dt
    if player.pickupMessageTimer <= 0 then
        player.pickupMessage = ""
    end
end
for i = #particles.shadowBursts, 1, -1 do
    local p = particles.shadowBursts[i]
    p.x = p.x + p.dx * dt
    p.y = p.y + p.dy * dt
    p.life = p.life - dt
    p.alpha = p.life / 0.5
    if p.life <= 0 then table.remove(particles.shadowBursts, i) end
end

if player.pickupMessageTimer > 0 then
    table.insert(particles.glowTrail, {
        x = player.x + player.images[player.currentFrame]:getWidth()/2,
        y = player.y + player.images[player.currentFrame]:getHeight()/2,
        alpha = 1,
        life = 0.6
    })
end

for i = #particles.glowTrail, 1, -1 do
    local t = particles.glowTrail[i]
    t.life = t.life - dt
    t.alpha = t.life / 0.6
    if t.life <= 0 then table.remove(particles.glowTrail, i) end
end

end

function shootShuriken(direction)
    if shurikenTimer <= 0 and not player.isDead then
        local s = {
            x = player.x + player.images[player.currentFrame]:getWidth() / 2,
            y = player.y + player.images[player.currentFrame]:getHeight() / 2,
            dx = 0, dy = 0,
            rotation = 0
        }
        if direction == "up" then s.dy = -shurikenSpeed
        elseif direction == "down" then s.dy = shurikenSpeed
        elseif direction == "left" then s.dx = -shurikenSpeed
        elseif direction == "right" then s.dx = shurikenSpeed end

        table.insert(shurikens, s)
        sounds.shoot:play()

        shurikenTimer = shurikenCooldown
    end
end

function love.keypressed(key)
if gameState == "start" then
    if key == "return" then 
        gameState = "playing"
    end
    return
elseif gameState == "gameover" then
    if key == "return" then 
        resetGame()
        gameState = "playing"
    end

    return
end
    
if player.hidden or player.isDead then return end

if key == "up" then
    shootShuriken("up")
elseif key == "down" then
    shootShuriken("down")
elseif key == "left" then
    shootShuriken("left")
elseif key == "right" then
    shootShuriken("right")
elseif key == "space" then
    if player.shadowsPlaced < player.maxShadows then
        local newShadow = {
            x = player.x + player.images[player.currentFrame]:getWidth() / 2,
            y = player.y + player.images[player.currentFrame]:getHeight() / 2,
            radius = 50
        }
        table.insert(shadowZones, newShadow)
        player.shadowsPlaced = player.shadowsPlaced + 1
        spawnShadowBurst(newShadow.x, newShadow.y)
    end
elseif key == "e" and player.hasCloak and player.canDash and not player.isDashing then
    player.isDashing = true
    player.dashTimer = player.dashDuration
    player.canDash = false
    player.invulnerableTime = player.dashDuration
elseif key == "g" then
    player.godMode = not player.godMode
    if player.godMode then
        player.health = 1000
        player.maxHealth = 1000
        player.damage = player.baseDamage * 9999999999999999999
        player.speed = player.baseSpeed * 2
        
    else
        player.maxHealth = 3
        player.health = 3
        player.damage = player.baseDamage
        player.speed = player.baseSpeed
        
    end

end
end



function drawHealthBar(x, y, health, maxHealth)
    local barWidth = 32
    local barHeight = 4
    local healthRatio = math.max(0, health / maxHealth)
    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle("fill", x - barWidth / 2, y - 10, barWidth * healthRatio, barHeight)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", x - barWidth / 2, y - 10, barWidth, barHeight)
end


function love.draw()
    if gameState == "start" then
        if gameState == "start" then
            if startScreenImage then
                love.graphics.draw(startScreenImage, 0, 0, 0,
                    love.graphics.getWidth() / startScreenImage:getWidth(),
                    love.graphics.getHeight() / startScreenImage:getHeight())
            end
            return
        end
        
    elseif gameState == "gameover" then
        love.graphics.setColor(1, 0.2, 0.2)
        love.graphics.setFont(love.graphics.newFont(36))
        love.graphics.printf("GAME OVER", 0, 200, love.graphics.getWidth(), "center")
        love.graphics.setFont(love.graphics.newFont(20))
        love.graphics.printf("Press Enter to Try Again", 0, 300, love.graphics.getWidth(), "center")
        return
    end
    if backgroundImage then
        love.graphics.draw(backgroundImage, 0, 0, 0,
            love.graphics.getWidth() / backgroundImage:getWidth(),
            love.graphics.getHeight() / backgroundImage:getHeight())
    end

    if player.pickupMessageTimer > 0 then
        love.graphics.setColor(1, 1, 1)
        local font = love.graphics.newFont(20)
        love.graphics.setFont(font)
        local msg = player.pickupMessage
        local width = font:getWidth(msg)
        love.graphics.print(msg, (love.graphics.getWidth() - width) / 2, 10)
    end
    

    
    love.graphics.setColor(0, 0, 0, 0.4)
    for _, s in ipairs(shadowZones) do
        love.graphics.circle("fill", s.x, s.y, s.radius)
    end
    love.graphics.setColor(1, 1, 1)

    
for _, p in ipairs(particles.shadowBursts) do
    love.graphics.setColor(0, 0, 0, p.alpha)
    love.graphics.circle("fill", p.x, p.y, 5)
end


for _, t in ipairs(particles.glowTrail) do
    love.graphics.setColor(1, 1, 0.5, t.alpha)
    love.graphics.circle("fill", t.x, t.y, 5)
end
love.graphics.setColor(1, 1, 1)


    
    
if not boss or boss.health <= 0 then
    love.graphics.draw(doorImage, door.x, door.y)
end


    
    for _, e in ipairs(enemies) do
        if e.isDead then
            enemyDeathScale = 0.065
            love.graphics.draw(enemyDeathImage, e.x, e.y, 0, enemyDeathScale, enemyDeathScale)
        else
            local img = enemyFrames[e.currentFrame]
            local scaleX = (e.direction == "left") and -enemyScale or enemyScale
            local offsetX = (e.direction == "left") and img:getWidth() or 0
            love.graphics.draw(img, e.x + offsetX * enemyScale, e.y, 0, scaleX, enemyScale)
            local ew = enemyFrames[e.currentFrame]:getWidth() * enemyScale
            drawHealthBar(e.x + ew / 2, e.y, e.health, e.maxHealth)
            

        end
    end
    if boss and not player.isDead then
        for j = #shurikens, 1, -1 do
            local s = shurikens[j]
            if math.abs(s.x - boss.x) < boss.width / 2 and math.abs(s.y - boss.y) < boss.height / 2 then
                boss.health = boss.health - (player.comboDamage * player.damage)
                if boss.health <= 0 and not boss.isDead then
                    boss.health = 0
                    boss.isDead = true
                    boss.deathTimer = 0
                end
                player.hasDamagedEnemy = true
                player.comboHits = player.comboHits + 1
                player.comboDamage = 1 + player.comboHits * 0.25
                player.comboTimer = 1.0
                table.remove(shurikens, j)
                break
            end
        end
    end

    if boss and not boss.isDead then
        if boss.frameTimer >= boss.frameDuration then
            boss.frameTimer = 0
            boss.frame = (boss.frame % #bossFrames) + 1
        end
    end
    

    local coinScale = 0.03  
    for _, coin in ipairs(coins) do
        if not coin.collected then
            love.graphics.draw(
                coinImage,
                coin.x, coin.y,
                0,
                coinScale, coinScale,
                coinImage:getWidth() / 2, coinImage:getHeight() / 2
            )
        end
    end

    for _, item in ipairs(shopItems or {}) do
        if not item.collected then
            local floatOffset = math.sin(itemFloatTimer * 2) * 5 
            if item.image then
                love.graphics.draw(
                    item.image,
                    item.x,
                    item.y + floatOffset,
                    0,
                    0.10, 0.10,
                    item.image:getWidth() / 2,
                    item.image:getHeight() / 2
                )
            end
            love.graphics.setColor(1, 1, 0)
            love.graphics.print(tostring(item.cost), item.x - 10, item.y + 40 + floatOffset)
            love.graphics.setColor(1, 1, 1)
        end
    end
    
    
    
    
    if player.isDead then
        local scale = .45
        love.graphics.draw(playerDeathImage, player.x, player.y, 0, scale, scale)
    else
        love.graphics.setColor(1, 1, 1, player.alpha)
        local scaleX = player.direction == "left" and -1 or 1
        local offsetX = player.direction == "left" and player.images[player.currentFrame]:getWidth() or 0
        love.graphics.draw(player.images[player.currentFrame], player.x + offsetX, player.y, 0, scaleX, 1)
        love.graphics.setColor(1, 1, 1, 1)
        local pw = player.images[player.currentFrame]:getWidth()
        drawHealthBar(player.x + pw / 2, player.y, player.health, player.maxHealth)
        
    end

    
    for _, s in ipairs(shurikens) do
        love.graphics.draw(shurikenImage, s.x, s.y, s.rotation, 1, 1,
            shurikenImage:getWidth() / 2, shurikenImage:getHeight() / 2)
    end

   
love.graphics.setColor(0, 0, 0, 0.5)
love.graphics.rectangle("fill", 15, 15, 220, player.godMode and 70 or 50, 8)

love.graphics.setColor(1, 1, 1)
love.graphics.setFont(love.graphics.newFont(18))
love.graphics.print("Coins: " .. player.coinsCollected, 25, 22)
love.graphics.print("Shadows left: " .. (player.maxShadows - player.shadowsPlaced), 25, 42)

if player.godMode then
    love.graphics.setColor(1, 0.2, 0.2)
    love.graphics.print("God Mode Enabled", 25, 62)
    love.graphics.setColor(1, 1, 1) 
end

if boss then
    if boss.isDead then
        
        local scale = 0.15  
        love.graphics.draw(enemyDeathImage, boss.x, boss.y, 0, scale, scale)
    else
        
        local bossImage = bossFrames[boss.frame]
        local scale = 0.25
        local flip = boss.direction == "left" and -1 or 1
        local offsetX = boss.direction == "left" and bossImage:getWidth() * scale or 0
        love.graphics.draw(bossImage, boss.x + offsetX, boss.y, 0, scale * flip, scale)
        
    end

    
    
    love.graphics.setColor(1, 1, 1)
    local bossImage = bossFrames[boss.frame]
    local bossWidth = bossImage:getWidth() * 0.5  
    drawHealthBar(boss.x + bossWidth / 2, boss.y - 10, boss.health, boss.maxHealth)
    

    
    for _, p in ipairs(boss.projectiles) do
        love.graphics.setColor(1, 0.5, 0)
        love.graphics.circle("fill", p.x, p.y, 6)
    end
    love.graphics.setColor(1, 1, 1)

    


end
if player.isDead and fadeAlpha > 0 then
    love.graphics.setColor(0, 0, 0, fadeAlpha)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setColor(1, 1, 1)
end
end

