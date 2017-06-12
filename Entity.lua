Entity = {}
Entity.__index = Entity

function Entity.new(x, y)
	local self = setmetatable({}, Entity)

	self.x = x or 0
	self.y = y or 0
	self.targetX = x or 0
	self.targetY = y or 0
	self.animationSpeed = 1

	self.subItems = {}

	return self
end

function Entity:childIndex(child)
	assert(child ~= nil, "child can't be nil!")

	for k, v in ipairs(self.subItems) do
		if v == child then
			return k
		end
	end

	-- not found
	return -1
end

function Entity:addChild(child)
	assert(child ~= nil, "child can't be nil!")

	-- look for item index
	local idx = self:childIndex(child)

	-- if not in the list, then add it
	if idx == -1 then
		table.insert(self.subItems, child)
	end
end

function Entity:removeChild(child)
	assert(child ~= nil, "child can't be nil!")

	-- look for item index
	local idx = self:childIndex(child)

	if idx ~= -1 then
		table.remove(self.subItems, idx)
	end

end

function Entity:update(dt)
	-- update animation
	local speed = self.animationSpeed * dt
	self.x = self.x + math.max(-speed, math.min(speed, self.targetX - self.x))
	self.y = self.y + math.max(-speed, math.min(speed, self.targetY - self.y))

	-- update child
	for k, v in ipairs(self.subItems) do
		v:update(dt)
	end
end

function Entity:draw(parentX, parentY)
	local _x = self.x + (parentX or 0)
	local _y = self.y + (parentY or 0)

	-- draw child
	for k, v in ipairs(self.subItems) do
		v:draw(_x, _y)
	end	
end

function Entity:animateTo(x, y, speed)
	self.targetX = x
	self.targetY = y

	if speed then
		self.animationSpeed = speed
	else
		animationSpeed = 1
		self.x = x
		self.y = y
	end
end

function Entity:moveTo(x, y)
	self:animateTo(x, y)
end

Button = {}
Button.image = love.graphics.newImage("Gfx/button.png")
Button.image:setFilter("nearest", "nearest")
Button.activeQuad = love.graphics.newQuad(0, 0, 80, 16, Button.image:getDimensions())
Button.quad = love.graphics.newQuad(0, 16, 80, 16, Button.image:getDimensions())
Button.smallImage = love.graphics.newImage("Gfx/button_small.png")
Button.smallImage:setFilter("nearest", "nearest")
Button.smallActiveQuad = love.graphics.newQuad(0, 0, 16, 16, Button.smallImage:getDimensions())
Button.smallQuad = love.graphics.newQuad(0, 16, 16, 16, Button.smallImage:getDimensions())

function Button.new(title, x, y, small)
	local self = Entity.new(x, y)

	self.active = false
	self.small = small
	self.title = title

	self.draw = Button.draw

	return self
end

function Button:draw(parentX, parentY)
	local _x = self.x + parentX
	local _y = self.y + parentY

	love.graphics.setColor(255, 255, 255, 255)

	local w = 80
	local image = Button.image
	local quad = Button.quad

	if self.active then
		quad = Button.activeQuad
	end

	if self.small then
		w = 16
		image = Button.smallImage
		quad = Button.smallQuad

		if self.active then
			quad = Button.smallActiveQuad
		end
	end


	if active then
		love.graphics.draw(image, quad, _x, _y)
	else
		love.graphics.draw(image, quad, _x, _y)		
	end

	if self.active then
		local t = math.floor(love.timer.getTime()*8)
		if t % 2 == 0 then
			love.graphics.setColor(128, 128, 128, 255)
		end
	end

	love.graphics.setFont(gameFont)
	love.graphics.printf(self.title, _x, _y + 4, w, "center")

	Entity.draw(self, parentX, parentY)
end

Text = {}
function Text.new(text, x, y, width, align)
	local self = Entity.new(x, y)

	self.text = text
	self.draw = Text.draw
	self.width = width
	self.align = align 

	return self
end

function Text:draw(parentX, parentY)
	local _x = self.x + parentX
	local _y = self.y + parentY

	love.graphics.setFont(gameFont)

	love.graphics.setColor(0, 0, 0, 255)
	if self.width and self.align then
		love.graphics.printf(self.text, _x + 1, _y + 1, self.width, self.align)	
	else
		love.graphics.print(self.text, _x + 1, _y + 1)
	end

	love.graphics.setColor(255, 255, 255, 255)
	if self.width and self.align then
		love.graphics.printf(self.text, _x, _y, self.width, self.align)	
	else
		love.graphics.print(self.text, _x, _y)
	end

	Entity.draw(self, parentX, parentY)
end

Sprite = {}
function Sprite.new(image, quad, x, y)
	local self = Entity.new(x, y)

	self.quad = quad
	self.image = image
	self.draw = Sprite.draw

	return self	
end

function Sprite:draw(parentX, parentY)
	local _x = self.x + parentX
	local _y = self.y + parentY

	love.graphics.setColor(255, 255, 255, 255)

	if quad then
		love.graphics.draw(self.image, self.quad, _x, _y)
	else
		love.graphics.draw(self.image, _x, _y)
	end

	Entity.draw(self, parentX, parentY)
end

gameFont = love.graphics.newImageFont("Gfx/font.png"," !\"#$%&`()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_'abcdefghijklmnopqrstuvwxyz{|}~µ", 1)
gameFont:setFilter("nearest", "nearest")
