local G={}

local pex = require("pex")
local composer=require("composer")

G.debug=false --physics
G.debugFuel=false --for fuel, energy and barrels
G.autoPilotLevel=2 -- 1=autoaltitude control, 2=level up rocket and hold position

G.aW = display.actualContentWidth
G.aH = display.actualContentHeight
print(display.actualContentWidth.." x "..display.actualContentHeight)
G.W = display.contentWidth
G.H = display.contentHeight
print(G.W.." x "..G.H)
G.CX = display.contentCenterX
G.CY = display.contentCenterY
G.dW=(display.pixelHeight-(display.contentWidth/display.contentScaleY))/(display.pixelHeight/display.contentHeight)
G.skyRotationStart=false
G.skyMenu = nil
G.degMenu = 0

G.W0_5=G.W/2
G.H0_5=G.H/2
G.W0_125=G.W/8
G.h=G.H

G.PI = math.pi
G.rad = G.PI/180

G.astronautsSaved=0
G.noOfAstronauts=3
G.showAstro=false
G.astronautsPositioned=0
G.rocket={}
G.newLevel=true
G.btnAutoAltitudeActive=false
G.energy_max=0
G.fuel_max=0
G.xPosScore,G.yPosScore=0,0
G.scoreGroup = {}
G.txtPos=650
G.astro_name="astronautsmall.png"
G.astro_outline = graphics.newOutline( 4, G.astro_name )
G.HUDLevel=1
G.HUDScore=0
G.energy=0
G.deg=0

if G.debugFuel then G.energy_max=2000 else G.energy_max=1500 end
if G.debugFuel then G.fuel_max=90000 else G.fuel_max=90000 end
G.fuel_max_05=G.fuel_max*0.5
G.fuel_max_025=G.fuel_max*0.25
G.fuel_max_007=G.fuel_max*0.07
G.energy_max_05=G.energy_max*0.5
G.energy_max_025=G.energy_max*0.25
G.energy_max_007=G.energy_max*0.07
G.barrel={}
G.rocketName="rocketnew.png";G.sizeX=69*1.5;G.sizeY=93*1.5;G.density=4.75;G.power=150;G.factor=1.5;G.joySize=1.5;G.agility=5.5

G.d_ene=G.W-96*G.joySize*4
G.d_fuel=G.W-96*G.joySize*4
---------------------------------- PARTICLES ----------------------------------------------------
G.particlerocketBurner = pex.load("pex/rocketburner.pex","pex/texture.png")
G.particlerocketThruster = pex.load("pex/rocketthruster.pex","pex/texture.png")
G.particleExplosion = pex.load("pex/explosion.pex","pex/texture.png")
G.particleSparks = pex.load("pex/sparks.pex","pex/texture.png")
------------------------------ MUSIC AND SOUND --------------------------------------------------

G.music1 = audio.loadStream( "sound/patrol.mp3" )
G.music2 = audio.loadStream( "sound/menu sci-fi_0.mp3" )
G.music3 = audio.loadStream( "sound/space_0.mp3" )
G.music4 = audio.loadStream( "sound/01 Solaris.mp3" )

G.sndTarget1 = audio.loadSound( "sound/target.mp3" )
G.sndTarget2 = audio.loadSound( "sound/target2.mp3" )
G.sndTargetExpedite = audio.loadSound( "sound/expedite.mp3")
G.sndGameOver = audio.loadSound( "sound/gameover.mp3" )

G.sndAccept=audio.loadSound( 'sndMissionAccept.wav' )
G.sndReject=audio.loadSound( 'sndMissionReject.wav' )

G.sndSystem={}

G.sndSystem[1]= audio.loadSound( 'sound/autopilot_activated.mp3' )
G.sndSystem[2]= audio.loadSound( 'sound/scanner_activated.mp3' )
G.sndSystem[3]= audio.loadSound( 'sound/shield_ok.mp3' )
G.sndSystem[4]= audio.loadSound( 'sound/shield_50.mp3' )
G.sndSystem[5]= audio.loadSound( 'sound/shield_10.mp3' )
G.sndSystem[6]= audio.loadSound( 'sound/alert.mp3' )
G.sndSystem[7]= audio.loadSound( 'sound/fuel_ok.mp3' )
G.sndSystem[8]= audio.loadSound( 'sound/fuel_50.mp3' )
G.sndSystem[9]= audio.loadSound( 'sound/fuel_10.mp3' )

function G.btnResetTap(event)
	if event~=nil then
		if event.target.name=='button' then audio.play( G.sndAccept );	end
	end
	timer.performWithDelay(300, composer.gotoScene( 'intermediate', {effect="fade", time=500} ))
end

function G.btnAutoAltitudeTap(event)
   G.btnAutoAltitudeActive=not G.btnAutoAltitudeActive
   G.newLevel=false
end

function G.btnScannerTap(event)
   G.btnScanner.active=not G.btnScanner.active
end

return G