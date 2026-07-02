-- Module for keeping track of and rendering visible enemy units
-- Based on dbg_exampleDrawLines.lua by PepeAmpere
moduleInfo = {
	name = "highlightUnit",
	desc = "highlight unit",
	author = "Martin Verner",
	date = "2026-05-22",
	license = "MIT",
	layer = -1,
	enabled = true
}

function widget:GetInfo()
	return moduleInfo
end

-- get madatory module operators
VFS.Include("modules.lua") -- modules table
VFS.Include(modules.attach.data.path .. modules.attach.data.head) -- attach lib module

-- get other madatory dependencies
attach.Module(modules, "stringExt")
Vec3 = attach.Module(modules, "vec3")

local glColor = gl.Color
local glBeginEnd = gl.BeginEnd
local glLineWidth = gl.LineWidth
local glLineStipple = gl.LineStipple
local glVertex = gl.Vertex
local GL_LINE_LOOP = GL.LINE_LOOP
local max = math.max
local min = math.min

local units = {}
local color = {1, 0, 0, 0.5}

local function Update(unitsData, usedColor)
	units = unitsData
    color = usedColor
end

local function GetCurrentUnits()
    return units
end

local function UnitSeen(unitKey)
    return units[unitKey] ~= nil
end

local function GetUnitPosition(unitKey)
    if units[unitKey] ~= nil then
        return units[unitKey].pos
    end
    return nil
end

function widget:Initialize()
	widgetHandler:RegisterGlobal('units_update', Update)
    widgetHandler:RegisterGlobal('units_getCurrent', GetCurrentUnits)
    widgetHandler:RegisterGlobal('units_unitSeen', UnitSeen)
    widgetHandler:RegisterGlobal('units_getPosition', GetUnitPosition)  
end

function widget:GameFrame(n)
end

function widget:DrawWorld()
	for unitKey, unitData in pairs(units) do
        -- Draws a rect around the unit's position
        if(unitData ~= nil) then
            local unitPosition = unitData.pos	
            local function RectLines(pos, size)
                glVertex(pos.x - size, pos.y, pos.z - size)
                glVertex(pos.x + size, pos.y, pos.z - size)
                glVertex(pos.x + size, pos.y, pos.z + size)
                glVertex(pos.x - size, pos.y, pos.z + size)
            end

            local x, y, z = unitPosition.x, unitPosition.y, unitPosition.z
            local size = 10 -- Size of the rectangle
            
            -- Draws the rectangle with the specified color
            glColor(color)
            
            glLineStipple(false)
            glLineWidth(5)
            glBeginEnd(GL_LINE_LOOP, RectLines, unitPosition, size)
            glLineStipple(false)
        end
	end
	glColor(1, 0, 0, 1)
end