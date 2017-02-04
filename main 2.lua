--android icons 192,144,96,72,48,36
--------------------------------------------------------------------------------
-- main.lua
--------------------------------------------------------------------------------
local composer=require("composer")
display.setStatusBar(display.HiddenStatusBar)
system.activate( "multitouch" )
native.setProperty("windowMode", "fullscreen")

local G=require ('globals')
local U=require ('utils')

local music -- function for playing music
audio.setVolume( 1 )
G.musicChannel=10
G.planetNo=11
G.levelCleared=false
G.firstMusic=4

function music(event)
	local m=math.random(1,4)
	if G.firstMusic==4 then m=4;G.firstMusic=0;end
	if m==1 then audio.play( G.music1, {loops = 0, channel=G.musicChannel, onComplete=music} );
	elseif m==2 then audio.play( G.music2, {loops = 0, channel=G.musicChannel, onComplete=music} );
	elseif m==3 then audio.play( G.music3, {loops = 0, channel=G.musicChannel, onComplete=music} );
	else audio.play( G.music4, {loops = 0, channel=G.musicChannel, onComplete=music} ) ;
	end
	audio.setVolume( 0.25, {channel=G.musicChannel} )
end

music()


local perfMon=require('performance')
perfMon:newPerformanceMeter()

composer.gotoScene( "intermediate" )



