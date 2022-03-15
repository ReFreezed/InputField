--
-- InputField tests
--

local function assertValue(value, expected)
	if value == expected then  return  end
	error("Expected '"..tostring(expected).."', got '"..tostring(value).."'.", 2)
end

io.stdout:setvbuf("no")
io.stderr:setvbuf("no")
collectgarbage("stop")

local InputField = assert(loadfile(love.filesystem.getSource().."/../InputField.lua"))()

--
-- API tests.
--
do
	local field = InputField("foo")

	assertValue(field:getType(),     "normal")
	assertValue(field:isPassword(),  false)
	assertValue(field:isMultiline(), false)

	-- Text.
	assertValue(field:getText(),        "foo")
	assertValue(field:getVisibleText(), "foo")
	field:setText("b\när")
	assertValue(field:getText(),        "bär") -- We're single-line, so no newlines.
	assertValue(field:getTextLength(),  3)

	-- Dimensions.
	field:setDimensions(200, 150)
	local w, h = field:getDimensions()
	assertValue(w, 200)
	assertValue(h, 150)

	field:setWidth(100)
	field:setHeight(50)
	assertValue(field:getWidth(),  100)
	assertValue(field:getHeight(), 50)

	-- Filter function.
	local function filterFunc(char)
		return char == "b"
	end

	field:setFilter(filterFunc)
	assertValue(field:getFilter(), filterFunc)

	field:setText("")
	field:textinput("abc")
	assertValue(field:getText(), "ac")

	field:setFilter(nil)
	assertValue(field:getFilter(), nil)

	-- Font and filtering.
	local imageDataStr = table.concat{
		"\0\0\0\0", "\255\255\255\255",
		"\0\0\0\0", "\255\255\255\255", "\255\255\255\255",
		"\0\0\0\0",
	}
	local imageData = (love.getVersion() < 11) and love.image.newImageData(#imageDataStr/4, 1, imageDataStr) or love.image.newImageData(#imageDataStr/4, 1, "rgba8", imageDataStr)
	local font      = love.graphics.newImageFont(imageData, "12")

	field:setFontFilteringActive(true)
	assertValue(field:isFontFilteringActive(), true)

	local defaultFont = field:getFont()
	field:setFont(font)
	assertValue(field:getFont(), font)

	field:setText("")
	field:textinput("0123210")
	assertValue(field:getText(), "1221")

	field:setFontFilteringActive(false)
	assertValue(field:isFontFilteringActive(), false)

	field:setFont(defaultFont)

	-- Editable.
	field:setText("")
	field:textinput("a")
	assertValue(field:getText(), "a")

	field:setEditable(false)
	assertValue(field:isEditable(), false)

	field:textinput("b")
	assertValue(field:getText(), "a")

	field:setEditable(true)
	assertValue(field:isEditable(), true)

	field:textinput("c")
	assertValue(field:getText(), "ac")

	-- Cursor.
	field:setText("foo")
	field:setCursor(1)
	assertValue(field:getCursor(), 1)
	local pos1, pos2 = field:getSelection()
	assertValue(pos1, 1)
	assertValue(pos2, 1)
	assertValue(field:getSelectedVisibleText(), "")

	field:moveCursor(1)
	assertValue(field:getCursor(), 2)
	assertValue(field:getSelectedVisibleText(), "")

	field:moveCursor(-100, "end")
	assertValue(field:getCursor(), 0)
	assertValue(field:getSelectedVisibleText(), "fo")
	assertValue(field:getCursorSelectionSide(), "start")
	assertValue(field:getAnchorSelectionSide(), "end")

	-- Selection and mouse events.
	field:setText("foobar")

	field:setSelection(1, 4)
	local pos1, pos2 = field:getSelection()
	assertValue(pos1, 1)
	assertValue(pos2, 4)
	assertValue(field:getSelectedText(),        "oob")
	assertValue(field:getSelectedVisibleText(), "oob")

	field:mousepressed (0,    0, 1, 1)
	field:mousemoved   (1000, 0)
	field:mousereleased(1000, 0, 1)
	assertValue(field:getSelectedVisibleText(), "foobar")

	field:mousepressed (0,    0, 1, 1)
	field:releaseMouse ()
	field:mousemoved   (1000, 0)
	field:mousereleased(1000, 0, 1)
	assertValue(field:getSelectedVisibleText(), "")

	field:setSelection(0, 0)
	field:selectAll()
	local pos1, pos2 = field:getSelection()
	assertValue(pos1, 0)
	assertValue(pos2, 6)

	-- insert, replace
	field:setText("foobar")
	field:setSelection(1, 3)
	field:insert("ööö")
	assertValue(field:getText(), "föööbar")

	-- Double clicking.
	field:setDoubleClickMaxDelay(1.50)
	assertValue(field:getDoubleClickMaxDelay(), 1.50)

	field:setText("foo bar")
	field:mousepressed (0, 0, 1, 1)
	field:mousereleased(0, 0, 1)
	field:mousepressed (0, 0, 1, 2)
	field:mousereleased(0, 0, 1)
	assertValue(field:getSelectedText(), "foo")

	-- Mouse scroll speed.
	field:setMouseScrollSpeed(1, 2)
	local speedX, speedY = field:getMouseScrollSpeed()
	assertValue(speedX, 1)
	assertValue(speedY, 2)

	field:setMouseScrollSpeedX(3)
	field:setMouseScrollSpeedY(4)
	assertValue(field:getMouseScrollSpeedX(), 3)
	assertValue(field:getMouseScrollSpeedY(), 4)

	-- History.
	field:clearHistory()

	field:setMaxHistory(10)
	assertValue(field:getMaxHistory(), 10)

	-- Blinking.
	assertValue(type(field:getBlinkPhase()), "number")
	field:resetBlinking()

	-- Misc.
	field:update(0)
end

do
	local field = InputField("fo\no", "multiwrap")

	assertValue(field:getType(),     "multiwrap")
	assertValue(field:isPassword(),  false)
	assertValue(field:isMultiline(), true)

	-- Text.
	assertValue(field:getText(),        "fo\no")
	assertValue(field:getVisibleText(), "fo\no")

	-- Type change.
	field:setType("password")

	assertValue(field:getType(),     "password")
	assertValue(field:isPassword(),  true)
	assertValue(field:isMultiline(), false)

	-- Text.
	assertValue(field:getText(),        "foo")
	assertValue(field:getVisibleText(), "***")
end

do
	-- Bug: Calling some methods on a field that never had text causes a freeze.
	local field = InputField("", "multiwrap")
	field:selectAll()
end

-- @Incomplete:
-- canScroll, canScrollHorizontally, canScrollVertically
-- eachVisibleLine, eachSelection
-- getAlignment, setAlignment
-- getCursorLayout
-- getInfoAtCoords, getInfoAtCursor, getInfoAtCharacter.
-- getScroll, getScrollX, getScrollY, setScroll, setScrollX, setScrollY, scroll, scrollToCursor
-- getScrollHandles, getScrollHandleHorizontal, getScrollHandleVertical
-- getScrollLimits
-- getTextDimensions, getTextWidth, getTextHeight
-- getTextOffset
-- getVisibleLine, getVisibleLineCount.
-- getWheelScrollSpeed, setWheelScrollSpeed.
-- keypressed
-- wheelmoved

print("Tests completed successfully!")
love.event.quit()
