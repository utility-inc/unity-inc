# HiveLib

A legitimate Roblox utility library for creating custom GUIs.

## Features

- Draggable window
- Customizable buttons, toggles, sliders, text boxes
- Keybind system (toggle GUI + custom keybinds)
- Notification system
- Theme support (dark mode by default)
- Section headers and separators

## Usage

### Loadstring

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/utility-inc/unity-inc/main/HiveLib.lua"))()
```

### Full Example

```lua
local HiveLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/utility-inc/unity-inc/main/HiveLib.lua"))()

-- Create the GUI
local gui = HiveLib:CreateGui()

-- Set toggle key (Press ESC to toggle GUI)
HiveLib:SetToggleKey(Enum.KeyCode.Escape)

-- Add custom keybind
HiveLib:AddKeybind("Print Hello", Enum.KeyCode.H, function()
    print("Hello! Keybind pressed.")
end)

-- Add components
HiveLib:AddButton("Click Me", function()
    HiveLib:Notification("Hello", "You clicked the button!", 3)
end)

HiveLib:AddToggle("Enable Feature", false, function(state)
    print("Feature enabled:", state)
end)

HiveLib:AddSlider("Volume", 0, 100, 50, function(value)
    print("Volume:", value)
end)

HiveLib:AddTextBox("Name", "Enter name...", function(text)
    print("Name:", text)
end)

HiveLib:AddLabel("This is a label")

HiveLib:AddSeparator()

HiveLib:AddSection("More Options")

HiveLib:AddButton("Another Button", function()
    print("Button clicked")
end)
```

## API Reference

### Core Functions

| Function | Description |
|----------|-------------|
| `HiveLib.new()` | Create a new HiveLib instance |
| `HiveLib:CreateGui()` | Create the main GUI window |
| `HiveLib:Show()` | Show the GUI |
| `HiveLib:Hide()` | Hide the GUI |
| `HiveLib:Toggle()` | Toggle GUI visibility |
| `HiveLib:Destroy()` | Destroy the GUI |

### Keybinds

| Function | Description |
|----------|-------------|
| `HiveLib:SetToggleKey(key)` | Set key to toggle GUI visibility |
| `HiveLib:AddKeybind(name, key, callback, toggleGui)` | Add a custom keybind |
| `HiveLib:RemoveKeybind(name)` | Remove a keybind by name |

### Components

| Function | Description |
|----------|-------------|
| `HiveLib:AddButton(name, callback)` | Add a clickable button |
| `HiveLib:AddToggle(name, default, callback)` | Add a toggle switch |
| `HiveLib:AddSlider(name, min, max, default, callback)` | Add a slider |
| `HiveLib:AddTextBox(name, placeholder, callback)` | Add a text input |
| `HiveLib:AddLabel(text)` | Add a text label |
| `HiveLib:AddSeparator()` | Add a horizontal separator |
| `HiveLib:AddSection(title)` | Add a section header |

### Notifications

| Function | Description |
|----------|-------------|
| `HiveLib:Notification(title, text, duration)` | Show a notification |

## Theme Customization

You can customize the theme colors when creating a new instance:

```lua
local lib = HiveLib.new()
lib.Theme.Background = Color3.fromRGB(20, 20, 20)
lib.Theme.Accent = Color3.fromRGB(255, 100, 100)
-- etc.
```

## Available Theme Colors

- `Background` - Main background color
- `Secondary` - Secondary/button backgrounds
- `Accent` - Primary accent color
- `Text` - Main text color
- `TextSecondary` - Secondary text color
- `Border` - Border color
- `Success` - Success/ON state color
- `Warning` - Warning color
- `Error` - Error/close button color

## License

MIT License
