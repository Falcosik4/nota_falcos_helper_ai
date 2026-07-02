function getInfo()
	return {
		tooltip = "Initializes the swampdota values",
	}
end

function Run()
    
    local currentUnits = Spring.GetTeamUnits(Spring.GetMyTeamID())

    bb.testUnits = currentUnits -- { unitID }
    for _, unitID in ipairs(currentUnits) do
        --Spring.Echo("Checking unit ID: " .. unitID)
        local unitDefID = Spring.GetUnitDefID(unitID) 



        if bb.spawnedUnits[unitID] == nil then
            --Spring.Echo("Unit ID " .. unitID .. " with unitDefID " .. unitDefID .. " is not in spawnedUnits, adding it now.")
            bb.spawnedUnits[unitID] = true

            if unitDefID == UnitDefNames["armatlas"].id then
                Spring.GiveOrderToUnit(unitID, CMD.IDLEMODE, { 0 }, {})
            end

            if bb.freeUnits[unitDefID] == nil then
                --Spring.Echo("No free units list for unitDefID " .. unitDefID .. ", creating a new list.")
                bb.freeUnits[unitDefID] = {}
            end
            
            --Spring.Echo("Adding unit ID " .. unitID .. " to freeUnits list for unitDefID " .. unitDefID)
            table.insert(bb.freeUnits[unitDefID], unitID)
        end
    end

    return SUCCESS
end