function generateQuads(atlis, tilewidth, tileheight)
	local sheetwidth = atlis:getWidth() / tilewidth
	local sheetheight = atlis :getHeight() / tileheight

	local sheetcounter = 1
	local quads = {}

	for i = 0,sheetheight - 1 do
		for j = 0 , sheetwidth - 1 do
			quads[sheetcounter] = love.graphics.newQuad(j * tilewidth, i * tileheight, tilewidth, tileheight, atlis:getDimensions())
			sheetcounter = sheetcounter + 1
		end
	end

	return quads

end