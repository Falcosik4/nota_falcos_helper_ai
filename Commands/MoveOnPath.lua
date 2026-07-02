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
				name = "uncompressedPath",
				variableType = "expression",
				componentType = "editBox",
				defaultValue = "nil",
			},
			{
				name = "moveBack",
				variableType = "expression",
				componentType = "editBox",
				defaultValue = "false",
			},
			{
				name = "threshold",
				variableType = "number",
				componentType = "editBox",
				defaultValue = 40,
			},
			{
				name="compressing",
				variableType = "expression",
				componentType = "editBox",
				defaultValue = "true",
			}

		}
	}
end

local areaCheckStepSizeX = 100
local areaCheckStepSizeZ = 100

local areaCheckStepsX = 4
local areaCheckStepsZ = 4

local areaCheckHeightThreshold = 20

-- Checks if the pathfinding can be optimized for this position by checking if current position is in the pit (its height is way lower than the average of the area around it).
local function canOptimize(position)

	local averageHeight = 0
	local currentHeight = Spring.GetGroundHeight(position.x, position.z)

	for x = -areaCheckStepsX, areaCheckStepsX do
		for z = -areaCheckStepsZ, areaCheckStepsZ do
			local checkPosX = position.x + x * areaCheckStepSizeX
			local checkPosZ = position.z + z * areaCheckStepSizeZ

			averageHeight = averageHeight + Spring.GetGroundHeight(checkPosX, checkPosZ)
		end
	end

	averageHeight = averageHeight / ((areaCheckStepsX * 2 + 1) * (areaCheckStepsZ * 2 + 1))

	--Spring.Echo("currentHeight: " .. currentHeight .. ", averageHeight: " .. averageHeight)
	return averageHeight - currentHeight < areaCheckHeightThreshold
end


local minCompressionSteps = 1
-- Compresses path by truncating points in the same direction, also considering diagonal paths
local function getCompressedPath(path)

	local newPath = {}



	--Spring.Echo("calculating compressed path from: " .. tostring(path))
	if #path > 0 then
		table.insert(newPath, path[1])
		--Spring.Echo("-Moves-first point: " .. tostring(path[1]))

		if #path > 1 then
			local currentDir = (path[2] - path[1]):Normalize()	

			local currentCompressionSteps = 0
			for i = 2, #path - 1 do
				local currentPoint = path[i]
				local nextPoint = path[i+1]
				local nextNextPoint = path[i+2]

				local nextDir = Vec3(nextPoint.x - currentPoint.x, 0, nextPoint.z - currentPoint.z):Normalize()
				
				if not canOptimize(currentPoint) and currentCompressionSteps >= minCompressionSteps then
					table.insert(newPath, currentPoint)
					--Spring.Echo("-- Adding point to compressed path: " .. tostring(currentPoint))
					currentCompressionSteps = 0
					currentDir = nextDir
				else
					if nextNextPoint ~= nil then
						nextDir = Vec3(nextNextPoint.x - currentPoint.x, 0, nextNextPoint.z - currentPoint.z):Normalize()
						i = i+1 -- We skip a step
					end 

					if currentDir:Distance(nextDir) > 0.05 then
						table.insert(newPath, currentPoint)
						currentCompressionSteps = 0
						--Spring.Echo("--- Adding point to compressed path: " .. tostring(currentPoint))
						currentDir = nextDir
					else
						currentCompressionSteps = currentCompressionSteps + 1
					end
				end
			end

		table.insert(newPath, path[#path])
		--Spring.Echo("--last point: " .. tostring(path[#path]))
		end
	end

	return newPath
end

-- speed-ups
local SpringGetUnitPosition = Spring.GetUnitPosition
local SpringGiveOrderToUnit = Spring.GiveOrderToUnit

local setupPath = false
local targetPosition
local compressedPath = {}

local movementThreshold = 0.5
local lastPosition = Vec3(-100,-100,-100) -- Default value is outside of the

local function clearState(self)
	self.setupPath = false
	self.targetPosition = nil
	self.compressedPath = {}
end

function Run(self, units, parameter)

	--Spring.Echo("Movin on path!")
	local unit = parameter.unit -- ID
	local threshold = parameter.threshold
	local moveBack = parameter.moveBack

	if parameter.uncompressedPath == nil then
		return SUCCESS
	end

	--Spring.Echo("Is path setup ? " .. tostring(self.setupPath))

	if self.setupPath == nil or self.setupPath ==false then
		self.lastPosition = Vec3(-100,-100,-100) -- we reset last position to avoid false positives in stuck detection when setting up a new path
		--Spring.Echo("Got into path building!")
		local uncompressedPath = parameter.uncompressedPath -- array

		-- pick the spring command implementing the move
		local cmdID = CMD.MOVE

		if parameter.compressing == true then
			self.compressedPath = getCompressedPath(uncompressedPath)
		else
			self.compressedPath = uncompressedPath
		end

		local i = 1
		if moveBack then
			i = #self.compressedPath
			self.targetPosition = uncompressedPath[1]
		else
			self.targetPosition = uncompressedPath[#uncompressedPath]
		end

		--Spring.Echo("targetPosition: " .. tostring(self.targetPosition))

		while i > 0 and i <= #self.compressedPath do
			SpringGiveOrderToUnit(unit, cmdID, self.compressedPath[i]:AsSpringVector(), {"shift"})
			if not moveBack then i = i + 1 else i = i - 1 end
		end

		self.setupPath = true
	end

	if Spring.ValidUnitID(unit) == false then
		clearState(self)
		return FAILURE
	end
	
	local unitX, unitY, unitZ = SpringGetUnitPosition(unit)
	local unitPosition = Vec3(unitX, 0, unitZ)
	

	if unitPosition:Distance(self.lastPosition) < movementThreshold then
		--Spring.Echo("Unit is stuck, clearing path state.")
		clearState(self)
		return FAILURE
	end

	self.lastPosition = unitPosition

	local targetPosVec = Vec3(self.targetPosition.x, 0, self.targetPosition.z)
	local distance = unitPosition:Distance(targetPosVec)

	if distance < threshold then
		clearState(self)
		return SUCCESS
	end
	
	return RUNNING
end