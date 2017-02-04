local levelObjects = {}

local G=require ('globals')
local U=require ('utils')
local physics=require ('physics')
local mabs=math.abs
local mrandom=math.random

levelObjects.visible=false

function levelObjects:new(params)
	print('New object '..params.fileName)
	print('Object x='..params.x..' , y='..params.y)
	local objectGroup = display.newImageRect( params.displayGroup, params.fileName, params.width or 24, params.height or 57)
	objectGroup.x,objectGroup.y=  params.x or 0,params.y or 0 
	local object_outline = graphics.newOutline( params.outlineStep or 5, params.fileName )
    physics.addBody( objectGroup, "dynamic", { density = params.density or 3, friction = 0.99, bounce = 0.0, outline=object_outline , filter=params.filter} )
	objectGroup.name=params.name
	objectGroup.joint=physics.newJoint("weld",objectGroup,G.planet,params.x,params.y+params.height*0.5)
	objectGroup.joint.frequency=2.0
	objectGroup.joint.dampingRatio=0.8

	function objectGroup:show()
		objectGroup.alpha=1
		objectGroup.rotation=0
	end

	function objectGroup:hide()
		objectGroup.alpha=0
	end

	function objectGroup:destroy()
		display.remove( objectGroup )
		objectGroup=nil
	end

	return objectGroup
end

return levelObjects