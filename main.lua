gameState = require "gameState"

gameFont = love.graphics.newImageFont("font.png"," !\"#$%&`()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_'abcdefghijklmnopqrstuvwxyz{|}")
gameFont:setFilter("nearest", "nearest")

button = {}
button.image = love.graphics.newImage("button.png")
button.image:setFilter("nearest", "nearest")
button.activeQuad = love.graphics.newQuad(0, 0, 80, 16, button.image:getDimensions())
button.quad = love.graphics.newQuad(0, 16, 80, 16, button.image:getDimensions())
button.smallImage = love.graphics.newImage("button_small.png")
button.smallImage:setFilter("nearest", "nearest")
button.smallActiveQuad = love.graphics.newQuad(0, 0, 16, 16, button.smallImage:getDimensions())
button.smallQuad = love.graphics.newQuad(0, 16, 16, 16, button.smallImage:getDimensions())

function button.draw(title, x, y, active, small)
	love.graphics.setFont(gameFont)

	local w = 80
	local image = button.image
	local quad = button.quad

	if active then
		quad = button.activeQuad
	end

	if small then
		w = 16
		image = button.smallImage
		quad = button.smallQuad

		if active then
			quad = button.smallActiveQuad
		end
	end


	if active then
		love.graphics.draw(image, quad, x, y)
	else
		love.graphics.draw(image, quad, x, y)		
	end

	love.graphics.printf(title, x, y + 4, w, "center")
end


function moveItem(pos, dest, speed)
	pos[1] = pos[1] + math.max(-speed, math.min(speed, dest[1] - pos[1]))
	pos[2] = pos[2] + math.max(-speed, math.min(speed, dest[2] - pos[2]))	
end

mainMenu = { 
	position = {640, 0},
	destPosition = {640, 0},
	selectedItem = 0
 }

function mainMenu:update(dt)
	moveItem(self.position, self.destPosition, 2048 * dt)	
end

function mainMenu:draw()
	love.graphics.push()
	love.graphics.translate(self.position[1], self.position[2])

	love.graphics.setColor(0, 0, 0, 255)
	love.graphics.printf("Main Menu", 1, 81, 320, "center")	
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.printf("Main Menu", 0, 80, 320, "center")

	button.draw("New Game", 70, 100, self.selectedItem == 0)
	button.draw("Highscore", 170, 100, self.selectedItem == 1)

	love.graphics.pop()
end

function mainMenu:keypressed(key, scancode, isrepeat)
	if key == "left" and self.selectedItem ~= 0 then
		self.selectedItem = 0
		titleState.menuChangeSound:rewind()
		titleState.menuChangeSound:play()		
	end

	if key == "right" and self.selectedItem ~= 1 then
		self.selectedItem = 1
		titleState.menuChangeSound:rewind()
		titleState.menuChangeSound:play()		
	end

	if key == "return" then
		-- hide
		titleState:showMenu(self, false, "left")

		if self.selectedItem == 0 then
			titleState:showMenu(gameModeMenu, true, "left")
		else
			-- show high score
			titleState:showLogo(false)
			titleState:showMenu(highscoreMenu, true, "left")
		end

		titleState.menuValidSound:rewind()
		titleState.menuValidSound:play()		
	end
end

gameModeMenu = { 
	position = {640, 0},
	destPosition = {640, 0},
	selectedItem = 0
 }

function gameModeMenu:update(dt)
	moveItem(self.position, self.destPosition, 2048 * dt)	
end

function gameModeMenu:draw()
	love.graphics.push()
	love.graphics.translate(self.position[1], self.position[2])

	love.graphics.setColor(0, 0, 0, 255)
	love.graphics.printf("Choose mode", 1, 81, 320, "center")	
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.printf("Choose mode", 0, 80, 320, "center")


	button.draw("Classic", 70, 100, self.selectedItem == 0)
	button.draw("Challenge", 170, 100, self.selectedItem == 1)

	love.graphics.pop()
end

function gameModeMenu:keypressed(key, scancode, isrepeat)
	if key == "left" and self.selectedItem ~= 0 then
		self.selectedItem = 0
		titleState.menuChangeSound:rewind()
		titleState.menuChangeSound:play()		
	end

	if key == "right" and self.selectedItem ~= 1 then
		self.selectedItem = 1
		titleState.menuChangeSound:rewind()
		titleState.menuChangeSound:play()		
	end

	if key == "return" then
		-- hide
		titleState:showMenu(self, false, "left")
		titleState:showMenu(levelMenu, true, "left")


		titleState.menuValidSound:rewind()
		titleState.menuValidSound:play()	
	end

	if key == "escape" then
		titleState:showMenu(self, false, "right")
		titleState:showMenu(mainMenu, true, "right")

		titleState.menuCancelSound:rewind()
		titleState.menuCancelSound:play()	
	end
end

levelMenu = { 
	position = {640, 0},
	destPosition = {640, 0},
	selectedItem = 0
 }

function levelMenu:update(dt)
	moveItem(self.position, self.destPosition, 2048 * dt)	
end

function levelMenu:draw()
	love.graphics.push()
	love.graphics.translate(self.position[1], self.position[2])

	love.graphics.setColor(0, 0, 0, 255)
	love.graphics.printf("Choose Level", 1, 81, 320, "center")	
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.printf("Choose Level", 0, 80, 320, "center")

	for i = 0, 9 do
		button.draw(i, 62 + i * 20, 100, self.selectedItem == i, true)
	end


	love.graphics.pop()
end

function levelMenu:keypressed(key, scancode, isrepeat)
	if key == "left" and self.selectedItem > 0 then
		self.selectedItem = self.selectedItem - 1

		titleState.menuChangeSound:rewind()
		titleState.menuChangeSound:play()	
	end

	if key == "right" and self.selectedItem < 9 then
		self.selectedItem = self.selectedItem + 1

		titleState.menuChangeSound:rewind()
		titleState.menuChangeSound:play()	
	end

	if key == "return" then
		titleState.menuValidSound:rewind()
		titleState.menuValidSound:play()	

		changeState(gameState)
	end

	if key == "escape" then

		titleState:showMenu(self, false, "right")
		titleState:showMenu(gameModeMenu, true, "right")


		titleState.menuCancelSound:rewind()
		titleState.menuCancelSound:play()	
	end
end

highscoreMenu = {
	position = {640, 0},
	destPosition = {640, 0},
	selectedItem = 0,
	smallLogo = love.graphics.newImage("logo_small.png")
}

function highscoreMenu:update(dt)
	moveItem(self.position, self.destPosition, 2048 * dt)	
end

function highscoreMenu:draw()
	love.graphics.push()
	love.graphics.translate(self.position[1], self.position[2])

	love.graphics.draw(self.smallLogo, 126, 10)

	love.graphics.setColor(0, 0, 0, 255)
	love.graphics.printf("Highscore", 1, 31, 320, "center")	
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.printf("Highscore", 0, 30, 320, "center")


	love.graphics.pop()
end

function highscoreMenu:keypressed(key, scancode, isrepeat)
	if key == "escape" then

		titleState:showMenu(self, false, "right")
		titleState:showMenu(mainMenu, true, "right")
		titleState:showLogo(true)


		titleState.menuCancelSound:rewind()
		titleState.menuCancelSound:play()	
	end
end

titleState = {}
titleState.background = love.graphics.newImage("menu_background.png")
titleState.logoImage = love.graphics.newImage("logo.png")
titleState.logoDestPosition = {89, -100}
titleState.logoPosition = {89, -100}
titleState.menuValidSound = love.audio.newSource("menu_valid.wav", "static")
titleState.menuChangeSound = love.audio.newSource("menu_change.wav", "static")
titleState.menuCancelSound = love.audio.newSource("menu_cancel.wav", "static")
titleState.displayedMenu = nil

function titleState:load()
	self:showLogo(true)
	self:showMenu(mainMenu, true, "left")
end

function titleState:showLogo(visible)
	if visible then
		self.logoDestPosition = {89, 20}
	else
		self.logoDestPosition = {89, -100}		
	end
end

function titleState:update(dt)
	moveItem(self.logoPosition, self.logoDestPosition, 1024 * dt)
	mainMenu:update(dt)
	gameModeMenu:update(dt)
	levelMenu:update(dt)
	highscoreMenu:update(dt)
end

function titleState:draw()
	love.graphics.draw(self.background)

	love.graphics.setColor(0, 0, 0, 255)
	love.graphics.print("Made by Pilo 2016", 1, 171)
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.print("Made by Pilo 2016", 0, 170)

	-- draw logo
	love.graphics.draw(self.logoImage, titleState.logoPosition[1], titleState.logoPosition[2])

	mainMenu:draw()
	gameModeMenu:draw()
	levelMenu:draw()
	highscoreMenu:draw()
end

function titleState:keypressed(key, scancode, isrepeat)
	if mainMenu.position[1] == 0 then
		mainMenu:keypressed(key, scan, code, isrepeat)
	end

	if gameModeMenu.position[1] == 0 then
		gameModeMenu:keypressed(key, scan, code, isrepeat)
	end

	if levelMenu.position[1] == 0 then
		levelMenu:keypressed(key, scan, code, isrepeat)
	end

	if highscoreMenu.position[1] == 0 then
		highscoreMenu:keypressed(key, scan, code, isrepeat)
	end
end

function titleState:showMenu(menu, visible, direction)
	if visible then
		menu.destPosition = {0, 0}

		if direction == "left" then
			menu.position = {640, 0}
		else
			menu.position = {-640, 0}
		end
	else
		menu.position = {0, 0}

		if direction == "left" then
			menu.destPosition = {-640, 0}
		else
			menu.destPosition = {640, 0}
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

currentState = nil
function changeState(state)
	currentState = state
	currentState:load()
end

function love.load()
	setupScreen()

	changeState(titleState)
end

function love.mousepressed(x, y, button)
end

function love.keypressed(key, scancode, isrepeat)
	if key == "escape" then
		--love.event.quit()
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