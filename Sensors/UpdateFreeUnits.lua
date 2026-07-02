local sensorInfo = {
	name = "UpdateFreeUnits",
	desc = "Updates the list of free units. Returns the updated list",
	author = "Martin Verner",
	date = "2026-07-02",
	license = "notAlicense",
}

local EVAL_PERIOD_DEFAULT = -1 -- acutal, no caching

function getInfo()
	return {
		period = EVAL_PERIOD_DEFAULT
	}
end


--function CheckUnits(currentUnits)
--
--end

return function()
    
	local units = Spring.GetTeamUnits(Spring.GetMyTeamID())

	for _, unitID in ipairs(units) do
		local unitDefID = Spring.GetUnitDefID(unitID) 
		if bb.spawnedUnits[unitID] == nil then
			bb.spawnedUnits[unitID] = true
			if bb.freeUnits[unitDefID] == nil then
				bb.freeUnits[unitDefID] = {}
			end
			
			table.insert(bb.freeUnits[unitDefID], unitID)
		end
	end

	return bb.freeUnits
end