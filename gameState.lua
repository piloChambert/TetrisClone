local gameState = {}
gameState.background = love.graphics.newImage("menu_background.png")
gameState.bezelImage = love.graphics.newImage("bezel.png")
gameState.scorePanelImage = love.graphics.newImage("score_panel.png")
gameState.nextCellImage = love.graphics.newImage("next_cell.png")

gameState.rotateSound = love.audio.newSource("rotate.wav", "static")
gameState.moveSound = love.audio.newSource("move.wav", "static")
gameState.fallSound = love.audio.newSource("fall.wav", "static")
gameState.lineSound = love.audio.newSource("line.wav", "static")


gameState.scoreFont = love.graphics.newImageFont("score_font.png","0123456789")
gameState.scoreFont:setFilter("nearest", "nearest")

tetrominos = require "tetrominos"

function gameState:load()
	-- create an empty grid
	self.grid = {}

	for y = 0,19 do
		for x = 0,9 do
			self.grid[y * 10 + x] = -1
		end
	end

	-- create tiles quad
	self.tileImage = love.graphics.newImage("tiles.png")
	self.tileQuad = {}
	for i = 0, 6 do
		self.tileQuad[i] = love.graphics.newQuad(i * 8, 0, 8, 8, self.tileImage:getDimensions())
	end

	self:generateTetromino(love.math.random(7) - 1)
	self.nextTetromino = love.math.random(7) - 1

	self.timer = 0

	self.lineCount = 0
	self.score = 0
	self.level = 1
	self.combo = 1
	self.blinkColorTimer = 0

	self.decrementTimer = 1.0
	self.fall = false -- when true, it moves the tetromino to the bottom

	-- line offset are used to animate the grid when lines dissappear
	self.lineOffset = {}
	for y = 0,19 do
		self.lineOffset[y] = 0
	end

end

function gameState:generateTetromino(idx) 
	self.tetromino = {
		idx = idx,
		orientation = 0,
		x = 3,
		y = 0,
		display_x = 24, -- displayed position
		display_y = 0
	}
end

-- return true if tetromino collide with anything in the grid
function gameState:collideWithGrid(tetromino, tx, ty)
	for j = 0, 3 do
		for i = 0, 3 do
			local x = tx + i
			local y = ty + j
			if tetromino[j * 4 + i + 1] ~= 0 then
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

function gameState:canMoveLeft()
	return not self:collideWithGrid(tetrominos[self.tetromino.idx][self.tetromino.orientation], self.tetromino.x - 1, self.tetromino.y)
end

function gameState:canMoveRight()
	return not self:collideWithGrid(tetrominos[self.tetromino.idx][self.tetromino.orientation], self.tetromino.x + 1, self.tetromino.y)
end

function gameState:canMoveDown()
	return not self:collideWithGrid(tetrominos[self.tetromino.idx][self.tetromino.orientation], self.tetromino.x, self.tetromino.y + 1)
end

function gameState:canRotateTo(orient) 
	return not self:collideWithGrid(tetrominos[self.tetromino.idx][orient], self.tetromino.x, self.tetromino.y)
end

-- return the list of fill lines
function gameState:fullLines()
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

function gameState:copyTetromino() 
	local tetromino = tetrominos[self.tetromino.idx][self.tetromino.orientation]
	for j = 0, 3 do
		for i = 0, 3 do
			local x = self.tetromino.x + i
			local y = self.tetromino.y + j

			if tetromino[j * 4 + i + 1] ~= 0 then
				self.grid[y * 10 + x] = self.tetromino.idx
			end
		end
	end	
end

-- remove line at idx, and copy the top down
function gameState:removeLine(idx)
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
function gameState:updateGrid() 
	-- any line to remove?
	local lines = self:fullLines()
	local score = 10

	if #lines > 0 then
		print("allo")
		for k, idx in ipairs(lines) do
			print(idx)
			self:removeLine(idx)
			print(idx)
		end

		-- incremente score
		self.score = self.score + score

		-- extra bonus for multiple lines
		score = score + 5

		self.lineSound:rewind()
		self.lineSound:play()
	end

	if #lines > 0 then
		self.combo = self.combo * 2
	end

	self.lineCount = self.lineCount + #lines
end

function gameState:moveTetrominoDown()
	local bottom = false
	if self:canMoveDown() then
		-- move down
		self.tetromino.y = self.tetromino.y + 1

		bottom = false
	else
		bottom  = true
	end

	return bottom
end

function gameState:update(dt)
	local bottom = false
	if self.fall then
		local s = 2048 * dt
		self.tetromino.display_y = self.tetromino.display_y + math.max(-s, math.min(s, self.fall * 8 - self.tetromino.display_y))
		self.tetromino.y = math.floor(self.tetromino.display_y / 8)

		bottom = not self:canMoveDown()
	else
		-- move the tetromino down
		self.timer = self.timer + dt

		if self.timer > self.decrementTimer then
			bottom = self:moveTetrominoDown()

			-- reset timer
			self.timer = 0
		end

		-- updated tetromino displayed position
		local s = 256 * dt
		self.tetromino.display_x = self.tetromino.display_x + math.max(-s, math.min(s, (self.tetromino.x * 8) - self.tetromino.display_x))
		self.tetromino.display_y = self.tetromino.display_y + math.max(-s, math.min(s, (self.tetromino.y * 8) - self.tetromino.display_y))
	end

	-- update line animation
	for i = 0, 19 do
		local s = 256 * dt
		self.lineOffset[i] = self.lineOffset[i] + math.max(-s, math.min(s, -self.lineOffset[i])) -- to 0
	end

	if bottom then
		-- copy tetromino to grid
		self:copyTetromino()

		-- update the new grid
		self:updateGrid()

		-- generate a new tetromino
		self:generateTetromino(self.nextTetromino)
		self.nextTetromino = love.math.random(7) - 1

		-- reset timer
		self.timer = 0

		-- reset fall state
		self.fall = false
	end

	-- color blink timer
	self.blinkColorTimer = self.blinkColorTimer + dt * 4096
	if self.blinkColorTimer > 512 then
		self.blinkColorTimer = self.blinkColorTimer - 512
	end
end

function gameState:drawTetromino(idx, orient, gx, gy)
	local tetromino = tetrominos[idx][orient]

	for y = 0,3 do
		for x = 0,3 do
			local tile = tetromino[y * 4 + x + 1]
			if tile ~= 0 then
				love.graphics.draw(self.tileImage, self.tileQuad[idx], gx + x * 8, gy + y * 8)
			end
		end
	end	
end

function gameState:drawNextTetromino(x, y)
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.draw(self.nextCellImage, x, y)

	local offset = {0, 0}
	local n = self.nextTetromino
	if n == 0 then
		offset = {0, 4}
	elseif n == 1 then
		offset = {4, 0}
	elseif n == 2 then
		offset = {0, 0}
	elseif n == 3 then
		offset = {4, 0}
	elseif n == 4 then
		offset = {4, 0}
	elseif n == 5 then 
		offset = {4, 0}
	elseif n == 6 then
		offset = {4, 0}
	end

	self:drawTetromino(self.nextTetromino, 0, x + 6 + offset[1], y + 6 + offset[2])	

	love.graphics.setColor(0, 0, 0, 255)
	love.graphics.print("Next", x+1, y - 9)	
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.print("Next", x, y - 10)	
end

function gameState:draw()
	-- draw background
	love.graphics.draw(self.background)

	-- draw a simple frame
	love.graphics.setColor(0, 0, 0, 230)
	love.graphics.polygon("fill", 120, 10, 200, 10, 200, 170, 120, 170)
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.polygon("line", 119.5, 9.5, 200.5, 9.5, 200.5, 170.5, 119.5, 170.5)

	-- draw bezel
	love.graphics.draw(self.bezelImage, 117, 7)

	-- draw panel
	--love.graphics.draw(self.scorePanelImage, 210, 7)	

	-- draw the grid
	love.graphics.push()
	love.graphics.translate(120, 10)

	for y = 0,19 do
		for x = 0,9 do
			local tile = self.grid[y * 10 + x]
			if tile ~= -1 then
				local offset = self.lineOffset[y]
				love.graphics.draw(self.tileImage, self.tileQuad[tile], x * 8, y * 8 + offset)
			end
		end
	end	

	-- draw tetromino
	self:drawTetromino(self.tetromino.idx, self.tetromino.orientation, self.tetromino.display_x, self.tetromino.display_y)

	love.graphics.pop()

	-- draw score
	love.graphics.setFont(gameState.scoreFont)
	love.graphics.setColor(0, 0, 0, 255)
	love.graphics.printf(self.score, 211, 21, 80, "left")
	love.graphics.printf(self.lineCount, 211, 51, 80, "left")
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.printf(self.score, 210, 20, 80, "left")
	love.graphics.printf(self.lineCount, 210, 50, 80, "left")

	-- draw next
	love.graphics.setFont(gameFont)
	love.graphics.setColor(0, 0, 0, 255)
	love.graphics.printf("Score", 211, 11, 80, "left")	
	love.graphics.printf("Lines", 211, 41, 80, "left")
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.printf("Score", 210, 10, 80, "left")
	love.graphics.printf("Lines", 210, 40, 80, "left")
	love.graphics.printf("Combo", 210, 70, 80, "left")

	-- print combo
	if self.combo > 0 then
		love.graphics.setColor(0, 0, 0, 255)
		love.graphics.print("Combo", 211, 71)
		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.print("Combo", 210, 70)

		local green = self.blinkColorTimer
		if green > 255 then
			green = 511 - green
		end

		love.graphics.setColor(255, green, 0, 255)
		love.graphics.print(string.format("X%d", self.combo), 260, 70)
	end


	-- next tetromino
	self:drawNextTetromino(40,40)
end

function gameState:keypressed(key, scancode, isrepeat)
	if key == "kp5" and not self.fall then
		local newOrient = (self.tetromino.orientation + 1) % 4
		if self:canRotateTo(newOrient) then
			self.tetromino.orientation = newOrient
			self.rotateSound:play()
		end
	end

	if key == "kp4" and self:canMoveLeft() and not self.fall then
		self.tetromino.x = self.tetromino.x - 1
		self.moveSound:play()
	end

	if key == "kp6" and self:canMoveRight() and not self.fall then
		self.tetromino.x = self.tetromino.x + 1
		self.moveSound:play()
	end

	if key == "kp2" then
		-- make the tetromino fall
		-- compute the y position
		local y = self.tetromino.y + 1
		while not self:collideWithGrid(tetrominos[self.tetromino.idx][self.tetromino.orientation], self.tetromino.x,  y) do
			y = y + 1
		end

		print(y)

		self.fall = y - 1
		self.fallSound:play()
	end
end

return gameState