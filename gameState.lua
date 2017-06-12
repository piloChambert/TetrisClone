tetrominoShapes = require "tetrominos"

local gameStatePlay = {}
function gameStatePlay:enter()
	game:fadeIn()
end

function gameStatePlay:update(dt)
	-- check input

	-- rotate (if not falling)
	if PlayerControl.player1Control:testTrigger("use") and not gameState.fall then
		local newOrient = (gameState.tetromino.orientation + 1) % 4
		if gameState.gridEntity:canRotate(gameState.tetromino, newOrient) then
			gameState.tetromino.orientation = newOrient
			gameState.rotateSound:stop()
			gameState.rotateSound:play()
		end
	end

	if PlayerControl.player1Control:testTrigger("left") and gameState.gridEntity:canMoveLeft(gameState.tetromino) and not gameState.fall then
		gameState.tetromino:animateToGrid(gameState.tetromino.gridX - 1, gameState.tetromino.gridY, 256)
		gameState.moveSound:stop()		
		gameState.moveSound:play()
	end

	if PlayerControl.player1Control:testTrigger("right") and gameState.gridEntity:canMoveRight(gameState.tetromino) and not gameState.fall then
		gameState.tetromino:animateToGrid(gameState.tetromino.gridX + 1, gameState.tetromino.gridY, 256)
		gameState.moveSound:stop()		
		gameState.moveSound:play()
	end

	if PlayerControl.player1Control:testTrigger("attack") and not gameState.fall then
		-- make the tetromino fall
		
		local dist = gameState.gridEntity:canMoveDown(gameState.tetromino)
		gameState.tetromino:animateToGrid(gameState.tetromino.gridX, gameState.tetromino.gridY + dist, 1024)

		gameState.fall = true
		gameState.fallSound:stop()
		gameState.fallSound:play()

		print(gameState.fall)
	end

	if PlayerControl.player1Control:testTrigger("menu_back") and not gameState.fall then
		gameState.fsm:changeState(inGameMenuState)
	end

	-- move tetromino
	gameState:updateTetromino(dt)
end

function gameStatePlay:exit()
end

function backToMenuThread() 
	game:fadeOut()
	wait(0.5)
	game:fadeIn()

	game.fsm:changeState(menuState)
end

newHighscoreState = {}
newHighscoreState.music = love.audio.newSource("Music/highscore.xm", "stream")
newHighscoreState.music:setLooping(true)

function newHighscoreState:enter()
	game:fadeIn()
	newHighscoreState.music:play()

	self.view = Entity.new(0, 0)
	game.scene:addChild(self.view)

	self.view:addChild(Text.new("New Highscore!", 0, 35, 320, "center"))
	self.view:addChild(Text.new(self.highscore, 0, 55, 320, "center"))

	self.view:addChild(Text.new("Enter your name", 0, 80, 320, "center"))
	self.view:addChild(Sprite.new(love.graphics.newImage("Gfx/text_field.png"), nil, 95, 96))
	self.nameField = Text.new("", 0, 100, 320, "center")
	self.view:addChild(self.nameField)

	self.name = ""
	self.timer = 0
end

function newHighscoreState:textinput(text)
	self.name = self.name .. text
end

function newHighscoreState:update(dt)
	-- blink cursor
	self.timer = self.timer + dt

	if (math.floor(self.timer * 5)) % 2 == 0 then
		self.nameField.text = self.name .. "_"
	else
		self.nameField.text = self.name .. "µ"
	end

	if PlayerControl.player1Control:testTrigger("text_del") then
		self.name = self.name:sub(1, -2)
	end

	if PlayerControl.player1Control:testTrigger("menu_valid") then
		-- insert in score
		table.insert(game.highscores, {name=self.name, score=self.highscore})

		-- sort
		table.sort(game.highscores, function(k1, k2) return k1.score > k2.score end )

		-- remove last entry
		table.remove(game.highscores, #game.highscores)

		-- save highscore
		love.filesystem.write("highscores.lua", serialize(game.highscores))

		game.fsm:changeState(ThreadState.new(backToMenuThread))
	end
end

function newHighscoreState:exit()
	game:fadeOut()
	newHighscoreState.music:stop()
	game.scene:removeChild(self.view)
end

function gameOverThread()
	-- copy last tetromino
	gameState.gridEntity:copyTetromino(gameState.tetromino)

	-- and don't display it
	gameState.gridEntity:removeChild(gameState.tetromino)

	-- stop music
	gameState.music:stop()

	-- play lost music
	gameState.lostMusic:play()

	-- show game over
	gameState.gameOverText:animateTo(0, 85, 2048)

	-- fill the grid
	for y = 19,0, -1 do 
		for x = 0,9 do
			gameState.gridEntity.grid[y * 10 + x] = 7
		end

		wait(0.016)
	end

	wait(1)
	game:fadeOut()
	wait(0.3)

	-- new highscore?
	if gameState.score > game.highscores[10].score then
		-- display new highscore input menu
		newHighscoreState.highscore = gameState.score
		game.fsm:changeState(newHighscoreState)
	else
		game.fsm:changeState(menuState)
	end
end

function gameReadyThread()
	-- first show instruction

	-- fade in
	game:fadeIn()
	wait(0.2)

	-- wait for an input
	while not PlayerControl.player1Control:testTrigger("menu_valid") do
		coroutine.yield()
	end

	game.menuValidSound:stop()
	game.menuValidSound:play()

	-- let's go!
	gameState.view:animateTo(0, 0)
	gameState.instructionView:animateTo(-640, 0)

	-- setup text
	gameState.gameReadyText:moveTo(640, 85)	
	gameState.gameReadyText.text = "Get Ready!"


	-- wait for fade
	wait(0.2)

	-- show "get ready"
	gameState.gameReadyText:animateTo(0, 85, 2048)
	wait(1)

	-- hide get ready
	gameState.gameReadyText:animateTo(-640, 85, 2048)	
	wait(0.4)

	-- show 1
	gameState.gameReadyText:moveTo(640, 85)	
	gameState.gameReadyText.text = "1"
	gameState.gameReadyText:animateTo(0, 85, 2048)
	wait(0.4)
	gameState.ready1Sound:play()
	wait(0.4)
	gameState.gameReadyText:animateTo(-640, 85, 2048)	

	-- show 2
	gameState.gameReadyText:moveTo(640, 85)	
	gameState.gameReadyText.text = "2"
	gameState.gameReadyText:animateTo(0, 85, 2048)
	wait(0.4)
	gameState.ready1Sound:play()
	wait(0.4)
	gameState.gameReadyText:animateTo(-640, 85, 2048)	

	-- show 3
	gameState.gameReadyText:moveTo(640, 85)	
	gameState.gameReadyText.text = "3"
	gameState.gameReadyText:animateTo(0, 85, 2048)
	wait(0.4)
	gameState.ready2Sound:play()
	wait(0.4)
	gameState.gameReadyText:animateTo(-640, 85, 2048)	



	gameState.music:play()
	gameState.fsm:changeState(gameStatePlay)
end

function backToMainMenuThread()
	-- stop music
	gameState.music:stop()

	-- fade out
	game:fadeOut()
	wait(0.3)

	game.fsm:changeState(menuState)
end

inGameMenuState = { idx = 0}
function inGameMenuState:enter()
	if not self.window then
		self.window = Sprite.new(game.menuWindowImage, nil, 60, -360 + 40)
		game.scene:addChild(self.window)

		self.cancelButton = Button.new("Cancel", 15, 70)
		self.exitButton = Button.new("Exit", 105, 70)
		self.window:addChild(self.exitButton)
		self.window:addChild(self.cancelButton)
		self.window:addChild(Text.new("Are you sure you want to go back to main menu?", 20, 30, 160, "center"))
	else
		-- move window on top
		game.scene:removeChild(self.window)
		game.scene:addChild(self.window)	
	end

	self.idx = 0

	game.menuCancelSound:stop()
	game.menuCancelSound:play()
	self.window:animateTo(60, 40, 2048)
end

function inGameMenuState:update(dt)
	if PlayerControl.player1Control:testTrigger("left") and self.idx > 0 then
		self.idx = 0

		game.menuChangeSound:stop()
		game.menuChangeSound:play()
	end

	if PlayerControl.player1Control:testTrigger("right") and self.idx < 1 then
		self.idx = 1

		game.menuChangeSound:stop()
		game.menuChangeSound:play()
	end

	if PlayerControl.player1Control:testTrigger("menu_valid") then
		if self.idx == 0 then
			
			gameState.fsm:changeState(gameStatePlay)

			game.menuValidSound:stop()
			game.menuValidSound:play()	
		else
			gameState.fsm:changeState(ThreadState.new(backToMainMenuThread))

			game.menuCancelSound:stop()
			game.menuCancelSound:play()
		end
	end


	self.cancelButton.active = self.idx == 0
	self.exitButton.active = self.idx == 1
end

function inGameMenuState:exit()
	self.window:animateTo(60, -360 + 40, 2048)
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

	local tetromino = tetrominoShapes[self.index][self.orientation]

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

-- return true if tetromino shape collide with anything in the grid
function TetrominoGrid:collideWithGrid(tetrominoShape, tx, ty)
	for j = 0, 3 do
		for i = 0, 3 do
			local x = tx + i
			local y = ty + j
			if tetrominoShape[j * 4 + i + 1] ~= 0 then
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
	local shape = tetrominoShapes[tetromino.index][tetromino.orientation]
	return not self:collideWithGrid(shape, tetromino.gridX - 1, tetromino.gridY)
end

-- return true if tetromino can move right
function TetrominoGrid:canMoveRight(tetromino)
	-- test if there is a collison on the left
	local shape = tetrominoShapes[tetromino.index][tetromino.orientation]
	return not self:collideWithGrid(shape, tetromino.gridX + 1, tetromino.gridY)
end

-- return true if orientation is valid
function TetrominoGrid:canRotate(tetromino, newOrientation)
	-- test if there is a collison on the left
	local shape = tetrominoShapes[tetromino.index][newOrientation]
	return not self:collideWithGrid(shape, tetromino.gridX, tetromino.gridY)
end

-- return nil if at bottom
-- else return distance to bottom
function TetrominoGrid:canMoveDown(tetromino)
	-- test if there is a collison on the left
	local shape = tetrominoShapes[tetromino.index][tetromino.orientation]
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
	local shape = tetrominoShapes[tetromino.index][tetromino.orientation]
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

gameState.ready1Sound = love.audio.newSource("Sounds/ready1.wav", "static")
gameState.ready2Sound = love.audio.newSource("Sounds/ready2.wav", "static")

gameState.scoreFont = love.graphics.newImageFont("Gfx/score_font.png","0123456789")
gameState.scoreFont:setFilter("nearest", "nearest")

gameState.music = love.audio.newSource("Music/main_theme.xm", "stream")
gameState.lostMusic = love.audio.newSource("Music/lost.xm", "stream")

gameState.music:setLooping(true)

gameState.mode = "classic"
gameState.level = 0
gameState.levels = {[0] =  0.88,
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

-- create tiles quad
gameState.tileImage = love.graphics.newImage("Gfx/tiles.png")
gameState.tileQuad = {}
for i = 0, 7 do
	gameState.tileQuad[i] = love.graphics.newQuad(i * 8, 0, 8, 8, gameState.tileImage:getDimensions())
end

function gameState:enter()
	self.timer = 0

	self.lineCount = 0
	self.score = 0

	self.fall = false -- when true, it moves the tetromino to the bottom

	self.view = Entity.new(640, 0)
	game.scene:addChild(self.view)

	-- add element to the scene
	self.scorePanel = Entity.new(640,0)
	self.view:addChild(self.scorePanel)

	self.levelText = Text.new("Level " .. self.level, 0, 10)
	self.scorePanel:addChild(self.levelText)
	self.highscoreText = Text.new("Highscore" .. game.highscores[9].score, 0, 30)
	self.scorePanel:addChild(self.highscoreText)
	self.scoreText = Text.new("0", 0, 40)
	self.scorePanel:addChild(self.scoreText)
	self.scorePanel:addChild(Text.new("Line", 0, 60))
	self.linesText = Text.new("0", 0, 70)
	self.scorePanel:addChild(self.linesText)

	self.nextTetrominoPanel = Entity.new(-640 + 78, 10)
	self.view:addChild(self.nextTetrominoPanel)
	self.nextTetrominoPanel:addChild(Text.new("Next", 0, 0, 32, "left"))
	self.nextTetromino = TetrominoEntity.new(0, 20, 0, 0)
	self.nextTetrominoPanel:addChild(self.nextTetromino)

	self.gridBezel = Sprite.new(gameState.bezelImage, nil, 117, 367)
	self.view:addChild(self.gridBezel)

	self.gridEntity = TetrominoGrid.new(3, 3)
	self.gridBezel:addChild(self.gridEntity)

	self.tetromino = TetrominoEntity.new(0, 0, 0, 0)
	self.gridEntity:addChild(self.tetromino)

	self.scorePanel:animateTo(210, 0, 2048)
	self.nextTetrominoPanel:animateTo(78, 10, 2048)
	self.gridBezel:animateTo(117, 7, 2048)

	self.gameReadyText = Text.new("Get Ready!", 640, 85, 320, "center")
	self.view:addChild(self.gameReadyText)

	self.gameOverText = Text.new("Game Over", 640, 85, 320, "center")
	self.view:addChild(self.gameOverText)

	self.instructionView = Entity.new(0, 0)
	game.scene:addChild(self.instructionView)

	self.instructionView:addChild(Text.new("How to play", 0, 40, 320, "center"))
	self.instructionView:addChild(Text.new("Move", 40, 70, 80, "right"))
	self.instructionView:addChild(Text.new("Rotate", 40, 95, 80, "right"))
	self.instructionView:addChild(Text.new("Fall", 40, 120, 80, "right"))
	self.instructionView:addChild(Sprite.new(love.graphics.newImage("Gfx/controls.png"), nil, 140, 62))
	local startBtn = Button.new("Start", 120, 150)
	startBtn.active = true
	self.instructionView:addChild(startBtn)

	if self.mode == "challenge" then
		-- fill with some "noise"
		for y = 0, 3 + self.level / 4 do
			for x = 0,9 do
				local r = love.math.random()

				if r < 0.25 then
					self.gridEntity.grid[(19 - y) * 10 + x] = love.math.random(7)
				end
			end
		end
	end

	self:generateTetromino(love.math.random(7) - 1)

	self.fsm = FSM(ThreadState.new(gameReadyThread))
end

function gameState:exit()
	-- clean game scene
	game.scene:removeChild(self.view)
	game.scene:removeChild(self.instructionView)
end

-- generate a next tetromino and 
function gameState:generateTetromino(idx) 
	self.tetromino.index = idx
	self.tetromino.orientation = 0
	self.tetromino:moveToGrid(3, 0)

	-- next one
	self.nextTetromino.index = love.math.random(7) - 1
end

-- look for completed lines, remove them and update score
function gameState:updateGrid() 
	-- any line to remove?
	local lines = self.gridEntity:fullLines()
	local score = 10

	if #lines > 0 then
		for k, idx in ipairs(lines) do
			self.gridEntity:removeLine(idx)
		end

		self.lineCount = self.lineCount + #lines

		-- update score
		local points = 40
		if #lines == 2 then
			points = 100
		elseif #lines == 3 then
			points = 300
		elseif #lines == 4 then
			points = 1200
		end
		self.score = self.score + points * (self.level + 1)

		-- update level
		local levelUp = false
		local newLevel = math.max(math.floor(self.lineCount / 20), self.level)

		if self.level < newLevel then
			self.level = newLevel
			self.levelUpSound:rewind()
			self.levelUpSound:play()
		else 
			self.lineSound:rewind()
			self.lineSound:play()
		end
	end

	self.scoreText.text = self.score
	self.linesText.text = self.lineCount
	self.levelText.text = "Level " .. self.level
end

-- update tetromino
function gameState:updateTetromino(dt)
	-- move tetromino
	local bottom = false
	if self.fall then
		-- if falling, move it until we reach the bottom
		-- the tromino is animated for this

		-- current displayed grid position
		local _y = math.floor(self.tetromino.y / 8)
		bottom = _y == self.tetromino.gridY
	else
		-- move the tetromino down according to timer
		self.timer = self.timer + dt

		if self.timer > self.levels[self.level] then
			-- move tetromino down
			if self.gridEntity:canMoveDown(self.tetromino) then
				self.tetromino:animateToGrid(self.tetromino.gridX, self.tetromino.gridY + 1, 256)
			else
				-- can't move down
				bottom = true
			end

			-- reset timer
			self.timer = 0
		end
	end

	-- if the tetromino reach the end of the grid
	if bottom then
		-- copy tetromino to grid
		self.gridEntity:copyTetromino(self.tetromino)

		-- update the new grid
		self:updateGrid()

		-- generate a new tetromino
		self:generateTetromino(self.nextTetromino.index)

		-- reset timer
		self.timer = 0

		-- reset fall state
		self.fall = false

		-- are we stuck?
		if not self.gridEntity:canMoveDown(self.tetromino) then
			-- Game over!
			self.fsm:changeState(ThreadState.new(gameOverThread))
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

return gameState