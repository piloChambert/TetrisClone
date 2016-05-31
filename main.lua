gameState = {}

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

	self.background = love.graphics.newImage("level1_background.png")
end

function gameState:generateTetromino(idx) 
	self.tetromino = {
		idx = idx,
		orientation = 0,
		x = 3,
		y = 0
	}
end

-- return true if tetromino collide with anything in the grid
function gameState:collide(tetromino, tx, ty)
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
	return not self:collide(tetrominos[self.tetromino.idx][self.tetromino.orientation], self.tetromino.x - 1, self.tetromino.y)
end

function gameState:canMoveRight()
	return not self:collide(tetrominos[self.tetromino.idx][self.tetromino.orientation], self.tetromino.x + 1, self.tetromino.y)
end

function gameState:canMoveDown()
	return not self:collide(tetrominos[self.tetromino.idx][self.tetromino.orientation], self.tetromino.x, self.tetromino.y + 1)
end

function gameState:canRotateTo(orient) 
	return not self:collide(tetrominos[self.tetromino.idx][orient], self.tetromino.x, self.tetromino.y)
end

-- return the list of fill lines
function gameState:fullLines()
	local res = {}

	for j = 0, 19 do
		local full = true

		for i = 0, 9 do
			if self.grid[j * 10 + i] == -1 then
				full = false
				break
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
	end

	-- new blank line at top
	for i = 0, 9 do
		self.grid[i] = -1
	end
end

function gameState:moveTetrominoDown()
	local bottom = false
	if self:canMoveDown() then
		-- move down
		self.tetromino.y = self.tetromino.y + 1

		bottom = false
	else
		-- copy tetromino to grid
		self:copyTetromino()

		-- any line to remove?
		local lines = self:fullLines()
		local score = 10
		if #lines > 0 then
			for k, idx in ipairs(lines) do
				print(idx)
				self:removeLine(idx)
			end

			-- incremente score
			self.score = self.score + score

			-- extra bonus for multiple lines
			score = score + 5
		end

		self.lineCount = self.lineCount + #lines

		-- generate a new tetromino
		self:generateTetromino(self.nextTetromino)
		self.nextTetromino = love.math.random(7) - 1

		bottom  = true
	end

	return bottom
end

function gameState:update(dt)
	-- move the tetromino down
	self.timer = self.timer + dt

	if self.timer > 1.0 then
		self:moveTetrominoDown()

		-- reset timer
		self.timer = 0
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

function gameState:draw()
	-- draw background
	love.graphics.draw(self.background)

	-- draw a simple frame
	love.graphics.setColor(0, 0, 0, 230)
	love.graphics.polygon("fill", 120, 10, 200, 10, 200, 170, 120, 170)
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.polygon("line", 119.5, 9.5, 200.5, 9.5, 200.5, 170.5, 119.5, 170.5)

	-- draw the grid
	love.graphics.push()
	love.graphics.translate(120, 10)


	for y = 0,19 do
		for x = 0,9 do
			local tile = self.grid[y * 10 + x]
			if tile ~= -1 then
				love.graphics.draw(self.tileImage, self.tileQuad[tile], x * 8, y * 8)
			end
		end
	end	

	-- draw tetromino
	self:drawTetromino(self.tetromino.idx, self.tetromino.orientation, self.tetromino.x * 8, self.tetromino.y * 8)

	love.graphics.pop()

	-- draw next
	love.graphics.print("Next:", 220, 80)	
	self:drawTetromino(self.nextTetromino, 0, 220, 100)	

	love.graphics.print("Lines:" .. self.lineCount, 220, 20)
	love.graphics.print("Score:" .. self.score, 220, 30)	
	love.graphics.print("Level:" .. self.level, 220, 40)	

end

function gameState:keypressed(key, scancode, isrepeat)
	if key == "kp5" then
		local newOrient = (self.tetromino.orientation + 1) % 4
		if self:canRotateTo(newOrient) then
			self.tetromino.orientation = newOrient
		end
	end

	if key == "kp4" and self:canMoveLeft() then
		self.tetromino.x = self.tetromino.x - 1
	end

	if key == "kp6" and self:canMoveRight() then
		self.tetromino.x = self.tetromino.x + 1
	end

	if key == "kp2" then
		-- move down as much as possible
		while not self:moveTetrominoDown() do
		end
	end
end

-- screen configuration
canvasConfiguration = {
	width = 320, 
	height = 180,
	scale = 1,
	offset = {x = 0, y = 0}
}

configuration = {
	windowedScreenScale = 4,
	fullscreen = false,
	azerty = false
}

local mainCanvas
function setupScreen()
	canvasConfiguration.scale = configuration.windowedScreenScale 

	if configuration.fullscreen then
		local dw, dh = love.window.getDesktopDimensions()
		--print(dw, dh)

		canvasConfiguration.scale = math.floor(math.min(dw / canvasConfiguration.width, dh / canvasConfiguration.height))
		canvasConfiguration.offset.x = (dw - (canvasConfiguration.width * canvasConfiguration.scale)) * 0.5
		canvasConfiguration.offset.y = (dh - (canvasConfiguration.height * canvasConfiguration.scale)) * 0.5
	else
		canvasConfiguration.offset.x = 0
		canvasConfiguration.offset.y = 0
	end

	local windowW = canvasConfiguration.width * canvasConfiguration.scale
	local windowH = canvasConfiguration.height * canvasConfiguration.scale
	love.window.setMode(windowW, windowH, {fullscreen = configuration.fullscreen})

	local formats = love.graphics.getCanvasFormats()
	if formats.normal then
		mainCanvas = love.graphics.newCanvas(canvasConfiguration.width, canvasConfiguration.height)
		mainCanvas:setFilter("nearest", "nearest")
	end
end

local currentState = gameState
function love.load()
	setupScreen()

	local font = love.graphics.newImageFont("font.png"," !\"#$%&`()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_'abcdefghijklmnopqrstuvwxyz{|}")
    font:setFilter("nearest", "nearest")
    love.graphics.setFont(font)

	currentState:load()
end

function love.mousepressed(x, y, button)
end

function love.keypressed(key, scancode, isrepeat)
	if key == "escape" then
		love.event.quit()
	end

	currentState:keypressed(key, scancode, isrepeat)
end

function love.update(dt)
	currentState:update(dt)
end

function love.draw()
		-- if we have a canvas
	if mainCanvas ~= nil then
		love.graphics.setCanvas(mainCanvas)
		love.graphics.clear()
		--mainCanvas:clear()

		currentState:draw()

		love.graphics.setColor(255, 255, 255, 255)

		love.graphics.setCanvas()
		love.graphics.draw(mainCanvas, canvasConfiguration.offset.x, canvasConfiguration.offset.y, 0, canvasConfiguration.scale, canvasConfiguration.scale)
	else
		-- else print an error
	    local y = 0
    	for formatname, formatsupported in pairs(canvasformats) do
        	local str = string.format("Supports format '%s': %s", formatname, tostring(formatsupported))
        	love.graphics.print(str, 10, y)
        	y = y + 20
    	end
	end
end