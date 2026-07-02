function getInfo()
	return {
		onNoUnits = SUCCESS, -- instant success
		tooltip = "Adds a unit to the shopping list with a given priority (lower number = higher priority)",
		parameterDefs = {
			{ 
				name = "unitName",
				variableType = "expression",
				componentType = "editBox",
				defaultValue = "'armbox'",
			},
			{
				name = "amount",
				variableType = "expression",
				componentType = "editBox",
				defaultValue = "1",
			},
			{ 
				name = "priority",
				variableType = "expression",
				componentType = "editBox",
				defaultValue = "0",
			},
			{
				name="shoppingCart",
				variableType = "expression",
				componentType = "editBox",
				defaultValue = "",
			},
		}
	}
end

function Run(self, units, parameter)
	local unitName = parameter.unitName
	local priority = parameter.priority
	local shoppingCart = parameter.shoppingCart

	if bb.shoppingList[priority] == nil then
		bb.shoppingList[priority] = {}
	end

	if shoppingCart[unitName] == nil then
		shoppingCart[unitName] = 0
	end

	for i=1, parameter.amount do
		shoppingCart[unitName] = shoppingCart[unitName] + 1
		table.insert(bb.shoppingList[priority], unitName)
	end

	return SUCCESS

end

function Reset(self)
	return self
end