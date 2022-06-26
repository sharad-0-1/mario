Animation = Class{}

function Animation:init(parms)
	self.frames = parms.frames
	self.interval = parms.interval
	self.timer = 0
	self.currentframe = 1
end

function Animation:reset()
	self.timer = 0
	self.currentframe = 1
end

function Animation:getCurrentFrame()
	return self.frames[self.currentframe]
end


function Animation:update(dt)
	self.timer = self.timer + dt

	if #self.frames == 1 then
		return self.currentframe
	else
		while self.timer > self.interval do
			self.timer = self.timer - self.interval
			self.currentframe =(self.currentframe + 1) % (#self.frames + 1)
			self.currentframe = self.currentframe == 0 and 1 or self.currentframe
		end
	end
end

