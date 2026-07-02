function getInfo()
	return {
		onNoUnits = SUCCESS, -- instant success
		tooltip = "Initializes the swampdota values",
		parameterDefs = {
            { 
				name = "initialAtlases",
				variableType = "expression",
				componentType = "editBox",
				defaultValue = "0",
			},

            { 
				name = "initialSeers",
				variableType = "expression",
				componentType = "editBox",
				defaultValue = "0",
			},

            { 
				name = "initialInfiltrators",
				variableType = "expression",
				componentType = "editBox",
				defaultValue = "0",
			},
		}
	}
end

function Run(self, units, parameter)

    local myID = Spring.GetMyTeamID()
    
    bb.freeUnits = Spring.GetTeamUnitsSorted(myID) -- { unitDefID -> { unitID } }
    bb.shoppingList = { } -- { priority -> { unitDefID } }

    bb.spawnedUnits = {} -- { unitID }

    for _, unitID in ipairs(Spring.GetTeamUnits(myID)) do
        bb.spawnedUnits[unitID] = true

        local unitDefID = Spring.GetUnitDefID(unitID)
        if unitDefID == UnitDefNames["armatlas"].id then
            Spring.GiveOrderToUnit(unitID, CMD.IDLEMODE, { 0 }, {})
        end
    end


    if parameter.initialAtlases > 0 or parameter.initialSeers > 0 or parameter.initialInfiltrators > 0 then

        bb.shoppingList[0] = {}
        
        for i=1, parameter.initialAtlases do
            table.insert(bb.shoppingList[0], "armatlas")
        end

        for i=1, parameter.initialSeers do
            table.insert(bb.shoppingList[0], "armseer")
        end

        for i=1, parameter.initialInfiltrators do
            table.insert(bb.shoppingList[0], "armspy")
        end
    end

	return SUCCESS
end
