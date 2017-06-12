local gameStatePlay = {}
function gameStatePlay:enter()
end

function gameStatePlay:update(dt)
	-- check input

	if not gameState.gridEntity.fall then
		-- rotate 
		if PlayerControl.player1Control:testTrigger("use") and gameState.gridEntity:rotate() then
			game.rotateSound:stop()
			game.rotateSound:play()
		end

		if PlayerControl.player1Control:testTrigger("left") and gameState.gridEntity:moveLeft() then
			game.moveSound:stop()		
			game.moveSound:play()
		end

		if PlayerControl.player1Control:testTrigger("right") and gameState.gridEntity:moveRight() then
			game.moveSound:stop()		
			game.moveSound:play()
		end

		if PlayerControl.player1Control:testTrigger("attack") and gameState.gridEntity:moveDown() then
			game.fallSound:stop()
			game.fallSound:play()
		end
	end

	-- move tetromino
	local bottom, lineCount = gameState.gridEntity:updateTetromino(dt) 
	if bottom then
		if lineCount > 0 then
			-- update score
			local points = 40
			if lineCount == 2 then
				points = 100
			elseif lineCount == 3 then
				points = 300
			elseif lineCount == 4 then
				points = 1200
			end
			gameState.gridEntity.score = gameState.gridEntity.score + points * (gameState.gridEntity.level + 1)

			-- update level
			local levelUp = false
			local newLevel = math.min(math.max(math.floor(gameState.gridEntity.lineCount / 20), gameState.gridEntity.level), 10)

			if gameState.gridEntity.level < newLevel then
				gameState.gridEntity.fallTime = levelsFallTime[newLevel]
				gameState.gridEntity.level = newLevel
				game.levelUpSound:rewind()
				game.levelUpSound:play()
			else 
				game.lineSound:rewind()
				game.lineSound:play()
			end
		end

		-- update score, line, etc
		gameState.scoreText.text = gameState.gridEntity.score
		gameState.linesText.text = gameState.gridEntity.lineCount
		gameState.levelText.text = "Level " .. gameState.gridEntity.level

		-- generate a new tetromino
		gameState:generateTetromino(gameState.nextTetromino.index)

		-- are we stuck?
		if not gameState.gridEntity:canMoveDown(gameState.gridEntity.tetromino) then
			-- Game over!
			gameState.fsm:changeState(ThreadState.new(gameOverThread))
		end
	end

	
	if PlayerControl.player1Control:testTrigger("menu_back") then
		gameState.fsm:changeState(inGameMenuState)
	end
end

function gameStatePlay:exit()
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

		game.fsm:changeState(ThreadState.new(backToMainMenuThread))
	end
end

function newHighscoreState:exit()
	game:fadeOut()
	newHighscoreState.music:stop()
	game.scene:removeChild(self.view)
end

function gameOverThread()
	-- copy last tetromino
	gameState.gridEntity:copyTetromino(gameState.gridEntity.tetromino)

	-- and don't display it
	gameState.gridEntity:removeChild(gameState.gridEntity.tetromino)

	-- stop music
	game.levelMusic:stop()

	-- play lost music
	game.lostMusic:play()

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
	if gameState.gridEntity.score > game.highscores[10].score then
		-- display new highscore input menu
		newHighscoreState.highscore = gameState.gridEntity.score
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
	game.ready1Sound:play()
	wait(0.4)
	gameState.gameReadyText:animateTo(-640, 85, 2048)	

	-- show 2
	gameState.gameReadyText:moveTo(640, 85)	
	gameState.gameReadyText.text = "2"
	gameState.gameReadyText:animateTo(0, 85, 2048)
	wait(0.4)
	game.ready1Sound:play()
	wait(0.4)
	gameState.gameReadyText:animateTo(-640, 85, 2048)	

	-- show 3
	gameState.gameReadyText:moveTo(640, 85)	
	gameState.gameReadyText.text = "3"
	gameState.gameReadyText:animateTo(0, 85, 2048)
	wait(0.4)
	game.ready2Sound:play()
	wait(0.4)
	gameState.gameReadyText:animateTo(-640, 85, 2048)	



	game.levelMusic:play()
	gameState.fsm:changeState(gameStatePlay)
end

function backToMainMenuThread()
	-- fade out
	game:fadeOut()
	wait(0.3)

	game.fsm:changeState(menuState)
end

inGameMenuState = { idx = 0 }
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
			-- stop music
			game.levelMusic:stop()

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

local gameState = {}
gameState.mode = "classic"
function gameState:enter()
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

	self.gridBezel = Sprite.new(game.bezelImage, nil, 117, 367)
	self.view:addChild(self.gridBezel)

	self.gridEntity = TetrominoGrid.new(3, 3)
	self.gridBezel:addChild(self.gridEntity)

	self.gridEntity.level = self.level
	self.gridEntity.fallTime = levelsFallTime[self.level]

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
	self.gridEntity.tetromino.index = idx
	self.gridEntity.tetromino.orientation = 0
	self.gridEntity.tetromino:moveToGrid(3, 0)

	-- next one
	self.nextTetromino.index = love.math.random(7) - 1
end

function gameState:update(dt)
	self.fsm:update(dt)
end

return gameState