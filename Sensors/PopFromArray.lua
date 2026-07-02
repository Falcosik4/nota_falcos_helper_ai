
local sensorInfo = {
	name = "GetFirstFromList",
	desc = "Returns the first element from a list, or nil if the list is empty",
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



return function(array)
    if array == nil or #array == 0 then
        return nil
	end
	
	return table.remove(array, 1)
end

