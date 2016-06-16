local DummyState = {}

function DummyState:enter()
end

function DummyState:exit()
end

function DummyState:update(dt)
end

-- for coroutine
function wait(t)
	local startTime = love.timer.getTime()
	local endTime = startTime + t

	while love.timer.getTime() < endTime do
		coroutine.yield()
	end
end

ThreadState = {}
ThreadState.__index = ThreadState

function ThreadState:enter()
end

function ThreadState:exit()
end

function ThreadState:update(dt)

	local r, error = coroutine.resume(self.co)

	if not r then
		love.event.quit()
		print(error)
	end
end

function ThreadState.new(func)
	-- create coroutine
	local self = setmetatable({}, ThreadState)
	self.co = coroutine.create(func)

	return self
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