FSM = require "FSM"
require "PlayerControl"
require "Entity"
gameState = require "gameState"

gameFont = love.graphics.newImageFont("Gfx/font.png"," !\"#$%&`()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_'abcdefghijklmnopqrstuvwxyz{|}")
gameFont:setFilter("nearest", "nearest")

mainMenuState = { idx = 0 }
function mainMenuState:enter()
	menuState.newgameButton.active = self.idx == 0
	menuState.highscoresButton.active = self.idx == 1	

	menuState.mainMenu:animateTo(0, 0, 2048)
	game:fadeIn()

	self.timer = 0
end

function mainMenuState:update(dt)
	-- doesn't allow input while animating
	self.timer = self.timer + dt
	if self.timer > 0.3 then
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
			menuState.mainMenu:animateTo(-640, 0, 2048)

			if self.idx == 0 then
				menuState.fsm:changeState(gameModeMenuState)
			else
				menuState.fsm:changeState(highscoreMenuState)
			end

			game.menuValidSound:stop()
			game.menuValidSound:play()
		end
	end

	menuState.newgameButton.active = self.idx == 0
	menuState.highscoresButton.active = self.idx == 1	
end

function mainMenuState:exit()
end

gameModeMenuState = { idx = 0 }
function gameModeMenuState:enter()
	menuState.classicButton.active = self.idx == 0
	menuState.challengeButton.active = self.idx == 1	

	menuState.gameModeMenu:animateTo(0, 0, 2048)

	self.timer = 0
end

function gameModeMenuState:update(dt)
	-- doesn't allow input while animating
	self.timer = self.timer + dt
	if self.timer > 0.3 then
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
			menuState.gameModeMenu:animateTo(-640, 0, 2048)
			menuState.fsm:changeState(levelMenuState)

			game.menuValidSound:stop()
			game.menuValidSound:play()
		end

		if PlayerControl.player1Control:testTrigger("menu_back") then
			menuState.gameModeMenu:animateTo(640, 0, 2048)
			menuState.fsm:changeState(mainMenuState)

			game.menuCancelSound:stop()
			game.menuCancelSound:play()
		end
	end

	menuState.classicButton.active = self.idx == 0
	menuState.challengeButton.active = self.idx == 1	
end

function gameModeMenuState:exit()
end

levelMenuState = { idx = 0 }
function levelMenuState:enter()
	for i = 0, 9 do
		menuState.levelButtons[i+1].active = self.idx == i
	end

	menuState.levelMenu:animateTo(0, 0, 2048)

	self.timer = 0
end

function levelMenuState:update(dt)
	-- doesn't allow input while animating
	self.timer = self.timer + dt
	if self.timer > 0.3 then
		if PlayerControl.player1Control:testTrigger("left") and self.idx > 0 then
			self.idx = self.idx - 1

			game.menuChangeSound:stop()
			game.menuChangeSound:play()
		end

		if PlayerControl.player1Control:testTrigger("right") and self.idx < 9 then
			self.idx = self.idx + 1

			game.menuChangeSound:stop()
			game.menuChangeSound:play()
		end

		if PlayerControl.player1Control:testTrigger("menu_valid") then
			menuState.levelMenu:animateTo(-640, 0, 2048)
			game:fadeOut()
			menuState.fsm:changeState(ThreadState.new(startGameThread))

			game.menuValidSound:stop()
			game.menuValidSound:play()
		end

		if PlayerControl.player1Control:testTrigger("menu_back") then
			menuState.levelMenu:animateTo(640, 0, 2048)
			menuState.fsm:changeState(gameModeMenuState)

			game.menuCancelSound:stop()
			game.menuCancelSound:play()
		end
	end

	for i = 0, 9 do
		menuState.levelButtons[i+1].active = self.idx == i
	end
end

function levelMenuState:exit()
end

highscoreMenuState = {}
function highscoreMenuState:enter()
	menuState.logo:animateTo(89, -100, 1024)
	menuState.highscoreMenu:animateTo(0, 0, 2048)
end

function highscoreMenuState:update(dt)
	if PlayerControl.player1Control:testTrigger("menu_valid") then
		menuState.highscoreMenu:animateTo(640, 0, 2048)
		menuState.logo:animateTo(89, 20, 1024)
		menuState.fsm:changeState(mainMenuState)

		game.menuCancelSound:stop()
		game.menuCancelSound:play()
	end

	if PlayerControl.player1Control:testTrigger("menu_back") then
		menuState.highscoreMenu:animateTo(640, 0, 2048)
		menuState.logo:animateTo(89, 20, 1024)
		menuState.fsm:changeState(mainMenuState)

		game.menuCancelSound:stop()
		game.menuCancelSound:play()
	end
end

function highscoreMenuState:exit()
end

function startGameThread()
	game:fadeOut()
	wait(0.5)
	game.fsm:changeState(gameState)
end

menuState = {}
function menuState:enter()
	print("Menu")

	-- logo
	self.logo = Sprite.new(love.graphics.newImage("Gfx/logo.png"), nil, 89, -100)
	self.logo:animateTo(89, 20, 1024)
	game.scene:addChild(self.logo)

	-- main menu
	self.mainMenu = Entity.new(640, 0)
	game.scene:addChild(self.mainMenu)
	self.mainMenu:addChild(Text.new("Main Menu", 0, 80, 320, "center"))

	self.newgameButton = Button.new("New Game", 70, 100)
	self.mainMenu:addChild(self.newgameButton)
	self.newgameButton.active = true

	self.highscoresButton = Button.new("Highscores", 170, 100)
	self.mainMenu:addChild(self.highscoresButton)

	-- game mode menu
	self.gameModeMenu = Entity.new(640, 0)
	game.scene:addChild(self.gameModeMenu)
	self.gameModeMenu:addChild(Text.new("Choose Mode", 0, 80, 320, "center"))

	self.classicButton = Button.new("Classic", 70, 100)
	self.gameModeMenu:addChild(self.classicButton)
	self.classicButton.active = true

	self.challengeButton = Button.new("Challenge", 170, 100)
	self.gameModeMenu:addChild(self.challengeButton)

	-- choose level
	self.levelMenu = Entity.new(640, 0)
	game.scene:addChild(self.levelMenu)
	self.levelMenu:addChild(Text.new("Choose Level", 0, 80, 320, "center"))

	self.levelButtons = {}
	for i = 0, 9 do 
		local btn = Button.new(i + 1, 62 + i * 20, 100, true)
		self.levelMenu:addChild(btn)
		table.insert(self.levelButtons, btn)
	end

	self.levelButtons[1].active = true

	-- highscore
	self.highscoreMenu = Entity.new(640, 0)
	game.scene:addChild(self.highscoreMenu)
	self.highscoreMenu:addChild(Sprite.new(love.graphics.newImage("Gfx/logo_small.png"), nil, 126, 5))
	self.highscoreMenu:addChild(Text.new("Highscores", 0, 25, 320, "center"))

	self.fsm = FSM.new(mainMenuState)
end

function menuState:update(dt)
	self.fsm:update(dt)
end

function menuState:exit()
	-- remove element from scene
	game.scene:removeChild(self.logo)
	game.scene:removeChild(self.mainMenu)
	game.scene:removeChild(self.gameModeMenu)
	game.scene:removeChild(self.levelMenu)
	game.scene:removeChild(self.highscoreMenu)
end

game = {}
game.menuChangeSound = love.audio.newSource("Sounds/menu_change.wav", "static")
game.menuValidSound = love.audio.newSource("Sounds/menu_valid.wav", "static")
game.menuCancelSound = love.audio.newSource("Sounds/menu_cancel.wav", "static")

function game:load()
	-- background
	self.backgroundImage = love.graphics.newImage("Gfx/menu_background.png")

	-- fade
	self.fadeDest = 255
	self.fadeValue = 255

	self.scene = Entity.new()
	self.fsm = FSM.new(menuState)
end

-- fade the screen in the next frames
function game:fadeOut()
	self.fadeDest = 255
end

-- fade the screen in the next frames
function game:fadeIn()
	self.fadeDest = 0
end

function game:update(dt)
	self.fsm:update(dt)
	self.scene:update(dt)

	-- update fade
	local fadeSpeed = 1024 * dt
	self.fadeValue = self.fadeValue + math.max(math.min(self.fadeDest - self.fadeValue, fadeSpeed), -fadeSpeed)
end

function game:draw()
	love.graphics.draw(self.backgroundImage)
	self.scene:draw()

	-- fade
	love.graphics.setColor(0, 0, 0, self.fadeValue)
	love.graphics.polygon("fill", 0, 0, 320, 0, 320, 180, 0, 180)
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


function love.load()
	setupScreen()

	game:load()
end

function love.mousepressed(x, y, button)
end

function love.keypressed(key, scancode, isrepeat)
	if key == "escape" then
		--love.event.quit()
	end
end

function love.update(dt)
	PlayerControl.player1Control:update()
	game:update(dt)
end

function love.draw()
		-- if we have a canvas
	if mainCanvas ~= nil then
		love.graphics.setCanvas(mainCanvas)
		love.graphics.clear()

		game:draw()

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