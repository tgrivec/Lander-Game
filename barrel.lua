local Barrel = {}

local G=require ('globals')
local U=require ('utils')
local physics=require ('physics')
local mabs=math.abs
local mrandom=math.random


Barrel.visible=false

function Barrel:new(params)
	print('New barrel '..params.fileName)
	print('Barrel x='..params.x..' , y='..params.y)
	--local barrelGroup = display.newGroup()
	local barrelGroup = display.newImageRect( params.displayGroup, params.fileName, params.width or 24, params.height or 57)
	barrelGroup.x,barrelGroup.y=  params.x or 0,params.y or 0 
	--params.displayGroup:insert(barrelGroup)
	local barrel_outline = graphics.newOutline( 4, params.fileName )
    physics.addBody( barrelGroup, "dynamic", { density = 3, friction = 0.99, bounce = 0.0, outline=barrel_outline , filter={categoryBits=64, maskBits=7}} )
	barrelGroup.barrelTargetRect=display.newGroup( )
	barrelGroup.barrelHolo=display.newImageRect( params.displayGroup, params.fileNameHolo, 16, 24 )
	barrelGroup.barrelHolo.alpha=0.5
	barrelGroup.barrelHoloDistance=display.newText( params.displayGroup, '000.0 m', 0,0, 62,20, '5by7', 16 )
  	barrelGroup.barrelHoloDistance:setTextColor( 0,1,0.5,0.8 )
  	barrelGroup.score=0 
	barrelGroup.alpha=0	
	
	U.newScannerTarget({group=barrelGroup.barrelTargetRect,width=params.width or 24,height=params.height or 57})

	function barrelGroup:setHolo(params) -- {dir=1 left side, dir=-1 right side of astroHolo, x,y, text}
		barrelGroup.barrelHolo.x=params.x+12*params.dir
		barrelGroup.barrelHolo.y=params.y-50
		barrelGroup.barrelHoloDistance.x=params.x+50*params.dir
		barrelGroup.barrelHoloDistance.y=params.y-40
		barrelGroup.barrelHoloDistance.text=params.text or '000.0 m'
	end

	function barrelGroup:show()
		barrelGroup.alpha=1
		barrelGroup.rotation=0
	end

	function barrelGroup:hide()
		barrelGroup.alpha=0
	end

	function barrelGroup:scannerOn()
		barrelGroup.barrelTargetRect.alpha=0.75
		barrelGroup.barrelHolo.alpha=0.75
		barrelGroup.barrelHoloDistance.alpha=0.75
		barrelGroup.barrelTargetRect.x,barrelGroup.barrelTargetRect.y=params.displayGroup:localToContent(barrelGroup.x , barrelGroup.y)
        barrelGroup.barrelTargetRect.rotation=barrelGroup.rotation
	end

	function barrelGroup:scannerOff()
		barrelGroup.barrelTargetRect.alpha=0
		barrelGroup.barrelHolo.alpha=0
		barrelGroup.barrelHoloDistance.alpha=0
	end

	function barrelGroup:destroy()
		display.remove(barrelGroup.barrelHoloDistance)
		display.remove(barrelGroup.barrelHolo)
		display.remove(barrelGroup.barrelTargetRect.l)
		display.remove(barrelGroup.barrelTargetRect)
		display.remove( barrelGroup )
		barrelGroup.barrelHoloDistance=nil
		barrelGroup.barrelHolo=nil
		barrelGroup.barrelTargetRect=nil
		barrelGroup=nil
	end

	return barrelGroup
end

return Barrel