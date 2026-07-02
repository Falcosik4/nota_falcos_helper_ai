function getInfo()
	return {
		tooltip = "Moves a unit approximately to a position.",
		parameterDefs = {
			{ 
				name = "unit",
				variableType = "expression",
				componentType = "editBox",
				defaultValue = "",
			},
			{ 
				name = "position",
				variableType = "expression",
				componentType = "editBox",
				defaultValue = "",
			},
			{
				name = "baseThreshold",
				variableType = "number",
				componentType = "editBox",
				defaultValue = 40,
			},
		}
	}
end

-- constants
local THRESHOLD_STEP = 150

-- speed-ups
local SpringGetUnitPosition = Spring.GetUnitPosition
local SpringGiveOrderToUnit = Spring.GiveOrderToUnit

local function ClearState(self)
	self.lastPosition = Vec3(0,0,0)
	self.threshold = THRESHOLD_DEFAULT
	self.setup = false
end

function Run(self, units, parameter)

	local position = parameter.position -- Vec3
	local unit = parameter.unit -- ID
	local baseThreshold = parameter.baseThreshold

	-- pick the spring command implementing the move
	local cmdID = CMD.MOVE

	local unitPosition = Vec3(SpringGetUnitPosition(unit))
	local distance = unitPosition:Distance(position)

	if self.setup == nil or self.setup == false then
		SpringGiveOrderToUnit(unit, cmdID, position:AsSpringVector(), {})
		self.setup = true

		self.threshold = baseThreshold
		self.lastPosition = Vec3(0,0,0)

	end



	if Script.LuaUI.mapGrid_isPointSafe(position) == false then
		SpringGiveOrderToUnit(unit, CMD.STOP, {}, {})
		return FAILURE
	end

	if unitPosition == self.lastPosition then
		self.threshold = self.threshold + THRESHOLD_STEP
	else
		self.threshold = baseThreshold
	end


	if distance < self.threshold then
		return SUCCESS
	else
		self.lastPosition = unitPosition
		return RUNNING
	end

end


function Reset(self)
	ClearState(self)
end
