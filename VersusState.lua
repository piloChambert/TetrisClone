local VersusState = {}

function VersusState:enter()
	game:fadeIn()
	self.view = Entity.new(0, 0)
	game.scene:addChild(self.view)

	-- crate player 1 and 2 tables
	self.players = {}
	for i = 1, 2 do
		self.players[i] = {}
		self.players[i].rng = love.math.newRandomGenerator(8)

		if i == 1 then
			self.players[i].control = PlayerControl.player1Control
		else
			self.players[i].control = PlayerControl.player2Control
		end

		self.players[i].gridBezel = Sprite.new(game.bezelImage, nil, 27, 7)
		self.view:addChild(self.players[i].gridBezel)

		self.players[i].grid = TetrominoGrid.new(3, 3)
		self.players[i].gridBezel:addChild(self.players[i].grid)

		self.players[i].nextTetromino = TetrominoEntity.new(0, 20, 0, 0)
		self.view:addChild(self.players[i].nextTetromino)

		self.players[i].nextTetromino.index = self.players[i].rng:random(0, 6)
		self:generateNextTetromino(i)

		-- score
		self.players[i].scoreLabel = Text.new("0", 120, 10, 64, "right")
		self.view:addChild(self.players[i].scoreLabel)
		self.players[i].lineLabel = Text.new("0", 120, 30, 64, "right")
		self.view:addChild(self.players[i].lineLabel)
		self.players[i].levelLabel = Text.new("0", 120, 50, 64, "right")
		self.view:addChild(self.players[i].levelLabel)
	end

	self.players[1].gridBezel:moveTo(17, 7)
	self.players[1].nextTetromino:moveTo(120, 10)
	self.players[2].gridBezel:moveTo(217, 7)
	self.players[2].nextTetromino:moveTo(170, 10)

	self.view:addChild(Text.new("TIME", 140, 4, 40, "center"))
	self.timerLabel = Text.new("45", 140, 10, 40, "center", bigFont)
	self.timerLabel.color = {r = 255, g = 198, b = 0, a = 255}
	self.view:addChild(self.timerLabel)

	self.gameTime = 60

	--self.fsm = FSM(ThreadState.new(gameReadyThread))
end

function VersusState:exit()
	-- clean game scene
	game.scene:removeChild(self.view)
	self.view = nil
end

-- generate a next tetromino and 
function VersusState:generateNextTetromino(idx) 
	-- copye next tetromino idx to current
	self.players[idx].grid.tetromino.index = self.players[idx].nextTetromino.index
	self.players[idx].grid.tetromino.orientation = 0
	self.players[idx].grid.tetromino:moveToGrid(3, 0)

	-- generate next one
	self.players[idx].nextTetromino.index = self.players[idx].rng:random(0, 6)
end


function VersusState:update(dt)
	--self.fsm:update(dt)

	for i = 1,2 do
		local player = VersusState.players[i]

		if not player.grid.fall then
			-- rotate 
			if player.control:testTrigger("use") and player.grid:rotate() then
				game.rotateSound:stop()
				game.rotateSound:play()
			end

			if player.control:testTrigger("left") and player.grid:moveLeft() then
				game.moveSound:stop()		
				game.moveSound:play()
			end

			if player.control:testTrigger("right") and player.grid:moveRight() then
				game.moveSound:stop()		
				game.moveSound:play()
			end

			if player.control:testTrigger("attack") and player.grid:moveDown() then
				game.fallSound:stop()
				game.fallSound:play()
			end
		end

		local bottom, lineCount = player.grid:updateTetromino(dt) 
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
				player.grid.score = player.grid.score + points * (player.grid.level + 1)

				-- update level
				local levelUp = false
				local newLevel = math.min(math.max(math.floor(player.grid.lineCount / 20), player.grid.level), 10)

				if player.grid.level < newLevel then
					player.grid.fallTime = levelsFallTime[newLevel]
					player.grid.level = newLevel
					game.levelUpSound:rewind()
					game.levelUpSound:play()
				else 
					game.lineSound:rewind()
					game.lineSound:play()
				end
			end

			-- update score, line, etc
			player.scoreLabel.text = player.grid.score
			player.lineLabel.text = player.grid.lineCount
			player.levelLabel.text = "Level " .. player.grid.level

			-- generate a new tetromino
			VersusState:generateNextTetromino(i)

			-- are we stuck?
			if not player.grid:canMoveDown(player.grid.tetromino) then
				-- Game over!
				--gameState.fsm:changeState(ThreadState.new(gameOverThread))
			end
		end
	end

	-- timer
	VersusState.gameTime = VersusState.gameTime - dt
	VersusState.timerLabel.text = math.floor(VersusState.gameTime)
end

return VersusState