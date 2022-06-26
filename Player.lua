Player = Class{}

require 'Animation'
MOVE_SPEED = 80
JUMP_SPEED = 400
GRAVITY = 15

function Player:init(map)
	self.height = 20
	self.width = 16
	self.map = map
	self.x = map.tilewidth * 2
	self.y = map.tileheight * (map.mapheight / 2  + 2) - self.height

	self.dx = 0
	self.dy = 0
	self.points = 0
	self.texture = love.graphics.newImage('graphics/blue_alien.png')
	self.frame = generateQuads(self.texture, self.width, self.height)
	self.audio ={
		['coin'] =love.audio.newSource('sounds/coin.wav', 'static'),
		['empty'] = love.audio.newSource('sounds/empty-block.wav', 'static'),
		['hit'] = love.audio.newSource('sounds/hit.wav', 'static'),
		['jump'] = love.audio.newSource('sounds/jump.wav', 'static'),
		['dead'] = love.audio.newSource('sounds/dead.wav', 'static')

	}

	self.animations = {
		['idle'] = Animation {
			frames = {self.frame[1]},
			interval = 1
		},
		['walking'] = Animation {
			frames = {self.frame[9], self.frame[10], self.frame[11]},
			interval = 0.15
		},
		['jumping'] = Animation {
			frames = {self.frame[3]},
			interval = 1
		}
	}
	self.killed = false
	self.state = 'ground'
	self.animation = self.animations['idle']
	self.facing = 1

end

function Player:update(dt)
	if self.state == 'ground' then
		if love.keyboard.wasPressed('space') then
			self.dy = -JUMP_SPEED
			self.state = 'jumping'
			self.audio['jump']:play()
			self.animation = self.animations['jumping']
		end
	end
	if self.state == 'jumping' then
		if love.keyboard.isDown('d') then
			self.dx = MOVE_SPEED
			self.facing = 1
		elseif love.keyboard.isDown('a') then
			self.dx = -MOVE_SPEED
			self.facing = -1
		end
	end
	if self.state == 'ground' then
		if love.keyboard.isDown('d') then
			self.dx = MOVE_SPEED
			self.animation = self.animations['walking']
			self.facing = 1
		elseif love.keyboard.isDown('a') then
			self.dx = -MOVE_SPEED
			self.animation = self.animations['walking']
			self.facing = -1
		else
			self.animation = self.animations['idle']
			self.dx = 0
		end
	end
	if self.state =='jumping' then
		self.dy = self.dy + GRAVITY
		if self.map:getTile(math.floor(self.x / self.map.tilewidth) + 1, math.floor(self.y / self.map.tileheight) + 1) == JUMP_BLOCK then
			self.dy = 0
			self.y = (self.y / self.map.tileheight ) * self.map.tileheight + 1
			self.map:setTile(math.floor(self.x / self.map.tilewidth) + 1, math.floor(self.y / self.map.tileheight) + 1, BLOCK_BROKEN)
			self.audio['coin']:play()
			self.points = self.points + 100
		end
		if self.map:getTile(math.floor((self.x + self.width) / self.map.tilewidth) + 1,  math.floor(self.y / self.map.tileheight) + 1) == JUMP_BLOCK then
			self.dy = 0
			self.y = (self.y / self.map.tileheight ) * self.map.tileheight + 1
			self.map:setTile(math.floor((self.x + self.width)/ self.map.tilewidth) + 1, math.floor(self.y / self.map.tileheight) + 1, BLOCK_BROKEN)
			self.audio['coin']:play()
			self.points = self.points + 100
		end
		if self.map:getTile(math.floor(self.x / self.map.tilewidth) + 1, math.floor(self.y / self.map.tileheight) + 1) == BLOCK_BROKEN then
			self.dy = 0
			self.y = (self.y / self.map.tileheight ) * self.map.tileheight + 1
			self.audio['empty']:play()
		end
		if self.map:getTile(math.floor((self.x + self.width) / self.map.tilewidth + 0.5) + 1,  math.floor(self.y / self.map.tileheight) + 1) == JUMP_BLOCK then
			self.dy = 0
			self.y = (self.y / self.map.tileheight ) * self.map.tileheight + 1
			self.audio['empty']:play()
		end
	end

	self.y = self.y + self.dy * dt

	if self.map:iscolliding(self.map:getTile(math.floor(self.x / self.map.tilewidth + 0.5)+ 1, math.floor((self.y + self.height) / self.map.tileheight) + 1)) or self.map:iscolliding(self.map:getTile(math.floor((self.x + self.width) / self.map.tilewidth - 0.5)+ 1, math.floor((self.y + self.height) / self.map.tileheight) + 1)) then
		self.dy = 0
		self.y = math.floor((self.y + self.height)/ self.map.tileheight) * self.map.tileheight - self.height 
		self.state = 'ground'
	else
		self.state = 'jumping'
	end
	if self.dx~= 0 then
		if self.map:iscolliding(self.map:getTile(math.floor((self.x + self.width) / self.map.tilewidth) + 1, math.floor(self.y / self.map.tileheight) + 1)) or self.map:iscolliding(self.map:getTile(math.floor((self.x + self.width) / self.map.tilewidth) + 1, math.floor((self.y + self.height - 1) / self.map.tileheight) + 1)) then
			self.dx = 0 
			self.audio['hit']:play()
			self.x = ((self.x + self.width - 1) / self.map.tilewidth) * self.map.tilewidth - self.width
		end
		if self.map:iscolliding(self.map:getTile(math.floor((self.x - 1) / self.map.tilewidth) + 1, math.floor(self.y / self.map.tileheight) + 1)) or self.map:iscolliding(self.map:getTile(math.floor((self.x - 1) / self.map.tilewidth) + 1, math.floor((self.y + self.height - 1) / self.map.tileheight) + 1)) then
			self.dx = 0 
			self.audio['hit']:play()
			self.x = ((self.x + 1)  / self.map.tilewidth) * self.map.tilewidth 
		end
	end
	self.x = math.max(0, math.min(self.x + self.dx * dt, self.map.mapwidthpixels - self.width))
	if self.y >=self.map.mapheightpixels then
		self.audio['dead']:play()
		self.killed = true
	end
	self.animation:update(dt)
end

function Player:render()
	love.graphics.draw(self.texture, self.animation:getCurrentFrame(), math.floor(self.x + self.width / 2), math.floor(self.y + self.height / 2),
	 0, self.facing, 1, self.width / 2, self.height / 2)
end