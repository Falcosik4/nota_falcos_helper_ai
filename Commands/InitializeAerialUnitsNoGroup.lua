function getInfo()
	return {
		tooltip = "Initializes the swampdota values",
	}
end

function Run()
    
    local currentUnits = Spring.GetTeamUnits(Spring.GetMyTeamID())

    bb.testUnits = currentUnits -- { unitID }
    for _, unitID in ipairs(currentUnits) do
        local unitDefID = Spring.GetUnitDefID(unitID) 

        if unitDefID == UnitDefNames["armatlas"].id then
            Spring.GiveOrderToUnit(unitID, CMD.IDLEMODE, { 0 }, {})
        end
    end

    return SUCCESS
end