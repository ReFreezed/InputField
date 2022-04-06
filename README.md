# InputField

[![](https://img.shields.io/github/release/ReFreezed/InputField.svg)](https://github.com/ReFreezed/InputField/releases/latest)
[![](https://img.shields.io/github/license/ReFreezed/InputField.svg)](https://github.com/ReFreezed/InputField/blob/master/LICENSE.txt)

**InputField** for [LÖVE](https://love2d.org/) enables simple handling of user text input into your program.
The library is a [single file](https://raw.githubusercontent.com/ReFreezed/InputField/master/InputField.lua) with no external dependencies.
[MIT license](LICENSE.txt).

You can download the [latest release](https://github.com/ReFreezed/InputField/releases/latest) or clone the repository.

- [Features](#features)
- [Basic Usage](#basic-usage)



## Features

- Different field types: *Single-line*, *multi-line* (with or without wrapping), *password* (obscured characters).
- Text cursor and navigation (by keyboard and mouse).
- Text selection.
- Scrolling, both vertical and horizontal.
- Text alignment.
- Shortcuts for common operations, like copying selected text or deleting the next word.
- Undo and redo (history).
- Helper functions for rendering.

The library does not do any rendering itself, but provides helper functions for rendering text, cursors and selections.



## Basic Usage

```lua
local InputField = require("InputField")
local field      = InputField("Initial text.")

local fieldX = 80
local fieldY = 50

love.keyboard.setKeyRepeat(true)

function love.keypressed(key, scancode, isRepeat)
	field:keypressed(key, isRepeat)
end
function love.textinput(text)
	field:textinput(text)
end

function love.mousepressed(mx, my, mbutton, pressCount)
	field:mousepressed(mx-fieldX, my-fieldY, mbutton, pressCount)
end
function love.mousemoved(mx, my)
	field:mousemoved(mx-fieldX, my-fieldY)
end
function love.mousereleased(mx, my, mbutton)
	field:mousereleased(mx-fieldX, my-fieldY, mbutton)
end
function love.wheelmoved(dx, dy)
	field:wheelmoved(dx, dy)
end

function love.draw()
	love.graphics.setColor(0, 0, 1)
	for _, x, y, w, h in field:eachSelection() do
		love.graphics.rectangle("fill", fieldX+x, fieldY+y, w, h)
	end

	love.graphics.setColor(1, 1, 1)
	for _, text, x, y in field:eachVisibleLine() do
		love.graphics.print(text, fieldX+x, fieldY+y)
	end

	local x, y, h = field:getCursorLayout()
	love.graphics.rectangle("fill", fieldX+x, fieldY+y, 1, h)
end
```

See the [library file](https://raw.githubusercontent.com/ReFreezed/InputField/master/InputField.lua) for documentation,
or the [examples folder](https://github.com/ReFreezed/InputField/tree/master/examples) for more elaborate example programs.


