--
-- InputField test project
--

local FONT_SIZE = 20

local FIELD_TYPE = "normal"
local FIELD_TYPE = "password"
local FIELD_TYPE = "multiwrap"
-- local FIELD_TYPE = "multinowrap"

local FIELD_X         = 50
local FIELD_Y         = 100
local FIELD_WIDTH     = 120
local FIELD_HEIGHT    = 80
local FIELD_PADDING   = 6
local SCROLLBAR_WIDTH = 4
local BLINK_INTERVAL  = 0.90

local LG = love.graphics



local font = LG.newFont(FONT_SIZE)
font:setLineHeight(1.3)

io.stdout:setvbuf("no")
io.stderr:setvbuf("no")

love.keyboard.setKeyRepeat(true)

local field = require"InputField"("Foo, bar...\nFoobar?", FIELD_TYPE)
field:setFont(font)
field:setDimensions(FIELD_WIDTH-2*FIELD_PADDING, FIELD_HEIGHT-2*FIELD_PADDING)



function love.keypressed(key, scancode, isRepeat)
	if key == "escape" then
		love.event.quit()
	else
		field:keypressed(key, scancode, isRepeat)
	end
end

function love.textinput(text)
	field:textinput(text)
end



function love.mousepressed(mx, my, mbutton, pressCount)
	field:mousepressed(mx-FIELD_X-FIELD_PADDING, my-FIELD_Y-FIELD_PADDING, mbutton, pressCount)
end

function love.mousemoved(mx, my, dx, dy)
	field:mousemoved(mx-FIELD_X-FIELD_PADDING, my-FIELD_Y-FIELD_PADDING, dx, dy)
end

function love.mousereleased(mx, my, mbutton, pressCount)
	field:mousereleased(mx-FIELD_X-FIELD_PADDING, my-FIELD_Y-FIELD_PADDING, mbutton)
end

function love.wheelmoved(dx, dy)
	field:scroll(-dx*10, -dy*10) -- Note: Only works as long as the cursor is in view.
end



function love.update(dt)
	field:update(dt)
end



function love.draw()
	LG.clear(.2, .2, .2, 1)
	LG.setScissor(FIELD_X, FIELD_Y, FIELD_WIDTH, FIELD_HEIGHT)

	-- Background.
	LG.setColor(0, 0, 0)
	LG.rectangle("fill", FIELD_X, FIELD_Y, FIELD_WIDTH, FIELD_HEIGHT)

	-- Selection.
	LG.setColor(.2, .2, 1)
	for _, selX, selY, selW, selH in field:eachSelection() do
		LG.rectangle("fill", FIELD_X+FIELD_PADDING+selX, FIELD_Y+FIELD_PADDING+selY, selW, selH)
	end

	-- Text.
	LG.setFont(font)
	LG.setColor(1, 1, 1)
	for _, line, lineX, lineY in field:eachTextLine() do
		LG.print(line, FIELD_X+FIELD_PADDING+lineX, FIELD_Y+FIELD_PADDING+lineY)
	end

	-- Cursor.
	local curX, curY = field:getCursorOffset()
	LG.setColor(1, 1, 1, ((field:getBlinkPhase()/BLINK_INTERVAL)%1 < .5 and 1 or 0))
	LG.rectangle("fill", FIELD_X+FIELD_PADDING+curX-1, FIELD_Y+FIELD_PADDING+curY, 2, font:getHeight())

	LG.setScissor()

	-- Bars.
	local textW,      textH      = field:getTextDimensions()
	local scrollX,    scrollY    = field:getScroll()
	local maxScrollX, maxScrollY = field:getScrollLimits()

	local innerW   = textW + 2*FIELD_PADDING
	local innerH   = textH + 2*FIELD_PADDING
	local visibleX = math.min(FIELD_WIDTH  / innerW, 1)
	local visibleY = math.min(FIELD_HEIGHT / innerH, 1)
	local barW     = visibleX * FIELD_WIDTH
	local barH     = visibleY * FIELD_HEIGHT
	local barX     = (maxScrollX == 0) and 0 or (scrollX / maxScrollX) * (FIELD_WIDTH  - barW)
	local barY     = (maxScrollY == 0) and 0 or (scrollY / maxScrollY) * (FIELD_HEIGHT - barH)

	LG.setColor(0, 0, 0, .3)
	LG.rectangle("fill", FIELD_X+FIELD_WIDTH, FIELD_Y,  SCROLLBAR_WIDTH, FIELD_HEIGHT)
	LG.rectangle("fill", FIELD_X, FIELD_Y+FIELD_HEIGHT, FIELD_WIDTH, SCROLLBAR_WIDTH)

	LG.setColor(.7, .7, .7)
	LG.rectangle("fill", FIELD_X+FIELD_WIDTH, FIELD_Y+barY,  SCROLLBAR_WIDTH, barH)
	LG.rectangle("fill", FIELD_X+barX, FIELD_Y+FIELD_HEIGHT, barW, SCROLLBAR_WIDTH)
end


