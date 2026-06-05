local sensorInfo = {
	name = "IsXXYYSafe",
	desc = "Checks if an XXYY box between the source and target position is safe for movement",
	author = "Martin Verner",
	date = "2026-06-04",
	license = "MIT",
}

local EVAL_PERIOD_DEFAULT = -1 -- acutal, no caching


function getInfo()
	return {
		period = EVAL_PERIOD_DEFAULT
	}
end


return function(sourcePos, targetPos)
	return Script.LuaUI.mapGrid_xxyySafe(sourcePos, targetPos)
end