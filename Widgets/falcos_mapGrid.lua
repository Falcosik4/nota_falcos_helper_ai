-- Divides the map into a grid showing some useful information (height, possible "passability" defined by height difference threshold, and enemies in range of each cell).
-- 
moduleInfo = {
	name = "mapGrid",
	desc = "map grid",
	author = "Martin Verner",
	date = "2026-05-24",
	license = "MIT",
	layer = -1,
	enabled = true
}


local DEFAULT_RANGE = 680 -- = crasher's default weapon range
local CELLS_PER_LINE = 25

local cell_distance_x
local cell_distance_z

local RANGE_HEIGHT_THRESHOLD = 150
local HEIGHT_THRESHOLD = 8.4
local MapSize
local gridCells = {}

local spGetGroundHeight = Spring.GetGroundHeight
local spGetUnitPosition = Spring.GetUnitPosition

local maxUnitsInRange = 0
local canDisplay = false

local MIN_TEXT_SIZE = 10
local MAX_TEXT_SIZE = 50


local debugMinXs = {0,0,0,0}
local debugMaxXs = {0,0,0,0}
local debugMinZs = {0,0,0,0}
local debugMaxZs = {0,0,0,0}

local currentDebugIndex = 1

function widget:GetInfo()
	return moduleInfo
end



local function ExistsPath(startPosition, targetPosition, heightThreshold)
    -- Finds a path from start to target position throughout the grid, using A*
    -- The distance function is simply the Euclidean distance between the positions, and the heuristic is the number of enemies in range of the cell (times )

    local startCellX, startCellZ = GetCellIndices(startPosition)
    local targetCellX, targetCellZ = GetCellIndices(targetPosition)

    local startCell = GetCell(startCellX, startCellZ)
    local targetCell = GetCell(targetCellX, targetCellZ)

    
    local lastDir = {0,0}
    local currentHeight = startCell.pos.y

    local currentCell = startCell


    local openCells = { startCell }
    local closedCells = {}
    local parents = {}


    while currentCell ~= targetCell do
        currentCell = openCells[1]
        table.remove(openCells, 1)

        local neighbors = GetNeighbors(startPosition.x, startPosition.z)

        local lowestCost = math.huge

        for i = 1, #neighbors do
            local neighbor = neighbors[i]
            local heightDiff = math.abs(neighbor.cell.pos.y - currentHeight)

            if heightDiff <= heightThreshold then
                if neighbor.cell == targetCell then
                    return true
                end
                openCells[#openCells + 1] = neighbor.cell
                parents[neighbor.cell] = currentCell
            end
        end 
    end

    return false
end

function GetCellIndices(position)
    local cellX = math.floor(position.x / cell_distance_x)
    local cellZ = math.floor(position.z / cell_distance_z)

    return cellX, cellZ
end

function GetCell(cellX, cellZ)
    return gridCells[cellX * CELLS_PER_LINE + cellZ + 1]
end

function XXYYSafe(pos1, pos2)
    local minX = math.min(pos1.x, pos2.x)
    local maxX = math.max(pos1.x, pos2.x)

    local minZ = math.min(pos1.z, pos2.z)
    local maxZ = math.max(pos1.z, pos2.z)

    debugMinXs[currentDebugIndex] = minX
    debugMaxXs[currentDebugIndex] = maxX
    debugMinZs[currentDebugIndex] = minZ
    debugMaxZs[currentDebugIndex] = maxZ

    currentDebugIndex = (currentDebugIndex % 4) + 1

    --Spring.Echo("Min X: " .. minX .. ", max X: " .. maxX .. ", min Z: " .. minZ .. ", max Z: " .. maxZ)

    local minXCell = math.floor(minX / cell_distance_x)
    local maxXCell = math.floor(maxX / cell_distance_x)

    local minZCell = math.floor(minZ / cell_distance_z)
    local maxZCell = math.floor(maxZ / cell_distance_z)



    for cellX = minXCell, maxXCell do
        for cellZ = minZCell, maxZCell do
            local cell = GetCell(cellX, cellZ)
            if cell.inEnemyRange > 0 then
                return false
            end
        end
    end

    --Spring.Echo("Is safe!")

    return true
end

function GetNeighbors(cellX, cellZ)
    -- Returns the neighboring cells of the given cell (horizonatlly, vertically, diagonally)
    local neighbors = {}

    for dy = -1, 1 do
        for dx = -1, 1 do
            if dx ~= 0 or dy ~= 0 then
                local neighborX = cellX + dx
                local neighborZ = cellZ + dy

                if neighborX >= 0 and neighborX <= CELLS_PER_LINE and neighborZ >= 0 and neighborZ < CELLS_PER_LINE then
                    table.insert(neighbors, { dir={dx, dy}, cell=gridCells[neighborX * CELLS_PER_LINE + neighborZ + 1]})
                end
            end
        end
    end

    return neighbors
end

local function UpdateMap()
    for i = 0, CELLS_PER_LINE+1 do
        cell_distance_x = MapSize.x / CELLS_PER_LINE
        cell_distance_z = MapSize.z / CELLS_PER_LINE

        for j = 0, CELLS_PER_LINE do
            local cellX = i * cell_distance_x
            local cellZ = j * cell_distance_z

            local height = spGetGroundHeight(cellX, cellZ)
            gridCells[i * CELLS_PER_LINE + j + 1] = { pos = Vec3(cellX, height, cellZ), inEnemyRange = 0, inRadar = Spring.IsPosInRadar(cellX, height, cellZ) }
        end
    end
end

local function UpdateEnemyRange(enemies, unitDefArray, weaponDefArray)
    for i = 1, #gridCells do
        gridCells[i].inEnemyRange = 0
    end
    --Spring.Echo("====== Beginning enemy range update ======")
    for unitID, enemyData in pairs(enemies) do
        local enemyPos = enemyData.pos
        local enemyHeight = enemyData.pos.y

        local enemyCellX = enemyPos.x / (MapSize.x / CELLS_PER_LINE)
        local enemyCellZ = enemyPos.z / (MapSize.z / CELLS_PER_LINE)
    
        local maxWeaponRange = 0

        local unitDefID = Spring.GetUnitDefID(unitID)
        if unitDefID == nil then -- The type is not known -> assume default range
            maxWeaponRange = DEFAULT_RANGE
        else
            local enemyWeapons = unitDefArray[unitDefID].weapons
            if enemyWeapons == nil then
                maxWeaponRange = 0
            elseif #enemyWeapons > 0 then
                for j = 1, #enemyWeapons do
                
                    local weaponDefID = enemyWeapons[j].weaponDef
                    local weaponRange = weaponDefArray[weaponDefID].range
                    if maxWeaponRange == nil or weaponRange > maxWeaponRange then
                        maxWeaponRange = weaponRange
                    end
                end
            end
        end


        if maxWeaponRange > 0 then -- No dangerous area added if maxWeaponRange is 0 

            local weaponRangeX = maxWeaponRange / (MapSize.x / CELLS_PER_LINE)
            local weaponRangeZ = maxWeaponRange / (MapSize.z / CELLS_PER_LINE)

            local minCellX = math.max(0, math.floor(enemyCellX - weaponRangeX + 0.5))
            local maxCellX = math.min(CELLS_PER_LINE-1, math.ceil(enemyCellX + weaponRangeX))
            local minCellZ = math.max(0, math.floor(enemyCellZ - weaponRangeZ + 0.5))
            local maxCellZ = math.min(CELLS_PER_LINE-1, math.ceil(enemyCellZ + weaponRangeZ))

            ----Spring.Echo("Enemy cell X: " .. enemyCellX .. ", enemy cell Z: " .. enemyCellZ .. ", weapon range in cells X: " .. weaponRangeX .. ", weapon range in cells Z: " .. weaponRangeZ)
            ----Spring.Echo("Minimal cell X: " .. minCellX .. ", maximal cell X: " .. maxCellX .. ", minimal cell Z: " .. minCellZ .. ", maximal cell Z: " .. maxCellZ)
            
            if minCellZ == 0 then
                ----Spring.Echo("!!!\n ZERO Z COORDINATE !!!\n")
            end

            for i = minCellX, maxCellX do
                for j = minCellZ, maxCellZ do
                    local cell = GetCell(i, j)

                    local cellHeight = cell.pos.y
                    local heightDiff = enemyHeight - cellHeight
                    
                    -- Usually, the enemies can better shoot uphill than downhill, so we use a higher threshold for height difference when the enemy is higher than the cell. This means that some cells that would be considered in range when the enemy is lower will not be considered in range when the enemy is higher, which is more realistic.
                    if heightDiff <= RANGE_HEIGHT_THRESHOLD and heightDiff >= -(2*RANGE_HEIGHT_THRESHOLD) then
                        cell.inEnemyRange = cell.inEnemyRange + 1
                    end


                    if cell.inEnemyRange > maxUnitsInRange then
                        maxUnitsInRange = cell.inEnemyRange
                    end
                end
            end
        end 

    end
    
    ----Spring.Echo("====== Finished enemy range update ======\n\n\n")
end
    

local function Setup(defaultRange, heightThreshold, rangeHeightThreshold, cellsPerLine)
    
    if defaultRange ~= nil then
        DEFAULT_RANGE = defaultRange
    end
    if heightThreshold ~= nil then
        HEIGHT_THRESHOLD = heightThreshold
    end
    if rangeHeightThreshold ~= nil then
        RANGE_HEIGHT_THRESHOLD = rangeHeightThreshold
    end
    if cellsPerLine ~= nil then
        CELLS_PER_LINE = cellsPerLine
    end

    UpdateMap()
end

local function IsPointSafe(point)
    local cellX, cellZ = GetCellIndices(point)
    local cell = GetCell(cellX, cellZ)

    if cell.inEnemyRange > 0 then
        return false
    else
        return true
    end
end

function widget:Initialize()
    widgetHandler:RegisterGlobal('mapGrid_updateEnemyRange', UpdateEnemyRange)
    widgetHandler:RegisterGlobal('mapGrid_setup', Setup)
    widgetHandler:RegisterGlobal('mapGrid_existsPath', ExistsPath)
    widgetHandler:RegisterGlobal('mapGrid_xxyySafe', XXYYSafe)
    widgetHandler:RegisterGlobal('mapGrid_isPointSafe', IsPointSafe)
    MapSize = {x = Game.mapSizeX, z = Game.mapSizeZ}
    UpdateMap()
end

function widget:UnsyncedHeightMapUpdate()
    UpdateMap()
end

function widget:KeyPress(key, mods, isRepeat)
    if key == 0x6D and mods.ctrl and not isRepeat then
        canDisplay = not canDisplay
    end

    return false
end

-- get madatory module operators
VFS.Include("modules.lua") -- modules table
VFS.Include(modules.attach.data.path .. modules.attach.data.head) -- attach lib module

-- get other madatory dependencies
attach.Module(modules, "stringExt")
Vec3 = attach.Module(modules, "vec3")

-- OpenGL speedups
local glColor = gl.Color
local glBeginEnd = gl.BeginEnd
local glPushMatrix = gl.PushMatrix
local glPopMatrix = gl.PopMatrix
local glTranslate = gl.Translate
local glText = gl.Text
local glLineWidth = gl.LineWidth
local glVertex = gl.Vertex
local GL_LINE_STRIP = GL.LINE_STRIP
local max = math.max
local min = math.min

local units = {}
local color = {1, 0, 0, 0.5}

local function Update(unitsData, usedColor)
	units = unitsData
    color = usedColor
end

function Lerp(a, b, t)

    local value
    if t < 0 then
        value = a
    elseif t > 1 then
        value = b
    else
        value = a + (b - a) * t
    end

    return value
end

function widget:DrawWorld()
    if not canDisplay then
        return
    end

    -- Draws lines of the grid, colored by height difference between neighboring cells (red = impassable, green = passable)
    glColor(color)
    glLineWidth(1)
    for i = 0, CELLS_PER_LINE+1 do
        glBeginEnd(GL_LINE_STRIP, function()
            for j = 0, CELLS_PER_LINE-1 do

                local cellCoordinates = GetCell(i,j).pos
                
                local nextCell
                if j < CELLS_PER_LINE-2 then
                    nextCell = GetCell(i, j + 1).pos
                else
                    nextCell = nil
                end

                if nextCell ~= nil then
                
                    local heightDifference = math.abs(cellCoordinates.y - nextCell.y)
                    local colorRed = Lerp(0, 1, heightDifference / HEIGHT_THRESHOLD)
                    local colorGreen = 1 - colorRed
                    glColor(colorRed, colorGreen, 0, 0.5)
                else
                    glColor(1, 0, 0, 0.5)
                end

                glVertex(cellCoordinates.x, cellCoordinates.y, cellCoordinates.z)
            end
        end)
    end


    -- Draws columns of the grid, colored by height difference between neighboring cells (red = impassable, green = passable)
    for j = 0, CELLS_PER_LINE-1 do
        glBeginEnd(GL_LINE_STRIP, function()
            for i = 0, CELLS_PER_LINE+1 do
                local cellCoordinates = gridCells[i * CELLS_PER_LINE + j + 1].pos
                local nextCell
                if j < CELLS_PER_LINE-2 then
                    nextCell = GetCell(i, j + 1).pos
                else
                    nextCell = nil
                end

                if nextCell ~= nil then           
                    local heightDifference = math.abs(cellCoordinates.y - nextCell.y)
                    local colorRed = Lerp(0, 1, heightDifference / HEIGHT_THRESHOLD)
                    local colorGreen = 1 - colorRed
                    glColor(colorRed, colorGreen, 0, 0.5)
                else
                    glColor(1, 0, 0, 0.5)
                end
                glVertex(cellCoordinates.x, cellCoordinates.y, cellCoordinates.z)
            end
        end)
    end

    -- Draws numbers of enemies in range for each cell
    for i = 0, CELLS_PER_LINE+1 do
        for j = 0, CELLS_PER_LINE-1 do
            local cell = GetCell(i, j)
            local text = tostring(cell.inEnemyRange)
            glColor(1, 1, 1, 1)

            local textSize = 20 -- default text size

            if maxUnitsInRange > 0 then
                textSize = Lerp(MIN_TEXT_SIZE, MAX_TEXT_SIZE, cell.inEnemyRange / maxUnitsInRange) 
            end

            glPushMatrix()
            glTranslate(cell.pos.x, cell.pos.y, cell.pos.z + 25)
            gl.Billboard()
            glText(text, 0, 0, textSize)
            glPopMatrix()
        end
    end

    for i = 1, 4 do
        glColor(1, 1, 0, 0.2)
        glBeginEnd(GL.QUADS, function()
            glVertex(debugMinXs[i], Spring.GetGroundHeight(debugMinXs[i], debugMinZs[i]), debugMinZs[i])
            glVertex(debugMaxXs[i], Spring.GetGroundHeight(debugMaxXs[i], debugMinZs[i]), debugMinZs[i])
            glVertex(debugMaxXs[i], Spring.GetGroundHeight(debugMaxXs[i], debugMaxZs[i]), debugMaxZs[i])
            glVertex(debugMinXs[i], Spring.GetGroundHeight(debugMinXs[i], debugMaxZs[i]), debugMaxZs[i])
        end)
    end

end