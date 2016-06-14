tetrominos = require "tetrominos"

local gameStatePlay = {}
function gameStatePlay:enter()
end

function gameStatePlay:update(dt)
	-- check input
	if PlayerControl.player1Control:testTrigger("attack") and not gameState.fall then
		local newOrient = (gameState.tetromino.orientation + 1) % 4
		if gameState:canRotateTo(newOrient) then
			gameState.tetromino.orientation = newOrient
			gameState.rotateSound:play()
		end
	end

	if PlayerControl.player1Control:testTrigger("left") and gameState:canMoveLeft() and not gameState.fall then
		gameState.tetromino.x = gameState.tetromino.x - 1
		gameState.moveSound:play()
	end

	if PlayerControl.player1Control:testTrigger("right") and gameState:canMoveRight() and not gameState.fall then
		gameState.tetromino.x = gameState.tetromino.x + 1
		gameState.moveSound:play()
	end

	if PlayerControl.player1Control:testTrigger("down") then
		-- make the tetromino fall
		-- compute the y position
		local y = gameState.tetromino.y + 1
		while not gameState:collideWithGrid(tetrominos[gameState.tetromino.idx][gameState.tetromino.orientation], gameState.tetromino.x,  y) do
			y = y + 1
		end

		print(y)

		gameState.fall = y - 1
		gameState.fallSound:play()
	end

	-- move tetromino
	gameState:updateTetromino(dt)
end

function gameStatePlay:exit()
end


local gameStateGameOver = {}
function gameStateGameOver:enter()
end

function gameStateGameOver:update(dt)
end

function gameStateGameOver:exit()
end

TetrominoEntity = {}
function TetrominoEntity.new(x, y, index, orientation)
	local self = Entity.new(x, y)

	self.index = index
	self.orientation = orientation
	self.draw = TetrominoEntity.draw

	return self
end

function TetrominoEntity:draw(parentX, parentY)
	local _x = self.x + (parentX or 0)
	local _y = self.y + (parentY or 0)

	local tetromino = tetrominos[self.index][self.orientation]

	for i = 0,3 do
		for j = 0,3 do
			local tile = tetromino[j * 4 + i + 1]
			if tile ~= 0 then
				love.graphics.draw(gameState.tileImage, gameState.tileQuad[self.index], _x + i * 8, _y + j * 8)
			end
		end
	end	

	Entity.draw(self, parentX, parentY)
end

TetrominoGrid = {}
function TetrominoGrid.new(grid, x, y)
	local self = Entity.new(x, y)
	self.draw = TetrominoGrid.draw

	self.grid = grid

	-- line offset are used to animate the grid when lines dissappear
	self.lineOffset = {}
	for y = 0,19 do
		self.lineOffset[y] = 0
	end

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
				love.graphics.draw(gameState.tileImage, gameState.tileQuad[tile], x * 8, y * 8 + offset)
			end
		end
	end	

	love.graphics.pop()

	Entity.draw(self, parentX, parentY)
end

local gameState = {}
gameState.background = love.graphics.newImage("Gfx/menu_background.png")
gameState.bezelImage = love.graphics.newImage("Gfx/bezel.png")
gameState.scorePanelImage = love.graphics.newImage("Gfx/score_panel.png")
gameState.nextCellImage = love.graphics.newImage("Gfx/next_cell.png")

gameState.rotateSound = love.audio.newSource("Sounds/rotate.wav", "static")
gameState.moveSound = love.audio.newSource("Sounds/move.wav", "static")
gameState.fallSound = love.audio.newSource("Sounds/fall.wav", "static")
gameState.lineSound = love.audio.newSource("Sounds/line.wav", "static")
gameState.levelUpSound = love.audio.newSource("Sounds/level_up.wav", "static")

gameState.scoreFont = love.graphics.newImageFont("Gfx/score_font.png","0123456789")
gameState.scoreFont:setFilter("nearest", "nearest")

gameState.levels = {
					{1.0, 10},
					{0.7, 20},
					{0.5, 40},
					{0.42, 80},
					{0.35, 100},
					{0.3, 120},
					{0.2, 140},
					{0.12, 160},
					{0.08, 180},
					{0.05, 200}
}

-- create tiles quad
gameState.tileImage = love.graphics.newImage("Gfx/tiles.png")
gameState.tileQuad = {}
for i = 0, 6 do
	gameState.tileQuad[i] = love.graphics.newQuad(i * 8, 0, 8, 8, gameState.tileImage:getDimensions())
end

function gameState:enter()
	-- create an empty grid
	self.grid = {}

	for y = 0,19 do
		for x = 0,9 do
			self.grid[y * 10 + x] = -1
		end
	end

	self:generateTetromino(love.math.random(7) - 1)
	self.nextTetromino = love.math.random(7) - 1

	self.timer = 0

	self.lineCount = 0
	self.score = 0
	self.level = 1
	self.combo = 1

	self.fall = false -- when true, it moves the tetromino to the bottom

	-- add element to the scene
	self.scorePanel = Entity.new(640,0)
	game.scene:addChild(self.scorePanel)

	self.levelText = Text.new("Level " .. self.level, 0, 10)
	self.scorePanel:addChild(self.levelText)
	self.scorePanel:addChild(Text.new("Score", 0, 30))
	self.scoreText = Text.new("0", 0, 40)
	self.scorePanel:addChild(self.scoreText)
	self.scorePanel:addChild(Text.new("Line", 0, 60))
	self.linesText = Text.new("0", 0, 70)
	self.scorePanel:addChild(self.linesText)

	self.nextTetrominoEntity = TetrominoEntity.new(-640+78, 10, self.nextTetromino, 0)
	game.scene:addChild(self.nextTetrominoEntity)

	self.gridEntity = TetrominoGrid.new(self.grid, 120, 10)
	game.scene:addChild(self.gridEntity)

	self.currentTetrominoEntity = TetrominoEntity.new(self.tetromino.x * 8, self.tetromino.y * 8, self.tetromino.idx, self.tetromino.orientation)
	self.gridEntity:addChild(self.currentTetrominoEntity)

	self.scorePanel:animateTo(210, 0, 2048)
	self.nextTetrominoEntity:animateTo(78, 0, 2048)

	self.fsm = FSM(gameStatePlay)
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

		self.gridEntity.lineOffset[j] = self.gridEntity.lineOffset[j] - 8
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
		self.score = self.score + score * self.combo

		-- extra bonus for multiple lines
		score = score + 5

		-- update combo status
		self.combo = self.combo * 2

		-- update level
		local levelUp = false
		if self.level < 10 then
			-- increase level
			if self.levels[self.level][2] < self.score then
				self.level = self.level + 1
				levelUp = true
			end
		end

		if not levelUp then
			self.lineSound:rewind()
			self.lineSound:play()
		else 
			self.levelUpSound:rewind()
			self.levelUpSound:play()
		end
	else
		self.combo = 1
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

-- update tetromino
function gameState:updateTetromino(dt)
	-- move tetromino
	local bottom = false
	if self.fall then
		-- if falling, move it until we reach the bottom
		local s = 2048 * dt
		local _y = self.currentTetrominoEntity.y + math.max(-s, math.min(s, self.fall * 8 - self.currentTetrominoEntity.y))
		self.tetromino.y = math.floor(_y / 8)

		self.currentTetrominoEntity:moveTo(self.currentTetrominoEntity.x, _y)

		bottom = not self:canMoveDown()
	else
		-- move the tetromino down according to timer
		self.timer = self.timer + dt

		if self.timer > self.levels[self.level][1] then
			bottom = self:moveTetrominoDown()

			-- reset timer
			self.timer = 0
		end

		self.currentTetrominoEntity:animateTo(self.tetromino.x * 8, self.tetromino.y * 8, 256)
		self.currentTetrominoEntity.orientation = self.tetromino.orientation
	end

	-- if the tetromino reach the end of the grid
	if bottom then
		-- copy tetromino to grid
		self:copyTetromino()

		-- update the new grid
		self:updateGrid()

		-- generate a new tetromino
		self:generateTetromino(self.nextTetromino)
		self.nextTetromino = love.math.random(7) - 1
		self.nextTetrominoEntity.index = self.nextTetromino
		self.currentTetrominoEntity.index = self.tetromino.idx
		self.currentTetrominoEntity.orientation = self.tetromino.orientation
		self.currentTetrominoEntity:moveTo(self.tetromino.x * 8, self.tetromino.y * 8)

		-- reset timer
		self.timer = 0

		-- reset fall state
		self.fall = false

		-- are we stuck?
		if self:collideWithGrid(tetrominos[self.tetromino.idx][self.tetromino.orientation], self.tetromino.x, self.tetromino.y) then
			-- Game over!
			changeState(titleState)
		end
	end

	-- update line animation
	for i = 0, 19 do
		local s = 256 * dt
		self.gridEntity.lineOffset[i] = self.gridEntity.lineOffset[i] + math.max(-s, math.min(s, -self.gridEntity.lineOffset[i])) -- to 0
	end
end

function gameState:update(dt)
	self.fsm:update(dt)
end

function gameState:drawNextTetromino(x, y)
	love.graphics.setColor(255, 255, 255, 255)

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

	local _x = x + offset[1]
	local _y = y + offset[2] + 10 

	-- outline
	love.graphics.setColor(0, 0, 0, 255)
	for j = -1, 1 do
		for i = -1, 1 do
			self:drawTetromino(self.nextTetromino, 0, _x + i, _y + j)	
		end
	end

	love.graphics.setColor(255, 255, 255, 255)
	self:drawTetromino(self.nextTetromino, 0, _x, _y)

	love.graphics.setColor(0, 0, 0, 255)
	love.graphics.printf("Next", x+1, y+1, 32, "right")	
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.printf("Next", x, y, 32, "right")	
end

return gameState