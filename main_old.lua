--android icons 192,144,96,72,48,36
--------------------------------------------------------------------------------
-- main.lua
--------------------------------------------------------------------------------

display.setStatusBar(display.HiddenStatusBar)
system.activate( "multitouch" )

local G=require ('globals')
local U=require ('utils')

G.debug=false

math.randomseed(os.time())
local mcos=math.cos
local msin=math.sin
local mrad=math.rad
local mrandom=math.random
local mabs=math.abs
local msqrt=math.sqrt
local sGetTimer = system.getTimer
local display_newImageRect=display.newImageRect
local mfloor=math.floor

local prevTime = 0
--G.fuel_max --  15000
if G.debug then G.energy_max=20000 else G.energy_max=1500 end
if G.debug then G.fuel_max=120000 else G.fuel_max=90000 end
G.fuel_max_05=G.fuel_max*0.5
G.fuel_max_025=G.fuel_max*0.25
G.fuel_max_007=G.fuel_max*0.07
G.energy_max_05=G.energy_max*0.5
G.energy_max_025=G.energy_max*0.25
G.energy_max_007=G.energy_max*0.07

local dHmaliplanet=-40

local jointsMaxForce=15
local jointsMaxTorque=9.5
local maxImpulse=95 -- 80 je minimalno
local joints

local autoThrust=0
--------------------------------------------------------------------------------
-- Create Sample Effect
--------------------------------------------------------------------------------
local music -- function for playing music



local physics=require("physics")
local jslib = require ("joystick")
local loadsave = require("loadsave")
local performance = require "performance"
local pex = require("pex")
audio.setVolume( 1 )
physics.setDebugErrorsEnabled(false)
physics.setReportCollisionsInContentCoordinates( true )
local musicChannel=10
local soundChannel1=2 -- ganeover
local soundSysChannel={}
soundSysChannel[1] = 20
soundSysChannel[2] = 21
soundSysChannel[3] = 22
soundSysChannel[4] = 23
soundSysChannel[5] = 24
soundSysChannel[6] = 25
physics.start( )
G.sysNormal=true
G.sysWarning=false
G.sysCritical=false
G.newLevel = true
local i=mrandom(1,4)
local r=msqrt(G.W*G.W+G.H*G.H)
local skyX,skyY=r*1.78*1.8,r*1.8
local worldLimit = G.W/3--(G.aW-G.W)/2
local sky = display_newImageRect( "galaxy"..i..".png", skyX, skyY )
sky.anchorX=0.5
sky.anchorY=0.5
sky.dx=G.W/3
sky.dy=G.H/3
sky.x=G.W/2
sky.y=G.H/2

local world = display.newGroup( )
G.scoreGroup = display.newGroup( )

local HUD = display.newGroup( )
--world.anchorChildren = true
world.anchorX=0.0--world.x/(U.worldSize-G.W+1)
world.anchorY=0.0
HUD.anchorX=0.0--world.x/(U.worldSize-G.W+1)
HUD.anchorY=0.0
---------------------------------------------------------------------------------- PLANET --------------------------------------------------------
local planet
local image1_name
local barrelFuel1,barrelFuel2,barrelShield1
U.worldSize=4096

G.planetNo=mrandom(12)
G.planetNo=11
if G.planetNo<4 then 
	planet = display_newImageRect( world , "planet.png", U.worldSize, 246 )
	image1_name = "planet.png"
elseif G.planetNo>=4 and G.planetNo<=6 then 
	planet = display_newImageRect( world , "planet2.png", U.worldSize, 246 )
	image1_name = "planet2.png"
elseif G.planetNo>=7 and G.planetNo<=9 then 
	planet = display_newImageRect( world , "planet3.png", U.worldSize, 246 )
	image1_name = "planet3.png"
else 
	planet = display_newImageRect( world , "planet4.png", U.worldSize, 246 )
	image1_name = "planet4.png"
end
local image1_outline = graphics.newOutline( 4, image1_name )
planet.anchorX = 0.0
planet.anchorY = 1.0
world.x=-mrandom(U.worldSize-G.W-G.dW*2)-G.dW
world.y=0

planet.x=0

--if G.H>800 then
--	planet.y=G.H
--else
	planet.y=G.H-dHmaliplanet
--end

physics.addBody( planet, "static", { density = 1.0,friction = 0.9,bounce = 0.1,outline = image1_outline } )
planet.myName="planet"
local screenLimitLeft=display.newLine( world , -1, 0, -1, G.H )
screenLimitLeft.alpha=0
physics.addBody( screenLimitLeft, "static", { density = 1.0,friction = 0.9,bounce = 0.1})
screenLimitLeft.myName="wall"
local screenLimitRight=display.newLine( world , U.worldSize, 0, U.worldSize, G.H )
screenLimitRight.alpha=0
physics.addBody( screenLimitRight, "static", { density = 1.0,friction = 0.9,bounce = 0.1})
screenLimitRight.myName="wall"
local screenLimitTop=display.newLine( 0, -50, U.worldSize, -50 )
physics.addBody( screenLimitTop, "static", { density = 1.0,friction = 0.9,bounce = 0.1})
screenLimitTop.myName="wall"
local backFrictionOverlay=display.newRect( world, U.worldSize*0.5, G.H/2, U.worldSize, G.H )
backFrictionOverlay:setFillColor( 0,0,0,0.0 )
physics.addBody( backFrictionOverlay, "static", { isSensor = true } )
local rocketName,sizeX,sizeY,density,power,factor;
--if G.H<640 then G.rocketName="G.rocketsmall.png";sizeX=69;sizeY=93;density=8;power=100;factor=1;joySize=1;agility=2 else G.rocketName="G.rocket.png";sizeX=139;sizeY=186;density=4;power=200;factor=2;joySize=1.5;agility=9 end
--G.rocketName="G.rocketsmall.png";sizeX=69*1.5;sizeY=93*1.5;density=6;power=160;factor=1.5;joySize=1.5;agility=8
rocketName="rocketnew.png";sizeX=69*1.5;sizeY=93*1.5;density=4.75;power=150;factor=1.5;joySize=1.5;agility=5.5

physics.setGravity( 0, 2.0 )
--physics.setDrawMode("hybrid")

----------------------------------------------------------------------- G.rocket & BURNERS ----------------------------------------
physics.pause( )
G.rocket = display_newImageRect( world , rocketName, sizeX, sizeY)
--local image2_name = rocketName
local image2_outline = graphics.newOutline( 2, rocketName )
G.rocket.myName="rocket"
G.rocket.anchorX=0.5
G.rocket.anchorY=0.5
G.rocket.x,G.rocket.y=-world.x+G.W/2,50
G.rocket.vx,G.rocket.vy=0,0
G.rocket.extraFuel1,G.rocket.extraFuel2,G.rocket.extraShield1=false,false,false
physics.start( )

local particlerocketBurner = pex.load("pex/rocketburner.pex","pex/texture.png")
local particlerocketThruster = pex.load("pex/rocketthruster.pex","pex/texture.png")
local particleExplosion = pex.load("pex/explosion.pex","pex/texture.png")
local particleSparks = pex.load("pex/sparks.pex","pex/texture.png")

local emitter = display.newEmitter(particlerocketBurner)
world:insert(emitter)
emitter.startColorRed = 0.1
emitter.startColorGreen = 0.7
emitter.startColorBlue = 0.3
emitter.startColorAlpha = 0.55
emitter.finishColorRed = 0.5
emitter.finishColorGreen = 0.5
emitter.finishColorBlue = 0.7
emitter.finishColorAlpha = 0.2
local emitterL = display.newEmitter(particlerocketBurner)
world:insert(emitterL)
emitterL.startColorRed = 0.1
emitterL.startColorGreen = 0.7
emitterL.startColorBlue = 0.3
emitterL.startColorAlpha = 0.55
local emitterR = display.newEmitter(particlerocketBurner)
world:insert(emitterR)
emitterR.startColorRed = 0.1
emitterR.startColorGreen = 0.7
emitterR.startColorBlue = 0.3
emitterR.startColorAlpha = 0.55
local emitterL2 = display.newEmitter(particlerocketThruster)
local emitterR2 = display.newEmitter(particlerocketThruster)
world:insert(emitterL2)
world:insert(emitterR2)

local emitterExplosion1 = display.newEmitter( particleExplosion )
local emitterSparks = display.newEmitter( particleSparks )
world:insert(emitterExplosion1)
world:insert(emitterSparks)
emitterSparks.anchorX=0.5
emitterSparks.anchorY=0.5


emitter.angleVariance=1
emitterL.angleVariance=1
emitterR.angleVariance=1
emitterL2.angleVariance=23
emitterR2.angleVariance=23
emitter.startParticleSize=emitter.startParticleSize*factor
emitterL.startParticleSize=20*factor
emitterR.startParticleSize=20*factor
emitterSparks.startParticleSize=8
physics.addBody( G.rocket, "dynamic", { density = density, friction = 1.0, bounce = 0.1,	outline = image2_outline } )
joints=physics.newJoint( "friction" , G.rocket, backFrictionOverlay, G.rocket.x, G.rocket.y )
joints.maxForce=jointsMaxForce
joints.maxTorque=jointsMaxTorque
emitterExplosion1:stop()
emitterSparks:stop( )
emitter:start( )
emitterL:start( )
emitterR:start( )
emitterL2:start( )
emitterR2:start( )


local shield = display_newImageRect( world , "shield.png",  sizeY*1.25, sizeY*1.25 )
shield.alpha=0
----------------------------------------------------------ASTRONAUTS--------------------------------------------------------------
local Astronaut=require ('astronaut')
local astronaut={}
local deltaPos=(U.worldSize-350)/G.noOfAstronauts
local astro_name="astronautsmall.png"
local astro_outline = graphics.newOutline( 4, astro_name )

for i=1,G.noOfAstronauts do
	astronaut[i]=Astronaut:new( {width=24, height=57, fileName="astronautsmall.png", displayGroup=world, x=mrandom(deltaPos)+deltaPos*(i-1)+200, y=350} )
	physics.addBody( astronaut[i], "dynamic", { density = 1, friction = 0.99, bounce = 0.0 } )
	astronaut[i]:collisionOn()
end

--------------------- JOYSTICK & G.HUD  ----------------------------------------------------------------------------------
local btnReset=display.newGroup( )
btnResetImage=display.newCircle( btnReset, 24*joySize,24*joySize, 24 )
btnResetImage:setFillColor(  0,1,0.5,0.3 )
btnResetText=display.newText( btnReset, 'R', 24*joySize,24*joySize, 'Airstrike Laser', 36 )
btnResetText:setTextColor( 0,1,0.5, 1 )
btnResetText.levelCleared=false
btnReset.textOnce=true
btnReset.levelCleared=false



local js = jslib.new(48*joySize,96*joySize)
js.x=96*joySize
js.y=G.H-96*joySize
js:activate()

local btnAutoAltitude=display.newGroup()
btnAutoAltImage=display.newCircle( btnAutoAltitude, js.x+96*joySize-18, js.y-96*joySize+18, 24 )
btnAutoAltImage:setFillColor(  0,1,0.5,0.3 )
btnAutoAltText=display.newText( btnAutoAltitude, 'A', js.x+96*joySize-18, js.y-96*joySize+18, 'Airstrike Laser', 36 )
btnAutoAltText:setTextColor( 0,1,0.5, 1 )
btnAutoAltitude.levelCleared=false
btnAutoAltitude.alpha=1

local btnScanner=display.newGroup()
btnScannerImage=display.newCircle( btnScanner, js.x-96*joySize+18, js.y-96*joySize+18, 24 )
btnScannerImage:setFillColor(  0,1,0.5,0.3 )
btnScannerText=display.newText( btnScanner, 'S', js.x-96*joySize+18, js.y-96*joySize+18, 'Airstrike Laser', 36 )
btnScannerText:setTextColor( 0,1,0.5, 1 )
btnScanner.active=false
btnScanner.alpha=1

local spdVer=display.newLine( G.W-80, G.H-144, G.W-80, G.H-16 )
spdVer.strokeWidth = 12*joySize
spdVer:setStrokeColor( 0,1,0.5,0.15 )
local spdHor=display.newLine( G.W-144, G.H-80, G.W-16, G.H-80 )
spdHor.strokeWidth = 12*joySize
spdHor:setStrokeColor( 0,1,0.5,0.15 )
local eneVer=display.newLine( 96*joySize*2, G.H-32, G.W-96*joySize*2+16, G.H-32 )
eneVer.strokeWidth = 12*joySize
eneVer:setStrokeColor( 0,1,0.5,0.15 )
local fuelVer=display.newLine( 96*joySize*2, G.H-16, G.W-96*joySize*2+16, G.H-16 )
fuelVer.strokeWidth = 12*joySize
fuelVer:setStrokeColor( 0,1,0.5,0.15 )
local spdVerPnt=display_newImageRect( "pointer.png", 2, 2 )
spdVerPnt.alpha = 0.8
spdVerPnt.x=G.W-80
spdVerPnt.y=G.H-80
local spdHorPnt=display_newImageRect( "pointer.png", 2, 2 )
spdHorPnt.alpha = 0.8
spdHorPnt.x=G.W-80
spdHorPnt.y=G.H-80
local enePnt=display_newImageRect( "pointer.png", 2*joySize, 2*joySize )
enePnt.alpha = 0.8
enePnt.x=96*joySize*2
enePnt.y=G.H-32
enePnt.anchorX=0.0
local fuelPnt=display_newImageRect( "pointer.png", 2*joySize, 2*joySize )
fuelPnt.alpha = 0.8
fuelPnt.x=96*joySize*2
fuelPnt.y=G.H-16
fuelPnt.anchorX=0.0
local d_ene=G.W-96*joySize*4
local d_fuel=G.W-96*joySize*4

local fuelIcon=display.newImageRect( 'energy.png', 8, 16 )
fuelIcon.alpha=0.7
fuelIcon.x=G.W-96*joySize*2+8
fuelIcon.y=G.H-32
local energyIcon=display.newImageRect( 'radioactive.png', 16, 16 )
energyIcon.alpha=0.7
energyIcon.x=G.W-96*joySize*2+8
energyIcon.y=G.H-16

G.rocketScannerTarget=display.newGroup( )
U.newScannerTarget({group=G.rocketScannerTarget,width=sizeX,height=sizeY})
world:insert(G.rocketScannerTarget)
G.barrelScannerTarget=display.newGroup( )
U.newScannerTarget({group=G.barrelScannerTarget,width=36,height=48})
world:insert(G.barrelScannerTarget)
world:insert(G.scoreGroup)
local deg=mrandom(360)
G.energy=G.energy_max
local fuel=G.fuel_max

local fuel_f=0.5*d_ene/G.fuel_max
local ene_f=0.5*d_fuel/G.energy_max
G.placeAstro=true


local sparksX=0
local sparksY=0
local sparksON=false
local cnt=0

G.HUDScore=0
G.HUDScoreTxt=display.newText('SCORE: 0',G.W/2+300,30, 'Space Age', 25);
G.HUDScoreTxt:setTextColor( 0,1,0.5,0.75 )
local HIScore=0
local HIScoreTxt=display.newText('HI-SCORE: 0',G.W/2,30, 'Space Age', 25);
HIScoreTxt:setTextColor( 0,1,0.5,0.75 )
G.HUDLevel=1
G.HUDLevelTxt=display.newText('LEVEL: 1',G.W/2-300,30, 'Space Age', 25);
G.HUDLevelTxt:setTextColor( 0,1,0.5,0.75 )

local txtPos=650
G.HUDNewLevelTxt1=display.newText('MISSION 1 ACCOMPLISHED',G.W+txtPos,G.H/2,'Airstrike Laser',55)
G.HUDNewLevelTxt2=display.newText('PREPARE FOR NEW MISSION',G.W+txtPos,G.H/2,'Airstrike Laser',55)
G.HUDNewLevelTxt3=display.newText('MISSION 2 IA A GO-GO-GO!',G.W+txtPos,G.H/2,'Airstrike Laser',55)
G.HUDGameOverTxt1=display.newText('MISSION FAILED!',G.W+txtPos,G.H/2,'Airstrike Laser',55)
G.HUDGameOverTxt2=display.newText('TOTAL SCORE: 0',G.W+txtPos,G.H/2,'Airstrike Laser',55)
G.HUDGameOverTxt3=display.newText('STARTING NEW GAME',G.W+txtPos,G.H/2,'Airstrike Laser',55)
G.HUDNewLevelTxt1:setTextColor( 0,1,0.5,0.9 )
G.HUDNewLevelTxt2:setTextColor( 0,1,0.5,0.9 )
G.HUDNewLevelTxt3:setTextColor( 0,1,0.5,0.9 )
G.HUDGameOverTxt1:setTextColor( 1,0.2,0.4,0.9 )
G.HUDGameOverTxt2:setTextColor( 1,0.2,0.4,0.9 )
G.HUDGameOverTxt3:setTextColor( 1,0.2,0.4,0.9 )
U.linesMissionTxt={'Attention pilot!', 'Galactic Logistic Operations Command Center (G.L.O.C.) greets you.', 'We will be your eyes and ears in following missions.', ' ','Mission orders follow:','Primary objective: Pick-up 3 civilians from planet','','','',''}
local tmr=timer.performWithDelay( 2000, function() U.newMissionText( {group=HUD} ) end )
-- world.xScale=0.5
-- world.yScale=0.5
-- world.anchorY=1

local gamedata=loadsave.loadTable("gamedata.json")
if (gamedata == nil) then
	gamedata={}
	gamedata.HIScore=0
	loadsave.saveTable(gamedata,"gamedata.json")
end
HIScoreTxt.text='HI-SCORE: '..gamedata.HIScore



local gameRun=true
local updateScreen = function(event)
	if G.btnAutoAltitudeActive then
		if btnAutoAltText.trans==nil then 
			btnAutoAltText.trans=transition.to(btnAutoAltText,{time=500, iterations=0,transition=easing.outinquad,alpha=0}) 
			audio.setVolume( 1 , {channel=soundSysChannel[1]} )
			audio.play( G.sndSystem[1], {loops = 0, channel=soundSysChannel[1]} );
		end
	else
		if btnAutoAltText.trans~=nil then transition.cancel(btnAutoAltText.trans);btnAutoAltText.trans=nil; end
		btnAutoAltText.alpha=0.7
	end
	if btnScanner.active then
		if btnScannerText.trans==nil then 
			btnScannerText.trans=transition.to(btnScannerText,{time=500, iterations=0,transition=easing.outinquad,alpha=0}); 
			audio.setVolume( 1 , {channel=soundSysChannel[2]} )
			audio.play( G.sndSystem[2], {loops = 0, channel=soundSysChannel[2]} );
		end
		G.rocketScannerTarget.alpha=1
		if G.barrelScannerTarget then G.barrelScannerTarget.alpha=1 end
		local dy=30
		local dyL,dyR=0,0
		for i=#astronaut,1,-1 do
			if astronaut[i].alpha>0 and astronaut[i].x>G.rocket.x then 
				dyL=dyL+dy 
				astronaut[i]:setHolo( {dir=1,x=G.rocket.x,y=G.rocket.y-dyL,text=string.format('%3.1f',(-(G.rocket.x-astronaut[i].x)*0.075)) ..' m'} )
			elseif astronaut[i].alpha>0 and astronaut[i].x<=G.rocket.x then
				dyR=dyR+dy 
				astronaut[i]:setHolo( {dir=-1,x=G.rocket.x,y=G.rocket.y-dyR,text=string.format('%3.1f',((G.rocket.x-astronaut[i].x)*0.075)) ..' m'} )
			end
		end
		if barrelFuel1 then
			barrelFuel1.barrelHolo.alpha=0.75
			barrelFuel1.barrelHoloDistance.alpha=0.75
			if barrelFuel1.x>G.rocket.x and barrelFuel1.alpha>0 then
				dyL=dyL+dy 
				barrelFuel1.barrelHolo.x=G.rocket.x+12
				barrelFuel1.barrelHolo.y=G.rocket.y-dyL-50
				barrelFuel1.barrelHoloDistance.x=G.rocket.x+50
				barrelFuel1.barrelHoloDistance.y=G.rocket.y-dyL-40
				barrelFuel1.barrelHoloDistance.text=string.format('%3.1f',(-(G.rocket.x-barrelFuel1.x)*0.075))
			elseif barrelFuel1.x<=G.rocket.x and barrelFuel1.alpha>0 then
				dyR=dyR+dy 
				barrelFuel1.barrelHolo.x=G.rocket.x-12
				barrelFuel1.barrelHolo.y=G.rocket.y-dyR-50
				barrelFuel1.barrelHoloDistance.x=G.rocket.x-50
				barrelFuel1.barrelHoloDistance.y=G.rocket.y-dyR-40
				barrelFuel1.barrelHoloDistance.text=string.format('%3.1f',((G.rocket.x-barrelFuel1.x)*0.075))
			end
		end
	else
		if btnScannerText.trans~=nil then transition.cancel(btnScannerText.trans);btnScannerText.trans=nil; end
		btnScannerText.alpha=0.75
		G.rocketScannerTarget.alpha=0
		if G.barrelScannerTarget then G.barrelScannerTarget.alpha=0 end
		if barrelFuel1 then 
			if barrelFuel1.barrelHolo then barrelFuel1.barrelHolo.alpha=0 end
			if barrelFuel1.barrelHoloDistance then barrelFuel1.barrelHoloDistance.alpha=0 end
		end
	end
	if U.stop and gameRun then btnReset.alpha=0.7 else btnReset.alpha=0 end
	if gameRun then
		physics.start()
		if tmrVolcano==nil and G.planetNo>=10 and G.planetNo<=11 then tmrVolcano=timer.performWithDelay( 100, U.VolcanoBurst, 0 ) end
		if btnScanner.active then
			G.energy=G.energy-0.35
			G.rocketScannerTarget.x,G.rocketScannerTarget.y=G.rocket.x,G.rocket.y
			G.rocketScannerTarget.rotation=G.rocket.rotation
			if barrelFuel1~=nil and G.barrelScannerTarget~=nil then
				G.barrelScannerTarget.x,G.barrelScannerTarget.y=barrelFuel1.x,barrelFuel1.y
				G.barrelScannerTarget.rotation=barrelFuel1.rotation
			else
				if G.barrelScannerTarget then G.barrelScannerTarget.alpha=0 end

			end
		end
		if barrelFuel1~=nil then
			if barrelFuel1.remove then
				if barrelFuel1.barrelHolo then barrelFuel1.barrelHolo:removeSelf( ) end
				if barrelFuel1.barrelHoloDistance then barrelFuel1.barrelHoloDistance:removeSelf( ) end
				physics.removeBody( barrelFuel1 )
				barrelFuel1:removeSelf()
		  		barrelFuel1=nil
	  		end
	  	end
	  	if barrelFuel2~=nil and barrelFuel2.remove then
			physics.removeBody( barrelFuel2 )
			barrelFuel2:removeSelf()
	  		barrelFuel2=nil
	  	end
	  	if barrelShield1~=nil and barrelShield1.remove then
			physics.removeBody( barrelShield1 )
			barrelShield1:removeSelf()
	  		barrelShield1=nil
	  	end
		cnt=cnt+1
		deg=deg+0.1
		local deginrad=mrad(deg)
		if sky then
			sky.x=G.W0_5 + sky.dx * msin(deginrad*0.05)
			sky.y=G.H0_5 + sky.dy * mcos(deginrad*0.05)
			sky.rotation=-0.5*deg
		end
		local jsAngle=js:getAngle()
		local jsDistance=js:getDistance()
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
		local powxdist=power*jsDistance
		local rocketrotrad=mrad(G.rocket.rotation)
		local factor42,factor25=65*factor,25*factor --65
		local massX,massY

		massX=G.rocket.x+xComp*factor*-7
		massY=G.rocket.y+yComp*factor*-7
		thrust=0
		lateral=0

		emitter.x = G.rocket.x - xComp*factor42
		emitter.y = G.rocket.y - yComp*factor42

		G.rocket.vx,G.rocket.vy = G.rocket:getLinearVelocity( )
		local a1=0.47
		emitterL.x = G.rocket.x - mcos(angle+a1)*factor42
		emitterL.y = G.rocket.y - msin(angle+a1)*factor42
		emitterR.x = G.rocket.x - mcos(angle-a1)*factor42
		emitterR.y = G.rocket.y - msin(angle-a1)*factor42
		emitterL2.x = G.rocket.x - mcos(angle+1.57)*factor42*0.3
		emitterL2.y = G.rocket.y - msin(angle+1.57)*factor42*0.3
		emitterR2.x = G.rocket.x - mcos(angle-1.57)*factor42*0.3
		emitterR2.y = G.rocket.y - msin(angle-1.57)*factor42*0.3
		
		if jsDistance>0.8 then
			if(jsAngle>210 and jsAngle<330) or (jsAngle>30 and jsAngle<150) then G.btnAutoAltitudeActive=false;G.newLevel=false end
		elseif G.rocket.rotation<-50 or G.rocket.rotation>50 then
			G.btnAutoAltitudeActive=false;G.newLevel=false
		end
		if fuel>0.5 and jsDistance>0.2 and G.rocket.alpha>0 then
			thrust=msin(jsAngle_180)*powxdist*0.5
			thrust2=msin(jsAngleinrad)*powxdist*0.5
			lateral=mcos(jsAngle_180)*powxdist*0.03
			ver=mabs(15*msin(jsAngleinrad)*jsDistance)
			hor=mabs(5*mcos(jsAngleinrad)*jsDistance)
			if jsAngle>180 and jsAngle<270 and lateral>0.7 then ------------------------- DOWN LEFT
				G.rocket:applyTorque( lateral*agility )
				G.rocket:applyForce( lateral*msin(rocketrotrad), -lateral*mcos(rocketrotrad), emitterL.x, emitterL.y )
				fuel=fuel-lateral
				emitterL:start( )
			else emitterL:stop( )
			end
			if jsAngle>270 and jsAngle<360 and lateral<-0.7 then -------------------------- DOWN RIGHT
				G.rocket:applyTorque( lateral*agility )
				G.rocket:applyForce( -lateral*msin(rocketrotrad), lateral*mcos(rocketrotrad), emitterR.x, emitterR.y )
				fuel=fuel+lateral
				emitterR:start( ) 
			else emitterR:stop( )
			end
			local lateralPower=0.6
			local rocketRotationRightOK=((G.rocket.rotation%360)>=75 and (G.rocket.rotation%360)<=180)
			local rocketRotationLeftOK=((G.rocket.rotation%360)<=285 and (G.rocket.rotation%360)>=180)
			if jsAngle<180 and jsAngle>90 and lateral>0.7 then ------------------------ UP LEFT
				local speed=msqrt(G.rocket.vx*G.rocket.vx+G.rocket.vy*G.rocket.vy)
				if rocketRotationLeftOK and speed==0 then 
					G.rocket:applyLinearImpulse( maxImpulse*msin(rocketrotrad+1.9), -maxImpulse*mcos(rocketrotrad+1.9), massX, massY )
					fuel=fuel-G.fuel_max*0.25
				else
					G.rocket:applyForce( lateralPower*(powxdist*0.5+thrust)*msin(rocketrotrad+1.57), -lateralPower*(powxdist*0.5+thrust)*mcos(rocketrotrad+1.57), massX, massY )
				end
				fuel=fuel-lateralPower*mabs(lateral)
				emitterL2:start( )
			else emitterL2:stop( )
			end
			if jsAngle>0 and jsAngle<90 and lateral<-0.7 then ---------------------- UP RIGHT
				local speed=msqrt(G.rocket.vx*G.rocket.vx+G.rocket.vy*G.rocket.vy)
				if rocketRotationRightOK and speed==0 then
					G.rocket:applyLinearImpulse( maxImpulse*msin(rocketrotrad-1.9), -maxImpulse*mcos(rocketrotrad-1.9), massX, massY )
					fuel=fuel-G.fuel_max*0.25
				else
					G.rocket:applyForce( lateralPower*(powxdist*0.5+thrust)*msin(rocketrotrad-1.57), -lateralPower*(powxdist*0.5+thrust)*mcos(rocketrotrad-1.57), massX, massY )
				end
				fuel=fuel-lateralPower*mabs(lateral)
				emitterR2:start( ) 
			else emitterR2:stop( )
			end

			if not G.btnAutoAltitudeActive then
				if (jsAngle>190 and jsAngle<350) then ------------------ DOWN or UP
					G.rocket:applyForce( 1.5*thrust*msin(rocketrotrad), -1.5*thrust*mcos(rocketrotrad), G.rocket.x, G.rocket.y )
					fuel=fuel-thrust
					emitter:start()
					emitter.speed=85+thrust*3
				elseif (jsAngle>10 and jsAngle<170) then
					G.rocket:applyForce( 1.5*thrust2*msin(rocketrotrad), -1.5*thrust2*mcos(rocketrotrad), G.rocket.x, G.rocket.y )
					fuel=fuel-thrust2
					emitter:start()
					emitter.speed=85+thrust2*3
				else emitter:stop()
				end
			end
		else
			if not G.btnAutoAltitudeActive then emitter:stop() end
			emitterL:stop( )
			emitterR:stop( )
			emitterL2:stop( )
			emitterR2:stop( )
		end
		----- AUTO ALTITUDE CONTROL ---------------------------------------
		if G.btnAutoAltitudeActive and fuel>0.5 then
			if G.rocket.vy>0 then 
				local autoThrustFinal = math.min((G.rocket.vy*4),power*0.5)
				
				if autoThrust<=autoThrustFinal then autoThrust=autoThrust+autoThrustFinal*0.1 end
				G.rocket:applyForce( 1.5*autoThrust*msin(rocketrotrad), -1.5*autoThrust*mcos(rocketrotrad), G.rocket.x, G.rocket.y )
			end
			if not G.newLevel then fuel=fuel-autoThrust end
			emitter:start()
			emitter.speed=85+autoThrust*3
		elseif jsDistance<0.2 or not ((jsAngle>190 and jsAngle<350) or (jsAngle>10 and jsAngle<170)) then
			emitter:stop()
		else
			autoThrust = 0	
		end
		------------------------------------------------------------------


		emitter.angle=-r
		emitterL.angle = -r
		emitterL.speed=60+lateral*12
		emitterR.angle = -r
		emitterR.speed=(60-lateral*12)
		emitterL2.angle = -r+90
		emitterL2.speed=40+lateral*14
		emitterR2.angle = -r-90
		emitterR2.speed=(40-lateral*14)

		if joints then
			local maxF=math.min(1+math.sqrt(G.rocket.vx*G.rocket.vx+G.rocket.vy*G.rocket.vy)/4,jointsMaxForce)
			joints.maxForce=(maxF)
		end
		----------------------------------------------------- UPDATE world coordinates --------------------------------------------
		local xr,yr=G.rocket:localToContent(0,0)

		local curTime = sGetTimer()
		local dxPerFrame = 0.03*G.rocket.vx
	    prevTime = curTime

		if G.rocket.vx>0 and xr>G.W-worldLimit-G.dW/2 and -world.x+G.W<U.worldSize-G.dW/2 then
			world.x=world.x-dxPerFrame
			if -world.x+G.W>U.worldSize-G.dW then world.x=-(U.worldSize-G.W)+G.dW end
		elseif G.rocket.vx<0 and xr<worldLimit+G.dW and world.x+G.dW<0 then
			world.x=world.x-dxPerFrame
			if world.x-G.dW>0 then world.x=G.dW end
		end
		local mvx=mabs(G.rocket.vx)
		local mvy=mabs(G.rocket.vy)
		------------------------------------------------- UPDATE velocity pointers -------------------------------------------------
		if G.rocket.vx<-256 then G.rocket.vx=-256 
		elseif G.rocket.vx>256 then G.rocket.vx=256 
		elseif G.rocket.vx<0 then
			spdHorPnt.xScale=mvx/(8) +0.1
			spdHorPnt.x=G.W-80-mvx/(8) +0.1
		elseif G.rocket.vx>0 then
			spdHorPnt.xScale=mvx/(8) +0.1
			spdHorPnt.x=G.W-80+mvx/(8) +0.1
		end
		if G.rocket.vy<-256 then G.rocket.vy=-256
		elseif G.rocket.vy>256 then G.rocket.vy=256
		elseif G.rocket.vy<0 then
			spdVerPnt.yScale=mvy/(8)+0.1
			spdVerPnt.y=G.H-80-mvy/(8)+0.1
		elseif G.rocket.vy>0 then
			spdVerPnt.yScale=mvy/(8)+0.1
			spdVerPnt.y=G.H-80+mvy/(8) +0.1
		end
		------------------------------------------------- check for astronaut proximity --------------------------------------------
		if G.placeAstro==false and G.energy>=0 and fuel>=0 then
			for i=1,G.noOfAstronauts do
				local snd=mrandom(1,2)
				if snd==1 then astronaut[i]:animate( {scannerActive=btnScanner.active,x=G.rocket.x, y=G.rocket.y, vx=G.rocket.vx, vy=G.rocket.vy, rotation=G.rocket.rotation, sound=G.sndTarget1, soundExp=G.sndTargetExpedite} )
				elseif snd==2 then astronaut[i]:animate( {scannerActive=btnScanner.active,x=G.rocket.x, y=G.rocket.y, vx=G.rocket.vx, vy=G.rocket.vy, rotation=G.rocket.rotation, sound=G.sndTarget2, soundExp=G.sndTargetExpedite} )
				end
			end
		end
		-------------------------------------------------- UPDATE ENERGY & FUEL ------------------------------------------------------
		if fuel<=0 then 
			fuel=0
			timer.performWithDelay( 8000, function() gameRun=false end )
		end
		if (fuel<G.fuel_max_05 and not G.sysWarning) or (G.energy<G.energy_max_05 and not G.sysWarning) then
			G.sysNormal=false
			G.sysWarning=true
			audio.setVolume( 1 , {channel=soundSysChannel[4]} )
			audio.play( G.sndSystem[4], {loops = 0, channel=soundSysChannel[4]} );
		end
		if (fuel<G.fuel_max_025 and not G.sysCritical) or (G.energy<G.energy_max_025 and not G.sysCritical) then
			G.sysNormal=false
			G.sysCritical=true
			audio.setVolume( 1 , {channel=soundSysChannel[5]} )
			audio.play( G.sndSystem[5], {loops = 0, channel=soundSysChannel[5]} );
		end
		if not G.sysNormal and fuel>G.fuel_max_05 and G.energy>G.energy_max_05 then
			G.sysNormal=true
			G.sysWarning=false
			G.sysCritical=false
			audio.setVolume( 1 , {channel=soundSysChannel[3]} )
			audio.play( G.sndSystem[3], {loops = 0, channel=soundSysChannel[3]} );
		end
		if fuel<G.fuel_max_007 or G.energy<G.energy_max_007 then
			if not audio.isChannelPlaying( soundSysChannel[6] ) then
				audio.setVolume( 0.25 , {channel=soundSysChannel[6]} )
				audio.play( G.sndSystem[6], {loops = -1, channel=soundSysChannel[6]} );
			end
		else
			audio.stop(soundSysChannel[6])
		end

		if fuel<G.fuel_max*0.75 and G.rocket.extraFuel1==false and (G.HUDLevel>=2 or G.debug) then
			barrelFuel1=display.newImageRect(world , "barrel.png", 27, 44)
			barrelFuel1.alpha=1
			barrelFuel1.remove=false
			barrelFuel1.name='barrelFuel'
			barrelFuel1.x=mrandom(1600)+400
			barrelFuel1.y=50
			local barrel_name="barrel.png"
			local barrel_outline = graphics.newOutline( 4, barrel_name )
			physics.addBody( barrelFuel1, "dynamic", { density = 3, friction = 0.99, bounce = 0.0, outline=barrel_outline } )
			G.rocket.extraFuel1=true
			barrelFuel1.barrelHolo=display.newImageRect( world, 'barrelgreen.png', 16, 24 )
			barrelFuel1.barrelHolo.alpha=0.75
			barrelFuel1.barrelHoloDistance=display.newText( world, '000.0 m', 0,0, 50,20, '5by7', 16 )
		  	barrelFuel1.barrelHoloDistance:setTextColor( 0,1,0.5,0.8 )
		  	
		end
		if fuel<G.fuel_max*0.5 and G.rocket.extraFuel2==false and G.HUDLevel>=6 then
			barrelFuel2=display.newImageRect(world , "barrel.png", 27, 44)
			barrelFuel2.alpha=1
			barrelFuel2.remove=false
			barrelFuel2.name='barrelFuel'
			barrelFuel2.x=mrandom(1600)+400
			barrelFuel2.y=50
			local barrel_name="barrel.png"
			local barrel_outline = graphics.newOutline( 4, barrel_name )
			physics.addBody( barrelFuel2, "dynamic", { density = 3, friction = 0.99, bounce = 0.0, outline=barrel_outline } )
			G.rocket.extraFuel2=true
		end
		if G.rocket.extraShield1==false and G.HUDLevel>=4 then
			barrelShield1=display.newImageRect(world , "barrelblue.png", 27, 44)
			barrelShield1.alpha=1
			barrelShield1.remove=false
			barrelShield1.name='barrelShield'
			barrelShield1.x=mrandom(1600)+400
			barrelShield1.y=50
			local barrel_name="barrelblue.png"
			local barrel_outline = graphics.newOutline( 4, barrel_name )
			physics.addBody( barrelShield1, "dynamic", { density = 3, friction = 0.99, bounce = 0.0, outline=barrel_outline } )
			G.rocket.extraShield1=true
		end
		if G.energy<=0 then
			G.energy=0;
			timer.performWithDelay( 0, function() 
													emitterExplosion1.x = G.rocket.x+mrandom(50)-25	
													emitterExplosion1.y = G.rocket.y+mrandom(50)-25  
													emitterExplosion1:start()
													end )
			timer.performWithDelay( 500, function() emitterExplosion1:stop() end )
			timer.performWithDelay( 50, function() 
													emitterExplosion1.x = G.rocket.x+mrandom(50)-25	
													emitterExplosion1.y = G.rocket.y+mrandom(50)-25  
													emitterExplosion1:start()
													end )
			timer.performWithDelay( 550, function() emitterExplosion1:stop() end )
			G.rocket.alpha=0
			shield.alpha=0
			js:deactivate()
			btnAutoAltitude.alpha=0
			btnScanner.alpha=0
			physics.pause( )
			G.btnAutoAltitudeActive=false
			gameRun=false
			
			timer.performWithDelay( 1500, function() gameRun=false; end )
		end
		enePnt.xScale=ene_f*G.energy/joySize+0.1
		fuelPnt.xScale=fuel_f*fuel/joySize+0.1

		if shield.alpha>0 then
			shield.x=G.rocket.x;shield.y=G.rocket.y
			shield.alpha=mcos(deg)*0.08+0.25
			shield.rotation=shield.rotation+mrandom(3)/30
		end
		if G.astronautsSaved>=G.noOfAstronauts then btnReset.levelCleared=true;gameRun=false end
	else
		physics.pause()
		if btnReset.levelCleared and btnReset.textOnce then ------------------------------- NEW LEVEL TEXT ----------------------
			btnReset.textOnce=false
			G.HUDNewLevelTxt1.text='MISSION '..G.HUDLevel..' ACCOMPLISHED'
			G.HUDNewLevelTxt2.text='PREPARE FOR NEW MISSION'
			G.HUDNewLevelTxt3.text='MISSION '..(G.HUDLevel+1)..' IS A GO-GO-GO!'
			timer.performWithDelay( 300, function() G.HUDNewLevelTxt1.trans=transition.to( G.HUDNewLevelTxt1, {x=-txtPos , y=G.H/2 , transition=easing.outInCirc, time=1500}) end )
			timer.performWithDelay( 1800, function() G.HUDNewLevelTxt2.trans=transition.to( G.HUDNewLevelTxt2, {x=-txtPos , y=G.H/2 , transition=easing.outInCirc, time=1500}) end )
			timer.performWithDelay( 3300, function() G.HUDNewLevelTxt3.trans=transition.to( G.HUDNewLevelTxt3, {x=-txtPos , y=G.H/2 , transition=easing.outInCirc, time=1500}) end )
			timer.performWithDelay(5000, function() btnReset:tap(); end)
		elseif btnReset.textOnce then --------------------------------------------------------- GAME OVER TEXT ---------------------
			audio.setVolume( 1 , {channel=soundChannel1} )
			audio.play( G.sndGameOver, {loops=0, channel=soundChannel1} )
			btnReset.textOnce=false
			
			G.HUDGameOverTxt2.text='TOTAL SCORE: '..G.HUDScore
			timer.performWithDelay( 300, function() G.HUDGameOverTxt1.trans=transition.to( G.HUDGameOverTxt1, {x=-txtPos , y=G.H/2 , transition=easing.outInCirc, time=1500}) end )
			timer.performWithDelay( 1800, function() G.HUDGameOverTxt2.trans=transition.to( G.HUDGameOverTxt2, {x=-txtPos , y=G.H/2 , transition=easing.outInCirc, time=1500}) end )
			timer.performWithDelay( 3300, function() G.HUDGameOverTxt3.trans=transition.to( G.HUDGameOverTxt3, {x=-txtPos , y=G.H/2 , transition=easing.outInCirc, time=1500}) end )
			timer.performWithDelay(5000, function() btnReset:tap(); end)
		end
		audio.stop(soundSysChannel[6])
		emitter:stop() 
		emitterL:stop( )
		emitterR:stop( )
		emitterL2:stop( )
		emitterR2:stop( )
	end
end

function btnAutoAltitude:tap(event)
	G.btnAutoAltitudeActive=not G.btnAutoAltitudeActive
	G.newLevel=false
end

function btnScanner:tap(event)
	btnScanner.active=not btnScanner.active
end

function music(event)
	local m=mrandom(1,3)
	if m==1 then audio.play( G.music1, {loops = 0, channel=musicChannel, onComplete=music} );
	elseif m==2 then audio.play( G.music2, {loops = 0, channel=musicChannel, onComplete=music} );
	else audio.play( G.music3, {loops = 0, channel=musicChannel, onComplete=music} ) ;
	end
	audio.setVolume( 0.25, {channel=musicChannel} )
end

function btnReset:tap(event)
	if tmrVolcano~=nil then 
		timer.cancel( tmrVolcano );tmrVolcano=nil 
		U.particleSystem:removeEventListener( "particleCollision" )
		local number_of_particles_destroyed = U.particleSystem:destroyParticles(
		    {
		        x = 0,
		        y = 0,
		        angle = 0,
		        halfWidth = 2000,
		        halfHeight = 1000
		    }
		)
	end
	U.clearMissionText()
	G.btnAutoAltitudeActive=false
	G.sysNormal=true
	G.sysWarning=false
	G.sysCritical=false
	G.newLevel=true
	audio.stop(musicChannel)
	audio.rewind({musicChannel})
	musicChannel=musicChannel+1
	if musicChannel>=13 then musicChannel=10 end 
	
	transition.cancel(G.HUDNewLevelTxt1.trans);G.HUDNewLevelTxt1.trans=nil;transition.cancel(G.HUDNewLevelTxt2.trans);G.HUDNewLevelTxt2.trans=nil;transition.cancel(G.HUDNewLevelTxt3.trans);G.HUDNewLevelTxt3.trans=nil;
	transition.cancel(G.HUDGameOverTxt1.trans);G.HUDGameOverTxt1.trans=nil;transition.cancel(G.HUDGameOverTxt2.trans);G.HUDGameOverTxt2.trans=nil;transition.cancel(G.HUDGameOverTxt3.trans);G.HUDGameOverTxt3.trans=nil;
	G.HUDNewLevelTxt1.x=txtPos+G.W
	G.HUDNewLevelTxt2.x=txtPos+G.W
	G.HUDNewLevelTxt3.x=txtPos+G.W
	G.HUDGameOverTxt1.x=txtPos+G.W
	G.HUDGameOverTxt2.x=txtPos+G.W
	G.HUDGameOverTxt3.x=txtPos+G.W
	btnReset.textOnce=true

	G.rocket.extraFuel1,G.rocket.extraFuel2,G.rocket.extraShield1=false,false,false
	if joints then joints:removeSelf( ) end
	joints=nil
	physics.removeBody( G.rocket )
	physics.removeBody( planet )
	if barrelFuel1~=nil then
		barrelFuel1.remove=true
		physics.removeBody( barrelFuel1 )
		barrelFuel1:removeSelf()
  		barrelFuel1=nil
  	end
  	if barrelFuel2~=nil then
		physics.removeBody( barrelFuel2 )
		barrelFuel2:removeSelf()
  		barrelFuel2=nil
  	end
  	if barrelShield1~=nil then
		physics.removeBody( barrelShield1 )
		barrelShield1:removeSelf()
  		barrelShield1=nil
  	end
	for i=G.noOfAstronauts,1,-1 do
		astronaut[i]:destroy()
		astronaut[i]=nil
	end
  	--physics.pause( )
  	if G.HUDScore>gamedata.HIScore then 
  		gamedata.HIScore=G.HUDScore 
  		loadsave.saveTable(gamedata, "gamedata.json")	
  		HIScoreTxt.text='HI-SCORE: '..gamedata.HIScore	
  	end
  	
  	if btnReset.levelCleared==false then
		G.HUDScore=0
		G.HUDLevel=1
		G.noOfAstronauts=3
		U.linesMissionTxt={'Attention pilot!', 'Galactic Logistic Operations Command Center (G.L.O.C.) greets you.', 'We will be your eyes and ears in following missions.', ' ','Mission orders follow:','Primary objective: Pick-up 3 civilians from planet','','','',''}
	else
		G.HUDLevel=G.HUDLevel+1
		if G.HUDLevel==2 then
			G.noOfAstronauts=4
			U.linesMissionTxt={'G.L.O.C. to lander commander...','We picked up distress signal from science outpost on planet.',' ','Primary objective: Save 4 scientist on planet surface','Secondary objective: Pickup extra fuel','','','','',''}
		elseif G.HUDLevel==3 then
			G.noOfAstronauts=4
			U.linesMissionTxt={'G.L.O.C. to lander commander...','Personnel shift rotation is due so go and pick them up.',' ','Primary objective: Take 4 engineers to vacation','','','','','',''}
		elseif G.HUDLevel==4 then
			G.noOfAstronauts=6
			U.linesMissionTxt={'Priority message from G.L.O.C. center',' ','Evacuate outpost personnel immediately.','We are sending shield energy cells to help you.',' ','Primary objective: Evacuate 6 outpost technicians','Secondary objective: Collect shield energy cells','','',''}
		else
			G.noOfAstronauts=3+math.floor(G.HUDLevel/2)
			U.linesMissionTxt={'G.L.O.C. to lander commander...','Standard mission - land and retrieve.','Over and out.',' ','Primary objective: Save '..G.noOfAstronauts..' astronauts','Secondary objective: Take additional fuel and energy cells','','','',''}
		end
	end
	local tmr=timer.performWithDelay( 2000, function() U.newMissionText( {group=HUD} ) end )
	
  	G.rocket.rotation=0
	js:activate()
	btnAutoAltitude.alpha=1
	btnAutoAltText.alpha=0.7
	timer.performWithDelay( mrandom(1100,1900), function() G.btnAutoAltitudeActive=true end )
	btnScanner.alpha=1
	btnScannerText.alpha=0.7
	btnScanner.active=false
	G.rocket.alpha=1
	G.energy=G.energy_max
	fuel=G.fuel_max
	local i=mrandom(1,3)
	if sky~=nil then
		sky:removeSelf( )
		sky=nil
	end
	if planet~=nil then
		planet:removeSelf( )
		planet=nil
		image1_outline=nil
	end
	local i=mrandom(1,4)
	local r=msqrt(G.W*G.W+G.H*G.H)
	local skyX,skyY=r*1.78*1.8,r*1.8
	sky = display_newImageRect( "galaxy"..i..".png", skyX, skyY )
	sky.anchorX=0.5
	sky.anchorY=0.5
	sky.dx=G.W/3
	sky.dy=G.H/3
	sky.x=G.W/2
	sky.y=G.H/2
	sky:toBack()
	G.planetNo=mrandom(12)
	if G.planetNo<4 then 
		planet = display_newImageRect( world , "planet.png", U.worldSize, 246 )
		image1_name = "planet.png"
	elseif G.planetNo>=4 and G.planetNo<=6 then 
		planet = display_newImageRect( world , "planet2.png", U.worldSize, 246 )
		image1_name = "planet2.png"
	elseif G.planetNo>=7 and G.planetNo<=9 then 
		planet = display_newImageRect( world , "planet3.png", U.worldSize, 246 )
		image1_name = "planet3.png"
	else 
		planet = display_newImageRect( world , "planet4.png", U.worldSize, 246 )
		image1_name = "planet4.png"
		U.particleSystem:addEventListener( "particleCollision" )
	end
	planet:toBack( )
	sky:toBack()
	image1_outline = graphics.newOutline( 4, image1_name )
	planet.anchorX = 0.0
	planet.anchorY = 1.0
	world.x=-mrandom(U.worldSize-G.W-G.dW*2)-G.dW
	world.y=0
	planet.x=0

	planet.y=G.H-dHmaliplanet
	physics.start( )
	physics.addBody( planet, "static", { density = 1.0,friction = 0.9,bounce = 0.1,outline = image1_outline } )
	planet.myName="planet"
	G.rocket.x,G.rocket.y=-world.x+G.W/2,50
	G.placeAstro=true
	local deltaPos=(U.worldSize-350)/G.noOfAstronauts

	for i=1,G.noOfAstronauts do
		astronaut[i]=Astronaut:new( {width=24, height=57, fileName="astronautsmall.png", displayGroup=world, x=mrandom(deltaPos)+deltaPos*(i-1)+200, y=350} )
		physics.addBody( astronaut[i], "dynamic", { density = 1, friction = 0.99, bounce = 0.0 } )
		astronaut[i]:collisionOn()
	end
	
	physics.addBody( G.rocket, "dynamic", { density = density, friction = 0.4, bounce = 0.1,	outline = image2_outline } )
	joints=physics.newJoint( "friction" , G.rocket, backFrictionOverlay, G.rocket.x, G.rocket.y )
	joints.maxForce=jointsMaxForce
	joints.maxTorque=jointsMaxTorque

	G.rocket.alpha=0
	G.astronautsSaved=0
	G.HUDLevelTxt.text='LEVEL: '..G.HUDLevel
	G.HUDScoreTxt.text='SCORE :'..G.HUDScore
	btnReset.levelCleared=false
	G.astronautsPositioned=0
	gameRun=true
	HUD:toFront( )
    return true 
end

local sparksInActive=true

audio.setVolume( 1 , {channel=soundChannel1} )
function G.rocket:preCollision(event)
	if event.other.name=='barrelFuel' then
		
    	fuel=fuel+math.random(1+math.floor(math.abs(G.fuel_max-fuel)))+G.fuel_max*0.25
    	if fuel>=G.fuel_max then fuel=G.fuel_max end
    	event.other.remove=true
    	G.xPosScore,G.yPosScore=event.x,event.y
    	U.newScoreText({score=-100,x=G.xPosScore,y=G.yPosScore,group=G.scoreGroup})
		G.HUDScore=G.HUDScore-100;G.HUDScoreTxt.text='SCORE :'..G.HUDScore 
    elseif event.other.name=='barrelShield' then
    	G.energy=G.energy+math.random(1+math.floor(math.abs(G.energy_max-G.energy)))+G.energy_max*0.25
    	if G.energy>=G.energy_max then G.energy=G.energy_max end
    	event.other.remove=true
    	G.xPosScore,G.yPosScore=event.x,event.y
    	U.newScoreText({score=-50,x=G.xPosScore,y=G.yPosScore,group=G.scoreGroup})
		G.HUDScore=G.HUDScore-50;G.HUDScoreTxt.text='SCORE :'..G.HUDScore 
	end
end
local hit=0
function G.rocket:postCollision (event)
	local hit=mabs(event.force)
	local vx,vy = G.rocket:getLinearVelocity( )
	local speed=msqrt(vx*vx+vy*vy)
    if ( hit >= 3 and G.rocket.alpha>0) then
        if hit>=50 then shield.alpha=0.5 end
        shield.trans=transition.to(shield,{alpha=0,time=1000})
        G.energy=G.energy-hit
    end
    if (event.friction>0.3 and speed>3) then
    	emitterSparks.x=event.x
		emitterSparks.y=event.y
		if sparksInActive and event.other.myName=="planet" and G.rocket.alpha>0 then
	    	emitterSparks:start()
	    	sparksInActive=false
	    	timer.performWithDelay( 250, function() emitterSparks:stop(); sparksInActive=true end )
	    end
    end
end

U.particleSystemCollision=function(self,event)
	if (event.phase=='began') then
		if event.object.myName=='rocket' then 
			G.energy=G.energy-0.05;
		end
	end
end

music()
timer.performWithDelay( mrandom(1100,1900), function() G.btnAutoAltitudeActive=true end )
U.particleSystem = physics.newParticleSystem{
	filename = "lava2.png",
	colorMixingStrength = 0.1,
	radius = 3,
	imageRadius = 6,
}
U.particleSystem.myName="volcano"
world:insert(U.particleSystem)
U.particleSystem.particleCollision = U.particleSystemCollision
U.particleSystem:addEventListener( "particleCollision" )

local perfMon=require('performance')
perfMon:newPerformanceMeter()

Runtime:addEventListener( "enterFrame", updateScreen )
G.rocket:addEventListener( "postCollision" , postCollision)
btnReset:addEventListener( "tap" )
btnAutoAltitude:addEventListener( "tap" )
btnScanner:addEventListener( "tap" )
G.rocket:addEventListener( "preCollision" )

