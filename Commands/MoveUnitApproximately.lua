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
end

function Run(self, units, parameter)

	local position = parameter.position -- Vec3
	local unit = parameter.unit -- ID
	local baseThreshold = parameter.baseThreshold

	Spring.Echo("Parameter ... " .. parameter.unit)

	-- pick the spring command implementing the move
	local cmdID = CMD.MOVE

	if self.threshold == nil then
		self.threshold = baseThreshold
	end

	if self.lastPosition == nil then
		self.lastPosition = Vec3(0,0,0)
	end

	Spring.Echo("Bear ID: " .. unit)

	if unitPosition == self.lastPosition then
		self.threshold = self.threshold + THRESHOLD_STEP
	else
		self.threshold = baseThreshold
	end

	local unitX, unitY, unitZ = SpringGetUnitPosition(unit)
	local unitPosition = Vec3(unitX, unitY, unitZ)
	local distance = unitPosition:Distance(position)

	if distance < self.threshold then
		return SUCCESS
	else
		SpringGiveOrderToUnit(unit, cmdID, position:AsSpringVector(), {})
		self.lastPosition = unitPosition
		return RUNNING
	end

--
--	for unitID, posIndex in pairs(customGroup) do
--
--
--		if (unitPosition == self.lastPositions[unitID]) then 
--			if (self.thresholds ~= nil and table.getn(self.thresholds) > unitID) then
--				self.thresholds[unitID] = self.thresholds[unitID] + THRESHOLD_STEP 
--			else
--				self.thresholds[unitID] = self.thresholds[unitID] + THRESHOLD_STEP
--			end
--		else
--			self.thresholds[unitID] = THRESHOLD_DEFAULT
--		end
--
--		self.lastPositions[unitID] = unitPosition
--
--		local unitOffset = formation[posIndex]
--		local unitWantedPosition = position + unitOffset
--		local distance = unitPosition:Distance(unitWantedPosition)
--		Spring.Echo("Unit " .. unitID .. " distance to wanted position: " .. distance .. ", threshold: " .. self.thresholds[unitID])
--		if(distance < self.thresholds[unitID]) then
--			unitsInPosition = unitsInPosition + 1
--		else
--			SpringGiveOrderToUnit(unitID, cmdID, unitWantedPosition:AsSpringVector(), {})
--		end
--
--		unitsTotal = unitsTotal + 1
--	end
--
--	if (unitsInPosition >= unitsTotal - 1) then
--		return SUCCESS
--	else
--		Spring.Echo("Units in position: " .. unitsInPosition .. "/" .. unitsTotal)
--		return RUNNING
--	end
--
end


function Reset(self)
	ClearState(self)
end
