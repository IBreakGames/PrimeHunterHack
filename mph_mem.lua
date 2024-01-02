require('mouseControl')
require('windowProperties')

--TODO - Investigate FPS cap - did some scanning and couldn't find a limiter
--TODO - Investigate bizhawk emulator compatibility
--TODO - credits detection (may also be covered by video and main menu detection)
--TODO - Detect options menu and add key remapping to options menu

sensitivity = 35 --arbritrary number, higher is faster, lower is slower
keyConfig = {
    fire = 'leftclick',
    zoom = 'rightclick',
    morphBall = 'C',
    powerBeam = '1',
    missiles = '2',
    specialWeapon = '3',
    specialWeaponSelector = 'shift',
    scanVisor = 'F'
}

itemPositions = {
    morphBall = {
        x = 222,
        y = 172
    },
    powerBeam = {
        x = 84,
        y = 32
    },
    missiles = {
        x = 125,
        y = 32
    },
    scanVisor = {
        x = 128,
        y = 173
    },
    specialWeapon = {
        x = 172,
        y = 32
    },
    specialWeaponSelector = {
        x = 228,
        y = 32
    }
}

cameraZAddress = 0x020DA7B4
zBoolAddress = 0x020DA7B6

cameraXAddress = 0x020DA7B8
xBoolAddress = 0x020DA7BA

cameraYAddress = 0x020DA7B0
yBoolAddress = 0x020DA7B2

touchTimerAddress = 0x020DE51E

currentStateAddress = 0x027E29AC

menuUpAddress = 0x020FB458

-- zoomBoolAddress = 0x020DAF64 --currently unused
zoomAmountAddress = 0x020D9B70

morphBoolAddress = 0x020DABEA

videoBoolAddress = 0x021042F4

mainMenuBoolAddress = 0x021D3D06

frozenBoolAddress = 0x020DE670

fpsCapAddress = 0x020FA7E4
memory.writebyte(fpsCapAddress, 32)

radius = 4096

function isFrozen()
    local frozenBool = memory.readwordsigned(frozenBoolAddress)
    if (frozenBool == 1) then
        return true
    else
        return false
    end
end

--rather than checking for all cases, this is only checking 3 states: main menu, video playing, and an in-game menu
--isMainMenu and isVideoPlaying will set isMenuUp to true, which covers everything for game bootup
function isMainMenu()
    local menuBool = memory.readwordsigned(mainMenuBoolAddress)
    if (menuBool == 1) then
        memory.writeword(menuUpAddress, 1)
        return true
    else
        return false
    end
end

function isVideoPlaying()
    local videoBool = memory.readwordsigned(videoBoolAddress)
    if (videoBool == 1) then
        memory.writeword(menuUpAddress, 1)
        return true
    else
        return false
    end
end

function getZoomAmount()
    return memory.readword(zoomAmountAddress)
end

function isMorphed()
    local morphBool = memory.readwordsigned(morphBoolAddress)
    if (morphBool == 1) then
        return true
    else
        return false
    end
end

function isMenuUp()
    local menuUp = memory.readwordsigned(menuUpAddress)
    if (menuUp == 1) then
        return true
    else
        return false
    end
end

function getCameraZ ()
    return memory.readwordsigned(cameraZAddress)
end

function getCameraX ()
    return memory.readwordsigned(cameraXAddress)
end

function getCameraY ()
    return memory.readwordsigned(cameraYAddress)
end

function zAdjacent()
    --based on z height and radius length, calculate adjacent side
    return math.sqrt(radius^2 - getCameraZ()^2)
end

function zAngle()
    return math.deg(math.asin(getCameraZ()/radius))
end

function xyAngle()
    --using current X and Y, calculate the x,y angle
    return math.deg(math.atan2(getCameraY(), getCameraX())) + 180
end

function newZ(degrees)
    return radius * math.sin(math.rad(degrees))
end

function newX(degrees, hypotenuse)
    return -hypotenuse * math.cos(math.rad(degrees))
end

function newY(degrees, hypotenuse)
    return -hypotenuse * math.sin(math.rad(degrees))
end

function setCameraZ(value)
    if (value > -1) then
        memory.writeword(zBoolAddress, 0)
    else
        memory.writeword(zBoolAddress, -1)
    end
    memory.writeword(cameraZAddress, value)
end

function setCameraY(value)
    if (value > -1) then
        memory.writeword(yBoolAddress, 0)
    else
        memory.writeword(yBoolAddress, -1)
    end
    memory.writeword(cameraYAddress, value)
end

function setCameraX(value)
    if (value > -1) then
        memory.writeword(xBoolAddress, 0)
    else
        memory.writeword(xBoolAddress, -1)
    end
    memory.writeword(cameraXAddress, value)
end

function moveCamera(dx, dy)
    local zoomAmount = getZoomAmount()
    if (zoomAmount == 0) then
        zoomAmount = 3799
    end
    local zoomScaler = 3799/zoomAmount
    local verticalAngle = zAngle()
    local newZAngle = verticalAngle + dy * sensitivity/200 * zoomScaler
    local newZVal = newZ(newZAngle)
    
    local horizontalAngle = xyAngle()
    local newHorizAngle = horizontalAngle + dx * sensitivity/200 * zoomScaler
    while (newHorizAngle > 360) do
        newHorizAngle = newHorizAngle - 360
    end
    while (newHorizAngle < 0) do
        newHorizAngle = newHorizAngle + 360
    end
    local xyHypotenuse = zAdjacent()
    local newXVal = newX(newHorizAngle, xyHypotenuse)
    local newYVal = newY(newHorizAngle, xyHypotenuse)


    --floor all values to prevent numbers greater than 4096. Sometimes this seems to happen? Probably sig fig issues. Without this the camera will occasially snap to random directions
    if (newZVal > 0) then
        newZVal = math.floor(newZVal)
    elseif (newZVal < 0) then
        newZVal = -1 * math.floor(newZVal * -1)
    end

    if (newXVal > 0) then
        newXVal = math.floor(newXVal)
    elseif (newXVal < 0) then
        newXVal = -1 * math.floor(newXVal * -1)
    end

    if (newYVal > 0) then
        newYVal = math.floor(newYVal)
    elseif (newYVal < 0) then
        newYVal = -1 * math.floor(newYVal * -1)
    end

    setCameraZ(newZVal)
    setCameraX(newXVal)
    setCameraY(newYVal)
end

function lockMouse(windowProps)
    local newMouseX = windowProps.left + windowProps.width/2
    local newMouseY = windowProps.top + windowProps.height * 0.7 --part way to the bottom
    mouseControl.moveMouse(newMouseX, newMouseY)
    local mouseData = mouseControl.getMouse()
    masterX = mouseData.x
    masterY = mouseData.y
end

function stopDoubleTapToJump()
    memory.writeword(touchTimerAddress, 254)
end

function printMouse()
    print(input.get()['xmouse'], input.get()['ymouse'])
end

function handleInputs(windowProps)
    local inputs = input.get()
    if (inputs[keyConfig.fire] and inputs[keyConfig.specialWeaponSelector] == nil) then --shoot when not holding special weapon selector
        joypad.set(1, {L = true})
    end

    if (inputs[keyConfig.zoom]) then
        joypad.set(1, {select = true})
    end

    --begin touch state items
    if (inputs[keyConfig.morphBall]) then
        touchItem('morphBall', windowProps)
    elseif (inputs[keyConfig.powerBeam]) then
        touchItem('powerBeam', windowProps)
    elseif (inputs[keyConfig.missiles]) then
        touchItem('missiles', windowProps)
    elseif (inputs[keyConfig.scanVisor]) then
        touchItem('scanVisor', windowProps)
    elseif (inputs[keyConfig.specialWeapon]) then
        touchItem('specialWeapon', windowProps)
    elseif (inputs[keyConfig.specialWeaponSelector]) then
        touchItem('specialWeaponSelector', windowProps)
    else
        touchItem()
    end
end

function touchStateEngine(key, xVal, yVal, windowProps)
    if (touchStateTable[key] == nil) then
        touchStateTable[key] = {
            state = 1,
            held = true
        }
    end
    local currentState = touchStateTable[key]
    if (currentState.state == 1) then
        touchStateTable[key].state = 2
        if (key == 'specialWeaponSelector') then
            local newMouseX = windowProps.left + windowProps.width/2 + windowProps.height * 0.23 --based on height since virtual screen widths are based on height of main window
            local newMouseY = windowProps.top + windowProps.height * 0.63
            mouseControl.moveMouse(newMouseX, newMouseY)
        end
        stylus.set{x = xVal, y = yVal, touch = false}
    elseif (currentState.state == 2) then
        touchStateTable[key].state = 3
        stylus.set{x = xVal, y = yVal, touch = false}
    elseif (currentState.state == 3) then
        touchStateTable[key].state = 4
        stylus.set{x = xVal, y = yVal, touch = false}
    elseif (currentState.state == 4) then
        touchStateTable[key].state = 5
        stylus.set{x = xVal, y = yVal, touch = true}
    elseif (currentState.state == 5) then
        touchStateTable[key].state = 6
        stylus.set{x = xVal, y = yVal, touch = true}
    elseif (currentState.state == 6) then
        touchStateTable[key].state = 7
        stylus.set{x = xVal, y = yVal, touch = true}
    elseif (currentState.state == 7 and currentState.held == true) then
        --hold down on the touch screen
        if (key == 'specialWeaponSelector') then --allows the mouse to behave almost like a weapon wheel selector while selector key is held down
            local mouseTouchInfo = input.get()
            stylus.set{x = mouseTouchInfo.xmouse, y = mouseTouchInfo.ymouse, touch = true}
        else
            stylus.set{x = xVal, y = yVal, touch = true}
        end
    elseif (currentState.state == 7) then
        touchStateTable[key].state = 8
        stylus.set{x = xVal, y = yVal, touch = false}
    elseif (currentState.state == 8) then
        touchStateTable[key].state = 9
        stylus.set{x = xVal, y = yVal, touch = false}
    elseif (currentState.state == 9) then
        touchStateTable[key] = nil
        stylus.set{x = xVal, y = yVal, touch = false}
    end
end

touchStateTable = {}


function touchItem(itemType, windowProps)
    local currentKey = nil
    for k, v in pairs(touchStateTable) do
        currentKey = k
        break
    end
    if (currentKey ~= nil) then
        --if item already in state machine, continue moving it through
        if (itemType == nil) then
            touchStateTable[currentKey].held = false
        end
        touchStateEngine(currentKey, itemPositions[currentKey].x, itemPositions[currentKey].y, windowProps)
    elseif (currentKey == nil and itemType ~= nil) then
        --if no item in state machine and itemType is not nil, start the state engine
        touchStateEngine(itemType, itemPositions[itemType].x, itemPositions[itemType].y, windowProps)
    end
end

masterX = mouseControl.getMouse()['x']
masterY = mouseControl.getMouse()['y']

frameDelay = 3
frameCount = 0

firstLoadDelay = 120
firstLoadCount = 0

function run()
    if (firstLoadCount < firstLoadDelay) then --this gives the game enough time to boot up, it's only necessary for that. Still works out side of first boot without introducing new issues
        firstLoadCount = firstLoadCount + 1
        return
    end
    local mouseInfo = mouseControl.getMouse()
    local windowProps = windowProperties.getProperties()
    if (emu.emulating() ~= true) then
        return
    end
    if ((isMenuUp() == false and isVideoPlaying() == false and isMainMenu() == false) and windowProps.isCorrectWindow) then
        frameCount = frameCount + 1
        handleInputs(windowProps)
        emu.unpause() --prevents emulator from pausing if gameplay is happening, should stop mouse from getting stuck and needing to alt+tab or close the emulator
        stopDoubleTapToJump()
        local mouseData = mouseControl.getMouse()
        local currentX = mouseData.x
        local currentY = mouseData.y
        local dx = masterX - currentX
        local dy = masterY - currentY
        local touchTableKey = nil
        for k, v in pairs(touchStateTable) do
            touchTableKey = k
            break
        end
        if (touchTableKey == nil and frameCount > frameDelay and isMorphed() == false) then
            --delay touching the screen again to prevent random drags from being detected
            stylus.set{x=0, y=0, touch=true}
        end
        if (touchTableKey ~= 'specialWeaponSelector') then
            if (isFrozen() == false) then
                moveCamera(dx, dy)
            end
            lockMouse(windowProps)
        else
            masterX = mouseInfo.x
            masterY = mouseInfo.y
        end
    else
        masterX = mouseInfo.x
        masterY = mouseInfo.y
    end
end

function touchScan()
    -- print('touching')
    stylus.set{x = itemPositions.scanVisor.x, y = itemPositions.scanVisor.y, touch = true}
end

while true do
    run()
    -- printMouse()
    emu.frameadvance()
end