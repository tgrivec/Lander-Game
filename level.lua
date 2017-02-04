local composer = require( "composer" )
local scene = composer.newScene()
local G=require ('globals')
local U=require ('utils')
local physics=require("physics")
local jslib = require ("joystick")
local loadsave = require("loadsave")
local performance = require "performance"
local pex = require("pex")
local Astronaut=require ('astronaut')
local Barrel = require ('barrel')
local levelObjects=require ("levelobjects")

physics.setDebugErrorsEnabled(false)
physics.setReportCollisionsInContentCoordinates( true )

local mcos=math.cos
local msin=math.sin
local mrad=math.rad
local mrandom=math.random
local mabs=math.abs
local msqrt=math.sqrt
local sGetTimer = system.getTimer
local mfloor=math.floor
local jointsMaxForce=15
local jointsMaxTorque=9.5
local maxImpulse=95 -- 80 je minimalno
local autoThrust=0
local prevTime = 0
local dHmaliplanet=-40
local factorSky=1.0
local rotSpeed=0.0
local rotSpeedOld=0.0
local rotOld=0.0
local rotSpeedDelta=0.0

local soundChannel1=2 -- gameover
local soundSysChannel={}
soundSysChannel[1] = 20
soundSysChannel[2] = 21
soundSysChannel[3] = 22
soundSysChannel[4] = 23
soundSysChannel[5] = 24
soundSysChannel[6] = 25
soundSysChannel[7] = 26
soundSysChannel[8] = 27
soundSysChannel[9] = 28

-- local trees={}
-- local domes={}
-- for i=1,5 do
-- 	trees[i]="alientree"..i..".png"
-- 	domes[i]="dome"..i..".png"
-- end
---------------------------------------------------------------------- ROCKET & BARREL & GROUND COLLISION --------------------------------------------------------------------------
function rocketPostCollision (event)
	local hit=mabs(event.force)
	local vx,vy = G.rocket:getLinearVelocity( )
	local speed=msqrt(vx*vx+vy*vy)
	if event.other.name=='barrelFuel' then
		G.fuel=G.fuel+mrandom(1+math.floor(math.abs(G.fuel_max-G.fuel)))+G.fuel_max*0.25
		if G.fuel>=G.fuel_max then G.fuel=G.fuel_max end
		event.other.remove=true
		G.xPosScore,G.yPosScore=event.x,event.y
		U.newScoreText({score=-100,x=G.xPosScore,y=G.yPosScore,group=G.scoreGroup})
		G.HUDScore=G.HUDScore-100;G.HUDScoreTxt.text='PRESTIGE :'..G.HUDScore 
	elseif event.other.name=='barrelShield' then
		G.energy=G.energy+math.random(1+math.floor(math.abs(G.energy_max-G.energy)))+G.energy_max*0.25
		if G.energy>=G.energy_max then G.energy=G.energy_max end
		event.other.remove=true
		G.xPosScore,G.yPosScore=event.x,event.y
		U.newScoreText({score=-50,x=G.xPosScore,y=G.yPosScore,group=G.scoreGroup})
		G.HUDScore=G.HUDScore-50;G.HUDScoreTxt.text='PRESTIGE :'..G.HUDScore 
	else
		if ( hit >= 3 and G.rocket.alpha>0) then
			if hit>=50 then G.shield.alpha=0.5 end
			G.shield.trans=transition.to(G.shield,{alpha=0,time=1000})
			G.energy=G.energy-hit
		end
		if (event.friction>0.3 and speed>3) then
			G.emitterSparks.x=event.x
			G.emitterSparks.y=event.y
			if G.sparksInActive and G.rocket.alpha>0 and (event.other.myName=="planet" or event.other.myName=="eiffel5" or event.other.myName=="eiffel4" or event.other.myName=="eiffel3" or event.other.myName=="eiffel2" or event.other.myName=="eiffel1") then
				G.emitterSparks:start()
				G.sparksInActive=false
				timer.performWithDelay( 250, function() if G.emitterSparks~=nil then G.emitterSparks:stop(); G.sparksInActive=true;end; end )
			end
		end
	end
end

------------------------------------------------------------------------- LEVEL SETUP -----------------------------------------------------------------------------
local setupLevel=function(sceneGroup, event)
	math.randomseed(os.time())
	G.shieldOK=true
	G.shield50=false
	G.shield10=false
	G.fuelOK=true
	G.fuel50=false
	G.fuel10=false

	local i=mrandom(1,4)
	local r=msqrt(G.W*G.W+G.H*G.H)
	G.worldLimit = G.W/3--(G.aW-G.W)/2
	--- sky rotation
	--G.skyX,G.skyY=r*1.78*factorSky,r*factorSky
	G.skyX,G.skyY=G.aW,G.aH
	G.world = display.newGroup( )
	local image1_name
	local screenRatio=G.aW/G.aH
	if event.params.planetNo==1 then 
		G.planet = display.newImageRect( G.world , "planet.png", U.worldSize, 246 )
		G.sky = display.newImageRect( sceneGroup, "galaxy1.png", 1920/(1080/G.aH), G.aH )
		--G.sky = display.newImageRect( sceneGroup, "galaxy6.png", G.skyX, G.skyY )
		image1_name = "planet.png"
	elseif event.params.planetNo==2 then 
		G.planet = display.newImageRect( G.world , "planet2.png", U.worldSize, 246 )
		G.sky = display.newImageRect( sceneGroup, "galaxy2.png", 1680/(1050/G.aH), G.aH )
		image1_name = "planet2.png"
	elseif event.params.planetNo==3 then 
		G.planet = display.newImageRect( G.world , "planet3.png", U.worldSize, 246 )
		G.sky = display.newImageRect( sceneGroup, "galaxy3.png", 1920/(1080/G.aH), G.aH )
		image1_name = "planet3.png"
	elseif event.params.planetNo==4 then
		G.planet = display.newImageRect( G.world , "planet4.png", U.worldSize, 246 )
		G.sky = display.newImageRect( sceneGroup, "galaxy4.png", 1920/(1084/G.aH), G.aH )
		image1_name = "planet4.png"
	elseif event.params.planetNo==5 then
		G.planet = display.newImageRect( G.world , "planet5.png", U.worldSize, 246 )
		G.sky = display.newImageRect( sceneGroup, "galaxy6.png", 1920/(1080/G.aH), G.aH )
		image1_name = "planet5.png"
	end

	local image1_outline = graphics.newOutline( 4, image1_name )

	G.sky:toBack( )
	G.sky.anchorX=0.5
	G.sky.anchorY=0.5
	G.sky.dx=G.W/2.5
	G.sky.dy=G.H/2.5
	local deginrad=mrad(G.deg)
	-- if G.sky then
	-- 	G.sky.x=G.W0_5 + G.sky.dx * msin(deginrad*0.05)
	-- 	G.sky.y=-G.H0_5 + G.sky.dy * mcos(deginrad*0.05)
	-- 	G.sky.rotation=-0.25*G.deg
	-- end
	G.sky.x=480
	G.sky.y=320

	sceneGroup:insert(G.world)
	G.scoreGroup = display.newGroup( )
	sceneGroup:insert(G.scoreGroup)
	G.HUD = display.newGroup( )
	sceneGroup:insert(G.HUD)
	G.world.anchorX=0.0
	G.world.anchorY=0.0
	G.HUD.anchorX=0.0
	G.HUD.anchorY=0.0
	G.astronautsPositioned=0
	G.astronautsSaved=0

	G.planet.anchorX = 0.0
	G.planet.anchorY = 1.0
	G.world.x=-mrandom(U.worldSize-G.W-G.dW*2)-G.dW
	G.world.y=0
	G.planet.x=0
	G.planet.y=G.H-dHmaliplanet
	physics.start( )
	physics.pause( )
	physics.addBody( G.planet, "static", { density = 1.0,friction = 0.9,bounce = 0.1,outline = image1_outline, filter={categoryBits=1, maskBits=255} } )
	G.planet.myName="planet"
	local screenLimitLeft=display.newLine( G.world , -1, 0, -1, G.H )
	screenLimitLeft.alpha=0
	physics.addBody( screenLimitLeft, "static", { density = 1.0,friction = 0.9,bounce = 0.1})
	screenLimitLeft.myName="wall"
	local screenLimitRight=display.newLine( G.world , U.worldSize, 0, U.worldSize, G.H )
	screenLimitRight.alpha=0
	physics.addBody( screenLimitRight, "static", { density = 1.0,friction = 0.9,bounce = 0.1})
	screenLimitRight.myName="wall"
	local screenLimitTop=display.newLine( G.world, 0, -50, U.worldSize, -50 )
	physics.addBody( screenLimitTop, "static", { density = 1.0,friction = 0.9,bounce = 0.1})
	screenLimitTop.myName="wall"
	G.planetNo=event.params.planetNo
	if event.params.planetNo==5 then
		local eiffel5_outline = graphics.newOutline( 2, "eiffel5.png" )
		G.eiffel5 = display.newImageRect( G.world , "eiffel5.png", 162, 66 )
		G.eiffel5.x,G.eiffel5.y=2469,480;
		physics.addBody( G.eiffel5, "dynamic", { density = 9.0,friction = 6.9,bounce = 0.1,outline = eiffel5_outline, filter={categoryBits=8, maskBits=3} } )
		G.eiffel5.myName="eiffel5"
		local eiffel4_outline = graphics.newOutline( 2, "eiffel4.png" )
		G.eiffel4 = display.newImageRect( G.world , "eiffel4.png", 162, 85 )
		G.eiffel4.x,G.eiffel4.y=2469,405;
		physics.addBody( G.eiffel4, "dynamic", { density = 6.0,friction = 4.9,bounce = 0.1,outline = eiffel4_outline, filter={categoryBits=8, maskBits=3}  } )
		G.eiffel4.myName="eiffel4"
		local eiffel3_outline = graphics.newOutline( 2, "eiffel3.png" )
		G.eiffel3 = display.newImageRect( G.world , "eiffel3.png", 162, 102 )
		G.eiffel3.x,G.eiffel3.y=2469,313;
		physics.addBody( G.eiffel3, "dynamic", { density = 3.0,friction = 3.9,bounce = 0.1,outline = eiffel3_outline, filter={categoryBits=8, maskBits=3}  } )
		G.eiffel3.myName="eiffel3"
		local eiffel2_outline = graphics.newOutline( 1, "eiffel2.png" )
		G.eiffel2 = display.newImageRect( G.world , "eiffel2.png", 162, 129 )
		G.eiffel2.x,G.eiffel2.y=2469,206;
		physics.addBody( G.eiffel2, "dynamic", { density = 2.0,friction = 3.9,bounce = 0.1,outline = eiffel2_outline, filter={categoryBits=8, maskBits=3}  } )
		G.eiffel2.myName="eiffel2"
		local eiffel1_outline = graphics.newOutline( 1, "eiffel1.png" )
		G.eiffel1 = display.newImageRect( G.world , "eiffel1.png", 162, 30 )
		G.eiffel1.x,G.eiffel1.y=2469,125;
		physics.addBody( G.eiffel1, "dynamic", { density = 1.0,friction = 3.9,bounce = 0.1,outline = eiffel1_outline, filter={categoryBits=8, maskBits=3}  } )
		G.eiffel1.myName="eiffel1"
		G.eiffel5Joint=physics.newJoint("weld",G.eiffel5,G.eiffel4,2469,405)
		G.eiffel4Joint=physics.newJoint("weld",G.eiffel4,G.eiffel3,2469,313)
		G.eiffel3Joint=physics.newJoint("weld",G.eiffel3,G.eiffel2,2469,206)
		G.eiffel2Joint=physics.newJoint("weld",G.eiffel2,G.eiffel1,2469,125)
		G.eiffel5Joint.frequency=2.0
		G.eiffel4Joint.frequency=2.0
		G.eiffel3Joint.frequency=2.0
		G.eiffel2Joint.frequency=2.0
		G.eiffel5Joint.dampingRatio=0.8
		G.eiffel4Joint.dampingRatio=0.8
		G.eiffel3Joint.dampingRatio=0.8
		G.eiffel2Joint.dampingRatio=0.8
	end

	local backFrictionOverlay=display.newRect( G.world, U.worldSize*0.5, G.H/2, U.worldSize, G.H )
	backFrictionOverlay:setFillColor( 0,0,0,0.0 )
	physics.addBody( backFrictionOverlay, "static", { isSensor = true } )

	physics.setGravity( 0, 2.0 )
	if G.debug then physics.setDrawMode("hybrid") end
	G.rocket = display.newImageRect( G.world , G.rocketName, G.sizeX, G.sizeY)
	local image2_outline = graphics.newOutline( 2, G.rocketName )
	G.rocket.myName="rocket"
	G.rocket.anchorX=0.5
	G.rocket.anchorY=0.5
	G.rocket.x,G.rocket.y=-G.world.x+G.W/2,50
	G.rocket.vx,G.rocket.vy=0,0
	G.rocket.extraFuel1,G.rocket.extraFuel2,G.rocket.extraShield1=false,false,false
	G.emitter = display.newEmitter(G.particlerocketBurner)
	G.world:insert(G.emitter)
	G.emitter:toBack( )
	G.emitter.startColorRed = 0.1
	G.emitter.startColorGreen = 0.7
	G.emitter.startColorBlue = 0.3
	G.emitter.startColorAlpha = 0.55
	G.emitter.finishColorRed = 0.5
	G.emitter.finishColorGreen = 0.5
	G.emitter.finishColorBlue = 0.7
	G.emitter.finishColorAlpha = 0.2
	G.emitterL = display.newEmitter(G.particlerocketBurner)
	G.world:insert(G.emitterL)
	G.emitterL:toBack( )
	G.emitterL.startColorRed = 0.1
	G.emitterL.startColorGreen = 0.7
	G.emitterL.startColorBlue = 0.3
	G.emitterL.startColorAlpha = 0.55
	G.emitterR = display.newEmitter(G.particlerocketBurner)
	G.world:insert(G.emitterR)
	G.emitterR:toBack( )
	G.emitterR.startColorRed = 0.1
	G.emitterR.startColorGreen = 0.7
	G.emitterR.startColorBlue = 0.3
	G.emitterR.startColorAlpha = 0.55
	G.emitterL2 = display.newEmitter(G.particlerocketThruster)
	G.emitterR2 = display.newEmitter(G.particlerocketThruster)
	G.world:insert(G.emitterL2)
	G.world:insert(G.emitterR2)
	G.emitterExplosion1 = display.newEmitter( G.particleExplosion )
	G.emitterSparks = display.newEmitter( G.particleSparks )
	G.world:insert(G.emitterExplosion1)
	G.world:insert(G.emitterSparks)
	G.emitterSparks.anchorX=0.5
	G.emitterSparks.anchorY=0.5

	G.emitter.angleVariance=1
	G.emitterL.angleVariance=1
	G.emitterR.angleVariance=1
	G.emitterL2.angleVariance=23
	G.emitterR2.angleVariance=23
	G.emitter.startParticleSize=G.emitter.startParticleSize*G.factor
	G.emitterL.startParticleSize=20*G.factor
	G.emitterR.startParticleSize=20*G.factor
	G.emitterSparks.startParticleSize=8
	physics.addBody( G.rocket, "dynamic", { density = G.density, friction = 1.0, bounce = 0.1,  outline = image2_outline , filter={categoryBits=2, maskBits=201}} )
	G.joints=physics.newJoint( "friction" , G.rocket, backFrictionOverlay, G.rocket.x, G.rocket.y )
	G.joints.maxForce=jointsMaxForce
	G.joints.maxTorque=jointsMaxTorque
	G.emitterExplosion1:stop()
	G.emitterSparks:stop( )
	G.emitter:stop( )
	G.emitterL:stop( )
	G.emitterR:stop( )
	G.emitterL2:stop( )
	G.emitterR2:stop( )
	G.shield = display.newImageRect( G.world , "shield.png",  G.sizeY*1.25, G.sizeY*1.25 )
	G.shield.alpha=0

	--  trees and plants and domes and stuff
	local planetTrees={}
	local planetDomes={}
	local planetRovers={}
	if event.params.planetNo==2 then
		planetTrees[1] = levelObjects:new( {width=0.45*376, height=0.45*300, fileName="alientree2.png", displayGroup=G.world, x=560, y=475 , filter={categoryBits=8, maskBits=2}} ) 
		planetTrees[2] = levelObjects:new( {width=0.46*376, height=0.46*300, fileName="alientree2.png", displayGroup=G.world, x=1450, y=465 , filter={categoryBits=8, maskBits=2}} ) 
		planetTrees[3] = levelObjects:new( {width=0.45*376, height=0.45*300, fileName="alientree2.png", displayGroup=G.world, x=2200, y=415 , filter={categoryBits=8, maskBits=2}} ) 
		planetTrees[4] = levelObjects:new( {width=0.45*376, height=0.45*300, fileName="alientree2.png", displayGroup=G.world, x=3100, y=474 , filter={categoryBits=8, maskBits=2}} ) 
		planetTrees[5] = levelObjects:new( {width=0.4*376, height=0.4*300, fileName="alientree2.png", displayGroup=G.world, x=4000, y=465 , filter={categoryBits=8, maskBits=2}} ) 
		planetDomes[1] = levelObjects:new( {width=0.3*506, height=0.3*300, fileName="dome1.png", displayGroup=G.world, x=1750, y=445 , density=9, outlineStep=4, filter={categoryBits=4, maskBits=0}} )
		planetRovers[1] = levelObjects:new( {width=0.3*359, height=0.3*300, fileName="rover1.png", displayGroup=G.world, x=1950, y=445 , density=5, outlineStep=10, filter={categoryBits=32, maskBits=0}} )
	elseif event.params.planetNo==4 then
		planetTrees[1] = levelObjects:new( {width=0.4*304, height=0.4*318, fileName="alientree3.png", displayGroup=G.world, x=560, y=585 , filter={categoryBits=8, maskBits=2}} ) 
		planetTrees[2] = levelObjects:new( {width=0.4*256, height=0.4*330, fileName="alientree4.png", displayGroup=G.world, x=950, y=540 , filter={categoryBits=8, maskBits=2}} ) 
		planetTrees[3] = levelObjects:new( {width=0.4*304, height=0.4*318, fileName="alientree3.png", displayGroup=G.world, x=1800, y=460 , filter={categoryBits=8, maskBits=2}} ) 
		planetTrees[4] = levelObjects:new( {width=0.5*256, height=0.5*330, fileName="alientree4.png", displayGroup=G.world, x=2300, y=400 , filter={categoryBits=8, maskBits=2}} ) 
		planetTrees[5] = levelObjects:new( {width=0.5*304, height=0.5*318, fileName="alientree3.png", displayGroup=G.world, x=2800, y=435 , filter={categoryBits=8, maskBits=2}} ) 
		planetTrees[6] = levelObjects:new( {width=0.4*304, height=0.4*318, fileName="alientree3.png", displayGroup=G.world, x=3500, y=485 , filter={categoryBits=8, maskBits=2}} ) 
		planetDomes[1] = levelObjects:new( {width=0.3*587, height=0.3*298, fileName="dome3.png", displayGroup=G.world, x=2550, y=468 , density=9, filter={categoryBits=4, maskBits=0}} )
		planetRovers[1] = levelObjects:new( {width=0.3*359, height=0.3*300, fileName="rover2.png", displayGroup=G.world, x=2720, y=468 , density=5, filter={categoryBits=32, maskBits=0}} )
	end

	G.btnReset=display.newGroup( )
	sceneGroup:insert(G.btnReset)
	G.btnResetImage=display.newCircle( G.btnReset, 24*G.joySize,24*G.joySize, 24 )
	G.btnResetImage:setFillColor(  0,1,0.5,0.3 )
	G.btnResetText=display.newText( G.btnReset, 'R', 24*G.joySize,24*G.joySize, 'Airstrike Laser', 36 )
	G.btnResetText:setTextColor( 0,1,0.5, 1 )
	G.btnReset.alpha=0.7
	G.btnReset.x=display.screenOriginX+4*G.joySize
	G.btnReset.y=display.screenOriginY+4*G.joySize
	G.btnReset.name='button'

	G.js = jslib.new(48*G.joySize,96*G.joySize,sceneGroup)
	G.js.x=96*G.joySize
	G.js.y=G.H-96*G.joySize
	G.js:activate()

	G.btnAutoAltitude=display.newGroup()
	sceneGroup:insert(G.btnAutoAltitude)
	--G.btnAutoAltImage=display.newCircle( G.btnAutoAltitude, G.js.x+96*G.joySize-18, G.js.y-96*G.joySize+18, 24 )
	G.btnAutoAltImage=display.newCircle( G.btnAutoAltitude, G.W-32, G.H-124, 24 )
	G.btnAutoAltImage:setFillColor(  0,1,0.5,0.3 )
	--G.btnAutoAltText=display.newText( G.btnAutoAltitude, 'A', G.js.x+96*G.joySize-18, G.js.y-96*G.joySize+18, 'Airstrike Laser', 36 )
	G.btnAutoAltText=display.newText( G.btnAutoAltitude, 'A', G.W-32, G.H-124, 'Airstrike Laser', 36 )
	G.btnAutoAltText:setTextColor( 0,1,0.5, 1 )
	G.btnAutoAltitude.alpha=1

	G.btnScanner=display.newGroup()
	sceneGroup:insert(G.btnScanner)
	--G.btnScannerImage=display.newCircle( G.btnScanner, G.js.x-96*G.joySize+18, G.js.y-96*G.joySize+18, 24 )
	G.btnScannerImage=display.newCircle( G.btnScanner, G.W-130, G.H-124, 24 )
	G.btnScannerImage:setFillColor(  0,1,0.5,0.3 )
	--G.btnScannerText=display.newText( G.btnScanner, 'S', G.js.x-96*G.joySize+18, G.js.y-96*G.joySize+18, 'Airstrike Laser', 36 )
	G.btnScannerText=display.newText( G.btnScanner, 'T', G.W-132, G.H-124, 'Airstrike Laser', 36 )
	G.btnScannerText:setTextColor( 0,1,0.5, 1 )
	G.btnScanner.active=false
	G.btnScanner.alpha=1

	G.spdVer=display.newLine( sceneGroup, G.W-80, G.H-144, G.W-80, G.H-16 )
	G.spdVer.strokeWidth = 12*G.joySize
	G.spdVer:setStrokeColor( 0,1,0.5,0.15 )
	G.spdHor=display.newLine( sceneGroup, G.W-144, G.H-80, G.W-16, G.H-80 )
	G.spdHor.strokeWidth = 12*G.joySize
	G.spdHor:setStrokeColor( 0,1,0.5,0.15 )
	G.eneVer=display.newLine( sceneGroup, 96*G.joySize*2, G.H-32, G.W-96*G.joySize*2+16, G.H-32 )
	G.eneVer.strokeWidth = 12*G.joySize
	G.eneVer:setStrokeColor( 0,1,0.5,0.15 )
	G.fuelVer=display.newLine( sceneGroup, 96*G.joySize*2, G.H-16, G.W-96*G.joySize*2+16, G.H-16 )
	G.fuelVer.strokeWidth = 12*G.joySize
	G.fuelVer:setStrokeColor( 0,1,0.5,0.15 )
	G.spdVerPnt=display.newImageRect( sceneGroup, "pointer.png", 2, 2 )
	G.spdVerPnt.alpha = 0.8
	G.spdVerPnt.x=G.W-80
	G.spdVerPnt.y=G.H-80
	G.spdHorPnt=display.newImageRect( sceneGroup, "pointer.png", 2, 2 )
	G.spdHorPnt.alpha = 0.8
	G.spdHorPnt.x=G.W-80
	G.spdHorPnt.y=G.H-80
	G.enePnt=display.newImageRect( sceneGroup, "pointer.png", 2*G.joySize, 2*G.joySize )
	G.enePnt.alpha = 0.8
	G.enePnt.x=96*G.joySize*2
	G.enePnt.y=G.H-32
	G.enePnt.anchorX=0.0
	G.fuelPnt=display.newImageRect( sceneGroup, "pointer.png", 2*G.joySize, 2*G.joySize )
	G.fuelPnt.alpha = 0.8
	G.fuelPnt.x=96*G.joySize*2
	G.fuelPnt.y=G.H-16
	G.fuelPnt.anchorX=0.0
	G.d_ene=G.W-96*G.joySize*4
	G.d_fuel=G.W-96*G.joySize*4
	G.fuelIcon=display.newImageRect( sceneGroup, 'energy.png', 8, 16 )
	G.fuelIcon.alpha=0.7
	G.fuelIcon.x=G.W-96*G.joySize*2+8
	G.fuelIcon.y=G.H-32
	G.energyIcon=display.newImageRect( sceneGroup, 'radioactive.png', 16, 16 )
	G.energyIcon.alpha=0.7
	G.energyIcon.x=G.W-96*G.joySize*2+8
	G.energyIcon.y=G.H-16

	G.rocketScannerTarget=display.newGroup( )
	U.newScannerTarget({group=G.rocketScannerTarget,width=G.sizeX,height=G.sizeY})
	G.world:insert(G.rocketScannerTarget)
	G.world:insert(G.scoreGroup)

	G.energy=G.energy_max
	G.fuel=G.fuel_max
	G.fuel_f=0.5*G.d_ene/G.fuel_max
	G.ene_f=0.5*G.d_fuel/G.energy_max
	G.placeAstro=true
	G.sparksX=0
	G.sparksY=0
	G.sparksON=false
	G.HUDScore=0

	G.HUDScoreTxt=display.newText(sceneGroup, 'PRESTIGE: '..G.HUDScore,G.W/2+300,display.screenOriginY+30, 'Space Age', 25);
	G.HUDScoreTxt:setTextColor( 0,1,0.5,0.75 )
	G.AstroRemainTxt=display.newText(sceneGroup,'ASTRONAUTS: 0',G.W/2,display.screenOriginY+30, 'Space Age', 25);
	G.AstroRemainTxt:setTextColor( 0,1,0.5,0.75 )
	G.HUDLevelTxt=display.newText(sceneGroup,'PLANET: 0',G.W/2-300,display.screenOriginY+30, 'Space Age', 25);
	G.HUDLevelTxt:setTextColor( 0,1,0.5,0.75 )
	G.txtPos=650
	G.HUDNewLevelTxt1=display.newText(sceneGroup,'MISSION 1 ACCOMPLISHED',G.W+G.txtPos,G.H/2,'Airstrike Laser',55)
	G.HUDNewLevelTxt2=display.newText(sceneGroup,'PREPARE FOR NEW MISSION',G.W+G.txtPos,G.H/2,'Airstrike Laser',55)
	 G.HUDGameOverTxt1=display.newText(sceneGroup,'MISSION FAILED!',G.W+G.txtPos,G.H/2,'Airstrike Laser',55)
	 G.HUDGameOverTxt2=display.newText(sceneGroup,'TOTAL PRESTIGE: 0',G.W+G.txtPos,G.H/2,'Airstrike Laser',55)
 	 G.HUDGameOverTxt3=display.newText(sceneGroup,'STARTING NEW GAME',G.W+G.txtPos,G.H/2,'Airstrike Laser',55)
	G.HUDNewLevelTxt1:setTextColor( 0,1,0.5,0.9 )
	G.HUDNewLevelTxt2:setTextColor( 0,1,0.5,0.9 )
 	 G.HUDGameOverTxt1:setTextColor( 1,0.2,0.4,0.9 )
	 G.HUDGameOverTxt2:setTextColor( 1,0.2,0.4,0.9 )
	 G.HUDGameOverTxt3:setTextColor( 1,0.2,0.4,0.9 )

	if event.params.level==1 then
		G.noOfAstronauts=3
		U.linesMissionTxt={'Attention pilot!', 'Galactic Logistic Operations Command Center (G.L.O.C.) greets you.', ' ','Mission orders follow:','Primary objective: Pick-up 3 civilians from planet','','','','',''}
	elseif event.params.level==2 then
		G.noOfAstronauts=4
		U.linesMissionTxt={'G.L.O.C. to lander commander...','We picked up distress signal from science outpost on planet.',' ','Primary objective: Save 4 scientist on planet surface','Secondary objective: Pickup extra fuel if in distress','','','','',''}
	elseif event.params.level==3 then
		G.noOfAstronauts=4
		U.linesMissionTxt={'G.L.O.C. to lander commander...','ALERT! ALERT!','Volcano eruption imminent.',' ','Primary objective: Evacuate all engineers from planet','','','','',''}
	elseif event.params.level==4 then
		G.noOfAstronauts=6
		U.linesMissionTxt={'Priority message from G.L.O.C. center',' ','Evacuate outpost personnel immediately.','We are sending shield energy cells to help you.',' ','Primary objective: Evacuate 6 outpost technicians','Secondary objective: Collect shield energy cells if in need','','',''}
	else
		G.noOfAstronauts=math.floor(event.params.level/2)+4
		U.linesMissionTxt={'G.L.O.C. to lander commander...','Standard mission - land and retrieve.','Over and out.',' ','Primary objective: Save '..G.noOfAstronauts..' astronauts','Secondary objective: Use additional fuel and energy cells if needed','','','',''}
	end
	G.HUDLevel=event.params.level

	G.astronaut={}
	G.deltaPos=(U.worldSize-350)/G.noOfAstronauts
	G.astro_name="astronautsmall.png"
	G.astro_outline = graphics.newOutline( 4, G.astro_name )
	physics.start( )
	for i=1,G.noOfAstronauts do
		G.astronaut[i]=Astronaut:new( {width=24*0.67, height=57*0.67, fileName="astronautsmall.png", displayGroup=G.world, x=mrandom(G.deltaPos)+G.deltaPos*(i-1)+200, y=350} )
		physics.addBody( G.astronaut[i], "dynamic", { density = 1, friction = 0.99, bounce = 0.0, filter={categoryBits=16, maskBits=1} } )
		print ("astro added")
		G.astronaut[i]:collisionOn()
	end

	G.tmr=timer.performWithDelay( 2000, function() U.newMissionText( {group=G.HUD} ) end )
	G.HUDScoreTxt.text='PRESTIGE: '..G.HUDScore
	G.HUDLevel=event.params.level
	G.HUDLevelTxt.text='PLANET: '..G.HUDLevel
	G.AstroRemainTxt.text='ASTRONAUTS: '..(G.noOfAstronauts-G.astronautsSaved)
	G.sparksInActive=true
	audio.setVolume( 1 , {channel=soundChannel1} )
	G.newLevel = true
	G.levelCleared=false
	if G.tmrVolcano==nil and event.params.volcano then 
		U.createVolcano()
		U.particleSystem1.particleCollision=U.particleSystemCollision
		U.particleSystem1:addEventListener( "particleCollision" )
		G.tmrVolcano=timer.performWithDelay( 100, U.VolcanoBurst, 0 ) 
	end
------------------------------------------------------------------------- END    OF    LEVEL      SETUP -----------------------------------------------------------------------------
end

local updateScreen = function(event)

	if G.gameRun then
		G.textOnce=true

		if G.btnAutoAltitudeActive then
			if G.btnAutoAltText.trans==nil then 
				G.btnAutoAltText.trans=transition.to(G.btnAutoAltText,{time=500, iterations=0,transition=easing.outinquad,alpha=0}) 
				audio.setVolume( 1 , {channel=soundSysChannel[1]} )
				audio.play( G.sndSystem[1], {loops = 0, channel=soundSysChannel[1]} );
			end
		else
			if G.btnAutoAltText.trans~=nil then transition.cancel(G.btnAutoAltText.trans);G.btnAutoAltText.trans=nil; end
			G.btnAutoAltText.alpha=0.7
		end
		if G.btnScanner.active then
			if G.btnScannerText.trans==nil then 
				G.btnScannerText.trans=transition.to(G.btnScannerText,{time=500, iterations=0,transition=easing.outinquad,alpha=0}); 
				audio.setVolume( 1 , {channel=soundSysChannel[2]} )
				audio.play( G.sndSystem[2], {loops = 0, channel=soundSysChannel[2]} );
			end
			G.rocketScannerTarget.alpha=1
			G.rocketScannerTarget.x,G.rocketScannerTarget.y=G.rocket.x,G.rocket.y
			G.rocketScannerTarget.rotation=G.rocket.rotation
			local dy=30
			local dyL,dyR=0,0
			for i=#G.astronaut,1,-1 do
				if G.astronaut[i].alpha>0 and G.astronaut[i].x>G.rocket.x then 
					dyL=dyL+dy 
					G.astronaut[i]:setHolo( {dir=1,x=G.rocket.x,y=G.rocket.y-dyL,text=string.format('%3.1f',(-(G.rocket.x-G.astronaut[i].x)*0.075)) ..' m'} )
				elseif G.astronaut[i].alpha>0 and G.astronaut[i].x<=G.rocket.x then
					dyR=dyR+dy 
					G.astronaut[i]:setHolo( {dir=-1,x=G.rocket.x,y=G.rocket.y-dyR,text=string.format('%3.1f',((G.rocket.x-G.astronaut[i].x)*0.075)) ..' m'} )
				end
			end
			G.energy=G.energy-0.35
			for i=#G.barrel,1,-1 do 
				if G.barrel[i]~=nil then 
					--G.barrel[i].group.x,G.barrel[i].group.y=G.barrel[i].x,G.barrel[i].y
					G.barrel[i]:scannerOn()
					if G.barrel[i].x>G.rocket.x and G.barrel[i].alpha>0 then
						dyL=dyL+dy 
						G.barrel[i].barrelHolo.x=G.rocket.x+12
						G.barrel[i].barrelHolo.y=G.rocket.y-dyL-50
						G.barrel[i].barrelHoloDistance.x=G.rocket.x+50
						G.barrel[i].barrelHoloDistance.y=G.rocket.y-dyL-40
						G.barrel[i].barrelHoloDistance.text=string.format('%3.1f',(-(G.rocket.x-G.barrel[i].x)*0.075))
					elseif G.barrel[i].x<=G.rocket.x and G.barrel[i].alpha>0 then
						dyR=dyR+dy 
						G.barrel[i].barrelHolo.x=G.rocket.x-12
						G.barrel[i].barrelHolo.y=G.rocket.y-dyR-50
						G.barrel[i].barrelHoloDistance.x=G.rocket.x-50
						G.barrel[i].barrelHoloDistance.y=G.rocket.y-dyR-40
						G.barrel[i].barrelHoloDistance.text=string.format('%3.1f',((G.rocket.x-G.barrel[i].x)*0.075))
					end		  					
				end				
			end
		else
			if G.btnScannerText.trans~=nil then 
				transition.cancel(G.btnScannerText.trans);
				G.btnScannerText.trans=nil; 
				G.btnScannerText.alpha=0.75
				G.rocketScannerTarget.alpha=0
				for i=#G.barrel,1,-1 do 
					if G.barrel[i]~=nil then G.barrel[i]:scannerOff() end
				end
			end
		end
		for i=#G.barrel,1,-1 do -- Uklanjanje ostataka od target rectangla
			if G.barrel[i]~=nil and G.barrel[i].remove then
				if G.barrel[i].barrelHolo then G.barrel[i].barrelHolo:removeSelf( ) end
				if G.barrel[i].barrelHoloDistance then G.barrel[i].barrelHoloDistance:removeSelf( ) end
				G.barrel[i]:scannerOff()
				physics.removeBody( G.barrel[i] )
				G.barrel[i]:removeSelf()
				G.barrel[i]=nil
			end
		end
		--sky rotation-----------------------------------------------------------------
		G.deg=G.deg+0--0.015
		--local deginrad=mrad(G.deg)
		--if G.sky and G.skyRotationStart then
		--	G.sky.x=G.aW*0.5--G.W0_5 + G.sky.dx * msin(deginrad*0.005)
		--	G.sky.y=G.aH*0.5---G.H0_5 + G.sky.dy * mcos(deginrad*0.005)
		--	G.sky.rotation=-0.15*G.deg
		--end
		local jsAngle=G.js:getAngle()
		local jsDistance=G.js:getDistance()
		local angle = mrad( G.rocket.rotation+270 )
		local xComp = mcos(angle)
		local yComp = msin(angle)
		local r = -(G.rocket.rotation+90)
		local thrust
		local lateral
		local ver
		local hor
		local vx
		local vy
		local jsAngle_180=mrad(jsAngle-180)
		local jsAngleinrad=mrad(jsAngle)
		local powxdist=G.power*jsDistance
		local rocketrotrad=mrad(G.rocket.rotation)
		local factor42,factor25=65*G.factor,25*G.factor --65
		local massX,massY

		massX=G.rocket.x+xComp*G.factor*-7
		massY=G.rocket.y+yComp*G.factor*-7
		thrust=0
		lateral=0

		G.emitter.x = G.rocket.x - xComp*factor42
		G.emitter.y = G.rocket.y - yComp*factor42

		G.rocket.vx,G.rocket.vy = G.rocket:getLinearVelocity( )
		local a1=0.47
		G.emitterL.x = G.rocket.x - mcos(angle+a1)*factor42
		G.emitterL.y = G.rocket.y - msin(angle+a1)*factor42
		G.emitterR.x = G.rocket.x - mcos(angle-a1)*factor42
		G.emitterR.y = G.rocket.y - msin(angle-a1)*factor42
		G.emitterL2.x = G.rocket.x - mcos(angle+1.57)*factor42*0.3
		G.emitterL2.y = G.rocket.y - msin(angle+1.57)*factor42*0.3
		G.emitterR2.x = G.rocket.x - mcos(angle-1.57)*factor42*0.3
		G.emitterR2.y = G.rocket.y - msin(angle-1.57)*factor42*0.3
		local rocketRot=G.rocket.rotation%360
		if jsDistance>0.8 then
			if(jsAngle>210 and jsAngle<330) or (jsAngle>30 and jsAngle<150) then G.btnAutoAltitudeActive=false;G.newLevel=false end
		elseif G.autoPilotLevel==1 and rocketRot<310 and rocketRot>50 then
			G.btnAutoAltitudeActive=false;G.newLevel=false
		end
		if G.fuel>0.5 and jsDistance>0.2 and G.rocket.alpha>0 then
			thrust=msin(jsAngle_180)*powxdist*0.5
			thrust2=msin(jsAngleinrad)*powxdist*0.5
			lateral=mcos(jsAngle_180)*powxdist*0.03
			ver=mabs(15*msin(jsAngleinrad)*jsDistance)
			hor=mabs(5*mcos(jsAngleinrad)*jsDistance)
			if jsAngle>180 and jsAngle<270 and lateral>0.7 then ------------------------- DOWN LEFT
				G.rocket:applyTorque( lateral*G.agility )
				G.rocket:applyForce( lateral*msin(rocketrotrad), -lateral*mcos(rocketrotrad), G.emitterL.x, G.emitterL.y )
				G.fuel=G.fuel-lateral
				G.emitterL:start( )
			else G.emitterL:stop( )
			end
			if jsAngle>270 and jsAngle<360 and lateral<-0.7 then -------------------------- DOWN RIGHT
				G.rocket:applyTorque( lateral*G.agility )
				G.rocket:applyForce( -lateral*msin(rocketrotrad), lateral*mcos(rocketrotrad), G.emitterR.x, G.emitterR.y )
				G.fuel=G.fuel+lateral
				G.emitterR:start( ) 
			else G.emitterR:stop( )
			end
			local lateralPower=0.6
			local rocketRotationRightOK=(rocketRot>=75 and rocketRot<=180)
			local rocketRotationLeftOK=(rocketRot<=285 and rocketRot>=180)
			if jsAngle<180 and jsAngle>90 and lateral>0.7 then ------------------------ UP LEFT
				local speed=msqrt(G.rocket.vx*G.rocket.vx+G.rocket.vy*G.rocket.vy)
				if rocketRotationLeftOK and speed==0 then 
					G.rocket:applyLinearImpulse( maxImpulse*msin(rocketrotrad+1.9), -maxImpulse*mcos(rocketrotrad+1.9), massX, massY )
					G.fuel=G.fuel-G.fuel_max*0.25
				else
					G.rocket:applyForce( lateralPower*(powxdist*0.5+thrust)*msin(rocketrotrad+1.57), -lateralPower*(powxdist*0.5+thrust)*mcos(rocketrotrad+1.57), massX, massY )
				end
				G.fuel=G.fuel-lateralPower*mabs(lateral)
				G.emitterL2:start( )
			else G.emitterL2:stop( )
			end
			if jsAngle>0 and jsAngle<90 and lateral<-0.7 then ---------------------- UP RIGHT
				local speed=msqrt(G.rocket.vx*G.rocket.vx+G.rocket.vy*G.rocket.vy)
				if rocketRotationRightOK and speed==0 then
					G.rocket:applyLinearImpulse( maxImpulse*msin(rocketrotrad-1.9), -maxImpulse*mcos(rocketrotrad-1.9), massX, massY )
					G.fuel=G.fuel-G.fuel_max*0.25
				else
					G.rocket:applyForce( lateralPower*(powxdist*0.5+thrust)*msin(rocketrotrad-1.57), -lateralPower*(powxdist*0.5+thrust)*mcos(rocketrotrad-1.57), massX, massY )
				end
				G.fuel=G.fuel-lateralPower*mabs(lateral)
				G.emitterR2:start( ) 
			else G.emitterR2:stop( )
			end

			if not G.btnAutoAltitudeActive then
				if (jsAngle>190 and jsAngle<350) then ------------------ DOWN or UP
					G.rocket:applyForce( 1.5*thrust*msin(rocketrotrad), -1.5*thrust*mcos(rocketrotrad), G.rocket.x, G.rocket.y )
					G.fuel=G.fuel-thrust
					G.emitter:start()
					G.emitter.speed=85+thrust*3
				elseif (jsAngle>10 and jsAngle<170) then
					G.rocket:applyForce( 1.5*thrust2*msin(rocketrotrad), -1.5*thrust2*mcos(rocketrotrad), G.rocket.x, G.rocket.y )
					G.fuel=G.fuel-thrust2
					G.emitter:start()
					G.emitter.speed=85+thrust2*3
				else G.emitter:stop()
				end
			end
		else
			if not G.btnAutoAltitudeActive then 
				G.emitter:stop() 
				G.emitterL:stop( )
				G.emitterR:stop( )
			end
			G.emitterL2:stop( )
			G.emitterR2:stop( )
		end
		----- AUTO ALTITUDE CONTROL / Autopilot ---------------------------------------
		if G.btnAutoAltitudeActive and G.fuel>0.5 then
			local rocketRot=G.rocket.rotation%360
			rotSpeed=rocketRot-rotOld
			rotSpeedDelta=rotSpeed-rotSpeedOld
			rotSpeedOld=rotSpeed
			rotOld=rocketRot
			--print (rotSpeedDelta.." "..rotSpeed)
			local powerFactor=1.42
			local power=0
			if G.rocket.vy>0 then 
				local autoThrustFinal = math.min((G.rocket.vy*4),G.power*0.5)
				if autoThrust<=autoThrustFinal then autoThrust=autoThrust+autoThrustFinal*0.1 end
				G.rocket:applyForce( 1.5*autoThrust*msin(rocketrotrad), -1.5*autoThrust*mcos(rocketrotrad), G.rocket.x, G.rocket.y )
			end
			if not G.newLevel then G.fuel=G.fuel-autoThrust end
			G.emitter:start()
			G.emitter.speed=85+autoThrust*3
			if G.autoPilotLevel==2 and rocketRot>181 and rocketRot<356 then ------------------------- DOWN LEFT
				if rotSpeedDelta>0.01 and rotSpeed>0 then power=0 else power=powerFactor*msqrt(mabs(rocketRot-360)) end
				G.rocket:applyTorque( power*G.agility )
				G.rocket:applyForce( power*msin(rocketrotrad), -power*mcos(rocketrotrad), G.emitterL.x, G.emitterL.y )
				G.fuel=G.fuel-power
				G.emitterL:start( )
				G.emitterL.angle = -r
				G.emitterL.speed=60+power*12
				lateral=power*0.5
			elseif G.autoPilotLevel==2 then G.emitterL:stop( )
			end
			if G.autoPilotLevel==2 and rocketRot>0 and rocketRot<181 then -------------------------- DOWN RIGHT
				if rotSpeedDelta>0.01 and rotSpeed>0 then power=0 else power=powerFactor*msqrt(mabs(rocketRot)) end
				G.rocket:applyTorque( -power*G.agility )
				G.rocket:applyForce( -power*msin(rocketrotrad), power*mcos(rocketrotrad), G.emitterR.x, G.emitterR.y )
				G.fuel=G.fuel+power
				G.emitterR:start( ) 
				G.emitterR.angle = -r
				G.emitterR.speed=(60-power*12)
				lateral=-power*0.5
			elseif G.autoPilotLevel==2 then G.emitterR:stop( )
			end
		elseif G.fuel<=0.5 then
			G.emitter:stop()
			autoThrust = 0 
			lateral = 0
		end
		------------------------------------------------------------------


		G.emitter.angle=-r
		G.emitterL.angle = -r
		G.emitterL.speed=60+lateral*12
		G.emitterR.angle = -r
		G.emitterR.speed=(60-lateral*12)
		G.emitterL2.angle = -r+90
		G.emitterL2.speed=40+lateral*14
		G.emitterR2.angle = -r-90
		G.emitterR2.speed=(40-lateral*14)

		if G.joints then
			local maxF=math.min(1+math.sqrt(G.rocket.vx*G.rocket.vx+G.rocket.vy*G.rocket.vy)/4,jointsMaxForce)
			G.joints.maxForce=(maxF)
		end
		----------------------------------------------------- UPDATE world coordinates --------------------------------------------
		local xr,yr=G.rocket:localToContent(0,0)

		local curTime = sGetTimer()
		local dxPerFrame = 0.03*G.rocket.vx
		prevTime = curTime

		if G.rocket.vx>0 and xr>G.W-G.worldLimit-0.5*G.dW and -G.world.x+G.W<U.worldSize-0.5*G.dW then
			G.world.x=G.world.x-dxPerFrame*0.5
			if -G.world.x+G.W>U.worldSize-G.dW then G.world.x=-(U.worldSize-G.W)+G.dW end
		elseif G.rocket.vx<0 and xr<G.worldLimit+G.dW and G.world.x+G.dW<0 then
			G.world.x=G.world.x-dxPerFrame*0.5
			if G.world.x-G.dW>0 then G.world.x=G.dW end
		end
		local mvx=mabs(G.rocket.vx)
		local mvy=mabs(G.rocket.vy)
		------------------------------------------------- UPDATE velocity pointers -------------------------------------------------
		if G.rocket.vx<-256 then G.rocket.vx=-256 
		elseif G.rocket.vx>256 then G.rocket.vx=256 
		elseif G.rocket.vx<0 then
			G.spdHorPnt.xScale=mvx/(8) +0.1
			G.spdHorPnt.x=G.W-80-mvx/(8) +0.1
		elseif G.rocket.vx>0 then
			G.spdHorPnt.xScale=mvx/(8) +0.1
			G.spdHorPnt.x=G.W-80+mvx/(8) +0.1
		end
		if G.rocket.vy<-256 then G.rocket.vy=-256
		elseif G.rocket.vy>256 then G.rocket.vy=256
		elseif G.rocket.vy<0 then
			G.spdVerPnt.yScale=mvy/(8)+0.1
			G.spdVerPnt.y=G.H-80-mvy/(8)+0.1
		elseif G.rocket.vy>0 then
			G.spdVerPnt.yScale=mvy/(8)+0.1
			G.spdVerPnt.y=G.H-80+mvy/(8) +0.1
		end
		------------------------------------------------- check for astronaut proximity --------------------------------------------
		if G.placeAstro==false and G.energy>=0 and G.fuel>=0 then
			for i=1,G.noOfAstronauts do
				local snd=mrandom(1,2)
				if snd==1 then G.astronaut[i]:animate( {scannerActive=G.btnScanner.active,x=G.rocket.x, y=G.rocket.y, vx=G.rocket.vx, vy=G.rocket.vy, rotation=G.rocket.rotation, sound=G.sndTarget1, soundExp=G.sndTargetExpedite} )
				elseif snd==2 then G.astronaut[i]:animate( {scannerActive=G.btnScanner.active,x=G.rocket.x, y=G.rocket.y, vx=G.rocket.vx, vy=G.rocket.vy, rotation=G.rocket.rotation, sound=G.sndTarget2, soundExp=G.sndTargetExpedite} )
				end
			end
		end
		-------------------------------------------------- UPDATE ENERGY & FUEL ------------------------------------------------------
		if G.fuel<=0 then 
			G.fuel=0
			G.btnReset.alpha=0.0
			timer.performWithDelay( 8000, function() G.gameRun=false end )
		end
		if (G.fuel<G.fuel_max_05 and not G.fuel50) then
			G.fuelOK=false
			G.fuel50=true
			audio.setVolume( 1 , {channel=soundSysChannel[8]} )
			audio.play( G.sndSystem[8], {loops = 0, channel=soundSysChannel[8]} );
		end
		if (G.fuel<G.fuel_max_025 and not G.fuel10) then
			G.fuelOK=false
			G.fuel10=true
			audio.setVolume( 1 , {channel=soundSysChannel[9]} )
			audio.play( G.sndSystem[9], {loops = 0, channel=soundSysChannel[9]} );
		end
		if not G.fuelOK and G.fuel>G.fuel_max_05 then
			G.fuelOK=true
			G.fuel50=false
			G.fuel10=false
			audio.setVolume( 1 , {channel=soundSysChannel[7]} )
			audio.play( G.sndSystem[7], {loops = 0, channel=soundSysChannel[7]} );
		end

		if (G.energy<G.energy_max_05 and not G.shield50) then
			G.shieldOK=false
			G.shield50=true
			audio.setVolume( 1 , {channel=soundSysChannel[4]} )
			audio.play( G.sndSystem[4], {loops = 0, channel=soundSysChannel[4]} );
		end
		if (G.energy<G.energy_max_025*0.25 and not G.shield10) then
			G.shieldOK=false
			G.shield10=true
			audio.setVolume( 1 , {channel=soundSysChannel[5]} )
			audio.play( G.sndSystem[5], {loops = 0, channel=soundSysChannel[5]} );
		end
		if not G.shieldOK and G.energy>G.energy_max_05 then
			G.shieldOK=true
			G.shield10=false
			G.shield50=false
			audio.setVolume( 1 , {channel=soundSysChannel[3]} )
			audio.play( G.sndSystem[3], {loops = 0, channel=soundSysChannel[3]} );
		end
		if G.fuel<G.fuel_max_007 or G.energy<G.energy_max_007 then
			if not audio.isChannelPlaying( soundSysChannel[6] ) then
				audio.setVolume( 0.5 , {channel=soundSysChannel[6]} )
				audio.play( G.sndSystem[6], {loops = -1, channel=soundSysChannel[6]} );
			end
		else
			audio.stop(soundSysChannel[6])
		end

		if G.fuel<G.fuel_max*0.75 and G.rocket.extraFuel1==false and (G.HUDLevel>=2 or G.debugFuel) then
			local i=#G.barrel+1
			G.barrel[i]=Barrel:new( {width=27, height=44, fileName="barrel.png", fileNameHolo="barrelgreen.png", displayGroup=G.world, x=G.rocket.x+200, y=50} )
			G.barrel[i].remove=false
			G.barrel[i].name='barrelFuel'
			G.barrel[i]:show()
			G.rocket.extraFuel1=true
		end
		if G.fuel<G.fuel_max*0.5 and G.rocket.extraFuel2==false and (G.HUDLevel>=6 or G.debugFuel) then
			local i=#G.barrel+1
			G.barrel[i]=Barrel:new( {width=27, height=44, fileName="barrel.png", fileNameHolo="barrelgreen.png", displayGroup=G.world, x=mrandom(1600)+400, y=50} )
			G.barrel[i].remove=false
			G.barrel[i].name='barrelFuel'
			G.barrel[i]:show()
			G.rocket.extraFuel2=true
		end
		if G.rocket.extraShield1==false and (G.HUDLevel>=4 or G.debugFuel) then
			local i=#G.barrel+1
			G.barrel[i]=Barrel:new( {width=27, height=44, fileName="barrelblue.png", fileNameHolo="barrelgreenshield.png", displayGroup=G.world, x=G.rocket.x+200, y=50} )		  
			G.barrel[i].remove=false
			G.barrel[i].name='barrelShield'
			G.barrel[i]:show()
			G.rocket.extraShield1=true
		end
		if G.energy<=0 then
			G.energy=0;
			timer.performWithDelay( 0, function() 
					G.emitterExplosion1.x = G.rocket.x+mrandom(50)-25 
					G.emitterExplosion1.y = G.rocket.y+mrandom(50)-25  
					G.emitterExplosion1:start()
				end )
			timer.performWithDelay( 500, function() G.emitterExplosion1:stop() end )
			timer.performWithDelay( 50, function() 
					G.emitterExplosion1.x = G.rocket.x+mrandom(50)-25 
					G.emitterExplosion1.y = G.rocket.y+mrandom(50)-25  
					G.emitterExplosion1:start()
				end )
			timer.performWithDelay( 550, function() G.emitterExplosion1:stop() end )
			G.rocket.alpha=0
			G.shield.alpha=0
			G.js:deactivate()
			G.btnAutoAltitude.alpha=0
			G.btnScanner.alpha=0
			--physics.pause( )
			G.btnAutoAltitudeActive=false
			G.gameRun=false
			G.btnReset.alpha=0.0
			timer.performWithDelay( 1500, function() G.gameRun=false; end )
		end
		G.enePnt.xScale=G.ene_f*G.energy/G.joySize+0.1
		G.fuelPnt.xScale=G.fuel_f*G.fuel/G.joySize+0.1

		if G.shield.alpha>0 then
			G.shield.x=G.rocket.x;G.shield.y=G.rocket.y
			G.shield.alpha=mcos(G.deg)*0.08+0.25
			G.shield.rotation=G.shield.rotation+mrandom(3)/15
		end
		if G.astronautsSaved>=G.noOfAstronauts then print('Mission accomplished');G.levelCleared=true;G.gameRun=false end
	else
		--physics.pause()
		if G.levelCleared and G.textOnce then ------------------------------- NEW LEVEL TEXT ----------------------
			local levelStars=0
			if G.HUDScore>(G.noOfAstronauts*150)+20 then levelStars=3
			elseif G.HUDScore>(G.noOfAstronauts*110) then levelStars=2
			elseif G.HUDScore>(G.noOfAstronauts*70) then levelStars=1
			else levelStars=0;
			end
			if G.gamedata.levelEnabled[G.HUDLevel+1]==false and levelStars>0 then
				G.gamedata.levelEnabled[G.HUDLevel+1]=true
			end 
			if G.gamedata.levelStars[G.HUDLevel]<levelStars then G.gamedata.levelStars[G.HUDLevel]=levelStars end
			G.textOnce=false
			G.HUDNewLevelTxt1.text='MISSION '..G.HUDLevel..' ACCOMPLISHED'
			G.HUDNewLevelTxt2.text='YOU EARNED '..levelStars..' STARS'
			timer.performWithDelay( 300, function() G.HUDNewLevelTxt1.trans=transition.to( G.HUDNewLevelTxt1, {x=-G.txtPos , y=G.H/2 , transition=easing.outInCirc, time=1500}) end )
			timer.performWithDelay( 1800, function() G.HUDNewLevelTxt2.trans=transition.to( G.HUDNewLevelTxt2, {x=-G.txtPos , y=G.H/2 , transition=easing.outInCirc, time=1500}) end )
			timer.performWithDelay(3300, function() G.btnResetTap(); end)
			G.HUDScore=0
		elseif G.textOnce then --------------------------------------------------------- GAME OVER TEXT ---------------------
			audio.setVolume( 1 , {channel=soundChannel1} )
			audio.play( G.sndGameOver, {loops=0, channel=soundChannel1} )
			G.textOnce=false
			G.HUDGameOverTxt2.text='TOTAL PRESTIGE: '..G.HUDScore
			timer.performWithDelay( 300, function() G.HUDGameOverTxt1.trans=transition.to( G.HUDGameOverTxt1, {x=-G.txtPos , y=G.H/2 , transition=easing.outInCirc, time=1500}) end )
			timer.performWithDelay( 1800, function() G.HUDGameOverTxt2.trans=transition.to( G.HUDGameOverTxt2, {x=-G.txtPos , y=G.H/2 , transition=easing.outInCirc, time=1500}) end )
			timer.performWithDelay( 3300, function() G.HUDGameOverTxt3.trans=transition.to( G.HUDGameOverTxt3, {x=-G.txtPos , y=G.H/2 , transition=easing.outInCirc, time=1500}) end )
			timer.performWithDelay(5000, function() G.btnResetTap(); end)
		end
		audio.stop(soundSysChannel[6])
		G.emitter:stop() 
		G.emitterL:stop( )
		G.emitterR:stop( )
		G.emitterL2:stop( )
		G.emitterR2:stop( )
	end
	if G.planetNo==5 then
		if G.eiffel2Joint~=nil then
			local reactionForceX, reactionForceY = G.eiffel2Joint:getReactionForce()
			if mabs(reactionForceX)>100 then G.eiffel2Joint:removeSelf( );G.eiffel2Joint=nil end
			--print ("force= "..reactionForceX.." , "..reactionForceY)
		end
		if G.eiffel3Joint~=nil then
			local reactionForceX, reactionForceY = G.eiffel3Joint:getReactionForce()
			if mabs(reactionForceX)>130 then G.eiffel3Joint:removeSelf( );G.eiffel3Joint=nil end
			--print ("force= "..reactionForceX.." , "..reactionForceY)
		end
		if G.eiffel4Joint~=nil then
			local reactionForceX, reactionForceY = G.eiffel4Joint:getReactionForce()
			if mabs(reactionForceX)>160 then G.eiffel4Joint:removeSelf( );G.eiffel4Joint=nil end
			--print ("force= "..reactionForceX.." , "..reactionForceY)
		end
		if G.eiffel5Joint~=nil then
			local reactionForceX, reactionForceY = G.eiffel5Joint:getReactionForce()
			if mabs(reactionForceX)>190 then G.eiffel5Joint:removeSelf( );G.eiffel5Joint=nil end
			--print ("force= "..reactionForceX.." , "..reactionForceY)
		end
	end
end

function scene:create( event )
	local sceneGroup = self.view
end

function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then

		setupLevel(sceneGroup,event)
		--G.deg=0
	elseif ( phase == "did" ) then
		physics.start( )
		timer.performWithDelay( mrandom(1100,1900), function() G.btnAutoAltitudeActive=true end )
		G.gameRun=true
		G.skyRotationStart=true
		Runtime:addEventListener( "enterFrame", updateScreen )
		G.rocket:addEventListener( "postCollision" , rocketPostCollision)
		G.btnReset:addEventListener( "tap", G.btnResetTap )
		G.btnAutoAltitude:addEventListener( "tap", G.btnAutoAltitudeTap )
		G.btnScanner:addEventListener( "tap" , G.btnScannerTap)
		-- Called when the scene is now on screen.
		-- Insert code here to make the scene come alive.
		-- Example: start timers, begin animation, play audio, etc.
	end
end

function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		loadsave.saveTable(G.gamedata, "gamedata.json")   
		G.AstroRemainTxt.text='ASTRONAUTS: '..(G.noOfAstronauts-G.astronautsSaved)
	elseif ( phase == "did" ) then
		G.skyRotationStart=false
		for i=G.noOfAstronauts,1,-1 do
			if G.astronaut[i]~=nil then G.astronaut[i]:destroy(); G.astronaut[i]=nil; end
		end
		display.remove(U.particleSystem);U.particleSystem=nil;

		U.clearMissionText()
		G.btnAutoAltitudeActive=false
		G.shieldOK=true
		G.shield50=false
		G.shield10=false
		G.fuelOK=true
		G.fuel50=false
		G.fuel10=false
		transition.cancel()
		display.remove(G.sky);G.sky=nil;
		display.remove(G.world);G.world=nil;
		display.remove(G.scoreGroup);G.scoreGroup=nil;
		display.remove(G.HUD);G.HUD=nil;
		display.remove(G.planet);G.planet=nil;

		display.remove(G.HUDScoreTxt);G.HUDScoreTxt=nil
		display.remove(G.AstroRemainTxt);G.AstroRemainTxt=nil
		display.remove(G.HUDLevelTxt);G.HUDLevelTxt=nil

		display.remove(G.HUDNewLevelTxt1);display.remove(G.HUDNewLevelTxt2);display.remove(G.HUDNewLevelTxt3);
		display.remove(G.HUDGameOverTxt1);display.remove(G.HUDGameOverTxt2);display.remove(G.HUDGameOverTxt3);
		G.HUDNewLevelTxt1=nil;G.HUDNewLevelTxt2=nil;G.HUDNewLevelTxt3=nil;
		G.HUDGameOverTxt1=nil;G.HUDGameOverTxt2=nil;G.HUDGameOverTxt3=nil;

		G.emitterExplosion1:stop()
		G.emitterSparks:stop( )
		G.emitter:stop( )
		G.emitterL:stop( )
		G.emitterR:stop( )
		G.emitterL2:stop( )
		G.emitterR2:stop( )

		display.remove(G.rocket);G.rocket=nil;
		display.remove(G.emitter);G.emitter=nil;
		display.remove(G.emitterL);G.emitterL=nil;
		display.remove(G.emitterR);G.emitterR=nil;
		display.remove(G.emitterL2);G.emitterL2=nil;
		display.remove(G.emitterR2);G.emitterR2=nil;
		display.remove(G.emitterExplosion1);G.emitterExplosion1=nil;
		display.remove(G.emitterSparks);G.emitterSparks=nil;
		display.remove(G.joints);G.joints=nil

		display.remove(G.shield);G.shield=nil


		display.remove(G.btnReset);G.btnReset=nil;
		display.remove(G.btnResetImage);G.btnResetImage=nil;
		display.remove(G.btnResetText);G.btnResetText=nil;
		display.remove(G.btnAutoAltitude);G.btnAutoAltitude=nil;
		display.remove(G.btnAutoAltImage);G.btnAutoAltImage=nil;
		display.remove(G.btnAutoAltText);G.btnAutoAltText=nil;
		display.remove(G.btnScanner);G.btnScanner=nil;
		display.remove(G.btnScannerImage);G.btnScannerImage=nil;
		display.remove(G.btnScannerText);G.btnScannerText=nil;

		display.remove(G.spdVer);G.spdVer=nil;
		display.remove(G.spdHor);G.spdHor=nil;
		display.remove(G.eneVer);G.eneVer=nil;
		display.remove(G.fuelVer);G.fuelVer=nil;
		display.remove(G.spdVerPnt);G.spdVerPnt=nil;
		display.remove(G.spdHorPnt);G.spdHorPnt=nil;
		display.remove(G.enePnt);G.enePnt=nil;
		display.remove(G.fuelPnt);G.fuelPnt=nil;
		display.remove(G.fuelIcon);G.fuelIcon=nil;
		display.remove(G.energyIcon);G.energyIcon=nil;

		display.remove(G.rocketScannerTarget);G.rocketScannerTarget=nil;
		display.remove(G.eiffel2Joint)
		display.remove(G.eiffel3Joint)
		display.remove(G.eiffel4Joint)
		display.remove(G.eiffel5Joint)
		display.remove(G.eiffel1)
		display.remove(G.eiffel2)
		display.remove(G.eiffel3)
		display.remove(G.eiffel4)
		display.remove(G.eiffel5)

		if planetTrees then
			for i=#planetTrees,1,-1 do
				display.remove(planetTrees[i])
			end
		end

		if G.tmr then timer.cancel( G.tmr ) end

		if G.js~=nil then G.js:deactivate(); end
		display.remove(G.js);G.js=nil

		if G.tmrVolcano~=nil then timer.cancel( G.tmrVolcano );G.tmrVolcano=nil; end

		for i=3,1,-1 do
			if G.barrel[i]~=nil then G.barrel[i]:destroy(); G.barrel[i]=nil; end
		end      

		if U.particleSystem~=nil then U.particleSystem:removeEventListener( "particleCollision" ); end
		Runtime:removeEventListener( "enterFrame", updateScreen )
		--G.rocket:removeEventListener( "postCollision" , rocketPostCollision)
		--G.btnReset:removeEventListener( "tap", G.btnResetTap )
		--G.btnAutoAltitude:removeEventListener( "tap", G.btnAutoAltitudeTap )
		--G.btnScanner:removeEventListener( "tap" , G.btnScannerTap)
		--G.rocket:removeEventListener( "preCollision" , rocketPreCollision)
	end
end

function scene:destroy( event )

	local sceneGroup = self.view

	-- Called prior to the removal of scene's view ("sceneGroup").
	-- Insert code here to clean up the scene.
	-- Example: remove display objects, save state, etc.
end

---------------------------------------------------------------------------------

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

---------------------------------------------------------------------------------

return scene