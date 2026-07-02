function getInfo()
	return {
		onNoUnits = SUCCESS, -- instant success
		tooltip = "Initializes attack behavior (holdFire, returnFire, fireAtWill)",

		parameterDefs = {
			{
				name = "unit",
				variableType = "expression",
				componentType = "editBox",
				defaultValue = "nil",
			},
			{ 
				name = "attackBehavior",
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
	local unit = parameter.unit -- ID

	if not Spring.ValidUnitID(unit) then
		return FAILURE
	end

	local attackBehavior = parameter.attackBehavior
 	local behaviorNumber = attackBehavior == "holdFire" and 0 or attackBehavior == "returnFire" and 1 or attackBehavior == "fireAtWill" and 2 or 2

	SpringGiveOrderToUnit(unit, CMD.FIRE_STATE, { behaviorNumber }, {})


	return SUCCESS
end
