TetrominoShapes =  {
	[0] = {
		[0] = {	0, 0, 0, 0,
			   	1, 1, 1, 1,
				0, 0, 0, 0,
				0, 0, 0, 0},
		[1] = {	0, 1, 0, 0,
			   	0, 1, 0, 0,
				0, 1, 0, 0,
				0, 1, 0, 0},
		[2] = {	0, 0, 0, 0,
			   	1, 1, 1, 1,
				0, 0, 0, 0,
				0, 0, 0, 0},
		[3] = {	0, 1, 0, 0,
			   	0, 1, 0, 0,
				0, 1, 0, 0,
				0, 1, 0, 0}
	},

	[1] = {
		[0] = {	0, 0, 0, 0,
			   	0, 1, 0, 0,
				1, 1, 1, 0,
				0, 0, 0, 0},
		[1] = {	0, 0, 0, 0,
			   	1, 0, 0, 0,
				1, 1, 0, 0,
				1, 0, 0, 0},
		[2] = {	0, 0, 0, 0,
			   	1, 1, 1, 0,
				0, 1, 0, 0,
				0, 0, 0, 0},
		[3] = {	0, 0, 0, 0,
			   	0, 0, 1, 0,
				0, 1, 1, 0,
				0, 0, 1, 0}
	},

	[2] = {
		[0] = {	0, 0, 0, 0,
			   	0, 1, 1, 0,
				0, 1, 1, 0,
				0, 0, 0, 0},
		[1] = {	0, 0, 0, 0,
			   	0, 1, 1, 0,
				0, 1, 1, 0,
				0, 0, 0, 0},
		[2] = {	0, 0, 0, 0,
			   	0, 1, 1, 0,
				0, 1, 1, 0,
				0, 0, 0, 0},
		[3] = {	0, 0, 0, 0,
			   	0, 1, 1, 0,
				0, 1, 1, 0,
				0, 0, 0, 0}
	},

	[3] = {
		[0] = {	0, 0, 0, 0,
			   	1, 1, 1, 0,
				1, 0, 0, 0,
				0, 0, 0, 0},
		[1] = {	1, 1, 0, 0,
			   	0, 1, 0, 0,
				0, 1, 0, 0,
				0, 0, 0, 0},
		[2] = {	0, 0, 1, 0,
			   	1, 1, 1, 0,
				0, 0, 0, 0,
				0, 0, 0, 0},
		[3] = {	0, 1, 0, 0,
			   	0, 1, 0, 0,
				0, 1, 1, 0,
				0, 0, 0, 0}
	},

	[4] = {
		[0] = {	0, 0, 0, 0,
			   	1, 1, 1, 0,
				0, 0, 1, 0,
				0, 0, 0, 0},
		[1] = {	0, 1, 0, 0,
			   	0, 1, 0, 0,
				1, 1, 0, 0,
				0, 0, 0, 0},
		[2] = {	1, 0, 0, 0,
			   	1, 1, 1, 0,
				0, 0, 0, 0,
				0, 0, 0, 0},
		[3] = {	0, 1, 1, 0,
			   	0, 1, 0, 0,
				0, 1, 0, 0,
				0, 0, 0, 0}
	},

	[5] = {
		[0] = {	0, 0, 0, 0,
			   	0, 1, 1, 0,
				1, 1, 0, 0,
				0, 0, 0, 0},
		[1] = {	0, 1, 0, 0,
			   	0, 1, 1, 0,
				0, 0, 1, 0,
				0, 0, 0, 0},
		[2] = {	0, 0, 0, 0,
			   	0, 1, 1, 0,
				1, 1, 0, 0,
				0, 0, 0, 0},
		[3] = {	0, 1, 0, 0,
			   	0, 1, 1, 0,
				0, 0, 1, 0,
				0, 0, 0, 0}
	},

	[6] = {
		[0] = {	0, 0, 0, 0,
			   	1, 1, 0, 0,
				0, 1, 1, 0,
				0, 0, 0, 0},
		[1] = {	0, 0, 1, 0,
			   	0, 1, 1, 0,
				0, 1, 0, 0,
				0, 0, 0, 0},
		[2] = {	0, 0, 0, 0,
			   	1, 1, 0, 0,
				0, 1, 1, 0,
				0, 0, 0, 0},
		[3] = {	0, 0, 1, 0,
			   	0, 1, 1, 0,
				0, 1, 0, 0,
				0, 0, 0, 0}
	}
}

-- create tiles quad
TetrominoShapes.tileImage = love.graphics.newImage("Gfx/tiles.png")
TetrominoShapes.tileQuad = {}
for i = 0, 7 do
	TetrominoShapes.tileQuad[i] = love.graphics.newQuad(i * 8, 0, 8, 8, TetrominoShapes.tileImage:getDimensions())
end

TetrominoEntity = {}
function TetrominoEntity.new(x, y, index, orientation)
	local self = Entity.new(x, y)

	self.index = index
	self.orientation = orientation

	-- copy TetrominoGrid func
	for key, value in pairs(TetrominoEntity) do
		self[key] = value
	end

	self.gridX = math.floor(x / 8)
	self.gridY = math.floor(y / 8)

	return self
end

function TetrominoEntity:draw(parentX, parentY)
	local _x = self.x + (parentX or 0)
	local _y = self.y + (parentY or 0)

	local tetromino = TetrominoShapes[self.index][self.orientation]

	for i = 0,3 do
		for j = 0,3 do
			local tile = tetromino[j * 4 + i + 1]
			if tile ~= 0 then
				love.graphics.draw(TetrominoShapes.tileImage, TetrominoShapes.tileQuad[self.index], _x + i * 8, _y + j * 8)
			end
		end
	end	

	Entity.draw(self, parentX, parentY)
end

function TetrominoEntity:moveToGrid(x, y)
	self.gridX = x
	self.gridY = y
	self:moveTo(x * 8, y * 8)
end

function TetrominoEntity:animateToGrid(x, y, speed)
	self.gridX = x
	self.gridY = y
	self:animateTo(x * 8, y * 8, speed)
end

TetrominoGrid = {}
TetrominoGrid.__index = TetrominoGrid
function TetrominoGrid.new(x, y)
	local self = Entity.new(x, y)

	-- copy TetrominoGrid func
	for key, value in pairs(TetrominoGrid) do
		self[key] = value
	end

	-- create empty grid
	self.grid = {}
	for y = 0,19 do
		for x = 0,9 do
			self.grid[y * 10 + x] = -1
		end
	end

	-- line offset are used to animate the grid when lines dissappear
	self.lineOffset = {}
	for y = 0,19 do
		self.lineOffset[y] = 0
	end

	-- tetromino
	self.tetromino = TetrominoEntity.new(0, 0, 0, 0)
	self:addChild(self.tetromino)

	self.fall = false -- when true, it moves the tetromino to the bottom

	self.level = 0
	self.fallTimer = 0
	self.fallTime = 0.88
	self.lineCount = 0
	self.score = 0

	return self
end

function TetrominoGrid:draw(parentX, parentY)
	local _x = self.x + (parentX or 0)
	local _y = self.y + (parentY or 0)

	-- draw the grid
	love.graphics.push()
	love.graphics.translate(_x, _y)


	-- draw a simple frame
	love.graphics.setColor(0, 0, 0, 128)
	love.graphics.polygon("fill", 0, 0, 80, 0, 80, 160, 0, 160)
	love.graphics.setColor(255, 255, 255, 255)

	-- draw the grid
	for y = 0,19 do
		for x = 0,9 do
			local tile = self.grid[y * 10 + x]
			if tile ~= -1 then
				local offset = self.lineOffset[y]
				love.graphics.draw(TetrominoShapes.tileImage, TetrominoShapes.tileQuad[tile], x * 8, y * 8 + offset)
			end
		end
	end	

	love.graphics.pop()

	Entity.draw(self, parentX, parentY)
end

-- return true if tetromino shape collide with anything in the grid
function TetrominoGrid:collideWithGrid(shape, tx, ty)
	for j = 0, 3 do
		for i = 0, 3 do
			local x = tx + i
			local y = ty + j
			if shape[j * 4 + i + 1] ~= 0 then
				-- test bound
				if x < 0 then return true end
				if x > 9 then return true end
				if y > 19 then return true end

				-- test with grid
				local tile = self.grid[y * 10 + x]

				if tile ~= -1 then return true end
			end
		end
	end

	-- else
	return false
end

-- return true if tetromino can move left
function TetrominoGrid:canMoveLeft(tetromino)
	-- test if there is a collison on the left
	local shape = TetrominoShapes[tetromino.index][tetromino.orientation]
	return not self:collideWithGrid(shape, tetromino.gridX - 1, tetromino.gridY)
end

-- return true if succeed
function TetrominoGrid:moveLeft()
	if self:canMoveLeft(self.tetromino) then
		self.tetromino:animateToGrid(self.tetromino.gridX - 1, self.tetromino.gridY)
		return true
	end

	return false
end

-- return true if tetromino can move right
function TetrominoGrid:canMoveRight(tetromino)
	-- test if there is a collison on the left
	local shape = TetrominoShapes[tetromino.index][tetromino.orientation]
	return not self:collideWithGrid(shape, tetromino.gridX + 1, tetromino.gridY)
end

-- return true if succeed
function TetrominoGrid:moveRight()
	if self:canMoveRight(self.tetromino) then
		self.tetromino:animateToGrid(self.tetromino.gridX + 1, self.tetromino.gridY)
		return true
	end

	return false
end

-- return true if orientation is valid
function TetrominoGrid:canRotate(tetromino, newOrientation)
	-- test if there is a collison on the left
	local shape = TetrominoShapes[tetromino.index][newOrientation]
	return not self:collideWithGrid(shape, tetromino.gridX, tetromino.gridY)
end

-- return true if succeed
function TetrominoGrid:rotate()
	local newOrient = (self.tetromino.orientation + 1) % 4
	if self:canRotate(self.tetromino, newOrient) then
		self.tetromino.orientation = newOrient
		return true
	end

	return false
end


-- return nil if at bottom
-- else return distance to bottom
function TetrominoGrid:canMoveDown(tetromino)
	-- test if there is a collison on the left
	local shape = TetrominoShapes[tetromino.index][tetromino.orientation]
	local dist = 1
	while not self:collideWithGrid(shape, tetromino.gridX, tetromino.gridY + dist) do
		dist = dist + 1
	end

	dist = dist - 1

	if dist == 0 then
		return false
	end

	-- else
	return dist
end

function TetrominoGrid:moveDown()
	local dist = self:canMoveDown(self.tetromino)

	if dist > 0 then
		self.tetromino:animateToGrid(self.tetromino.gridX, self.tetromino.gridY + dist, 1024)
		self.fall = true

		return true
	end

	return false
end


-- return the list of fill lines
function TetrominoGrid:fullLines()
	local res = {}

	for j = 0, 19 do
		local full = true

		for i = 0, 9 do
			if self.grid[j * 10 + i] == -1 then
				full = false
			end
		end

		if full then
			table.insert(res, j)
		end
	end

	return res
end

function TetrominoGrid:copyTetromino(tetromino) 
	local shape = TetrominoShapes[tetromino.index][tetromino.orientation]
	for j = 0, 3 do
		for i = 0, 3 do
			local x = tetromino.gridX + i
			local y = tetromino.gridY + j

			if shape[j * 4 + i + 1] ~= 0 then
				self.grid[y * 10 + x] = tetromino.index
			end
		end
	end	
end

-- remove line at idx, and copy the top down
function TetrominoGrid:removeLine(idx)
	-- just in case
	if idx < 0 or idx > 19 then
		return
	end

	for j = idx, 1, -1 do
		for i = 0, 9 do
			self.grid[j * 10 + i] = self.grid[(j - 1) * 10 + i]
		end

		self.lineOffset[j] = self.lineOffset[j] - 8
	end

	-- new blank line at top
	for i = 0, 9 do
		self.grid[i] = -1
	end
end

-- look for completed lines, remove them and update score
function TetrominoGrid:updateGrid(dt) 
	-- any line to remove?

end

-- update tetromino
function TetrominoGrid:updateTetromino(dt)
	-- move tetromino
	local bottom = false
	local lineCount = 0

	if self.fall then
		-- if falling, move it until we reach the bottom
		-- the tromino is animated for this

		-- current displayed grid position
		local _y = math.floor(self.tetromino.y / 8)
		bottom = _y == self.tetromino.gridY
	else
		-- move the tetromino down according to timer
		self.fallTimer = self.fallTimer + dt

		if self.fallTimer > self.fallTime then
			-- move tetromino down
			if self:canMoveDown(self.tetromino) then
				self.tetromino:animateToGrid(self.tetromino.gridX, self.tetromino.gridY + 1, 256)
			else
				-- can't move down
				bottom = true
			end

			-- reset timer
			self.fallTimer = 0
		end
	end

	-- if the tetromino reach the end of the grid
	if bottom then
		-- copy tetromino to grid
		self:copyTetromino(self.tetromino)

		-- update the new grid
		local lines = self:fullLines()
		lineCount = #lines
		if lineCount > 0 then
			for k, idx in ipairs(lines) do
				self:removeLine(idx)
			end

			self.lineCount = self.lineCount + #lines
		end

		-- reset timer
		self.fallTimer = 0

		-- reset fall state
		self.fall = false
	end

	-- update line animation
	for i = 0, 19 do
		local s = 256 * dt
		self.lineOffset[i] = self.lineOffset[i] + math.max(-s, math.min(s, -self.lineOffset[i])) -- to 0
	end

	return bottom, lineCount
end

levelsFallTime = {[0] =  0.88,
		[1] = 0.75,
		[2] = 0.62,
		[3] = 0.46,
		[4] = 0.28,
		[5] = 0.17,
		[6] = 0.13,
		[7] = 0.1, 
		[8] = 0.083,
		[9] = 0.066,
		[10] = 0.05
}