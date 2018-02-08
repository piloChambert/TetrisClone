FSM = require "fsm"
require "PlayerControl"
require "Entity"
serialize = require "ser"
gameState = require "gameState"
VersusState = require "VersusState"

require "tetrominos"


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

exitMenu = { idx = 0}
function exitMenu:enter()
	if not self.window then
		self.window = Sprite.new(game.menuWindowImage, nil, 60, -360 + 40)
		game.scene:addChild(self.window)

		self.cancelButton = Button.new("Cancel", 15, 70)
		self.exitButton = Button.new("Exit", 105, 70)
		self.window:addChild(self.exitButton)
		self.window:addChild(self.cancelButton)
		self.window:addChild(Text.new("Are you sure you want to quit?", 20, 30, 160, "center"))
	else
		-- move window on top
		game.scene:removeChild(self.window)
		game.scene:addChild(self.window)		
	end

	game.menuCancelSound:stop()
	game.menuCancelSound:play()
	self.window:animateTo(60, 40, 2048)
end

function exitMenu:update(dt)
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
			menuState.fsm:changeState(mainMenuState)

			game.menuValidSound:stop()
			game.menuValidSound:play()
		else
			love.event.quit()
		end
	end


	self.cancelButton.active = self.idx == 0
	self.exitButton.active = self.idx == 1
end

function exitMenu:exit()
	self.window:animateTo(60, -360 + 40, 2048)
end


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
			self.idx = self.idx - 1
			game.menuChangeSound:stop()
			game.menuChangeSound:play()
		end

		if PlayerControl.player1Control:testTrigger("right") and self.idx < 2 then
			self.idx = self.idx + 1

			game.menuChangeSound:stop()
			game.menuChangeSound:play()
		end

		if PlayerControl.player1Control:testTrigger("menu_valid") then
			menuState.mainMenu:animateTo(-640, 0, 2048)

			if self.idx == 0 then
				menuState.fsm:changeState(gameModeMenuState)
			elseif self.idx == 1 then
				menuState.fsm:changeState(ThreadState.new(startVerusGameThread))
			else
				menuState.fsm:changeState(highscoreMenuViewState)
			end

			game.menuValidSound:stop()
			game.menuValidSound:play()
		end

	if PlayerControl.player1Control:testTrigger("menu_back") then
		menuState.fsm:changeState(exitMenu)
	end

	end

	menuState.newgameButton.active = self.idx == 0
	menuState.versusButton.active = self.idx == 1
	menuState.highscoresButton.active = self.idx == 2
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

			-- set game mode
			if self.idx == 0 then
				gameState.mode = "classic"
			else
				gameState.mode = "challenge"
			end

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
	for i = 0, 10 do
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

		if PlayerControl.player1Control:testTrigger("right") and self.idx < 10 then
			self.idx = self.idx + 1

			game.menuChangeSound:stop()
			game.menuChangeSound:play()
		end

		if PlayerControl.player1Control:testTrigger("menu_valid") then
			menuState.levelMenu:animateTo(-640, 0, 2048)
			game:fadeOut()

			-- set level
			gameState.level = self.idx
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

	for i = 0, 10 do
		menuState.levelButtons[i+1].active = self.idx == i
	end
end

function levelMenuState:exit()
end

highscoreMenuViewState = {}
function highscoreMenuViewState:enter()
	menuState.logo:animateTo(89, -100, 1024)
	menuState.highscoreMenuView:animateTo(0, 0, 2048)

	-- sort highscore
	table.sort(game.highscores, function(k1, k2) return k1.score > k2.score end )

	-- set high score
	for i = 1, 10 do
		menuState.highscoresLabels[i].nameLabel.text = i .. ". " .. game.highscores[i].name
		menuState.highscoresLabels[i].scoreLabel.text = game.highscores[i].score
	end
end

function highscoreMenuViewState:update(dt)
	if PlayerControl.player1Control:testTrigger("menu_valid") then
		menuState.highscoreMenuView:animateTo(640, 0, 2048)
		menuState.logo:animateTo(89, 20, 1024)
		menuState.fsm:changeState(mainMenuState)

		game.menuCancelSound:stop()
		game.menuCancelSound:play()
	end

	if PlayerControl.player1Control:testTrigger("menu_back") then
		menuState.highscoreMenuView:animateTo(640, 0, 2048)
		menuState.logo:animateTo(89, 20, 1024)
		menuState.fsm:changeState(mainMenuState)

		game.menuCancelSound:stop()
		game.menuCancelSound:play()
	end
end

function highscoreMenuViewState:exit()
end

function startGameThread()
	game:fadeOut()
	wait(0.5)
	game.fsm:changeState(gameState)
end

function startVerusGameThread()
	game:fadeOut()
	wait(0.5)
	game.fsm:changeState(VersusState)
end

menuState = {}
menuState.music = love.audio.newSource("Music/menu_music.xm", "stream")
menuState.music:setLooping(true)

function menuState:enter()
	print("Menu")

	self.view = Entity.new(0, 0)
	game.scene:addChild(self.view)

	-- logo
	self.logo = Sprite.new(love.graphics.newImage("Gfx/logo.png"), nil, 89, -100)
	self.logo:animateTo(89, 20, 1024)
	self.view:addChild(self.logo)

	-- main menu
	self.mainMenu = Entity.new(640, 0)
	self.view:addChild(self.mainMenu)
	self.mainMenu:addChild(Text.new("Main Menu", 0, 80, 320, "center"))

	self.newgameButton = Button.new("New Game", 30, 100)
	self.mainMenu:addChild(self.newgameButton)
	self.newgameButton.active = true

	self.versusButton = Button.new("2 Players", 120, 100)
	self.mainMenu:addChild(self.versusButton)


	self.highscoresButton = Button.new("Highscores", 210, 100)
	self.mainMenu:addChild(self.highscoresButton)

	-- game mode menu
	self.gameModeMenu = Entity.new(640, 0)
	self.view:addChild(self.gameModeMenu)
	self.gameModeMenu:addChild(Text.new("Choose Mode", 0, 80, 320, "center"))

	self.classicButton = Button.new("Classic", 70, 100)
	self.gameModeMenu:addChild(self.classicButton)
	self.classicButton.active = true

	self.challengeButton = Button.new("Challenge", 170, 100)
	self.gameModeMenu:addChild(self.challengeButton)

	-- choose level
	self.levelMenu = Entity.new(640, 0)
	game.scene:addChild(self.levelMenu)
	self.levelMenu:addChild(Text.new("Choose Start Level", 0, 80, 320, "center"))

	self.levelButtons = {}
	for i = 0, 10 do 
		local btn = Button.new(i, 52 + i * 20, 100, true)
		self.levelMenu:addChild(btn)
		table.insert(self.levelButtons, btn)
	end

	self.levelButtons[1].active = true

	-- highscore
	self.highscoreMenuView = Entity.new(640, 0)
	self.view:addChild(self.highscoreMenuView)
	self.highscoreMenuView:addChild(Sprite.new(love.graphics.newImage("Gfx/logo_small.png"), nil, 126, 5))
	self.highscoreMenuView:addChild(Text.new("Highscores", 0, 25, 320, "center"))

	self.highscoresLabels = {}
	for i = 1, 10 do
		local nameLabel = Text.new(i .. ". Name", 90, 30 + i * 10, 140, "left")
		self.highscoreMenuView:addChild(nameLabel)
		local scoreLabel = Text.new(i .. "1545", 90, 30 + i * 10, 140, "right")
		self.highscoreMenuView:addChild(scoreLabel)

		-- shift the 10th lines alittle bit to the left
		if i == 10 then
			nameLabel:moveTo(nameLabel.x - 8, nameLabel.y)
		end

		table.insert(self.highscoresLabels, {nameLabel = nameLabel, scoreLabel = scoreLabel})
	end

	local backBtn = Button.new("Back", 120, 160)
	backBtn.active = true
	self.highscoreMenuView:addChild(backBtn)

	self.music:play()

	-- status text
	self.view:addChild(Text.new("Version 1.2", 0, 170, 320, "right"))
	self.view:addChild(Text.new("by Pilo", 0, 170, 320, "left"))

	if false then
		local dw, dh = love.window.getDesktopDimensions()
		self.view:addChild(Text.new(dw .. "x" .. dw, 0, 150, 320, "left"))		
	end

	self.fsm = FSM.new(mainMenuState)
end

function menuState:update(dt)
	self.fsm:update(dt)
end

function menuState:exit()
	-- remove element from scene
	game.scene:removeChild(self.view)

	self.music:stop()
end

game = {}
game.menuChangeSound = love.audio.newSource("Sounds/menu_change.wav", "static")
game.menuValidSound = love.audio.newSource("Sounds/menu_valid.wav", "static")
game.menuCancelSound = love.audio.newSource("Sounds/menu_cancel.wav", "static")

game.bezelImage = love.graphics.newImage("Gfx/bezel.png")
game.rotateSound = love.audio.newSource("Sounds/rotate.wav", "static")
game.moveSound = love.audio.newSource("Sounds/move.wav", "static")
game.fallSound = love.audio.newSource("Sounds/fall.wav", "static")
game.lineSound = love.audio.newSource("Sounds/line.wav", "static")
game.levelUpSound = love.audio.newSource("Sounds/level_up.wav", "static")
game.ready1Sound = love.audio.newSource("Sounds/ready1.wav", "static")
game.ready2Sound = love.audio.newSource("Sounds/ready2.wav", "static")
game.levelMusic = love.audio.newSource("Music/main_theme.xm", "stream")
game.levelMusic:setLooping(true)
game.lostMusic = love.audio.newSource("Music/lost.xm", "stream")

game.menuWindowImage = love.graphics.newImage("Gfx/menu_window.png")

function game:load()
	-- background
	self.backgroundImage = love.graphics.newImage("Gfx/menu_background.png")

	-- fade
	self.fadeDest = 255
	self.fadeValue = 255

	self.scene = Entity.new()

	-- load highscore
	self.highscores = { 	
		{name = "Super", score = 15520},
		{name = "Super", score = 12000},
		{name = "Super", score = 10000},
		{name = "Super", score = 8000},
		{name = "Super", score = 6000},
		{name = "Super", score = 4000},
		{name = "Super", score = 3000},
		{name = "Super", score = 2500},
		{name = "Super", score = 2000},
		{name = "Super", score = 0}
	}

	if love.filesystem.exists("highscores.lua") then
		local confChunk = love.filesystem.load("highscores.lua")

		local ok, result = pcall(confChunk)

		if not ok then 
			print("Error while running settings file : " .. tostring(result))
		else
			self.highscores = result
		end
	end

	--self.fsm = FSM.new(menuState)
	self.fsm = FSM.new(VersusState)
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
	PlayerControl.player2Control:update()
	game:update(dt)
end

function love.textinput(text)
	if game.fsm.currentState.textinput then
		game.fsm.currentState:textinput(text)
	end
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