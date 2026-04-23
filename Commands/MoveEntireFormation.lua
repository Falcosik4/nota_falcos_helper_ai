function getInfo()
	return {
		onNoUnits = SUCCESS, -- instant success
		tooltip = "Move custom group to defined position. Group doesn't stop until every soldier is in position. Uses code from Formation.moveCustomGroup.",
		parameterDefs = {
			{ 
				name = "groupDefintion",
				variableType = "expression",
				componentType = "editBox",
				defaultValue = "",
			},
			-- @parameter groupDefintion [table] - mapping unitID => positionIndex
			--[[ local example = {
				[14945] = 1,
				[5814] = 2,
				[126450] = 3,
			}
			]]--
			{ 
				name = "position",
				variableType = "expression",
				componentType = "editBox",
				defaultValue = "",
			},
			{ 
				name = "formation", -- relative formation
				variableType = "expression",
				componentType = "editBox",
				defaultValue = "<relative formation>",
			},
			-- @parameter formation [array] - list of Vec3
			--[[ local example = {
				[1] = Vec3(0,0,0),
				[2] = Vec3(10,0,0),
				[3] = Vec3(-10,0,0),
			}
			]]--
		}
	}
end

-- constants
local THRESHOLD_STEP = 150
local THRESHOLD_DEFAULT = 10

-- speed-ups
local SpringGetUnitPosition = Spring.GetUnitPosition
local SpringGiveOrderToUnit = Spring.GiveOrderToUnit

local function ClearState(self)
	self.lastPositions = {}
	self.thresholds = {}
end

function Run(self, units, parameter)
	local customGroup = parameter.groupDefintion -- table
	local position = parameter.position -- Vec3
	local formation = parameter.formation -- array of Vec3
	
	-- pick the spring command implementing the move
	local cmdID = CMD.MOVE

	local unitsInPosition = 0
	local unitsTotal = 0

	
	if(self.lastPositions == nil) then
		self.lastPositions = {}
	end
	if(self.thresholds == nil) then
		self.thresholds = {}
	end

	for unitID, posIndex in pairs(customGroup) do
		local unitX, unitY, unitZ = SpringGetUnitPosition(unitID)
		local unitPosition = Vec3(unitX, unitY, unitZ)

		if (unitPosition == self.lastPositions[unitID]) then 
			if (self.thresholds ~= nil and table.getn(self.thresholds) > unitID) then
				self.thresholds[unitID] = self.thresholds[unitID] + THRESHOLD_STEP 
			else
				self.thresholds[unitID] = self.thresholds[unitID] + THRESHOLD_STEP
			end
		else
			self.thresholds[unitID] = THRESHOLD_DEFAULT
		end

		self.lastPositions[unitID] = unitPosition

		local unitOffset = formation[posIndex]
		local unitWantedPosition = position + unitOffset
		local distance = unitPosition:Distance(unitWantedPosition)
		Spring.Echo("Unit " .. unitID .. " distance to wanted position: " .. distance .. ", threshold: " .. self.thresholds[unitID])
		if(distance < self.thresholds[unitID]) then
			unitsInPosition = unitsInPosition + 1
		else
			SpringGiveOrderToUnit(unitID, cmdID, unitWantedPosition:AsSpringVector(), {})
		end

		unitsTotal = unitsTotal + 1
	end

	if (unitsInPosition >= unitsTotal - 1) then
		return SUCCESS
	else
		Spring.Echo("Units in position: " .. unitsInPosition .. "/" .. unitsTotal)
		return RUNNING
	end

end


function Reset(self)
	ClearState(self)
end
