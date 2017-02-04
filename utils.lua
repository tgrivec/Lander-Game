local U={}

local G=require('globals')

local physics=require('physics')

U.optionsMissionTxt={}
U.tmrMissionTxt={}
U.transMissionTxt={}
U.linesMissionTxt={} -- text lines to show on screen
U.lineMissionTxt={}  -- display.newText tables
U.astroImageScanner={}
U.particleSystem1={}
U.particleSystem2={}

U.worldSize=4096
U.volcanoTimer=nil

local mrandom=math.random

U.particleParams_red1 =
{
	flags = { "water", "colorMixing", "fixtureContactListener" },
	linearVelocityX = 1,
	linearVelocityY = -55,
	angularVelocity = 9,
	color = { 1, 0, 0.1, 1 },
	x = 1251,
	y = 424,
	lifetime = 6.0,
	radius = 5,
}
U.particleParams_yel1 =
{
	flags = { "water", "colorMixing","fixtureContactListener" },
	linearVelocityX = -1,
	linearVelocityY = -45,
	angularVelocity = -9,
	color = { 1, 0.8, 0.2, 1 },
	x = 1255,
	y = 428,
	lifetime = 6.0,
	radius = 5,
}
U.particleParams_red2 =
{
	flags = { "water", "colorMixing" },
	linearVelocityX = 1,
	linearVelocityY = -55,
	angularVelocity = 9,
	color = { 1, 0, 0.1, 1 },
	x = 1251,
	y = 424,
	lifetime = 6.0,
	radius = 5,
}
U.particleParams_yel2 =
{
	flags = { "water", "colorMixing" },
	linearVelocityX = -1,
	linearVelocityY = -45,
	angularVelocity = -9,
	color = { 1, 0.8, 0.2, 1 },
	x = 1255,
	y = 428,
	lifetime = 6.0,
	radius = 5,
}
U.particleSystemCollision=function(self, event)
   if (event.phase=='began') then
      if event.object.myName=='rocket' then 
        G.energy=G.energy-0.5;
      end
   end
end
U.createVolcano = function()
	U.particleSystem1 = physics.newParticleSystem{
		filename = "lava2.png",
		colorMixingStrength = 0.1,
		radius = 3,
		imageRadius = 6
    }
    U.particleSystem2 = physics.newParticleSystem{
		filename = "lava2.png",
		colorMixingStrength = 0.1,
		radius = 3,
		imageRadius = 6
    }
    G.world:insert(U.particleSystem1)
    G.world:insert(U.particleSystem2)
end
U.indexParticleCollision=1
U.VolcanoBurst=function( event )
	local mrandom=mrandom
	U.indexParticleCollision=U.indexParticleCollision+1
	if U.indexParticleCollision%5==0 then
		U.particleParams_red1.color={ mrandom(75,100)*0.1, 0, 0.1, 1 }
		U.particleParams_yel1.color={ mrandom(70,100)*0.1, mrandom(40,80)*0.1, 0.2, 1 }
		U.particleParams_red1.linearVelocityY=-(mrandom(50)+115)
		U.particleParams_yel1.linearVelocityY=-(mrandom(50)+115)
		U.particleParams_red1.linearVelocityX=mrandom(64)-32
		U.particleParams_yel1.linearVelocityX=mrandom(64)-32
		U.particleSystem1:createGroup( U.particleParams_red1 )
		U.particleSystem1:createGroup( U.particleParams_yel1 )
	else
		U.particleParams_red2.color={ mrandom(75,100)*0.1, 0, 0.1, 1 }
		U.particleParams_yel2.color={ mrandom(70,100)*0.1, mrandom(40,80)*0.1, 0.2, 1 }
		U.particleParams_red2.linearVelocityY=-(mrandom(50)+115)
		U.particleParams_yel2.linearVelocityY=-(mrandom(50)+115)
		U.particleParams_red2.linearVelocityX=mrandom(64)-32
		U.particleParams_yel2.linearVelocityX=mrandom(64)-32
		U.particleSystem2:createGroup( U.particleParams_red2 )
		U.particleSystem2:createGroup( U.particleParams_yel2 )
	end
end

U.newScannerTarget=function(params)
	local x0,y0=params.width*0.5,params.height*0.5
	local dx,dy=10,10
	local dx2,dy2=dx*0.3,dy*0.3
	local x1,y1=-x0-dx2,-y0-dy2
	local x2,y2=x0+dx2,-y0-dy2
	local x3,y3=x0+dx2,y0+dy2
	local x4,y4=-x0-dx2,y0+dy2
	params.group.l={}
	params.group.l[1]=display.newLine( params.group, x1,y1,x1+dx,y1 )
	params.group.l[2]=display.newLine( params.group, x1,y1,x1,y1+dy )
	params.group.l[3]=display.newLine( params.group, x2,y2,x2-dx,y2 )
	params.group.l[4]=display.newLine( params.group, x2,y2,x2,y2+dy )
	params.group.l[5]=display.newLine( params.group, x3,y3,x3-dx,y3 )
	params.group.l[6]=display.newLine( params.group, x3,y3,x3,y3-dy )
	params.group.l[7]=display.newLine( params.group, x4,y4,x4+dx,y4 )
	params.group.l[8]=display.newLine( params.group, x4,y4,x4,y4-dy )
	for i=1,8 do
		params.group.l[i]:setStrokeColor( 0,1,0.5,1 )
		params.group.l[i].strokeWidth=1
	end
end

U.newMissionText=function(params)
	local posX=560 --480
	local deltaTime=2100
	local delayTime=1500
	local transTime=600
	local f=115	
	local alpha=0.82
	local offAutoAltitude=0
	if U.GLOC1==nil then U.GLOC1=display.newImageRect( params.group, 'tom1small.png', 115, 115 ) end
	if U.GLOC2==nil then U.GLOC2=display.newImageRect( params.group, 'tom2small.png', 115, 115 ) end
	U.GLOC1.x,U.GLOC1.y=50,150
	U.GLOC2.x,U.GLOC2.y=50,150
	U.GLOC2.alpha=0
	U.GLOC1.alpha=alpha
	U.stop=false
	U.tmr1=timer.performWithDelay( 325, function() 
				timer.performWithDelay(math.random(300), function() 
						if U.stop==false then 
							if U.GLOC1 then U.GLOC1.alpha=alpha-U.GLOC1.alpha; end 
							if U.GLOC2 then U.GLOC2.alpha=alpha-U.GLOC2.alpha; end
						end; 
					end, 1); 
				end , -1 )
	for i=1,10 do U.optionsMissionTxt[i]={
						parent = params.group or nil,
			   			x = posX,
			    		y = 175,
			   	 		width = 880 ,    --required for multi-line and alignment
			    		font = '5by7' ,  
			    		fontSize = 22,
			    		align = "left"  ,--new alignment parameter
				 		text=U.linesMissionTxt[i] or ''
		} 
		if U.linesMissionTxt[i]~='' then
			offAutoAltitude=offAutoAltitude+deltaTime
			U.tmrMissionTxt[i]=timer.performWithDelay( (i-1)*deltaTime, 
				function() U.lineMissionTxt[i]=display.newText(U.optionsMissionTxt[i]);U.lineMissionTxt[i]:setTextColor( 0,1,0.5,1 );
					U.transMissionTxt[i]=transition.to(U.lineMissionTxt[i], {delay=delayTime, y=U.lineMissionTxt[i].y-30, alpha=0.8, time=transTime,transition=easing.inOutSine , onComplete=function() 
						U.transMissionTxt[i]=transition.to( U.lineMissionTxt[i], {delay=delayTime, y=U.lineMissionTxt[i].y-30, alpha=0.6, time=transTime,transition=easing.inOutSine , onComplete=function() 
							U.transMissionTxt[i]=transition.to( U.lineMissionTxt[i], {delay=delayTime, y=U.lineMissionTxt[i].y-30, alpha=0, time=transTime, transition=easing.inOutSine ,onComplete=function() 
								U.transMissionTxt[i]=nil;
							end} )
						end} )
					end} )
				end )
		end
	end
	timer.performWithDelay( offAutoAltitude+deltaTime,function() 
												if G.newLevel==true then
													G.newLevel=false
													G.btnAutoAltitudeActive=false
												end	
												U.stop=true
												if U.GLOC1 then U.GLOC1.alpha=0;end 
												if U.GLOC2 then U.GLOC2.alpha=0;end
												if U.tmr1 then timer.cancel(U.tmr1);end  
											end )

end

U.clearMissionText=function()
	if U.tmr1 then timer.cancel(U.tmr1);U.tmr1=nil;end
	U.stop=true
	if U.GLOC1 then U.GLOC1.alpha=0;U.GLOC1:removeSelf();U.GLOC1=nil; end
	if U.GLOC2 then U.GLOC2.alpha=0;U.GLOC2:removeSelf();U.GLOC2=nil; end
	for i=10,1,-1 do
		U.linesMissionTxt[i]=''
		if U.transMissionTxt[i]~=nil then transition.cancel(U.transMissionTxt[i]);U.transMissionTxt[i]=nil end
		if U.tmrMissionTxt[i]~=nil then timer.cancel( U.tmrMissionTxt[i] );U.tmrMissionTxt[i]=nil; end
		if U.lineMissionTxt[i]~=nil then U.lineMissionTxt[i]:removeSelf( );U.lineMissionTxt[i]=nil; end
	end
end

U.newScoreText=function(params)
	optionsTxt={
			parent = params.group or G.scoreGroup,
   			x = params.x,
    		y = params.y,
   	 		width = 70 ,    --required for multi-line and alignment
    		font = 'Space Age' ,  
    		fontSize = 25,
    		align = "center"  ,--new alignment parameter
	 		text=params.score or ''
	} 
	local txt=display.newText(optionsTxt);
	txt:setTextColor( 0,1,0.5,1 )
	local trans=transition.to(txt,{time=1200, iterations=1,transition=easing.outinquad,alpha=0.2,xScale=1.2,yScale=1.2,y=params.y-180,onComplete=function() txt:removeSelf( ) end}); 
end

return U