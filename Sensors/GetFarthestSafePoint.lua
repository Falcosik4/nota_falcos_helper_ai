local sensorInfo = {
	name = "GetFarthestSafePoint",
	desc = "Returns the farthest safe point on the road.",
	author = "Martin Verner",
	date = "2026-07-02",
	license = "MIT",
}

local EVAL_PERIOD_DEFAULT = -1 -- acutal, no caching

function getInfo()
	return {
		period = EVAL_PERIOD_DEFAULT
	}
end

return function(path)
    local currPoint = nil
    for _, point in ipairs(path) do
        local position = point.position
        local newPoint = Vec3(position.x, position.y, position.z)
        local isSafe = Script.LuaUI.mapGrid_isPointSafe(newPoint)



        if isSafe then
            currPoint = newPoint
        else
            return currPoint
        end
    end

    return currPoint
end