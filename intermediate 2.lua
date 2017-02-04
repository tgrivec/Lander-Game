local composer = require( "composer" )
local G = require ('globals')
local loadsave = require("loadsave")
local scene = composer.newScene()
local btnLevelGrp={}
local btnLevel={}
local btnLevelStar1off={}
local btnLevelStar2off={}
local btnLevelStar3off={}
local btnLevelStar1on={}
local btnLevelStar2on={}
local btnLevelStar3on={}
local mrad=math.rad
local msin=math.sin
local mcos=math.cos

local updateScreen=function(event)
   G.degMenu=G.degMenu+0.1
   local deginrad=mrad(G.degMenu)
   if G.skyMenu then
      G.skyMenu.x=G.W0_5 + G.skyMenu.dx * msin(deginrad*0.005)
      G.skyMenu.y=G.H0_5 + G.skyMenu.dy * mcos(deginrad*0.005)
      G.skyMenu.rotation=-0.15*G.degMenu
   end
end

function scene:create( event )

   local sceneGroup = self.view
   
   -- Initialize the scene here.
   -- Example: add display objects to "sceneGroup", add touch listeners, etc.
   local r=math.sqrt(G.W*G.W+G.H*G.H)
   G.worldLimit = G.W/3--(G.aW-G.W)/2
   G.skyMenuX,G.skyMenuY=r*1.9,r*1.3
   local galaxyName="galaxy"..math.random(5)..".png"
   G.skyMenu = display.newImageRect( sceneGroup, galaxyName, G.skyMenuX, G.skyMenuY )
   G.skyMenu:toBack( )
   G.skyMenu.anchorX=0.5
   G.skyMenu.anchorY=0.5
   G.skyMenu.dx=G.W/5.5
   G.skyMenu.dy=G.H/5.5
   
   local landerlogo=display.newImageRect( sceneGroup, 'landerlogo.png', 822, 116 )
   landerlogo.x=G.W/2;landerlogo.y=120;landerlogo.alpha=0.7
   local zoom=1.75

   for i=1,12 do 
      btnLevelGrp[i]=display.newGroup( )
      sceneGroup:insert( btnLevelGrp[i] )
      btnLevel[i]=display.newRoundedRect( btnLevelGrp[i], 0,0, 64, 64, 4 )
      btnLevel[i]:setFillColor( 0,1,0.5,0.5 )
      btnLevel[i]:setStrokeColor( 0,0.3,0.2,0.7 )
      btnLevel[i].strokeWidth=2
      btnLevel[i].bottom=display.newRoundedRect( btnLevelGrp[i], 0,48, 64, 32, 4 )
      btnLevel[i].bottom:setFillColor( 0,0.25,0.2,0.25 )
      btnLevel[i].bottom:setStrokeColor( 0,0.3,0.2,0.35 )
      btnLevel[i].bottom.strokeWidth=2
      btnLevel[i].txt=display.newText( btnLevelGrp[i], i..' ', 0,0, 'Airstrike Laser', 42 )
      btnLevel[i].txt:setTextColor( 0,1,0.5, 0.8 )
      btnLevelGrp[i].enabled=false
      btnLevelGrp[i].level=i
      btnLevelGrp[i].stars=0
      btnLevelStar1off[i]=display.newImageRect( btnLevelGrp[i], 'star_black.png', 20, 20 )
      btnLevelStar1off[i].x=-20
      btnLevelStar1off[i].y=48
      btnLevelStar2off[i]=display.newImageRect( btnLevelGrp[i], 'star_black.png', 20, 20 )
      btnLevelStar2off[i].x=0
      btnLevelStar2off[i].y=48
      btnLevelStar3off[i]=display.newImageRect( btnLevelGrp[i], 'star_black.png', 20, 20 )
      btnLevelStar3off[i].x=20
      btnLevelStar3off[i].y=48
      btnLevelStar1on[i]=display.newImageRect( btnLevelGrp[i], 'star_gold.png', 20, 20 )
      btnLevelStar1on[i].x=-20
      btnLevelStar1on[i].y=48
      btnLevelStar2on[i]=display.newImageRect( btnLevelGrp[i], 'star_gold.png', 20, 20 )
      btnLevelStar2on[i].x=0
      btnLevelStar2on[i].y=48
      btnLevelStar3on[i]=display.newImageRect( btnLevelGrp[i], 'star_gold.png', 20, 20 )
      btnLevelStar3on[i].x=20
      btnLevelStar3on[i].y=48
   end
   btnLevelGrp[1].enabled=true

   local i=1
   for r=1,3 do
      for c=1,4 do
         btnLevelGrp[i].x=G.W*0.5+(c-2)*150-75
         btnLevelGrp[i].y=G.H*0.5+110+(r-2)*120
         i=i+1
      end
   end

   function btnLevelTap(event)
      print (event.target)
      print (btnLevelGrp[2])
      if event.target.enabled==true then
         audio.play( G.sndAccept );
         if event.target.level == 1 then composer.gotoScene( "level" , {effect="fade", time=500, params = {planetNo=1,volcano=false,level=event.target.level} })
         elseif event.target.level == 2 then composer.gotoScene( "level" , {effect="fade", time=500, params = {planetNo=2,volcano=false,level=event.target.level} })
         elseif event.target.level == 3 then composer.gotoScene( "level" , {effect="fade", time=500, params = {planetNo=4,volcano=false,level=event.target.level} })
         elseif event.target.level == 4 then composer.gotoScene( "level" , {effect="fade", time=500, params = {planetNo=3,volcano=false,level=event.target.level} })
         elseif event.target.level >= 1 then composer.gotoScene( "level" , {effect="fade", time=500, params = {planetNo=4,volcano=true,level=event.target.level} })
         end
      else
         audio.play( G.sndReject );
      end
   end

   for i=1,12 do btnLevelGrp[i]:addEventListener( "tap", btnLevelTap ) end
   
end

function scene:show( event )
   local sceneGroup = self.view
   local phase = event.phase
   if ( phase == "will" ) then
      -- Called when the scene is still off screen (but is about to come on screen).
      G.gamedata=loadsave.loadTable("gamedata.json")
      if (G.gamedata == nil) then
         G.gamedata={}
         G.gamedata.levelEnabled={}
         G.gamedata.levelStars={}
         for i=1,12 do
            G.gamedata.levelEnabled[i]=false
            G.gamedata.levelStars[i]=0
         end
      end
      G.gamedata.levelEnabled[1]=true
      print(G.gamedata.levelEnabled[2])
      loadsave.saveTable(G.gamedata,"gamedata.json")
      local starsCount=0
      for i=1,12 do 
         if G.gamedata.levelEnabled[i] and (i==1 or (i>=2 and math.floor(starsCount/(i-1))>=2)) then
            btnLevelGrp[i].alpha=1
            btnLevelGrp[i].enabled=true
         else 
            btnLevelGrp[i].alpha=0.25 
            btnLevelGrp[i].enabled=false
         end
         starsCount=starsCount+G.gamedata.levelStars[i]
         btnLevelStar1off[i].alpha=0
         btnLevelStar1on[i].alpha=1
         btnLevelStar2off[i].alpha=0
         btnLevelStar2on[i].alpha=1
         btnLevelStar3off[i].alpha=0
         btnLevelStar3on[i].alpha=1
         if G.gamedata.levelStars[i]==2 then
            btnLevelStar3off[i].alpha=1
            btnLevelStar3on[i].alpha=0
         elseif G.gamedata.levelStars[i]==1 then
            btnLevelStar2off[i].alpha=1
            btnLevelStar2on[i].alpha=0
            btnLevelStar3off[i].alpha=1
            btnLevelStar3on[i].alpha=0
         elseif G.gamedata.levelStars[i]==0 then
            btnLevelStar1off[i].alpha=1
            btnLevelStar1on[i].alpha=0
            btnLevelStar2off[i].alpha=1
            btnLevelStar2on[i].alpha=0
            btnLevelStar3off[i].alpha=1
            btnLevelStar3on[i].alpha=0
         end
      end
   elseif ( phase == "did" ) then
      composer.removeScene( 'level', false )
      Runtime:addEventListener( "enterFrame", updateScreen )
      -- Called when the scene is now on screen.
      -- Insert code here to make the scene come alive.
      -- Example: start timers, begin animation, play audio, etc.
   end
end

function scene:hide( event )

   local sceneGroup = self.view
   local phase = event.phase

   if ( phase == "will" ) then
      -- Called when the scene is on screen (but is about to go off screen).
      -- Insert code here to "pause" the scene.
      -- Example: stop timers, stop animation, stop audio, etc.
      Runtime:removeEventListener( "enterFrame", updateScreen )
   elseif ( phase == "did" ) then
      -- Called immediately after scene goes off screen.
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