local sensorInfo = {
	name = "GetClosestEnemyFrom",
	desc = "Returns the closest enemy in a zone to the source position.",
	author = "Martin Verner",
	date = "2026-06-02",
	license = "MIT",
}

VFS.Include("modules.lua")
VFS.Include(modules.attach.data.path .. modules.attach.data.head)

attach.Module(modules, "message")

local EVAL_PERIOD_DEFAULT = 0 -- instant, no caching

function getInfo()
	return {
		period = EVAL_PERIOD_DEFAULT
	}
end

return function(teamID, area, sourcePos)
	local enemyUnits = Spring.GetUnitsInSphere(area.center.x, area.center.y, area.center.z, area.radius, teamID)

	if enemyUnits ==nil or #enemyUnits == 0 then
		return nil
	end
	
	local closestEnemyPos = nil
	local closestDistance = math.huge

	for i = 1, #enemyUnits do
		local unitPos = Spring.GetUnitPosition(enemyUnits[i])
		if unitPos then
			local distance = Vec3(unitPos.x - sourcePos.x, unitPos.y - sourcePos.y, unitPos.z - sourcePos.z):Length()
			if distance < closestDistance then
				closestDistance = distance
				closestEnemyPos = unitPos
			end
		end
	end

	return closestEnemyPos
end