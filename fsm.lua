local DummyState = {}

function DummyState:enter()
end

function DummyState:exit()
end

function DummyState:update(dt)
end

local FSM = { currentState = nil }
FSM.__index = FSM

function FSM.new(startState)
	local self = setmetatable({}, FSM)
	self:changeState(startState)

	return self
end

function FSM:changeState(newState)
	if self.currentState then
		self.currentState:exit()
	end

	self.currentState = newState
	self.currentState:enter()
end

function FSM:update(dt)
	self.currentState:update(dt)
end

setmetatable(FSM, { __call = function(_, ...) return FSM.new(...) end })

return FSM