local sensorInfo = {
	name = "CanReachPosition",
	desc = "Checks if there is a path between start and target position, given a height offset",
	author = "Martin Verner",
	date = "2026-06-02",
	license = "MIT",
}

local EVAL_PERIOD_DEFAULT = 0 -- instant, no caching


function getInfo()
	return {
		period = EVAL_PERIOD_DEFAULT
	}
end


return function(sourcePos, targetPos, heightThreshold)
	return Script.LuaUI.mapGrid_existsPath(sourcePos, targetPos, heightThreshold)
end