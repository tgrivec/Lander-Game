local Astronaut = {}

local G=require ('globals')
local U=require ('utils')
local physics=require ('physics')
local mabs=math.abs
local mrandom=math.random
local soundChannel2=3 -- approach sound
local soundChannel3=4 -- target acquired
local soundChannel4=5 -- expedite



local sndApproach = {}
local distExpedite=G.W0_125*0.65

for i=1,5 do
	sndApproach[i]=audio.loadSound( "sound/approach"..i..".mp3" )
end

Astronaut.visible=false

function Astronaut:new(params)
	local astronaut = display.newGroup()
	local astroImage = display.newImageRect( astronaut, params.fileName, params.width or 24, params.height or 57)
	local astroTargetRect=display.newGroup( )
	astronaut.astroHolo=display.newImageRect( params.displayGroup, 'astronautsmallgreen.png', 12, 27 )
	astronaut.astroHolo.alpha=0.5
	astronaut.astroHoloDistance=display.newText( params.displayGroup, '000.0 m', 0,0, 62,20, '5by7', 16 )
  	astronaut.astroHoloDistance:setTextColor( 0,1,0.5,0.8 )
  	astronaut.score=0

	astronaut:insert( astroTargetRect )
	U.newScannerTarget({group=astroTargetRect,width=params.width or 24,height=params.height or 57})

	astronaut.x=params.x or 0
	astronaut.y=params.y or 0
	params.displayGroup:insert(astronaut)
	astronaut.alpha=0
	astronaut.myName="astronaut"
	astronaut.positioned=false
	astronaut.showTrigger=true
	astronaut.readyMove=false
	astronaut.transJump=nil
	astronaut.transMove=nil
	astronaut.commIndex=1

	function astronaut:enterFrame(event)
		if not astronaut.positioned then
			astronaut:move( {y=15} )
		elseif astronaut.showTrigger then
			astronaut.showTrigger=false
			astronaut:show()
			astronaut:collisionOff()
			astronaut:move( {y=10} )
			physics.removeBody( astronaut )
		end
	end

	Runtime:addEventListener( 'enterFrame', astronaut.enterFrame )

	function astronaut:move(params)
		astronaut.x=astronaut.x+(params.x or 0)
		astronaut.y=astronaut.y+(params.y or 0)
	end

	function astronaut:setHolo(params) -- {dir=1 left side, dir=-1 right side of astroHolo, x,y, text}
		astronaut.astroHolo.x=params.x+12*params.dir
		astronaut.astroHolo.y=params.y-50
		astronaut.astroHoloDistance.x=params.x+50*params.dir
		astronaut.astroHoloDistance.y=params.y-40
		astronaut.astroHoloDistance.text=params.text or '0 m'
	end

	function astronaut:show()
		astronaut.alpha=1
		astronaut.rotation=0
		--Astronaut.visible=true
	end

	function astronaut:hide()
		astronaut.alpha=0
		--Astronaut.visible=false
	end

	function astronaut:animate(params)
		-------------------------------------- JUMPING UP and DOWN ----------------------------------------------

		if mabs(params.x-astronaut.x)<G.W0_125 and astronaut.transJump == nil and not astronaut.readyMove and not astronaut.jumping and astronaut.alpha==1 then
			astronaut.xPosScore,astronaut.yPosScore=astronaut.x,astronaut.y
			astronaut.jumping=true
			astronaut.commIndex=astronaut.commIndex+1
			astronaut.transJump=transition.moveBy( astronaut, {x=0 , y=-7 , delay=1000, transition=easing.inOutQuad, time=350} )	
			astronaut.tmr1=timer.performWithDelay(1350, function() if astronaut~=nil then astronaut.transJump=transition.moveBy( astronaut, {x=0 , y=7 , delay=0, transition=easing.inOutQuad, time=400}); end; end)
			astronaut.tmr2=timer.performWithDelay(1750, function() if astronaut.transJump~=nil then transition.cancel(astronaut.transJump);astronaut.transJump=nil;astronaut.jumping=false;end; end)
			audio.setVolume( 1 , {channel=soundChannel2} )
			if astronaut.commIndex % 7 == 2 then audio.play( sndApproach[mrandom(1,5)], {loops = 0, channel=soundChannel2} ); end
		end
		-------------------------------------- moving to rocket -------------------------------------------------
		local rocketRotationOK=(((params.rotation%360)<=45 and (params.rotation%360)>=0) or ((params.rotation%360)<=360 and (params.rotation%360)>=315))
		if mabs(params.vx)<0.05 and mabs(params.vy)<0.05 and rocketRotationOK and mabs(params.x-astronaut.x)<G.W0_125 and mabs(params.y-astronaut.y)<150 and astronaut.alpha==1 then
			astronaut.readyMove=true
		end
		if mabs(params.vx)<0.3 and mabs(params.vy)<0.3 and mabs(params.x-astronaut.x)<G.W0_125 and mabs(params.y-astronaut.y)<150 and astronaut.transMove==nil and astronaut.alpha==1 and not astronaut.jumping and rocketRotationOK then
			astronaut.score=math.floor((G.W0_125-mabs(params.x-astronaut.x))/20)*30
			if mabs(params.x-astronaut.x)<=5 then astronaut.score=astronaut.score+20 end
			local timeMove=math.sqrt((params.x-astronaut.x)*(params.x-astronaut.x))*50--math.sqrt((params.x-astronaut.x)*(params.x-astronaut.x)+(params.y-astronaut.y)*(params.y-astronaut.y))*30
			print ("time to move: "..timeMove)
			astronaut.transMove=transition.moveTo( astronaut, {x=params.x, y=params.y+52, delay=500, transition=easing.inOutQuad, time=timeMove, 
				onComplete=function() 
					astronaut.alpha=0;astronaut.transMove=nil;
					G.astronautsSaved=G.astronautsSaved+1;
					G.AstroRemainTxt.text='ASTRONAUTS: '..(G.noOfAstronauts-G.astronautsSaved)
					audio.setVolume( 1 , {channel=soundChannel3} )
					audio.play( params.sound, {loops = 0, channel=soundChannel3} );
					local scoreNew=astronaut.score--+bonus
					U.newScoreText({score=scoreNew,x=astronaut.xPosScore,y=astronaut.yPosScore,group=G.scoreGroup})
					G.HUDScore=G.HUDScore+scoreNew;G.HUDScoreTxt.text='PRESTIGE :'..G.HUDScore 
				end}) 
			if mabs(params.x-astronaut.x)>distExpedite then
				audio.setVolume( 1 , {channel=soundChannel4} )
				audio.play( params.soundExp, {loops = 0, channel=soundChannel4} );
			end
		elseif mabs(params.vx)>1 or mabs(params.vy)>1 or not rocketRotationOK then

			if astronaut.readyMove then
				astronaut.readyMove=false
			end
			if astronaut.transMove then
				transition.cancel( astronaut.transMove )
				astronaut.transMove=nil
			end
		end
		-------------------------------------- SCANNER --------------------------------------------------------------
		if params.scannerActive==true and astronaut.alpha~=0 then
			astroTargetRect.alpha=1
			astronaut.astroHolo.alpha=0.5
			astronaut.astroHoloDistance.alpha=0.75
		else
			astroTargetRect.alpha=0
			astronaut.astroHolo.alpha=0.0
			astronaut.astroHoloDistance.alpha=0.0
		end
	end

	function astronaut:astronautCollision()
		if self.other.myName=='planet' then
			if not astronaut.positioned then 
				G.astronautsPositioned=G.astronautsPositioned+1
				astronaut.positioned=true
				if G.astronautsPositioned>=G.noOfAstronauts then
					G.placeAstro=false
					G.rocket.alpha=1	
					--physics.pause( )
				end
			end
		end
	end

	function astronaut:destroy()
		Runtime:removeEventListener( 'enterFrame', astronaut.enterFrame)
		transition.cancel(astronaut)
		if astronaut.tmr1 then timer.cancel( astronaut.tmr1 );astronaut.tmr1=nil; end
		if astronaut.tmr2 then timer.cancel( astronaut.tmr2 );astronaut.tmr2=nil; end
		if astronaut.astroHoloDistance then astronaut.astroHoloDistance:removeSelf() end
		if astronaut.astroHolo then astronaut.astroHolo:removeSelf( ) end
		astronaut.astroHoloDistance=nil
		astronaut.astroHolo=nil
		astroImage:removeSelf( )
		astronaut:removeSelf( )
		astroImage=nil
		astronaut=nil
	end

	function astronaut:collisionOn()
		astronaut:addEventListener("collision", astronaut.astronautCollision)
	end

	function astronaut:collisionOff()
		astronaut:removeEventListener( "collision" , astronaut.astronautCollision)
	end

	return astronaut
end

return Astronaut