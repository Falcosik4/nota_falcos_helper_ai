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

-- Inspired from and made with the help of Lukáš Hofman
-- @description return unit group where maverick is the first
return function()
	for i=1, #units do
		local defID = Spring.GetUnitDefID(units[i])
		if UnitDefs[defID].name == "armmav" then
			local x,y,z = Spring.GetUnitPosition(units[i])
			return { pos=Vec3(x,y,z), id=units[i] }
		end
	end
	return nil
end