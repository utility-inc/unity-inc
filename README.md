# Hive GUI Library

A Roblox Lua GUI library inspired by Hive server aesthetics with draggable windows and a modular component system. Designed for executors.

## Features

- **Draggable Window** - Click and drag the title bar to move the GUI
- **Right Shift Toggle** - Press Right Shift to show/hide the GUI
- **Custom Key System** - Enable custom keybinds for your features
- **Hive Theme** - Blue accent colors matching Hive server style
- **Built-in Components** - Labels, Buttons, Toggles, Sliders, Inputs
- **Re-execution Safety** - Automatically cleans up old GUI on re-execute
- **Attribute Tracking** - Track and restore player attributes

## Installation

```lua
local Hive = loadstring(game:HttpGet("https://raw.githubusercontent.com/utility-inc/unity-inc/main/libery.lua"))()
```

## Usage

```lua
local Hive = loadstring(game:HttpGet("https://raw.githubusercontent.com/utility-inc/unity-inc/main/libery.lua"))()

local GUI = Hive.new()

local Main = GUI:CreateSection("Main")
Main:CreateLabel("Welcome to Hive!")
Main:CreateButton("Click Me", function()
    print("Button clicked!")
end)

Main:CreateToggle(false, function(state)
    print("Toggle:", state)
end)

Main:CreateSlider(0, 100, 50, function(value)
    print("Slider value:", value)
end)

Main:CreateInput("Enter name...", function(text)
    print("Input:", text)
end)

GUI:EnableKeySystem()
GUI:BindKey(Enum.KeyCode.X, function()
    print("X key pressed!")
end)

GUI:BindKey(Enum.KeyCode.V, function()
    print("V key pressed!")
end)

GUI:SetAttribute("Speed", 50)
```

## API Reference

### Hive.new()
Creates a new Hive GUI instance.

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
    print("X pressed!")
end)
```

#### GUI:UnbindKey(key)
Removes a keybind.

#### GUI:SetToggleKey(key)
Changes the toggle key (default: RightShift).

### Attributes

#### GUI:SetAttribute(name, value)
Sets a player attribute and tracks it for restoration on re-execution.

#### GUI:GetAttribute(name)
Gets a player attribute value.

## Controls

- **Right Shift** - Toggle GUI visibility
- **Title Bar Drag** - Move the GUI window

## Theme Colors

- Background: RGB(25, 25, 35)
- Secondary: RGB(35, 35, 50)
- Accent: RGB(65, 105, 225)
- Accent Light: RGB(100, 149, 237)

## Version

v1.0.1
