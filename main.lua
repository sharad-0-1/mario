
WIN_WIDTH = 1280
WIN_HEIGHT = 720

VIR_WIDTH = 432
VIR_HEIGHT = 243

Class = require 'Class'
push = require 'Push'

require 'Util'
require 'Animation'
require 'Map'
require 'Player'

function love.load()
	math.randomseed(os.time())
	map = Map()
	love.graphics.setDefaultFilter('nearest', 'nearest')
	push:setupScreen(VIR_WIDTH, VIR_HEIGHT, WIN_WIDTH, WIN_HEIGHT, {
		fullscreen =false,
		vsync = true,
		resizable = true
	})
	love.window.setTitle("Mario 1.0")
	menu_font = love.graphics.newFont('fonts/menu.ttf', 24)
	score_font = love.graphics.newFont('fonts/score.ttf', 8)
	gamestate ='start'
	score = 0
	keyss = {}
end

function love.resize(w, h)
	push:resize(w, h)
end

function love.keypressed(key)
	if key == 'escape' then
		if gamestate == 'pause'  then
			gamestate = 'play'
    	elseif gamestate == 'play' then
    		gamestate = 'pause'
    	end
    end
    if gamestate == 'dead' and key == 'return' then
    	map.music:stop()
    	map = Map()
		gamestate ='play'
		score = 0
    end
    if key == 'return' then
    	gamestate = 'play'
    end
	keyss[key] = true
end

function love.keyboard.wasPressed(key)
	return keyss[key]
end
function love.update(dt)
	if gamestate == 'play' then
		map:update(dt)
		if map.player.x > score then
			score = map.player.x
		end
		if map.player.killed == true then
			gamestate = 'dead'
		end
	end
	keyss = {}
end

function love.draw()
	push:apply('start')	
	love.graphics.clear(108 / 255, 140 / 255, 1, 1)
	if gamestate == 'start' then
		love.graphics.setFont(menu_font)
		love.graphics.printf('Press Enter to play!', 0, 20, VIR_WIDTH, 'center')
	elseif gamestate == 'pause' then
		love.graphics.setFont(menu_font)
		love.graphics.printf('Press Enter to continue!', 0, 20, VIR_WIDTH, 'center')
	elseif gamestate == 'dead' then
		love.graphics.setFont(menu_font)
		love.graphics.printf('You died...Press Enter to retry', 0, 20, VIR_WIDTH, 'center')
	elseif gamestate == 'play' then
		love.graphics.setFont(score_font)
		love.graphics.printf(math.floor(score + map.player.points - 32), 0, 10, VIR_WIDTH, 'right')
    	love.graphics.translate(math.floor(-map.camx + 0.5), math.floor(-map.camy + 0.5))
	end
	map:render()
	push:apply('end')
end