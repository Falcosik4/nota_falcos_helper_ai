function getInfo()
	return {
		onNoUnits = SUCCESS, -- instant success
		tooltip = "Initializes attack behavior (holdFire, returnFire, fireAtWill)",
		parameterDefs = {
			{ 
				name = "attackBehavior",
				variableType = "expression",
				componentType = "editBox",
				defaultValue = "true",
			},
			{ 
				name = "movementBehavior",
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
	local attackBehavior = parameter.attackBehavior
	local movementBehavior = parameter.movementBehavior
	
 	local behvaiorNumber = attackBehavior == "holdFire" and 0 or attackBehavior == "returnFire" and 1 or attackBehavior == "fireAtWill" and 2 or 2
	local moveStateNumber = movementBehavior == "holdPos" and 0 or movementBehavior == "maneuver" and 1 or 0

	for i = 1, #units do
		local unitID = units[i]
		--if UnitDefs[Spring.GetUnitDefID(unitID)].weapons ~= nil then
		SpringGiveOrderToUnit(unitID, CMD.FIRE_STATE, { behvaiorNumber }, {})
		SpringGiveOrderToUnit(unitID, CMD.MOVE_STATE, { moveStateNumber }, {})
		--end
	end

	return SUCCESS
end
