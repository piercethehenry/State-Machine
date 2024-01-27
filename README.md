State Machine 🌟
Welcome to the State Machine project! This is an efficient and flexible Lua-based state machine, perfect for managing states in your applications, especially suited for environments like Roblox.

To get started with State Machine, follow these simple steps:

Clone the repository

bash
Copy code
git clone https://github.com/yourusername/statemachine.git
Navigate to the project directory

bash
Copy code
cd statemachine
Include the State Machine in your Lua project

Simply add the statemachine.lua file to your project directory.

Documentation 📖
The State Machine is designed to be simple yet flexible. Here's how you can get started:

Initializing a State Machine

```lua
local myStateMachine = stateMachine.init()
myStateMachine --> {
    CurrentState: BOOLEAN,
    States: TABLE,
    Exists: BOOLEAN (INTERNAL)
  }
```
Creating a State

```lua

-- Defining a state
myStateMachine:create_state("StateName", function(s) 
     print(s._name)
end, {
    on_active = function(s)
        print(s._name, 'is active!')
    end,
    on_exit = function(s)
        print(s._name, 'exited!')
    end
})

-- Shifting States

myStateMachine:shift_state("StateName") -- The current state will be shifted and will continously run StateName's ._init callback.
```
For more detailed information, refer to the code comments in statemachine.lua.
Examples 🌈
Here's a simple example of using the State Machine:

```lua

-- Initialize the state machine
local myStateMachine = stateMachine.init()

-- Create states
myStateMachine:create_state("Idle", function()
    print("Currently in Idle state")
end)

myStateMachine:create_state("Running", function()
    print("Currently Running")
end)

-- Shift to a state
myStateMachine:shift_state("Idle")
```

Contributing 🤝
Contributions are what make the open-source community such an amazing place to learn, inspire, and create. Any contributions you make are greatly appreciated.

Fork the Project
Create your Feature Branch (git checkout -b feature/AmazingFeature)
Commit your Changes (git commit -m 'Add some AmazingFeature')
Push to the Branch (git push origin feature/AmazingFeature)
Open a Pull Request
License 📄
Distributed under the MIT License. See LICENSE for more information.

Contact 📧
Discord: henry.zf

Project Link: https://github.com/yourusername/statemachine

