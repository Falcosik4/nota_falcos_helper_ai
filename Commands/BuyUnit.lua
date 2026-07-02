-- get madatory module operators
VFS.Include("modules.lua") -- modules table
VFS.Include(modules.attach.data.path .. modules.attach.data.head) -- attach lib module

-- get other madatory dependencies
attach.Module(modules, "message") -- communication backend load

function getInfo()
	return {
		onNoUnits = SUCCESS, -- instant success
		tooltip = "Buy unit in param",
		parameterDefs = {
			{ 
				name = "unitName",
				variableType = "expression",
				componentType = "editBox",
				defaultValue = "'armbox'",
			},
			{
				name="prepaidMetal",
				variableType = "expression",
				componentType = "editBox",
				defaultValue = "0",
			},
		}
	}
end

local DEFAULT_THRESHOLD = 50 -- Threshold to prevent sudden metal loss and thus failed purchase

function Run(self, units, parameter)

	local unitName = parameter.unitName
    local metal = Spring.GetTeamResources(Spring.GetMyTeamID(), "metal")
    
	if bb.prices[unitName] > (metal - parameter.prepaidMetal - DEFAULT_THRESHOLD) then
        return FAILURE
    end

    message.SendRules({
        subject = "swampdota_buyUnit",
        data = {
			unitName = unitName
		},
    })

	if unitName == "armmart" then -- armmart is the default unit, so we don't need to remove it from the shopping list
		return SUCCESS
	end

	-- Removes the unit from the shopping list
	for priority, unitList in pairs(bb.shoppingList) do
		for i, shoppingListName in ipairs(unitList) do
			if shoppingListName == unitName then
				table.remove(bb.shoppingList[priority], i)
				if(#bb.shoppingList[priority] == 0) then
					bb.shoppingList[priority] = nil
				end
				return SUCCESS
			end
		end
	end

	return FAILURE
end

function Reset(self)
	return self
end