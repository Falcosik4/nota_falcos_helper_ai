-- Logic inspired by Definition.lua in formation by PepeAmpere

local sensorInfo = {
	name = "GetMaverickGroup",
	desc = "Returns maverick group",
	author = "Lukáš Hofman",
	date = "2026-04-24",
	license = "notAlicense",
}

local EVAL_PERIOD_DEFAULT = 0 -- instant, no caching

function getInfo()
	return {
		period = EVAL_PERIOD_DEFAULT
	}
end

-- @description return unit group where maverick is the first
return function(leaderID)
 	local g = {}
	g[leaderID] = 1 -- Maverick is always pointman

	local slot = 2
	for i=1, #units do
		local id = units[i]
		if id ~= leaderID then
			g[id] = slot
			slot = slot + 1
		end
	end
	return g
end