function love.load()
    player = {
        x = 70,
        y = 300,
        speed = 250,
        points = 0,
        live = true,
        img = love.graphics.newImage('plane.png')
    }

    shootSound = love.audio.newSource('gun-sound.wav', 'static')
    failSound = love.audio.newSource('fail.wav', 'static')
    bgSound = love.audio.newSource('background.mp3', "stream")

    bulletImg = love.graphics.newImage('bullet.png')
    canShoot = true
    canShootTimeMax = 0.2
    canShootTime = canShootTimeMax
    bullets = {}

    createEnemyTimeMax = 1
    createEnemyTime = createEnemyTimeMax
    enemyImg = love.graphics.newImage('enemy.png')
    enemySpeed = 250
    enemies = {}
    started = false
end

function CheckCollision(x1, y1, w1, h1, x2, y2, w2, h2)
    return x1 < x2 + w2 and
           x2 < x1 + w1 and
           y1 < y2 + h2 and
           y2 < y1 + h1
end

function playGame(dt)
    if not bgSound:isPlaying() then
        love.audio.play(bgSound)
    end

    if love.keyboard.isDown('left') then
        if player.x > 0 then
            player.x = player.x - (player.speed * dt)
        end
    elseif love.keyboard.isDown('right') then
        if player.x < (love.graphics.getWidth() - player.img:getWidth()) then
            player.x = player.x + (player.speed * dt)
        end
    end

    canShootTime = canShootTime - (1 * dt)
    if canShootTime < 0 then
        canShoot = true
    end

    if love.keyboard.isDown('space') and canShoot and started then
        local newBullet = {
            x = player.x + ((player.img:getWidth() / 2) - 5),
            y = player.y,
            img = bulletImg
        }
        table.insert(bullets, newBullet)
        canShoot = false
        canShootTime = canShootTimeMax
        love.audio.play(shootSound)
    end

    for i, bullet in ipairs(bullets) do
        bullet.y = bullet.y - (250 * dt)
        if bullet.y < 0 then
            table.remove(bullets, i)
        end
    end

    createEnemyTime = createEnemyTime - (1 * dt)
    if createEnemyTime < 0 then
        createEnemyTime = createEnemyTimeMax

        local randomNumber = math.random(0, love.graphics.getWidth() - enemyImg:getWidth())
        local enemy = {
            x = randomNumber,
            y = -10,
            img = enemyImg
        }
        table.insert(enemies, enemy)
    end

    for i, enemy in ipairs(enemies) do
        enemy.y = enemy.y + (enemySpeed * dt)

        if enemy.y > love.graphics.getHeight() then
            table.remove(enemies, i)
            if player.points > 0 then
                player.points = player.points - 25
            end
        end
    end

    for i, enemy in ipairs(enemies) do
        for j, bullet in ipairs(bullets) do
            if CheckCollision(bullet.x, bullet.y, bullet.img:getWidth(), bullet.img:getHeight(),
                              enemy.x, enemy.y, enemy.img:getWidth(), enemy.img:getHeight()) then
                table.remove(bullets, j)
                table.remove(enemies, i)
                player.points = player.points + 50

                if player.speed < 350 then
                    player.speed = player.speed + 10
                end

                if createEnemyTimeMax > 0.4 then
                    createEnemyTimeMax = createEnemyTimeMax - 0.04
                    enemySpeed = enemySpeed + 10
                end
            end
        end

        if CheckCollision(player.x, player.y, player.img:getWidth(), player.img:getHeight(),
                          enemy.x, enemy.y, enemy.img:getWidth(), enemy.img:getHeight()) then
            table.remove(enemies, i)
            player.live = false
            love.audio.stop(bgSound)
            love.audio.play(failSound)
        end
    end
end

function love.update(dt)
    if love.keyboard.isDown('space') and not started then
        started = true
    end

    if started then
        if player.live then
            playGame(dt)
        end
    end

    if not player.live and love.keyboard.isDown('a') then
        love.audio.stop(failSound)
        player.x = 70
        player.y = 300
        enemies = {}
        bullets = {}
        player.live = true
        player.points = 0
        createEnemyTimeMax = 1
        createEnemyTime = createEnemyTimeMax
        enemySpeed = 250
    end
end

function love.draw()
    if started and player.live then
        love.graphics.draw(player.img, player.x, player.y)
        love.graphics.printf("Points: " .. player.points, 50, 350, 200)
        for i, bullet in ipairs(bullets) do
            love.graphics.draw(bullet.img, bullet.x, bullet.y)
        end
        for i, enemy in ipairs(enemies) do
            love.graphics.draw(enemy.img, enemy.x, enemy.y)
        end
    elseif not started then
        love.graphics.printf("PRECIONE A TECLA 'ESPAÇO' PARA INICIAR O JOGO", 0, love.graphics.getHeight() / 2, love.graphics.getWidth(), 'center')
    end

    if not player.live then
        love.graphics.printf("VOCÊ FEZ " .. player.points .. " PONTOS!", 0, love.graphics.getHeight() / 2, love.graphics.getWidth(), 'center')
        love.graphics.printf("PRECIONE A TECLA 'A' PARA REINICIAR O JOGO", 0, love.graphics.getHeight() / 2 + 50, love.graphics.getWidth(), 'center')
    end
end
