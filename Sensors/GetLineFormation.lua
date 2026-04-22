-- Logic inspired by Definition.lua in formation by PepeAmpere

local sensorInfo = {
	name = "GetLineFormation",
	desc = "Returns line formation definition",
	author = "Martin Verner",
	date = "2026-04-24",
	license = "notAlicense",
}

local EVAL_PERIOD_DEFAULT = 0 -- instant, no caching

function getInfo()
	return {
		period = EVAL_PERIOD_DEFAULT
	}
end

local lineFormation = {
	name = "line",
	positions = {
		[1]  = {0,0},		[2]  = {-2,0},		[3]  = {2,0},		[4]  = {-4,0},		[5]  = {4,0},
		[6]  = {-6,0},		[7]  = {6,0},		[8]  = {-8,0},		[9]  = {8,0},		[10] = {-10,0},
		[11] = {10,0},		[12] = {-12,0},		[13] = {12,0},		[14] = {-14,0},		[15] = {14,0},
		[16] = {-16,0},		[17] = {16,0},		[18] = {-18,0},		[19] = {18,0},		[20] = {-20,0},
		[21] = {20,0},		[22] = {-22,0},		[23] = {22,0},		[24] = {-24,0},		[25] = {24,0},
		[26] = {-26,0},		[27] = {26,0},		[28] = {-28,0},		[29] = {28,0},		[30] = {-30,0},
	},
	generated = false,
	defaults = {
		spacing = Vec3(25,0,0),
		hillyCoeficient = 20,
		constrained = true,
		variant = false,
		rotable = true,
	},
}

-- @description return stuctured description of the line formation
return function()
	local thisDefinition = lineFormation
	local thisPositions = thisDefinition.positions
	local vectorPositions = {}
	local vectorPositionsCount = 0
	
	for i=1, #thisPositions do
		vectorPositionsCount = vectorPositionsCount + 1
		vectorPositions[vectorPositionsCount] = Vec3(thisPositions[i][1], 0, thisPositions[i][2])
	end
	
	-- do not rewrite the originial table otherwise it is not robust on "reset"
	local finalDefinition = {
		name = thisDefinition.name,
		positions = vectorPositions,
		generated = thisDefinition.generated,
		defaults = thisDefinition.defaults,		
	}
	
	return finalDefinition
end