# Hive GUI Library

A Roblox Lua GUI library inspired by Hive server aesthetics with draggable windows and a modular component system. Designed for executors.

## Features

- **Draggable Window** - Click and drag the title bar to move the GUI
- **Right Shift Toggle** - Press Right Shift to show/hide the GUI
- **Custom Key System** - Enable custom keybinds for your features
- **Hive Theme** - Blue accent colors matching Hive server style
- **Built-in Components** - Labels, Buttons, Toggles, Sliders, Inputs
- **Re-execution Safety** - Automatically cleans up old GUI on re-execute
- **Data Persistence** - Save and load settings per script
- **Script Folders** - Each script gets its own folder in HiveData

## Installation

```lua
local Hive = loadstring(game:HttpGet("https://raw.githubusercontent.com/utility-inc/unity-inc/main/library.lua"))()
```

## Usage

```lua
local Hive = loadstring(game:HttpGet("https://raw.githubusercontent.com/utility-inc/unity-inc/main/library.lua"))()

local GUI = Hive.new("MyScript")

local Main = GUI:CreateSection("Welcome")
Main:CreateLabel("Welcome to Hive GUI!")
Main:CreateLabel("Press Right Shift to toggle")

local Button = GUI:CreateSection("Button Example")
Button:CreateButton("Notify", function()
    -- Button action
end)

local Toggles = GUI:CreateSection("Toggles")
local ExampleToggle = Toggles:CreateToggle(false, function(state)
    -- Toggle action
end)

local Sliders = GUI:CreateSection("Sliders")
Sliders:CreateLabel("Example Slider")
local ExampleSlider = Sliders:CreateSlider(0, 100, 50, function(value)
    -- Slider action
end)

GUI:EnableKeySystem()
GUI:BindKey(Enum.KeyCode.V, function()
    GUI:Toggle()
end)
```

## API Reference

### Hive.new(scriptName)
Creates a new Hive GUI instance.
- `scriptName`: Optional name for the script (creates separate data folder)

### GUI:CreateSection(name)
Creates a new section with the given name.
- Returns a section object with methods to create components

### Section Methods

#### section:CreateLabel(text)
Creates a text label.

#### section:CreateButton(text, callback)
Creates a clickable button.

#### section:CreateToggle(defaultState, callback)
Creates a toggle switch.
- `defaultState`: boolean (true/false)
- `callback(state)`: Called when toggle changes

#### section:CreateSlider(min, max, default, callback)
Creates a slider.
- `min`: Minimum value
- `max`: Maximum value  
- `default`: Starting value
- `callback(value)`: Called when slider value changes

#### section:CreateInput(placeholder, callback)
Creates a text input box.
- `placeholder`: Placeholder text
- `callback(text)`: Called when user presses Enter

### Key System

#### GUI:EnableKeySystem()
Enables custom keybinds.

#### GUI:BindKey(key, callback)
Binds a key to a callback.
```lua
GUI:BindKey(Enum.KeyCode.X, function()
    -- Action
end)
```

#### GUI:UnbindKey(key)
Removes a keybind.

#### GUI:SetToggleKey(key)
Changes the toggle key (default: RightShift).

### Data Persistence

#### GUI:Save(key, value)
Saves a value to the script's data folder.
```lua
GUI:Save("MySetting", true)
```

#### GUI:Load(key)
Loads a saved value.
```lua
local value = GUI:Load("MySetting")
```

## Controls

- **Right Shift** - Toggle GUI visibility
- **Title Bar Drag** - Move the GUI window

## Theme Colors

- Background: RGB(25, 25, 35)
- Secondary: RGB(35, 35, 50)
- Accent: RGB(65, 105, 225)
- Accent Light: RGB(100, 149, 237)

## Version

v1.0.2
