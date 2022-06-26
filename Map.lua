Map = Class{}

TILE_BRICK = 1--
TILE_EMPTY = 4

CLOUD_LEFT = 6
CLOUD_RIGHT = 7

BUSH_LEFT = 2
BUSH_RIGHT = 3

MUSHROOM_TOP = 10--
MUSHROOM_BOTTOM = 11--

JUMP_BLOCK = 5--
BLOCK_BROKEN = 9--


function Map:init()
	self.spritesheet = love.graphics.newImage('graphics/spritesheet.png')
	self.tilewidth = 16
	self.tileheight = 16
	self.mapwidth = 500
	self.mapheight = 20
	self.tiles = {}
	self.player = Player(self)

	self.camx = 0
	self.camy = 0

	self.mapwidthpixels = self.mapwidth * self.tilewidth
	self.mapheightpixels = self.mapheight * self.tileheight

	self.tilesprite = generateQuads(self.spritesheet, self.tilewidth, self.tileheight)
	self.music = love.audio.newSource('sounds/music.wav', 'static')

	for y = 1, self.mapheight do
		for x = 1, self.mapwidth do
			self:setTile(x, y, TILE_EMPTY)
		end
	end
	

	local last_cloud = 0
	local last_bush = 0
	local last_mushroom = 0
	local last_jump_block = 0
	local last_space = 0
	local x = 1

	while x < self.mapwidth do
		if x - last_cloud > 1 and math.random(20) == 1 then
			l = math.random(self.mapheight / 2 - 6)
			self:setTile(x, l, CLOUD_LEFT)
			self:setTile(x + 1 , l, CLOUD_RIGHT)
			last_cloud = x + 1
		end
		
		if x - last_bush > 1 and math.random(15) == 1  then
			l = self.mapheight / 2 + 2
			self:setTile(x, l, BUSH_LEFT)
			for y = l + 1, self.mapheight do
				self:setTile(x, y, TILE_BRICK)
			end
			self:setTile(x + 1 , l, BUSH_RIGHT)
			for y = l + 1, self.mapheight do
				self:setTile(x + 1, y, TILE_BRICK)
			end
			last_bush = x + 1
		end

		if x - last_mushroom > 4 and x ~= last_bush and math.random(20) == 1 then
			l = self.mapheight / 2 + 1
			self:setTile(x, l, MUSHROOM_TOP)
			self:setTile(x, l + 1, MUSHROOM_BOTTOM)
			last_mushroom = x
			for y = l + 2, self.mapheight do
				self:setTile(x, y, TILE_BRICK)
			end
		elseif  x - last_jump_block > 3 and  math.random(10) == 1 then
			l = self.mapheight / 2 - 1
			for y = 0, math.random(1, 2) do
				self:setTile(x + y, l, JUMP_BLOCK)
				for z = l + 4, self.mapheight do
					self:setTile(x + y, z, TILE_BRICK)
				end
				last_jump_block = x + y
			end
		elseif x - last_space > 4  and math.random(2) == 1  then
			last_space = x
			x = x + 1
		else
			for y = self.mapheight / 2 + 3, self.mapheight  do
				self:setTile(x, y, TILE_BRICK)
				self:setTile(x + 1, y, TILE_BRICK)
			end
			if math.random(20) == 1 and x - last_jump_block > 1 and x ~= last_bush then
				for y = self.mapheight / 2, self.mapheight / 2 + 2 do
					for z = 0, y - self.mapheight / 2  do
						self:setTile(x + z, y, TILE_BRICK)
						for y = self.mapheight / 2 + 3, self.mapheight  do
							self:setTile(x + z , y, TILE_BRICK)
						end
					end
				end
				x = x + 3
			end
		end
		x = x + 1
	end
	self.music:setLooping(true)
	self.music:setVolume(0.25)
	self.music:play()
end

function Map:update(dt)
	self.camx = math.max(0 , math.min(self.player.x - VIR_WIDTH / 4 , math.min(self.mapwidthpixels - VIR_WIDTH, self.player.x)))
	self.player:update(dt)
end

function Map:reset()
	self.spritesheet = love.graphics.newImage('graphics/spritesheet.png')
	self.tilewidth = 16
	self.tileheight = 16
	self.mapwidth = 50
	self.mapheight = 20
	self.tiles = {}
	self.player = Player(self)

	self.camx = 0
	self.camy = 0

	self.mapwidthpixels = self.mapwidth * self.tilewidth
	self.mapheightpixels = self.mapheight * self.tileheight

	self.tilesprite = generateQuads(self.spritesheet, self.tilewidth, self.tileheight)
	self.music = love.audio.newSource('Sounds/music.wav', 'static')
end

function Map:iscolliding(tile)
	if tile == 10 or tile == 11 or tile == 5 or tile == 9 or tile ==1 then
		return true
	end
	return false
end

function Map:setTile(x, y, tile)
	self.tiles[(y - 1) * self.mapwidth + x] = tile
end

function Map:getTile( x, y)
	return self.tiles[(y - 1) * self.mapwidth + x]
end

function Map:render()
	for i = 1, self.mapheight do
		for j = 1, self.mapwidth do
			love.graphics.draw(self.spritesheet, self.tilesprite[self:getTile( j, i)], (j - 1) * self.tilewidth, (i - 1) * self.tileheight)
		end
	end
	self.player:render()
end 