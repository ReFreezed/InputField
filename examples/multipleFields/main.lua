--
-- InputField example program: Multiple fields
--
-- This example has an array of "text inputs" objects, each with its own
-- InputField instance, and a system for what text input has focus.
--

local InputField = assert(loadfile(love.filesystem.getSource().."/../../InputField.lua"))() -- require"InputField"

local LG = love.graphics
local LK = love.keyboard



--
-- Values.
--

local FIELD_PADDING            = 6
local FONT_LINE_HEIGHT         = 1.3
local SCROLLBAR_WIDTH          = 5
local BLINK_INTERVAL           = 0.90
local MOUSE_WHEEL_SCROLL_SPEED = 15

local theFont = LG.newFont(16)

local textInputs = {
	{
		field  = InputField("Foo, bar? Foobar!", "normal"),
		x      = 50,
		y      = 100,
		width  = 120,
		height = theFont:getHeight() + 2*FIELD_PADDING,
	},
	{
		field  = InputField("v3ry 53cr37", "password"),
		x      = 50,
		y      = 170,
		width  = 120,
		height = theFont:getHeight() + 2*FIELD_PADDING,
	},
	{
		field = InputField("Lorem ipsum dolor sit amet, consectetur adipiscing elit.\nSed do eiusmod tempor incididunt ut labore et dolore magna aliqua. "
			.. "Sagittis eu volutpat odio facilisis.\n\nAccumsan sit amet nulla facilisi morbi tempus.\nViverra maecenas accumsan lacus vel facilisis volutpat est velit egestas.\n"
			.. "Adipiscing elit duis tristique sollicitudin.\nFacilisi morbi tempus iaculis urna id volutpat lacus.\nDiam quam nulla porttitor massa id neque aliquam.",
			"multinowrap"
		),
		x      = 280,
		y      = 100,
		width  = 350,
		height = 120,
	},
	{
		field = InputField("Luctus accumsan tortor posuere ac ut consequat. Ultrices vitae auctor eu augue.\n"
			.. "Placerat orci nulla pellentesque dignissim enim sit amet venenatis urna.\n\nConsequat nisl vel pretium lectus quam.\n"
			.. "Elit at imperdiet dui accumsan sit amet nulla facilisi morbi. Fames ac turpis egestas integer eget aliquet nibh praesent.",
			"multiwrap"
		),
		x      = 50,
		y      = 300,
		width  = 580,
		height = 190,
	},
}



--
-- Setup.
--

require"setup"

LK.setKeyRepeat(true)
theFont:setLineHeight(FONT_LINE_HEIGHT)

for _, textInput in ipairs(textInputs) do
	textInput.field:setFont(theFont)
	textInput.field:setDimensions(textInput.width-2*FIELD_PADDING, textInput.height-2*FIELD_PADDING)
end

local focusedTextInput = textInputs[1] -- Nil means no focus.



--
-- LÖVE callbacks.
--



local function indexOf(array, value)
	for i = 1, #array do
		if array[i] == value then  return i  end
	end
	return 0 -- Value is not in array.
end

local function isInside(x,y, rectX,rectY, rectW,rectH)
	return x >= rectX and y >= rectY and x < rectX+rectW and y < rectY+rectH
end



function love.keypressed(key, scancode, isRepeat)
	-- First handle keys that override InputField's behavior.
	if key == "tab" then
		-- Cycle focused input.
		local i = indexOf(textInputs, focusedTextInput)

		if LK.isDown("lshift","rshift") then  i = (i-2) % #textInputs + 1      -- Backwards.
		else                                  i =  i    % #textInputs + 1  end -- Forwards.

		focusedTextInput = textInputs[i]

		if focusedTextInput then
			focusedTextInput.field:resetBlinking()
		end

	-- Then handle InputField (if it has focus).
	elseif focusedTextInput and focusedTextInput.field:keypressed(key, isRepeat) then
		-- Event was handled.

	-- Lastly handle keys for when InputField doesn't have focus or the key wasn't handled by the library.
	elseif key == "escape" then
		love.event.quit()
	end
end

function love.textinput(text)
	if focusedTextInput then
		focusedTextInput.field:textinput(text)
	end
end



local isPressing         = false
local pressedTextInput   = nil
local pressedMouseButton = 0

function love.mousepressed(mx, my, mbutton, pressCount)
	if not isPressing then
		focusedTextInput = nil

		for i, textInput in ipairs(textInputs) do
			if isInside(mx, my, textInput.x, textInput.y, textInput.width, textInput.height) then
				if focusedTextInput ~= textInput then
					focusedTextInput = textInput
					textInput.field:resetBlinking()
				end

				isPressing         = true
				pressedTextInput   = textInput
				pressedMouseButton = mbutton

				local fieldX = textInput.x + FIELD_PADDING
				local fieldY = textInput.y + FIELD_PADDING
				textInput.field:mousepressed(mx-fieldX, my-fieldY, mbutton, pressCount)

				break
			end
		end
	end
end

function love.mousemoved(mx, my, dx, dy)
	if isPressing then
		local fieldX = pressedTextInput.x + FIELD_PADDING
		local fieldY = pressedTextInput.y + FIELD_PADDING
		pressedTextInput.field:mousemoved(mx-fieldX, my-fieldY)
	end
end

function love.mousereleased(mx, my, mbutton, pressCount)
	if isPressing and mbutton == pressedMouseButton then
		local fieldX = pressedTextInput.x + FIELD_PADDING
		local fieldY = pressedTextInput.y + FIELD_PADDING
		pressedTextInput.field:mousereleased(mx-fieldX, my-fieldY, mbutton)
		isPressing = false
	end
end

function love.wheelmoved(dx, dy)
	-- Scroll field under mouse.
	local mx, my = love.mouse.getPosition()

	for i, textInput in ipairs(textInputs) do
		if isInside(mx, my, textInput.x, textInput.y, textInput.width, textInput.height) then
			textInput.field:scroll(-dx*MOUSE_WHEEL_SCROLL_SPEED, -dy*MOUSE_WHEEL_SCROLL_SPEED)
			break
		end
	end
end



function love.update(dt)
	if focusedTextInput then
		focusedTextInput.field:update(dt)
	end
end



local extraFont = LG.newFont(12)

function love.draw()
	local drawStartTime = love.timer.getTime()
	LG.clear(.25, .25, .25, 1)

	for i, textInput in ipairs(textInputs) do
		--
		-- Input field.
		--
		local field    = textInput.field
		local fieldX   = textInput.x + FIELD_PADDING
		local fieldY   = textInput.y + FIELD_PADDING
		local hasFocus = (textInput == focusedTextInput)

		-- Field info.
		local text = i .. ", " .. field:getType()
		local y    = textInput.y - 3 - extraFont:getHeight()
		LG.setFont(extraFont)
		LG.setColor(1, 1, 1, .5)
		LG.print(text, textInput.x, y)

		-- Background.
		LG.setColor(0, 0, 0)
		LG.rectangle("fill", textInput.x, textInput.y, textInput.width, textInput.height)

		-- Contents.
		do
			LG.setScissor(textInput.x, textInput.y, textInput.width, textInput.height)

			-- Selection.
			if hasFocus then
				LG.setColor(.2, .2, 1)
			else
				LG.setColor(1, 1, 1, .3)
			end
			for _, x, y, w, h in field:eachSelection() do
				LG.rectangle("fill", fieldX+x, fieldY+y, w, h)
			end

			-- Text.
			LG.setFont(field:getFont())
			LG.setColor(1, 1, 1, (hasFocus and 1 or .8))
			for _, line, x, y in field:eachVisibleLine() do
				LG.print(line, fieldX+x, fieldY+y)
			end

			-- Cursor.
			if hasFocus and (field:getBlinkPhase() / BLINK_INTERVAL) % 1 < .5 then
				local w       = 2
				local x, y, h = field:getCursorLayout()
				LG.setColor(1, 1, 1)
				LG.rectangle("fill", fieldX+x-w/2, fieldY+y, w, h)
			end

			LG.setScissor()
		end

		--
		-- Scrollbars.
		--
		local canScrollX, canScrollY                 = field:canScroll()
		local hOffset, hCoverage, vOffset, vCoverage = field:getScrollHandles()

		local hHandleLength = hCoverage * textInput.width
		local vHandleLength = vCoverage * textInput.height
		local hHandlePos    = hOffset   * textInput.width
		local vHandlePos    = vOffset   * textInput.height

		-- Backgrounds.
		LG.setColor(0, 0, 0, .3)
		if canScrollY then  LG.rectangle("fill", textInput.x+textInput.width, textInput.y,  SCROLLBAR_WIDTH, textInput.height)  end -- Vertical scrollbar.
		if canScrollX then  LG.rectangle("fill", textInput.x, textInput.y+textInput.height, textInput.width, SCROLLBAR_WIDTH )  end -- Horizontal scrollbar.

		-- Handles.
		LG.setColor(.7, .7, .7)
		if canScrollY then  LG.rectangle("fill", textInput.x+textInput.width, textInput.y+vHandlePos,  SCROLLBAR_WIDTH, vHandleLength)  end -- Vertical scrollbar.
		if canScrollX then  LG.rectangle("fill", textInput.x+hHandlePos, textInput.y+textInput.height, hHandleLength, SCROLLBAR_WIDTH)  end -- Horizontal scrollbar.

		--
		-- Focus indication outline.
		--
		if hasFocus then
			local lineWidth = 2

			local x = textInput.x - lineWidth/2
			local y = textInput.y - lineWidth/2
			local w = textInput.width  + lineWidth
			local h = textInput.height + lineWidth

			if canScrollY then  w = w + SCROLLBAR_WIDTH  end
			if canScrollX then  h = h + SCROLLBAR_WIDTH  end

			LG.setColor(1, 1, 0, .4)
			LG.setLineWidth(lineWidth)
			LG.rectangle("line", x, y, w, h)
		end
	end

	--
	-- Stats.
	--
	local text = string.format(
		"Memory: %.2f MB\nDraw time: %.1f ms",
		collectgarbage"count" / 1024,
		(love.timer.getTime()-drawStartTime) * 1000
	)
	LG.setFont(extraFont)
	LG.setColor(1, 1, 1, .5)
	LG.print(text, 0, LG.getHeight()-2*extraFont:getHeight())
end


