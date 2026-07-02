local sensorInfo = {
	name = "UpdateAtlasesStatus",
	desc = "Updates the status of atlases",
	author = "Martin Verner",
	date = "2026-07-02",
	license = "notAlicense",
}

local EVAL_PERIOD_DEFAULT = -1 -- instant, no caching

function getInfo()
	return {
		period = EVAL_PERIOD_DEFAULT
	}
end


--function CheckUnits(currentUnits)
--
--end

return function(atlases, atlasesStatus)
    for i, uID in ipairs(atlases) do
		if atlasesStatus[uID] == nil then
			atlasesStatus[uID] = "free"
		end
	end

	return atlasesStatus
end