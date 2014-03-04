-----------------------------------------------------------------------------------------
-- Group name: Aqueduct Adventures
-- File name: stage4.lua
-- Purpose: The code for stage 4 of the game.
-- Group 5:
--    Terry Liu
--    Raymond Ononiwu
--    William Thomas
-- Description: 
--    This is stage 4. That is, Level 2, stage 2.
-----------------------------------------------------------------------------------------
local scene = storyboard.newScene();
local level = 4;

require("assets.displaysetup");

local mode = "normal";

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
local requiredWater = 0.75;

-- Screen size factors - used to scale background image size to screen
local bgWidthFactor = 3;
local bgHeightFactor = 2;
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
local destroyed=true;
 local loseScreen = {};
 local won = false;
 
---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

local function restart()
  storyboard.gotoScene( "assets.stages.stage4", "crossFade", 250 );
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
  
  storyboard.gotoScene( "assets.exit.exit2_2", "crossFade", 250 );
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
loseScreen=  {};
  destroyed=false;
  playSoundEffect(sounds.water, -1, 2);
  resetCamera();
  physics = require("physics");

  levelTime = 60;
  score = levelTime*1000;
  dt = 0.1;
  
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
  bg = display.newImage("images/bg/stages/2_2_bg.png", true);
  --bg.width = levelWidth;
  --bg.height = levelHeight;
  bg.width = 480*3;
  bg.height = 320*2;

  bg.x = bg.width / 2;
  bg.y = bg.height / 2;
  layers[1]:insert(bg);

  -- Loading pipe image layer
  pipes = display.newImage("images/pipes/stages/2_2_pipes.png", true);
  pipes.width = bg.width;
  pipes.height = bg.height;
  pipes.x = bg.x;
  pipes.y = bg.y;
  layers[4]:insert(pipes);

  --Generators
  -- Parameters: x, y, xF, yF, r, startUp, physics, group, interval, maxP
  generators[1] = GeneratorValveSmall:new(20, 208, 250, 0, 2, true, physics, layers[2], 50, 300);
  totalWater = generators[1].max;

  -- Valves
  -- Replaced first valve with GeneratorValveSmall above
  -- boolean values are for "turned" and "right"
  valves[1] = ValveII:new(740, 316, 2, true, layers[4], true);
  valves[2] = ValveII:new(968, 479.5, 2, true, layers[4], false);
  valves[3] = ValveII:new(1267, 435, 2, true, layers[4], true);

  -- Pumps
  pumps[1] = TurboPump:new(263, 423.5, 2, physics, layers[4], true, false);
  pumps[1]:start();
  pumps[2] = TurboPump:new(340, 333, 2, physics, layers[4], false, false);
  pumps[2]:start();
  pumps[3] = TurboPump:new(654, 535, 2, physics, layers[4], true, false);
  pumps[3]:start();
  pumps[4] = TurboPump:new(739, 475, 2, physics, layers[4], false, false);
  pumps[4]:start();
  pumps[5] = TurboPump:new(1201, 602, 1.7, physics, layers[4], true, false);
  pumps[5]:start();
  pumps[6] = TurboPump:new(1265, 540, 2, physics, layers[4], false, false);
  pumps[6]:start();


  -- Physical pipes
  -- GeneratorValveSmall
  physicsLineFactoryII:makeHorizPipeLine(40, 202, 115, 15);
  physicsLineFactoryII:makeNECurvePipe(148, 242, 40, 15);
  physicsLineFactoryII:makeHorizPipeLine(40, 202, 115, 15);
  physicsLineFactoryII:makeVertPipeLine(173, 242, 15, 115);
  physicsLineFactoryII:makeEastTPipe(203, 362, 15, 15);
  physicsLineFactoryII:makeSWCurvePipe(212.5, 389, 40, 15);
  physicsLineFactoryII:makeHorizPipeLine(212, 413.75, 100, 15);
  -- TurboPump1
  physicsLineFactoryII:makeSECurvePipe(308, 389, 40, 15);
  physicsLineFactoryII:makeVertPipeLine(332.5, 280, 15, 115);
  -- TurboPump2
  physicsLineFactoryII:makeNorthHorseshoePipe(370, 282, 38, 15);
  physicsLineFactoryII:makeSWCurvePipe(429, 281, 40, 15);
  physicsLineFactoryII:makeNorthTPipe(448.5, 290.5, 15, 15);
  physicsLineFactoryII:makeHorizPipeLine(428, 305.75, 215, 15);
  physicsLineFactoryII:makeEastHorseshoePipe(637, 339, 37, 15);
  physicsLineFactoryII:makeHorizPipeLine(593, 360.75, 45, 15);
  physicsLineFactoryII:makeWestHorseshoePipe(595, 397.75, 37, 15);
  physicsLineFactoryII:makeEastHorseshoePipe(597, 449, 38, 15);
  physicsLineFactoryII:makeWestHorseshoePipe(595, 508.5, 37, 15);
  physicsLineFactoryII:makeHorizPipeLine(598, 526, 110, 15);
  -- TurboPump3
  physicsLineFactoryII:makeSECurvePipe(706, 501.5, 40, 15);
  -- TurboPump4
  physicsLineFactoryII:makeVertPipeLine(731, 280, 15, 170);
  -- Valve1
  physicsLineFactoryII:makeNWCurvePipe(771, 285, 40, 15);
  physicsLineFactoryII:makeHorizPipeLine(768, 245, 115, 15);
  physicsLineFactoryII:makeEastHorseshoePipe(880, 278, 37, 15);
  physicsLineFactoryII:makeNWCurvePipe(881, 339.5, 40, 15);
  physicsLineFactoryII:makeVertPipeLine(841.5, 337, 15, 115);
  physicsLineFactoryII:makeSWCurvePipe(881, 449, 40, 15);
  physicsLineFactoryII:makeHorizPipeLine(881, 473.5, 230, 15);
  -- Valve2
  physicsLineFactoryII:makeNECurvePipe(1107, 513.5, 40, 15);
  physicsLineFactoryII:makeVertPipeLine(1132, 511, 15, 65);
  physicsLineFactoryII:makeSWCurvePipe(1171, 568, 40, 15);
  -- TurboPump5
  physicsLineFactoryII:makeSECurvePipe(1236, 570.5, 38, 16);
  physicsLineFactoryII:makeVertPipeLine(1257, 403, 15, 180);
  -- TurboPump6
  -- Valve3
  physicsLineFactoryII:makeNorthHorseshoePipe(1294, 403, 37, 15);
  physicsLineFactoryII:makeVertPipeLine(1312, 403, 15, 110);
  physicsLineFactoryII:makeSWCurvePipe(1351.5, 512, 40, 15);
  physicsLineFactoryII:makeHorizPipeLine(1346, 536.5, 10, 15);    

  -- Reservoir Tank
  physicsLineFactoryII:makePhysicsLine(1355,553,1355,622);
  physicsLineFactoryII:makePhysicsLine(1355,622,1417,622);
  physicsLineFactoryII:makePhysicsLine(1417,453,1417,622);

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
    if(getParticlesInTankRatio(1355,453,1417,625) >= requiredWater) then winLevel(); 
    elseif(loseLevel ~= nil and generators[1].max > 0 and generators[1].deadParticles/generators[1].max > (1-requiredWater)) then loseLevel('water'); end
  end,
  0);
end

local function destroyLevel()
  if(destroyed) then return; end
  destroyed=true
  audio.stop(2);
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

  if(kiosk.labels["entering_level_4"] == nil) then
    pushKioskFrame(function() end, 0, 0, "entering_level_4");
    
    createKioskCameraTween(50,100,0,-100,0,0);
    
    pushKioskFrame(function()
      generators[1]:switch();
    end, 0, 300);
    
    createKioskCameraTween(50,100,-80,-50,0,-100);
    
    pushKioskFrame(function()
      valves[1]:switch();
    end, 0, 0);
    
    createKioskCameraTween(50,100,-100,0,-80,-150);
    
    pushKioskFrame(function()
      valves[2]:switch();
    end, 0, 0);
    
    createKioskCameraTween(90,100,-160,-80,-180,-150);
    
    createKioskCameraTween(120,100,-300,0,-340,-230);
    
    pushKioskFrame(function()
      valves[3]:switch();
    end, 0, 0);
    
    createKioskCameraTween(120,100,-310,-90,-640,-230);
    
    pushKioskFrame(function()
      
    end, 0, 17000);
    
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
  storyboard.purgeScene( "assets.stages.stage4" );
        
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