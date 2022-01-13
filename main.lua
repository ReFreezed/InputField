--
-- InputField test project
--
local FONT_SIZE        = 20
local FONT_LINE_HEIGHT = 1.3

local FIELD_TYPE = "normal"
local FIELD_TYPE = "password"
local FIELD_TYPE = "multiwrap"
-- local FIELD_TYPE = "multinowrap"

local FIELD_OUTER_X      = 50
local FIELD_OUTER_Y      = 100
local FIELD_OUTER_WIDTH  = 120
local FIELD_OUTER_HEIGHT = 80
local FIELD_PADDING      = 6

local FIELD_INNER_X      = FIELD_OUTER_X + FIELD_PADDING
local FIELD_INNER_Y      = FIELD_OUTER_Y + FIELD_PADDING
local FIELD_INNER_WIDTH  = FIELD_OUTER_WIDTH  - 2*FIELD_PADDING
local FIELD_INNER_HEIGHT = FIELD_OUTER_HEIGHT - 2*FIELD_PADDING

local SCROLLBAR_WIDTH          = 5
local BLINK_INTERVAL           = 0.90
local MOUSE_WHEEL_SCROLL_SPEED = 10

local LG = love.graphics



if love.getVersion() < 11 then
	local _clear    = LG.clear
	local _setColor = LG.setColor

	function LG.clear(r, g, b, a)
		_clear((r and r*255), (g and g*255), (b and b*255), (a and a*255))
	end

	function LG.setColor(r, g, b, a)
		_setColor(r*255, g*255, b*255, (a and a*255))
	end
end



local theFont = LG.newFont(FONT_SIZE)
theFont:setLineHeight(FONT_LINE_HEIGHT)

io.stdout:setvbuf("no")
io.stderr:setvbuf("no")

love.keyboard.setKeyRepeat(true)

local InputField = require"InputField"
local field      = InputField("Foo, bar...\nFoobar?", FIELD_TYPE)
field:setFont(theFont)
field:setDimensions(FIELD_INNER_WIDTH, FIELD_INNER_HEIGHT)



function love.keypressed(key, scancode, isRepeat)
	if key == "escape" then
		love.event.quit()
	else
		field:keypressed(key, isRepeat)
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
	field:scroll(-dx*MOUSE_WHEEL_SCROLL_SPEED, -dy*MOUSE_WHEEL_SCROLL_SPEED)
end



function love.update(dt)
	field:update(dt)
end



local smallFont = LG.newFont(12)

function love.draw()
	LG.clear(.2, .2, .2, 1)

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
	local cursorWidth      = 2
	local cursorHeight     = theFont:getHeight()
	local cursorX, cursorY = field:getCursorLayout()
	LG.setColor(1, 1, 1, ((field:getBlinkPhase()/BLINK_INTERVAL)%1 < .5 and 1 or 0))
	LG.rectangle("fill", FIELD_INNER_X+cursorX-cursorWidth/2, FIELD_INNER_Y+cursorY, cursorWidth, cursorHeight)

	LG.setScissor()

	--
	-- Scrollbars.
	--
	local textWidth,  textHeight = field:getTextDimensions()
	local scrollX,    scrollY    = field:getScroll()
	local maxScrollX, maxScrollY = field:getScrollLimits()

	local contentWidth  = textWidth  + 2*FIELD_PADDING
	local contentHeight = textHeight + 2*FIELD_PADDING

	local amountVisibleX = math.min(FIELD_OUTER_WIDTH  / contentWidth,  1)
	local amountVisibleY = math.min(FIELD_OUTER_HEIGHT / contentHeight, 1)

	local barWidth  = amountVisibleX * FIELD_OUTER_WIDTH
	local barHeight = amountVisibleY * FIELD_OUTER_HEIGHT
	local barX      = (maxScrollX == 0) and 0 or (scrollX / maxScrollX) * (FIELD_OUTER_WIDTH  - barWidth)
	local barY      = (maxScrollY == 0) and 0 or (scrollY / maxScrollY) * (FIELD_OUTER_HEIGHT - barHeight)

	-- Backgrounds.
	LG.setColor(0, 0, 0, .3)
	LG.rectangle("fill", FIELD_OUTER_X+FIELD_OUTER_WIDTH, FIELD_OUTER_Y,  SCROLLBAR_WIDTH, FIELD_OUTER_HEIGHT) -- Vertical scrollbar.
	LG.rectangle("fill", FIELD_OUTER_X, FIELD_OUTER_Y+FIELD_OUTER_HEIGHT, FIELD_OUTER_WIDTH, SCROLLBAR_WIDTH ) -- Horizontal scrollbar.

	-- Handles.
	LG.setColor(.7, .7, .7)
	LG.rectangle("fill", FIELD_OUTER_X+FIELD_OUTER_WIDTH, FIELD_OUTER_Y+barY,  SCROLLBAR_WIDTH, barHeight) -- Vertical scrollbar.
	LG.rectangle("fill", FIELD_OUTER_X+barX, FIELD_OUTER_Y+FIELD_OUTER_HEIGHT, barWidth, SCROLLBAR_WIDTH ) -- Horizontal scrollbar.

	--
	-- Stats.
	--
	LG.setFont(smallFont)
	LG.setColor(1, 1, 1, .5)
	LG.print(("Memory: %.2f MB"):format(collectgarbage"count"/1024), 0, LG.getHeight()-smallFont:getHeight())
end


