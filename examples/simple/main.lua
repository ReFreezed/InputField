--
-- InputField example program: Simple
--
require"setup"

local InputField = require"InputField"
local LG         = love.graphics



local FONT_SIZE        = 20
local FONT_LINE_HEIGHT = 1.3

local FIELD_TYPE = "multiwrap" -- Possible values: normal, password, multiwrap, multinowrap

local FIELD_OUTER_X      = 50
local FIELD_OUTER_Y      = 100
local FIELD_OUTER_WIDTH  = 120
local FIELD_OUTER_HEIGHT = 80
local FIELD_PADDING      = 6

local FIELD_INNER_X      = FIELD_OUTER_X + FIELD_PADDING
local FIELD_INNER_Y      = FIELD_OUTER_Y + FIELD_PADDING
local FIELD_INNER_WIDTH  = FIELD_OUTER_WIDTH  - 2*FIELD_PADDING
local FIELD_INNER_HEIGHT = FIELD_OUTER_HEIGHT - 2*FIELD_PADDING

local SCROLLBAR_WIDTH = 5
local BLINK_INTERVAL  = 0.90



love.keyboard.setKeyRepeat(true)

local theFont = LG.newFont(FONT_SIZE)
theFont:setLineHeight(FONT_LINE_HEIGHT)

local field = InputField("Foo, bar...\nFoobar?", FIELD_TYPE)
field:setFont(theFont)
field:setDimensions(FIELD_INNER_WIDTH, FIELD_INNER_HEIGHT)



function love.keypressed(key, scancode, isRepeat)
	if field:keypressed(key, isRepeat) then
		-- Event was handled.
	elseif key == "escape" then
		love.event.quit()
	end
end

function love.textinput(text)
	field:textinput(text)
end



function love.mousepressed(mx, my, mbutton, pressCount)
	field:mousepressed(mx-FIELD_INNER_X, my-FIELD_INNER_Y, mbutton, pressCount)
end

function love.mousemoved(mx, my, dx, dy)
	field:mousemoved(mx-FIELD_INNER_X, my-FIELD_INNER_Y)
end

function love.mousereleased(mx, my, mbutton, pressCount)
	field:mousereleased(mx-FIELD_INNER_X, my-FIELD_INNER_Y, mbutton)
end

function love.wheelmoved(dx, dy)
	field:wheelmoved(dx, dy)
end



function love.update(dt)
	field:update(dt)
end



local extraFont = LG.newFont(12)

function love.draw()
	local drawStartTime = love.timer.getTime()
	LG.clear(.25, .25, .25, 1)

	--
	-- Input field.
	--
	LG.setScissor(FIELD_OUTER_X, FIELD_OUTER_Y, FIELD_OUTER_WIDTH, FIELD_OUTER_HEIGHT)

	-- Background.
	LG.setColor(0, 0, 0)
	LG.rectangle("fill", FIELD_OUTER_X, FIELD_OUTER_Y, FIELD_OUTER_WIDTH, FIELD_OUTER_HEIGHT)

	-- Selection.
	LG.setColor(.2, .2, 1)
	for _, selectionX, selectionY, selectionWidth, selectionHeight in field:eachSelection() do
		LG.rectangle("fill", FIELD_INNER_X+selectionX, FIELD_INNER_Y+selectionY, selectionWidth, selectionHeight)
	end

	-- Text.
	LG.setFont(theFont)
	LG.setColor(1, 1, 1)
	for _, lineText, lineX, lineY in field:eachVisibleLine() do
		LG.print(lineText, FIELD_INNER_X+lineX, FIELD_INNER_Y+lineY)
	end

	-- Cursor.
	local cursorWidth = 2
	local cursorX, cursorY, cursorHeight = field:getCursorLayout()
	local alpha = ((field:getBlinkPhase() / BLINK_INTERVAL) % 1 < .5) and 1 or 0
	LG.setColor(1, 1, 1, alpha)
	LG.rectangle("fill", FIELD_INNER_X+cursorX-cursorWidth/2, FIELD_INNER_Y+cursorY, cursorWidth, cursorHeight)

	LG.setScissor()

	--
	-- Scrollbars.
	--
	local horiOffset, horiCoverage, vertOffset, vertCoverage = field:getScrollHandles()

	local horiHandleLength = horiCoverage * FIELD_OUTER_WIDTH
	local vertHandleLength = vertCoverage * FIELD_OUTER_HEIGHT
	local horiHandlePos    = horiOffset   * FIELD_OUTER_WIDTH
	local vertHandlePos    = vertOffset   * FIELD_OUTER_HEIGHT

	-- Backgrounds.
	LG.setColor(0, 0, 0, .3)
	LG.rectangle("fill", FIELD_OUTER_X+FIELD_OUTER_WIDTH, FIELD_OUTER_Y,  SCROLLBAR_WIDTH, FIELD_OUTER_HEIGHT) -- Vertical scrollbar.
	LG.rectangle("fill", FIELD_OUTER_X, FIELD_OUTER_Y+FIELD_OUTER_HEIGHT, FIELD_OUTER_WIDTH, SCROLLBAR_WIDTH ) -- Horizontal scrollbar.

	-- Handles.
	LG.setColor(.7, .7, .7)
	LG.rectangle("fill", FIELD_OUTER_X+FIELD_OUTER_WIDTH, FIELD_OUTER_Y+vertHandlePos,  SCROLLBAR_WIDTH, vertHandleLength) -- Vertical scrollbar.
	LG.rectangle("fill", FIELD_OUTER_X+horiHandlePos, FIELD_OUTER_Y+FIELD_OUTER_HEIGHT, horiHandleLength, SCROLLBAR_WIDTH) -- Horizontal scrollbar.

	--
	-- Stats.
	--
	local text = string.format(
		"Memory: %.2f MB\nDraw time: %.1f ms\nIs busy: %s",
		collectgarbage"count" / 1024,
		(love.timer.getTime()-drawStartTime) * 1000,
		tostring(field:isBusy())
	)
	LG.setFont(extraFont)
	LG.setColor(1, 1, 1, .5)
	LG.print(text, 0, LG.getHeight()-3*extraFont:getHeight())
end


