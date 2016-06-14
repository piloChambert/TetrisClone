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
end

function mainMenuState:update(dt)
	if PlayerControl.player1Control:testTrigger("left") and self.idx > 0 then
		self.idx = 0
	end

	if PlayerControl.player1Control:testTrigger("right") and self.idx < 1 then
		self.idx = 1
	end

	if PlayerControl.player1Control:testTrigger("start") then
		menuState.mainMenu:animateTo(-640, 0, 2048)

		if self.idx == 0 then
			menuState.fsm:changeState(gameModeMenuState)
		else
			menuState.fsm:changeState(highscoreMenuState)
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
end

function gameModeMenuState:update(dt)
	if PlayerControl.player1Control:testTrigger("left") and self.idx > 0 then
		self.idx = 0
	end

	if PlayerControl.player1Control:testTrigger("right") and self.idx < 1 then
		self.idx = 1
	end

	if PlayerControl.player1Control:testTrigger("start") then
		menuState.gameModeMenu:animateTo(-640, 0, 2048)
		menuState.fsm:changeState(levelMenuState)
	end

	if PlayerControl.player1Control:testTrigger("back") then
		menuState.gameModeMenu:animateTo(640, 0, 2048)
		menuState.fsm:changeState(mainMenuState)
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
end

function levelMenuState:update(dt)
	if PlayerControl.player1Control:testTrigger("left") and self.idx > 0 then
		self.idx = self.idx - 1
	end

	if PlayerControl.player1Control:testTrigger("right") and self.idx < 9 then
		self.idx = self.idx + 1
	end

	if PlayerControl.player1Control:testTrigger("start") then
		menuState.levelMenu:animateTo(-640, 0, 2048)
		game.fsm:changeState(gameState)
	end

	if PlayerControl.player1Control:testTrigger("back") then
		menuState.levelMenu:animateTo(640, 0, 2048)
		menuState.fsm:changeState(gameModeMenuState)
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
	if PlayerControl.player1Control:testTrigger("start") then
		menuState.highscoreMenu:animateTo(640, 0, 2048)
		menuState.logo:animateTo(89, 20, 1024)
		menuState.fsm:changeState(mainMenuState)
	end

	if PlayerControl.player1Control:testTrigger("back") then
		menuState.highscoreMenu:animateTo(640, 0, 2048)
		menuState.logo:animateTo(89, 20, 1024)
		menuState.fsm:changeState(mainMenuState)
	end
end

function highscoreMenuState:exit()
end

menuState = {}
function menuState:enter()
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
function game:load()
	-- background
	self.backgroundImage = love.graphics.newImage("Gfx/menu_background.png")

	self.scene = Entity.new()
	self.fsm = FSM.new(menuState)
end

function game:update(dt)
	self.fsm:update(dt)
	self.scene:update(dt)
end

function game:draw()
	love.graphics.draw(self.backgroundImage)
	self.scene:draw()
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