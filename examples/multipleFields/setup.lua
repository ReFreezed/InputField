io.stdout:setvbuf("no")
io.stderr:setvbuf("no")

if love.getVersion() < 11 then
	local _clear    = love.graphics.clear
	local _setColor = love.graphics.setColor

	function love.graphics.clear(r, g, b, a)
		_clear((r and r*255), (g and g*255), (b and b*255), (a and a*255))
	end

	function love.graphics.setColor(r, g, b, a)
		_setColor(r*255, g*255, b*255, (a and a*255))
	end
end

package.preload.InputField = function()
	return assert(loadfile(love.filesystem.getSource().."/../../InputField.lua"))()
end
