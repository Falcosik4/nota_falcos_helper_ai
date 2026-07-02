function getInfo()
	return {
		onNoUnits = SUCCESS, -- instant success
		tooltip = "Initializes the map grid with custom values (nothing = default values)",
		parameterDefs = {
			{ 
				name = "defaultRange",
				variableType = "expression",
				componentType = "editBox",
				defaultValue = "",
			},
            { 
				name = "heightThreshold",
				variableType = "expression",
				componentType = "editBox",
				defaultValue = "",
			},
            { 
                name = "rangeHeightThreshold",
                variableType = "expression",
                componentType = "editBox",
                defaultValue = "",
            },
            { 
                name = "cellsPerLine",
                variableType = "expression",
                componentType = "editBox",
                defaultValue = "",
            },
		}
	}
end

-- speed-ups
local SpringGiveOrderToUnit = Spring.GiveOrderToUnit

function Run(self, units, parameter)
	

    local defaultRange = parameter.defaultRange
    local heightThreshold = parameter.heightThreshold
    local rangeHeightThreshold = parameter.rangeHeightThreshold
    local cellsPerLine = parameter.cellsPerLine

    Script.LuaUI.mapGrid_setup(defaultRange, heightThreshold, rangeHeightThreshold, cellsPerLine)

	return SUCCESS
end
