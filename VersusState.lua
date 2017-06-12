local VersusState = {}

function VersusState:enter()
	game:fadeIn()
	self.view = Entity.new(0, 0)
	game.scene:addChild(self.view)

	-- player 1
	self.player1Gridbezel = Sprite.new(game.bezelImage, nil, 27, 7)
	self.view:addChild(self.player1Gridbezel)
	self.player1Grid = TetrominoGrid.new(3, 3)
	self.player1Gridbezel:addChild(self.player1Grid)

	self.nextPlayer1Tetromino = TetrominoEntity.new(0, 20, 0, 0)
	self.view:addChild(self.nextPlayer1Tetromino)

	self.player2Gridbezel = Sprite.new(game.bezelImage, nil, 207, 7)
	self.view:addChild(self.player2Gridbezel)
	self.player2Grid = TetrominoGrid.new(3, 3)
	self.player2Gridbezel:addChild(self.player2Grid)

	self.nextPlayer2Tetromino = TetrominoEntity.new(0, 20, 0, 0)
	self.view:addChild(self.nextPlayer2Tetromino)



	self:generatePlayer1Tetromino(love.math.random(7) - 1)
	self:generatePlayer2Tetromino(love.math.random(7) - 1)

	--self.fsm = FSM(ThreadState.new(gameReadyThread))
end

function VersusState:exit()
	-- clean game scene
	game.scene:removeChild(self.view)
end

function VersusState:update(dt)
	--self.fsm:update(dt)

	if not VersusState.player1Grid.fall then
		-- rotate 
		if PlayerControl.player1Control:testTrigger("use") and VersusState.player1Grid:rotate() then
			game.rotateSound:stop()
			game.rotateSound:play()
		end

		if PlayerControl.player1Control:testTrigger("left") and VersusState.player1Grid:moveLeft() then
			game.moveSound:stop()		
			game.moveSound:play()
		end

		if PlayerControl.player1Control:testTrigger("right") and VersusState.player1Grid:moveRight() then
			game.moveSound:stop()		
			game.moveSound:play()
		end

		if PlayerControl.player1Control:testTrigger("attack") and VersusState.player1Grid:moveDown() then
			game.fallSound:stop()
			game.fallSound:play()
		end
	end

	local bottom, lineCount = VersusState.player1Grid:updateTetromino(dt) 
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
			VersusState.player1Grid.score = VersusState.player1Grid.score + points * (VersusState.player1Grid.level + 1)

			-- update level
			local levelUp = false
			local newLevel = math.min(math.max(math.floor(VersusState.player1Grid.lineCount / 20), VersusState.player1Grid.level), 10)

			if VersusState.player1Grid.level < newLevel then
				VersusState.player1Grid.fallTime = levelsFallTime[newLevel]
				VersusState.player1Grid.level = newLevel
				game.levelUpSound:rewind()
				game.levelUpSound:play()
			else 
				game.lineSound:rewind()
				game.lineSound:play()
			end
		end

		-- update score, line, etc
		--gameState.scoreText.text = gameState.gridEntity.score
		--gameState.linesText.text = gameState.gridEntity.lineCount
		--gameState.levelText.text = "Level " .. gameState.gridEntity.level

		-- generate a new tetromino
		VersusState:generatePlayer1Tetromino(VersusState.nextPlayer1Tetromino.index)

		-- are we stuck?
		if not VersusState.player1Grid:canMoveDown(VersusState.player1Grid.tetromino) then
			-- Game over!
			--gameState.fsm:changeState(ThreadState.new(gameOverThread))
		end
	end

	if not VersusState.player2Grid.fall then
		-- rotate 
		if PlayerControl.player2Control:testTrigger("use") and VersusState.player2Grid:rotate() then
			game.rotateSound:stop()
			game.rotateSound:play()
		end

		if PlayerControl.player2Control:testTrigger("left") and VersusState.player2Grid:moveLeft() then
			game.moveSound:stop()		
			game.moveSound:play()
		end

		if PlayerControl.player2Control:testTrigger("right") and VersusState.player2Grid:moveRight() then
			game.moveSound:stop()		
			game.moveSound:play()
		end

		if PlayerControl.player2Control:testTrigger("attack") and VersusState.player2Grid:moveDown() then
			game.fallSound:stop()
			game.fallSound:play()
		end
	end

	local bottom, lineCount = VersusState.player2Grid:updateTetromino(dt) 
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
			VersusState.player2Grid.score = VersusState.player2Grid.score + points * (VersusState.player2Grid.level + 1)

			-- update level
			local levelUp = false
			local newLevel = math.min(math.max(math.floor(VersusState.player2Grid.lineCount / 20), VersusState.player2Grid.level), 10)

			if VersusState.player2Grid.level < newLevel then
				VersusState.player2Grid.fallTime = levelsFallTime[newLevel]
				VersusState.player2Grid.level = newLevel
				game.levelUpSound:rewind()
				game.levelUpSound:play()
			else 
				game.lineSound:rewind()
				game.lineSound:play()
			end
		end

		-- update score, line, etc
		--gameState.scoreText.text = gameState.gridEntity.score
		--gameState.linesText.text = gameState.gridEntity.lineCount
		--gameState.levelText.text = "Level " .. gameState.gridEntity.level

		-- generate a new tetromino
		VersusState:generatePlayer2Tetromino(VersusState.nextPlayer2Tetromino.index)

		-- are we stuck?
		if not VersusState.player2Grid:canMoveDown(VersusState.player2Grid.tetromino) then
			-- Game over!
			--gameState.fsm:changeState(ThreadState.new(gameOverThread))
		end
	end
end

-- generate a next tetromino and 
function VersusState:generatePlayer1Tetromino(idx) 
	self.player1Grid.tetromino.index = idx
	self.player1Grid.tetromino.orientation = 0
	self.player1Grid.tetromino:moveToGrid(3, 0)

	-- next one
	self.nextPlayer1Tetromino.index = love.math.random(7) - 1
end

function VersusState:generatePlayer2Tetromino(idx) 
	self.player2Grid.tetromino.index = idx
	self.player2Grid.tetromino.orientation = 0
	self.player2Grid.tetromino:moveToGrid(3, 0)

	-- next one
	self.nextPlayer2Tetromino.index = love.math.random(7) - 1
end

return VersusState