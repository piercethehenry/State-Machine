-- StateMachine class represents a state machine that manages different states.
-- It allows creating states, shifting between states, and executing state-specific callbacks.
local StateMachine: { [any]: any } = { }
StateMachine.__index = StateMachine

-- Initializes a new instance of the StateMachine class.
-- Returns the created StateMachine object.
function StateMachine.init(): {}?
	-- Create a new StateMachine object
	local self = setmetatable({
		CurrentState = false,
		States = {}, 
		Exists = true       
	}, StateMachine)

	-- Initialize the StateMachine object
	self:__let()

	return self 
end 

-- secure_return function validates and returns the init function of a state.
-- It is an internal function and should not be called directly.
-- Parameters:
--   state: The state table to validate.
-- Returns:
--   The init function of the state.
function StateMachine:secure_return(state)
	assert(self, '?invalid parent')
	assert(type(state) == 'table', 'state must be a table')
	assert(state._init, `init function does not exist for state @{state}`)

	return state._init 
end 

-- __do function executes the current state's init function.
-- It is an internal function and should not be called directly.
function StateMachine:__do()
	while not self.CurrentState do 
		task.wait()
	end 

	local toReturn = self:secure_return(self.CurrentState)
	assert(toReturn, 'secure_return could not validate state')

	if self.on_activate and type(self.on_activate) == 'function' then 
		self.on_activate(self)
	end 

	toReturn(self)
end 

-- __validate function checks if a state table is valid.
-- It is an internal function and should not be called directly.
-- Parameters:
--   state: The state table to validate.
-- Returns:
--   true if the state table is valid, false otherwise.
function StateMachine:__validate(state: {}?)
	if not state._init or not state.active or not state._name or not state.conditions then 
		return false 
	end 

	return true
end 

-- __fix function fixes a specific problem in a state table.
-- It is an internal function and should not be called directly.
-- Parameters:
--   problem: The problem to fix.
--   input: The state table to fix.
function StateMachine:__fix(problem: string, input)
	if problem:lower() == 'no_conditions' then 
		input.conditions = {}
	end     
end 

-- __exit function executes the on_exit callback of the current state, if it exists.
-- It is an internal function and should not be called directly.
function StateMachine:__exit()
	if not self.CurrentState  then 
		return 
	end 

	if not self.CurrentState.conditions then 
		self:__fix('no_conditions', self.CurrentState)
	end

	if not self.CurrentState.conditions.on_exit then 
		return 
	end 

	self.CurrentState.conditions.on_exit(self)
end 

-- __identifier function returns the name of a state.
-- It is an internal function and should not be called directly.
-- Parameters:
--   state: The state table.
-- Returns:
--   The name of the state.
function StateMachine:__identifier(state: {}?)
	assert(state._name ~= nil, `state does not have a name`)

	return state._name
end 

-- __let function starts the state machine loop.
-- It is an internal function and should not be called directly.
function StateMachine:__let()
	task.spawn(function()
		while self and self.States and self.CurrentState ~= nil and self.Exists do 
			task.wait()
			self:__do()
			self:__exit()
		end 
	end)
end 

-- __search function searches for a state with the given index.
-- It is an internal function and should not be called directly.
-- Parameters:
--   index: The index to search for.
-- Returns:
--   true and the state table if found, false and nil otherwise.
function StateMachine:__search(index: string): boolean
	assert(#index >= 0, 'empty string cannot be an index')

	for _, v: { }? in next, self.States do 
		if self:__validate(v) and self:__identifier(v) == index then 
			return true, v
		end 
	end 

	return false, nil
end 

-- __push_back function adds a state to the state machine.
-- It is an internal function and should not be called directly.
-- Parameters:
--   state: The state table to add.
function StateMachine:__push_back(state: {}?)
	table.insert(self.States, state)
end 

-- create_state function creates a new state and adds it to the state machine.
-- Parameters:
--   index: The index of the state.
--   callback: The init function of the state.
--   conditions: Optional conditions table for the state.
function StateMachine:create_state(index: string, callback: ()->any?, conditions: {[string]:boolean})
	assert(self:__search(index) == false, `index @{index} already exists in the state machine`)

	local state = {
		_name = index,
		active = true,
		_init = callback,
		conditions = (conditions ~= nil and conditions) or ({})
	}

	local o_self = self 

	function state:identifier()
		return self._name
	end 

	function state:is_active()
		return self.active
	end

	function state:remove()
		table.clear(self)
		table.remove(o_self.States, table.find(o_self.States, self))
	end 

	o_self = nil 

	self:__push_back(state)
end 

-- shift_state function shifts the state machine to the state with the given index.
-- Parameters:
--   index: The index of the state to shift to.
function StateMachine:shift_state(index: string)
	assert(self:__search(index) == true, 'state does not exist')
	local e, state = self:__search(index)

	self.CurrentState = state
end

-- remove_state function removes the state with the index provided.
-- Parameters:
--          index: The index of the state to remove

function StateMachine:remove_state(index: string)
	assert(self:__search(index) == true, 'state does not exist')

	local s, state = self:__search(index)
	
	if state then 
		state:remove()
	end
end 
