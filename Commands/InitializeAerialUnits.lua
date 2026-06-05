function getInfo()
	return {
		onNoUnits = SUCCESS, -- instant success
		tooltip = "Initializes behavior of aerial units (in units)",
		parameterDefs = {
			{ 
				name = "landOnIdle",
				variableType = "expression",
				componentType = "editBox",
				defaultValue = "true",
			},
		}
	}
end

-- speed-ups
local SpringGiveOrderToUnit = Spring.GiveOrderToUnit

function Run(self, units, parameter)
	local landOnIdle = parameter.landOnIdle
	
	for i = 1, #units do
		local unitID = units[i]
		if UnitDefs[Spring.GetUnitDefID(unitID)].isAirUnit then
			SpringGiveOrderToUnit(unitID, CMD.IDLEMODE, { landOnIdle and 1 or 0 }, {})
		end
	end

	return SUCCESS
end
