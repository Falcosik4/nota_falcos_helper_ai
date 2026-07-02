function getInfo()
	return {
		tooltip = "Makes multiple units fight towards a position",
		parameterDefs = {
			{ 
				name = "units",
				variableType = "expression",
				componentType = "editBox",
				defaultValue = "nil",
			},
			{ 
				name = "position",
				variableType = "expression",
				componentType = "editBox",
				defaultValue = "nil",
			},
		},
	}
end




local CMD_FIGHT = CMD.FIGHT

function Run(self, units, parameter)

	local selectedUnits = parameter.units -- ID
	local position = parameter.position -- Vec3

	if selectedUnits == nil or position == nil then
		return FAILURE
	end

	Spring.GiveOrderToUnitArray(selectedUnits, CMD_FIGHT, position:AsSpringVector(),  {"shift"})
	--for i, unit in ipairs(selectedUnits) do
	--	Spring.GiveOrderToUnit(unit, CMD_FIGHT, {position:AsSpringVector()}, {"shift"})
	--end

	return SUCCESS
end