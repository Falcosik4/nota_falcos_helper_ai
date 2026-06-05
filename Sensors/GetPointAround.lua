local sensorInfo = {
	name = "GetPointAround",
	desc = "Gets the closest point around the target position in specified range and height tolerance. Returns nil if no suitable point is found.",
	author = "Martin Verner",
	date = "2026-06-02",
	license = "MIT",
}

local EVAL_PERIOD_DEFAULT = 0 -- instant, no caching


function getInfo()
	return {
		period = EVAL_PERIOD_DEFAULT
	}
end


return function(targetPos, sourcePos, range, heightTolerance)

	local direction = Vec3(targetPos.x - sourcePos.x, 0, targetPos.z - sourcePos.z):Normalize()

	for i = 0, 10, 1 do
		local angle = math.rad(i * 36)
		local sin = math.sin(angle)
		local cos = math.cos(angle)

		local rotatedDirection = Vec3(
			direction.x * cos - direction.z * sin,
			0,
			direction.x * sin + direction.z * cos
		)
		
		local rotatedTarget = rotatedDirection * range + targetPos

		local newHeight = Spring.GetGroundHeight(rotatedTarget.x, rotatedTarget.z)
		if heightTolerance == nil or math.abs(newHeight - targetPos.y) <= heightTolerance then
			return Vec3(rotatedTarget.x, newHeight, rotatedTarget.z)
		end
	end

	return nil -- No suitable point found
end