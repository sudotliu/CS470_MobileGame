-----------------------------------------------------------------------------------------
-- Group name: Aqueduct Adventures
-- File name: stage3.lua
-- Purpose: The code for stage 3 of the game.
-- Group 5:
--    Terry Liu
--    Raymond Ononiwu
--    William Thomas
-- Description: 
--    This is stage 3 of the game: Northern Owens Valley.
-----------------------------------------------------------------------------------------

local scene = storyboard.newScene();
local level = 3;

require("assets.displaysetup");

local destroyed = false;

-- Images
local bg = nil;
local pipes = nil;

--Timers
local tankTimer = nil;

-- Classes
local physicsLineFactoryII = nil;
local valves = {};
local generators = {};
local pumps = {};

-- HUD
local hud = nil;

-- Water win requirement
local totalWater = nil;
local requiredWater = 0.5;

-- Screen size factors - used to scale background image size to screen
local bgWidthFactor = 2;
local bgHeightFactor = 1;
-- Base the size of the level on the size of the device and the factor set above
local levelWidth = bgWidthFactor * metrics.size.width;
local levelHeight = bgHeightFactor * metrics.size.height;

-- For camera movement
local cameraBounds = {
  minX = -(levelWidth - metrics.size.width),
  maxX = -1,
  minY = -(levelHeight - metrics.size.height),
  maxY = 0,
};

local stageTimer = nil;
local levelTime = nil;
local score = nil;
local dt = nil;
local loseScreen = {};
local won = false;
 
---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------
local lostLevel = nil;

local function restart()
  storyboard.gotoScene( "assets.stages.stage3", "crossFade", 250 );
end

---[[ WILL'S CODE

--This will make the water volume louder with more particles moving
local function updateWaterSoundVolume()
  local newVol = 0;
  
  local sumVelocity = 0;
  local numParticles = 0;
  for i=1,#generators do
    if(generators[i] ~= nil) then
      local g = generators[i];      
      for j=1,#g.particles do
        local p = g.particles[j];
        if(p ~= nil and p.image ~= nil) then
          numParticles = numParticles+1;
          local vx,vy = p.image:getLinearVelocity();
          local mag = math.sqrt(vx*vx + vy*vy);
          sumVelocity = mag+sumVelocity;
        end
      end
    end
  end
  if(numParticles <= 0 or sumVelocity <= 0) then
    audio.setVolume(0, {channel=2});
    return;
  end  
  
  newVol = sumVelocity/9000;
  
  if(newVol < 0) then newVol = 0
  elseif(newVol > 1) then newVol = 1;
  end
  
  audio.setVolume(newVol, {channel=2});
end

local function getParticlesInTankRatio(xMin,yMin,xMax,yMax)
  
  if(totalWater <= 0) then return 0 end;
  local inTank = 0;
  local total = 0;
  for i=1,#generators do
    if(generators[i] ~= nil) then
      local g = generators[i];
      
      for j=1,#g.particles do
        local p = g.particles[j]
        --print('  ' .. p.image.x .. ', ' .. p.image.y);
        if(p ~= nil and p.image ~= nil) then
          if(p.image.x >= xMin and p.image.x <= xMax and p.image.y >= yMin and p.image.y <= yMax) then
            inTank = inTank+1
          end
        end
      end
    end
  end
  
  local ratio = inTank/totalWater;
  return ratio;
  
end

--HUD-COPY OVER TO ALL OTHER STAGES--------------------------------------------
local function keepHUDPlaced()  
  hud.x = -cameraX;
  hud.y = -cameraY;
  
  hud.bg.x = hud.x + hud.bg.width/2;
  hud.bg.y = hud.y + hud.bg.height/2;
  hud.text.x = hud.bg.x;
  hud.text.y = hud.bg.y;

  hud.timer.x = hud.x + hud.bg.width/2;
  hud.timer.y = hud.y + hud.bg.height/2;
  
  hud.exit.x = hud.x+4+hud.exit.width/2;
  hud.exit.y = hud.y+4+hud.exit.height/2;
  
  hud.restart.x = hud.x+hud.bg.width-4-hud.restart.width/2;
  hud.restart.y = hud.y+hud.bg.height-4-hud.restart.height/2;
end

local function createHUD()
  hud = {x=0,y=0};

  hud.bg = display.newImage("images/hud/bg_small.png", true);
  local scale = hud.bg.width / metrics.size.width;
  hud.bg.width = metrics.size.width;
  hud.bg.height = hud.bg.height / scale;
  layers[8]:insert(hud.bg);
  
   --Timer background
  hud.timer = display.newImage("images/hud/timer_small.png", true);
  hud.timer.width = hud.timer.width / scale;
  hud.timer.height = hud.timer.height / scale;
  layers[9]:insert(hud.timer);

   --Timer text
  hud.text = display.newText( math.ceil(levelTime), 0, 0, "Bebas Neue", 30 );
  hud.text:setTextColor(233,233,233);
  layers[9]:insert(hud.text);
  
  --Exit button
  hud.exit = display.newImage("images/hud/exit_small.png", true);
  hud.exit.width = hud.exit.width / scale;
  hud.exit.height = hud.exit.height / scale;
  layers[9]:insert(hud.exit);
  hud.exit:addEventListener("touch", function(e)
    if (e.phase == 'began' and not kiosk.on ) then   
      storyboard.gotoScene( "assets.map_screen", "crossFade", 250 );
      playSoundEffect(sounds.blip);
    end;
  end);
  
  --Restart button
  hud.restart = display.newImage("images/hud/restart_small.png", true);
  hud.restart.width = hud.restart.width / scale;
  hud.restart.height = hud.restart.height / scale;
  layers[9]:insert(hud.restart);
  hud.restart:addEventListener("touch", function(e)
    if (e.phase == 'began' and not kiosk.on ) then 
      playSoundEffect(sounds.blip); restart(); end;
  end);
    
  --Call at end
  keepHUDPlaced();
end

local function killHUD()
  hud.bg:removeSelf();
  hud.bg = nil;
  
  hud.text:removeSelf();
  hud.text = nil;

  hud.timer:removeSelf();
  hud.timer = nil;
  
  hud.exit:removeEventListener("touch", function(e)
    if (e.phase == 'began') then storyboard.gotoScene( "assets.map_screen", "crossFade", 250 ); end;
  end);
  hud.exit:removeSelf();
  hud.exit = nil;
  
  hud.restart:removeEventListener("touch", function(e)
    if (e.phase == 'began') then restart(); end;
  end);
  hud.restart:removeSelf();
  hud.restart = nil;
  
  hud = nil;
end
--END HUD----------------------------------------------------------------------
  
local function winLevel()
  won=true;
 if(score > storage.highScores[level]) then
    storage.highScores[level] = score;
    showNewHighScore = true;
  end
  
  if(storage.upToStage<(level+1)) then storage.upToStage = (level+1) end;
  storyboard.gotoScene( "assets.exit.exit2_1", "crossFade", 250 );
end

--Draggable camera
local curX = nil;
local curY = nil;
local function reportTouch(event)
  if(kiosk.on) then return; end
  if(event.phase == 'began' or curX == nil or curY == nil) then 
    curX = cameraX;
    curY = cameraY;
  elseif(event.phase == 'moved') then
    local newX = (event.x - event.xStart) + curX;     
    if(newX > cameraBounds.maxX) then newX = cameraBounds.maxX;
    elseif(newX < cameraBounds.minX) then newX = cameraBounds.minX;
    end
    
    local newY = (event.y - event.yStart) + curY;      
    if(newY < cameraBounds.minY) then newY = cameraBounds.minY;
    elseif(newY > cameraBounds.maxY) then newY = cameraBounds.maxY;
    end
    
    placeCamera(newX, newY);

    keepHUDPlaced();
  else
    curX = nil;
    curY = nil;
  end
end

local function createLevel()
  won=false;
  resetCamera();
  loseScreen = {};
  playSoundEffect(sounds.water, -1, 2);
  resetCamera();
  destroyed = false;
  physics = require("physics");
  
  levelTime = 60;
  score = levelTime*1000;
  dt = 0.1;
  requiredWater = .5;
  if(kiosk.on) then requiredWater = 0.3; end
  
  --score timer
  stageTimer = timer.performWithDelay(1000*dt,
    function()
      if(levelTime <=0) then loseLevel('time'); 
      else
        levelTime = levelTime-dt;
        if(levelTime < 0) then levelTime = 0; end
        local p = 1.073997;
        local bonus = 2-(generators[1].count/generators[1].max);
        score = math.ceil(levelTime*1000*p*bonus);
        print("Score: "..score);
        hud.text.text = math.ceil(levelTime);
      end
    end,
  0);

  physics.start();
  if(debugMode) then physics.setDrawMode("hybrid");
  else physics.setDrawMode("normal");
  end
  physics.setGravity(0, 7);

  physicsLineFactoryII = PhysicsLineFactoryII:new(physics,layers[4]);
  
  -- Loading bg
  bg = display.newImage("images/bg/stages/2_1_bg.png", true);
  --bg.width = levelWidth;
  --bg.height = levelHeight;
  bg.width = 480*2;
  bg.height = 320*1;

  bg.x = bg.width / 2;
  bg.y = bg.height / 2;
  layers[1]:insert(bg);

  -- Loading pipe image layer
  pipes = display.newImage("images/pipes/stages/2_1_pipes.png", true);
  pipes.width = bg.width;
  pipes.height = bg.height;
  pipes.x = bg.x;
  pipes.y = bg.y;
  layers[4]:insert(pipes);

  --Generators
  -- Parameters: x, y, xF, yF, r, startUp, physics, group, interval, maxP
  generators[1] = GeneratorValveSmall:new(124, 132, 250, 0, 3, true, physics, layers[2], 70, 250);
  totalWater = generators[1].max;
  
  -- Valves
  -- Replaced first valve with GeneratorValveSmall above
  -- boolean values are for "turned" and "right"
  valves[1] = ValveSmall:new(276, 175, 3, true, layers[4], false, false);
  valves[2] = ValveSmall:new(408, 227, 3, true, layers[4], false, false);
  valves[3] = ValveSmall:new(557, 190, 3, true, layers[4], true, true);
  valves[4] = ValveSmall:new(738, 261, 3, true, layers[4], false, false);
  valves[5] = ValveSmall:new(900, 132, 3, true, layers[4], false, false);

  -- Pumps
  pumps[1] = TurboPump:new(199, 277, 3, physics, layers[4], true, false);
  pumps[1]:start();
  pumps[2] = TurboPump:new(372, 200, 3.5, physics, layers[4], false, true);
  pumps[2]:start();
  pumps[3] = TurboPump:new(445.5, 193, 3, physics, layers[4], false, false);
  pumps[3]:start();
  pumps[4] = TurboPump:new(704, 264, 3, physics, layers[4], true, false);
  pumps[4]:start();
  pumps[5] = TurboPump:new(776, 290.5, 3, physics, layers[4], true, false);
  pumps[5]:start();
  pumps[6] = TurboPump:new(772, 223, 3, physics, layers[4], false, false);
  pumps[6]:start();
  pumps[7] = TurboPump:new(901, 253, 3, physics, layers[4], false, false);
  pumps[7]:start();

  -- Physical pipes
  -- GeneratorValveSmall
  physicsLineFactoryII:makeHorizPipeLine(143, 128, 40, 10);
  physicsLineFactoryII:makeEastHorseshoePipe(180, 149, 25, 10);
  physicsLineFactoryII:makeWestHorseshoePipe(180, 188.5, 25, 10);
  physicsLineFactoryII:makeEastHorseshoePipe(176, 220, 25, 10);
  physicsLineFactoryII:makeWestHorseshoePipe(179, 260, 25, 10);
  -- TurboPump1
  physicsLineFactoryII:makeSECurvePipe(219, 256.5, 25, 10);
  physicsLineFactoryII:makeVertPipeLine(234, 195, 10, 65);  
  physicsLineFactoryII:makeNWCurvePipe(256.5, 196, 23, 10);
  -- Valve1
  -- Begin failure path
  physicsLineFactoryII:makeVertPipeLine(271, 183, 10, 35);  
  physicsLineFactoryII:makeSWCurvePipe(295.5, 211, 25, 10);
  physicsLineFactoryII:makeHorizPipeLine(295, 226, 37, 10);  
  physicsLineFactoryII:makeNECurvePipe(331, 249, 23, 10);
  physicsLineFactoryII:makeVertPipeLine(344, 248, 10, 30);
  physicsLineFactoryII:makeNorthTPipe(344, 267, 10, 10);
  physicsLineFactoryII:makeHorizPipeLine(364, 277, 40, 10);
  physicsLineFactoryII:makeWestTPipe(393, 277, 10, 10);
  physicsLineFactoryII:makeVertPipeLine(403, 235, 10, 40);
  -- Valve2
  -- End failure path, back to valve 1 going right
  physicsLineFactoryII:makeHorizPipeLine(295, 173, 65, 10);  
  physicsLineFactoryII:makeWestTPipe(357, 173, 10, 10);
  -- Needed to add a down pump to make this work
  -- TurboPump2
  physicsLineFactoryII:makeSWCurvePipe(391.5, 210.5, 25, 10);
  physicsLineFactoryII:makeSECurvePipe(425.5, 210.5, 25, 10);
  -- TurboPump3
  physicsLineFactoryII:makeVertPipeLine(441, 137, 10, 40);
  physicsLineFactoryII:makeNWCurvePipe(465.5, 139, 25, 10);
  physicsLineFactoryII:makeHorizPipeLine(463, 114, 35, 10);  
  physicsLineFactoryII:makeNECurvePipe(496, 139, 25, 10);
  physicsLineFactoryII:makeSWCurvePipe(535.5, 135, 25, 10);
  physicsLineFactoryII:makeNECurvePipe(534, 175, 25, 10);
  -- Valve3
  physicsLineFactoryII:makeVertPipeLine(549, 208, 10, 70);
  physicsLineFactoryII:makeSouthHorseshoePipe(573.5, 277, 25, 10);
  physicsLineFactoryII:makeNWCurvePipe(611, 282, 25, 10);
  -- Broken pipes are just lines
  physicsLineFactoryII:makePhysicsLine(610, 267, 662, 267);
  -- Slant
  physicsLineFactoryII:makePhysicsLine(559, 196, 622, 257);
  physicsLineFactoryII:makeNorthTPipe(667, 247, 10, 10);
  -- TurboPump4
  -- Valve4
  physicsLineFactoryII:makeSECurvePipe(752, 244.5, 25, 10);
  physicsLineFactoryII:makeSWCurvePipe(757, 269, 25, 12);
  -- TurboPump5
  -- TurboPump6
  physicsLineFactoryII:makeVertPipeLine(767, 116, 10, 90);
  -- Diagonal bg pipe; two exaggerated line angles to work
  physicsLineFactoryII:makePhysicsLine(767, 116, 813, 85);
  physicsLineFactoryII:makePhysicsLine(797, 94, 816, 94);
  physicsLineFactoryII:makeNECurvePipe(814, 119, 25, 10);
  physicsLineFactoryII:makeSWCurvePipe(853.5, 115, 25, 10);
  physicsLineFactoryII:makeHorizPipeLine(852, 129.5, 35, 10);
  physicsLineFactoryII:makeSouthTPipe(896, 149.5, 10, 10);
  physicsLineFactoryII:makeHorizPipeLine(798, 284, 85, 10);  
  physicsLineFactoryII:makeSECurvePipe(882, 269.5, 25, 10);
  -- TurboPump7
  -- Valve5
  physicsLineFactoryII:makeVertPipeLine(896, 185, 10, 60);
    
  -- Reservoir Tank
  physicsLineFactoryII:makePhysicsLine(916,140,916,170);
  physicsLineFactoryII:makePhysicsLine(916,170,951,170);
  physicsLineFactoryII:makePhysicsLine(951,100,951,170);

  -- Boundaries
  physicsLineFactoryII:makePhysicsLine(-1000, bg.height, 10000, bg.height, 'oob');

  -- Create HUD
  createHUD();
  function bg:tap( event )
    
    -- For placing items; prints absolute x,y coordinates
    print("X:" .. event.x - cameraX);
    print("Y:" .. event.y - cameraY.. "\n");

    if (event.numTaps >= 2 ) then
      doubleTapped();
    end
  end

  bg:addEventListener( "tap" );
  Runtime:addEventListener("touch", reportTouch);

  --checking particles inside the tank
  tankTimer = timer.performWithDelay(200,
  function()
      if(won or destroyed or generators==nil or generators[1]==nil or not generators[1].alive) then return; end
    updateWaterSoundVolume();
    if(getParticlesInTankRatio(916,140,951,170) >= requiredWater) then winLevel(); 
    elseif(loseLevel ~= nil and generators[1].max > 0 and generators[1].deadParticles/generators[1].max > (1-requiredWater)) then loseLevel('water'); end
  end,
  0);
end

local function destroyLevel()
  if(destroyed) then return; end
  audio.stop(2);
  destroyed = true;
  physicsLineFactoryII:kill();
  physicsLineFactoryII = nil;
  
  bg:removeEventListener( "tap" );
  bg:removeSelf();
  bg = nil;
    
  pipes:removeSelf();
  pipes=nil;

  for i=1,#valves do
    valves[i]:kill();
    valves[i]=nil;
  end

  for i=1,#pumps do
    pumps[i]:kill();
    pumps[i]=nil;
  end
  
  for i=1,#generators do
    generators[i]:kill();
    generators[i]=nil;
  end
  
  for i=1,#layers do
    local l = layers[i];
    for j=1,#l do
      if(l[j] ~= nil) then
        l[j]:removeSelf();
        l[j] = nil;
      end
    end
  end
  
  timer.cancel(tankTimer);
  tankTimer = nil;
  
  timer.cancel(stageTimer);
  stageTimer = nil;
  
  Runtime:removeEventListener("touch", reportTouch);
  killHUD();
  resetCamera();
  
  physics:stop();
  physics= nil;
end

local function doubleTapped()
  if mode == "hybrid" then
    mode = "normal";
    physics.setDrawMode("normal");
  elseif mode == "normal" then
    mode = "hybrid";
    physics.setDrawMode("hybrid");
  end
  restart();
end
 
-- Called when the scene's view does not exist:
function scene:createScene( event )
  createLevel();
end
 
-- Called BEFORE scene has moved onscreen:
function scene:willEnterScene( event )
  local createKioskCameraTween = function(n, t, dx,dy,sx,sy)
    local x0 = cameraX+sx;
    local y0 = cameraY+sy;
    local mx = dx/n;
    local my = dy/n;
    for i=1,n do
      pushKioskFrame(function()
        placeCamera(x0+(mx*i),y0+(my*i));
        keepHUDPlaced();
      end, t/n, 0);
    end
  end;

  if(kiosk.labels["entering_level_3"] == nil) then
    pushKioskFrame(function() end, 0, 0, "entering_level_3");
    
    pushKioskFrame(function()
      generators[1]:switch();
    end, 1000, 300);
    
    createKioskCameraTween(50,100,-80,0,0,0);
    
    --Die purposely
    
    pushKioskFrame(function()
      restart();
    end, 12000, 1000);
    
    pushKioskFrame(function()
      generators[1]:switch();
    end, 1000, 300);
    
    createKioskCameraTween(50,100,-80,0,0,0);
    
    pushKioskFrame(function()
      valves[1]:switch();
    end, 0, 0);
    
    createKioskCameraTween(40,100,-100,0,-80,0);
    
    pushKioskFrame(function()
      valves[2]:switch();
    end, 0, 0);
    
    createKioskCameraTween(80,100,-160,0,-180,0);
    
    pushKioskFrame(function()
      valves[4]:switch();
    end, 0, 0);
    
    createKioskCameraTween(30,100,-80,0,-340,0);
    
    pushKioskFrame(function()
      valves[5]:switch();
    end, 0, 0);
    
    createKioskCameraTween(30,100,-60,0,-420,0);
    
    pushKioskFrame(function()
      
    end, 0, 14000);
    
  end
end
 
-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
  audio.stop(3);

 loseLevel = function(cause)
    destroyLevel();

    print('You lost!');
    loseScreen.loseOverlay = display.newImage('images/lose_'..cause..'.png',0,0);
    loseScreen.loseOverlay.width = metrics.size.width;
    loseScreen.loseOverlay.height = metrics.size.height;
    loseScreen.loseOverlay.x = -cameraX + loseScreen.loseOverlay.width/2;
    loseScreen.loseOverlay.y = -cameraY + loseScreen.loseOverlay.height/2;
    layers[#layers]:insert(loseScreen.loseOverlay);
    
    loseScreen.retry = display.newRect(0,0,120,50);
    loseScreen.retry:setFillColor(0,0,0);
    layers[1]:insert(loseScreen.retry);
    loseScreen.retry.x = loseScreen.loseOverlay.x-190;
    loseScreen.retry.y = loseScreen.loseOverlay.y+135;
    loseScreen.retry:addEventListener("touch", function(e)
      if(e.phase == 'began' and not kiosk.on) then
        restart();
      end
    end);   
    
    loseScreen.exit = display.newRect(0,0,220,50);
    loseScreen.exit:setFillColor(0,0,0);
    layers[1]:insert(loseScreen.exit);
    loseScreen.exit.x = loseScreen.loseOverlay.x+130;
    loseScreen.exit.y = loseScreen.loseOverlay.y+135;
    loseScreen.exit:addEventListener("touch", function(e)
      if(e.phase == 'began' and not kiosk.on) then
        storyboard.gotoScene('assets.map_screen');
      end
    end);
  end
        
end 
 
-- Called when scene is about to move offscreen:
function scene:exitScene( event )
  audio.stop(3);
        
end
 
-- Called AFTER scene has finished moving offscreen:
function scene:didExitScene( event )
  -- Remove previous scene's view
  storyboard.purgeScene( "assets.stages.stage3" );
        
end
 
 
-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )
  if(not destroyed) then destroyLevel(); end
  
  if(loseScreen.loseOverlay~=nil) then display.remove(loseScreen.loseOverlay); end
  if(loseScreen.retry~=nil) then display.remove(loseScreen.retry); end
  if(loseScreen.exit~=nil) then display.remove(loseScreen.exit); end
  loseScreen = {};
end
 
-- Called if/when overlay scene is displayed via storyboard.showOverlay()
function scene:overlayBegan( event )
        local overlay_scene = event.sceneName  -- overlay scene name
        
        -----------------------------------------------------------------------------
                
        --      This event requires build 2012.797 or later.
        
        -----------------------------------------------------------------------------
        
end
 
-- Called if/when overlay scene is hidden/removed via storyboard.hideOverlay()
function scene:overlayEnded( event )
        local overlay_scene = event.sceneName  -- overlay scene name
 
        -----------------------------------------------------------------------------
                
        --      This event requires build 2012.797 or later.
        
        -----------------------------------------------------------------------------
        
end

function loop ( event )

end
 
 
---------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------
 
-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "createScene", scene )
 
-- "willEnterScene" event is dispatched before scene transition begins
scene:addEventListener( "willEnterScene", scene )
 
-- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener( "enterScene", scene )
 
-- "exitScene" event is dispatched before next scene's transition begins
scene:addEventListener( "exitScene", scene )
 
-- "didExitScene" event is dispatched after scene has finished transitioning out
scene:addEventListener( "didExitScene", scene )
 
-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- storyboard.purgeScene() or storyboard.removeScene().
scene:addEventListener( "destroyScene", scene )
 
-- "overlayBegan" event is dispatched when an overlay scene is shown
scene:addEventListener( "overlayBegan", scene )
 
-- "overlayEnded" event is dispatched when an overlay scene is hidden/removed
scene:addEventListener( "overlayEnded", scene )

-- Main game loop
Runtime:addEventListener( "enterFrame", loop );

--[[
-- Collision detection
local function onCollision( event )
  if(event.object1.tag == nil or event.object2.tag == nil) then return; end

  -- Water removal after they hit the bottom of the screen.
  if ( event.phase == "began" ) then 
    if(event.object1.tag=='water' and event.object2.tag=='oob' ) then
      print('C: ' .. event.object1.x .. ', ' .. event.object1.y );
    elseif( event.object2.tag=='water' and event.object1.tag=='oob') then
      print( 'C: ' .. event.object2.x .. ', ' .. event.object2.y );
    end
  end
end
--]]

---------------------------------------------------------------------------------
 
return scene;