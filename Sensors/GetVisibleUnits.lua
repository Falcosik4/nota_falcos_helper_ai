local sensorInfo = {
	name = "GetVisibleUnits",
	desc = "Returns a list of visible enemy units for the given team",
	author = "Martin Verner",
	date = "2026-05-22",
	license = "MIT",
}

VFS.Include("modules.lua")
VFS.Include(modules.attach.data.path .. modules.attach.data.head)

attach.Module(modules, "message")

local EVAL_PERIOD_DEFAULT = 0 -- instant, no caching

local units = {}

function getInfo()
	return {
		period = EVAL_PERIOD_DEFAULT
	}
end

function checkExistingUnits()
	for unitID, unitData in pairs(units) do
		local unitSighted = Spring.IsUnitInRadar(unitID)
		--local positionSighted = Spring.IsPosInRadar(unitData.pos.x, unitData.pos.y, unitData.pos.z)
		local LosOrRadar, inLos, inRadar, jammed = Spring.GetPositionLosState(unitData.pos.x, unitData.pos.y, unitData.pos.z, 0)	

		if  (unitSighted==nil or not unitSighted) and LosOrRadar then
			units[unitID] = nil
		end
	end
end

return function(teamIDs)

	local allUnits = {}

	checkExistingUnits()

	for j=1, #teamIDs do
		local teamID = teamIDs[j]
		
		local visibleUnits = Spring.GetTeamUnits(teamID)



		for i=1, #visibleUnits do
			local unitID = visibleUnits[i]
			
			local x, y, z = Spring.GetUnitPosition(unitID)
			units[unitID] = { pos = Vec3(x, y, z) }
			table.insert(allUnits, unitID)
		end

	end 

	Script.LuaUI.units_update(units, {1, 0, 0, 0.5})
	Script.LuaUI.mapGrid_updateEnemyRange(units, UnitDefs, WeaponDefs)

	return allUnits
end