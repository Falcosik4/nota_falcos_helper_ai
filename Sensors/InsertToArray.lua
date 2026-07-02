
local sensorInfo = {
	name = "InsertToArray",
	desc = "Inserts an element into an array",
	author = "Martin Verner",
	date = "2026-07-02",
	license = "notAlicense",
}

local EVAL_PERIOD_DEFAULT = -1 -- acutal, no caching

function getInfo()
	return {
		period = EVAL_PERIOD_DEFAULT
	}
end



return function(array, element)
    if array == nil then
        return nil
	end
	
	table.insert(array, element)
	return array
end

