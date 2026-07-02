
local sensorInfo = {
	name = "GetBestBuy",
	desc = "Returns the best buy option from the shopping list (cheapest of all units with the highest priority)",
	author = "Martin Verner",
	date = "2026-07-01",
	license = "notAlicense",
}

local EVAL_PERIOD_DEFAULT = -1 -- acutal, no caching

function getInfo()
	return {
		period = EVAL_PERIOD_DEFAULT
	}
end



return function()
	local bestPrice = math.huge
	local bestBuy = "armmart"

	local count = 0
	for _,a in pairs(bb.shoppingList) do
		count = count + 1
	end
	
	 if bb.shoppingList == nil or count == 0 then
	-- 	if bb.shoppingList == nil then
	-- 		Spring.Echo("Shopping list is nil, returning default best buy: " .. bestBuy)
	-- 	else
	-- 		Spring.Echo("Shopping list is empty, returning default best buy: " .. bestBuy)
	-- 	end
	 	return bestBuy -- return default best buy if shopping list is empty
	 end

	table.sort(bb.shoppingList) -- sorts the shopping list by priority (highest priority = lowest number)

	for priority, unitDefNames in pairs(bb.shoppingList) do
		--Spring.Echo("Checking best buy for priority: " .. priority .. " ... size of unitDefNames: " .. #unitDefNames)
		for id, unitDefName in ipairs(unitDefNames) do
			local price = bb.prices[unitDefName]
			if price < bestPrice then
				bestPrice = price
				bestBuy = unitDefName
			end
		end
		return bestBuy -- return the first best buy found (highest priority)
	end
end

