local sensorInfo = {
	name = "IsEnemyVisible",
	desc = "Checks if an enemy unit is still visible (on radar)",
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

return function(unitID)
	return Script.LuaUI.units_unitSeen(unitID)
end