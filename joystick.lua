local Joystick = {}
 
function Joystick.new( innerRadius, outerRadius, sceneGroup )
    local stage = display.getCurrentStage()

    local joyGroup = display.newGroup()
    sceneGroup:insert(joyGroup)
    
    local bgJoystick = display.newCircle( joyGroup, 0,0, outerRadius )
    bgJoystick:setFillColor( 0,0,0,0 )
    bgJoystick.strokeWidth = 3
    bgJoystick:setStrokeColor( 0,1,0.5,0.3 )

    local radToDeg = 57.295779
    local degToRad = 0.017453
    local joystick = display.newCircle( joyGroup, 0,0, innerRadius )
    joystick:setFillColor( 0,1,.5, .3 )
 
    -- for easy reference later:
    joyGroup.joystick = joystick
    
    -- where should joystick motion be stopped?
    local stopRadius = outerRadius - innerRadius/2
    
    -- return a direction identifier, angle, distance
    local directionId = 0
    local angle = 0
    local distance = 0
    function joyGroup.getDirection()
        return directionId
    end
    function joyGroup:getAngle()
        return angle
    end
    function joyGroup:getDistance()
        return distance/stopRadius
    end
    
    function joystick:touch(event)
        local phase = event.phase
        local mtan2=math.atan2
        local msqrt=math.sqrt
        local mcos=math.cos
        local msin=math.sin
        if( (phase=='began') or (phase=="moved") ) then
            if( phase == 'began' ) then
                stage:setFocus(event.target, event.id)
                native.setProperty( "mouseCursorVisible", false )
            end
            local parent = self.parent
            local posX, posY = parent:contentToLocal(event.x, event.y)
            angle = (mtan2( posX, posY )*radToDeg)-90
            if( angle < 0 ) then
                angle = 360 + angle
            end
 
            -- could expand to include more directions (e.g. 45-deg)
            -- if( (angle>=45) and (angle<135) ) then
            --     directionId = 2
            -- elseif( (angle>=135) and (angle<225) ) then
            --     directionId = 3
            -- elseif( (angle>=225) and (angle<315) ) then
            --     directionId = 4
            -- else
            --     directionId = 1
            -- end
            
            -- could emit "direction" events here
            --Runtime:dispatchEvent( {name='direction',directionId=directionId } )
            
            distance = msqrt((posX*posX)+(posY*posY))
            
            if( distance >= stopRadius ) then
                distance = stopRadius
                local radAngle = angle*degToRad
                self.x = distance*mcos(radAngle)
                self.y = -distance*msin(radAngle)
            else
                self.x = posX
                self.y = posY
            end
            
        elseif phase=="ended" or phase=="canceled" then
            self.x = 0
            self.y = 0
            stage:setFocus(nil, event.id)
            
            directionId = 0
            angle = 0
            distance = 0
            native.setProperty( "mouseCursorVisible", true )
        else
            self.x = 0
            self.y = 0
            stage:setFocus(nil, event.id)
            
            directionId = 0
            angle = 0
            distance = 0
            native.setProperty( "mouseCursorVisible", true )
        end
        return true
    end
    
    function joyGroup:activate()
        self:addEventListener("touch", self.joystick )
        self.directionId = 0
        self.angle = 0
        self.distance = 0
        bgJoystick:setStrokeColor( 0,1,0.5,0.3 )
        joystick:setFillColor( 0,1,.5, .3 )
    end
    function joyGroup:deactivate()
        self:removeEventListener("touch", self.joystick )
        self.directionId = 0
        self.angle = 0
        self.distance = 0
        bgJoystick:setStrokeColor( 0,1,0.5,0.0 )
        joystick:setFillColor( 0,1,.5, .0 )
    end
 
    return( joyGroup )
end
 
return Joystick