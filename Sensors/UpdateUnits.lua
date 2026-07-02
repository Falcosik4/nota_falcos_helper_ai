local sensorInfo = {
	name = "UpdateUnits",
	desc = "Updates the list of available units",
	author = "Martin Verner",
	date = "2026-07-02",
	license = "notAlicense",
}

local EVAL_PERIOD_DEFAULT = -1 -- instant, no caching

function getInfo()
	return {
		period = EVAL_PERIOD_DEFAULT
	}
end


--function CheckUnits(currentUnits)
--
--end

return function(unitDefName, numUnits, currentUnits, shoppingCart)
    
	local unitDefID = UnitDefNames[unitDefName].id

	-- No need to fetch free units
	if bb.freeUnits[unitDefID] == nil or #currentUnits >= numUnits then
		return currentUnits
	end

	local orderedUnits = (shoppingCart and shoppingCart[unitDefID]) or 0

	local fetchedUnits = math.min(numUnits - #currentUnits - orderedUnits, #bb.freeUnits[unitDefID])

	--Spring.Echo("Fetched units ... " .. fetchedUnits .. " for unitDefName: " .. unitDefName)
	for i=1, fetchedUnits do
		local unitID = table.remove(bb.freeUnits[unitDefID], 1)
		--Spring.Echo("Inserting " .. unitID .. " into currentUnits for unitDefName: " .. unitDefName)
		table.insert(currentUnits, unitID)
		if shoppingCart[unitDefID] ~= nil then
			shoppingCart[unitDefID] = shoppingCart[unitDefID] -1
			if shoppingCart[unitDefID] <= 0 then
				shoppingCart[unitDefID] = nil
			end
		end 
	end

	return currentUnits
end