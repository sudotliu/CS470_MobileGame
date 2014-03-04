-----------------------------------------------------------------------------------------
-- Group name: Aqueduct Adventures
-- File name: stage1.lua
-- Purpose: The code for stage 1 of the game.
-- Group 5:
--    Terry Liu
--    Raymond Ononiwu
--    William Thomas
-- Description: 
--    This is stage 1 of the game, which creates the initial opening, loads the
--    background and pipe images, initiates the game engine, etc.
-----------------------------------------------------------------------------------------
local level = 1;

local physics = nil;
local scene = storyboard.newScene();
local interactable = false;
local destroyed = false;

--Images
local historyBackdrop = nil;
local bg = nil;
local pipes = nil;
local blankImg = nil;

local physicsLineFactory = nil;
local valves = {};
local generators = {};
local hud = nil;

local lakeBg = nil;
local shrinker = nil;

local toolOverlay = nil;

--Timers
local tankTimer = nil;
local lakeTimer = nil;
local stageTimer = nil;

--For camera movement
local cameraBounds = {
  minX = -240,
  maxX = 0,
  minY = -105,
  maxY = 24,
};

local totalWater = nil;
local requiredWater = nil;

local levelTime = nil;
local score = nil;
local dt = nil;
 local loseScreen = {};
 local won = false;
 
---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------
local loseLevel = nil;

local function restart()
  storyboard.gotoScene( "assets.stages.stage1", "crossFade", 250 );
end;

local function winLevel()
  won = true;
  if(score > storage.highScores[level]) then
    storage.highScores[level] = score;
    showNewHighScore = true;
  end
  interactable = false;
  if(storage.upToStage<(level+1)) then storage.upToStage = (level+1) end;
  storyboard.gotoScene( "assets.exit.exit1_1", "crossFade", 250 );
end

local function doubleTapped()
end;

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

--Draggable camera
local fx = nil;
local fy = nil;
local function reportTouch(e)
  if(kiosk.on) then return; end
    if(e.phase == 'began' or fx==nil or fy==nil) then 
      fx = cameraX;
      fy = cameraY;
      
      print(e.x-fx .. ', '..e.y-fy);
      
    elseif(e.phase == 'moved') then
      if(not interactable) then return; end
      local nx = (e.x-e.xStart)+fx;     
      if(nx>cameraBounds.maxX) then nx = cameraBounds.maxX;
      elseif(nx<cameraBounds.minX) then nx = cameraBounds.minX;
      end
      
      local ny = (e.y-e.yStart)+fy;      
      if(ny<cameraBounds.minY) then ny = cameraBounds.minY;
      elseif(ny>cameraBounds.maxY) then ny = cameraBounds.maxY;
      end
      
      placeCamera(nx,ny);
      
      keepHUDPlaced();
    else
      fx = nil;
      fy = nil;
    end
end
 
local function createLevel()  
  won=false;
  loseScreen = {};
  playSoundEffect(sounds.water, -1, 2);
  audio.setVolume(0,{channel=2});
  
  destroyed = false;
  resetCamera();
  levelTime = 30;
  score = levelTime*1000;
  dt = 0.1;
  requiredWater = 0.8;

  physics = require("physics");

  physics.start();
  if(debugMode) then physics.setDrawMode("hybrid");
  else physics.setDrawMode("normal");
  end
  physics.setGravity(0,9.81);
  
  physicsLineFactory = PhysicsLineFactoryII:new(physics,layers[6]);
  
  --Loading bg
  bg = display.newImage("images/bg/stages/1.png");
  local r1=bg.width/bg.height;
  bg.width = 720;
  bg.height = bg.width/r1;
  bg.x = 360;
  bg.y = 200;  
  layers[3]:insert(bg);
  
  --Shrinker block for lake.
  lakeBg = display.newRect(-5,172,50,21);
  lakeBg:setFillColor(74,58,41);
  layers[1]:insert(lakeBg);
  
  --(x,y,width,height,color,group,initialFillRatio)
  shrinker = ShrinkerBlock:new(-5,172,50,21,{r=151,g=230,b=246},layers[2],1)
  shrinker:draw();
  
  --Loading pipes
  pipes = display.newImage("images/pipes/stages/1.png");
  pipes.width=bg.width;
  pipes.height=bg.height;
  pipes.x=bg.x;
  pipes.y=bg.y;
  layers[6]:insert(pipes);
  
  --Valves
  valves[1]= Valve:new(186, 183.75, 2.6,true, layers[6], false, physics);
  valves[2]= Valve:new(354, 225.75, 2.6,true, layers[6], false, physics);
  
  --Pipes
  physicsLineFactory:makeHorizPipeLine(81,180.5,82,10);
  physicsLineFactory:makeHorizPipeLine(252,222.75,80,10);   
  physicsLineFactory:makeVertPipeLine(349,233,10,200);  
  physicsLineFactory:makeHorizPipeLine(420,264,168,10);
  physicsLineFactory:makeHorizPipeLine(505,306,80,10);
  physicsLineFactory:makeHorizPipeLine(505,347,120,10);
  
  physicsLineFactory:makePhysicsLine(81,181,81,200);
  physicsLineFactory:makePhysicsLine(51,190.5,71,190.5);
  physicsLineFactory:makePhysicsLine(179,190.5,200,190.5);
  physicsLineFactory:makePhysicsLine(-20,151,36,191);
  physicsLineFactory:makePhysicsLine(36,0,36,180);
  physicsLineFactory:makePhysicsLine(-20,0,-20,151);
  physicsLineFactory:makePhysicsLine(587,373,640,373);
  physicsLineFactory:makePhysicsLine(652,373,704,373);
  physicsLineFactory:makePhysicsLine(587,420,704,420);
  physicsLineFactory:makePhysicsLine(587,373,587,420);
  physicsLineFactory:makePhysicsLine(704,373,704,420);
  
  physicsLineFactory:makeNECurvePipe(209, 206.5,27,11);
  physicsLineFactory:makeSWCurvePipe(252, 206,27,11);
  physicsLineFactory:makeNECurvePipe(377, 248.5,27,11);
  physicsLineFactory:makeSWCurvePipe(420, 247.5,27,11);
  physicsLineFactory:makeNECurvePipe(624, 373,26,10);
  
  physicsLineFactory:makeEastHorseshoePipe(584,288,28,10);
  physicsLineFactory:makeWestHorseshoePipe(507,334,27.5,10);
  
  --Boundaries
  physicsLineFactory:makePhysicsLine(-1000,bg.height,10000, bg.height, 'oob');
  
   --Generators
  -- Parameters: x, y, xF, yF, r, startUp, physics, group, interval, maxP
  generators[1] = GeneratorValveII:new(59, 183.75, 250, 0, 2.6, true, physics, layers[5], layers[4], 50, 250);
  
  totalWater = generators[1].max;
  
  function bg:tap( event )
    if (event.numTaps >= 2 ) then
      doubleTapped();
    end
  end
  
  createHUD();

  bg:addEventListener( "tap" );  

  Runtime:addEventListener("touch", reportTouch);
  
  --checking particles inside the tank
  tankTimer = timer.performWithDelay(200,
    function()
      if(won or destroyed or generators==nil or generators[1]==nil or not generators[1].alive) then return; end
      updateWaterSoundVolume();
      if(getParticlesInTankRatio(586,376,705,422) >= requiredWater) then winLevel(); end   
      if(loseLevel ~= nil and generators[1].max > 0 and generators[1].deadParticles/generators[1].max > (1-requiredWater)) then loseLevel('water'); end
    end,
    0);
    
  --Resizing the lake
  lakeTimer = timer.performWithDelay(20,
    function()
      if(generators[1].count<generators[1].max or shrinker.ratio>0) then
        shrinker:updateFillRatio(1-(generators[1].count/generators[1].max));
        shrinker:draw();    
      else
        timer.cancel(lakeTimer);
        shrinker:kill();
      end
    end,
    0);
  
  --score timer
  stageTimer = timer.performWithDelay(1000*dt,
    function()
      if(storage.highScores[level]==0) then return; end
      if(levelTime <=0) then loseLevel('time'); 
      else
        levelTime = levelTime-dt;
        if(levelTime < 0) then levelTime = 0; end
        local p = 1.073997;
        local bonus = 2-(generators[1].count/generators[1].max);
        score = math.ceil(levelTime*1000*p*bonus);
        hud.text.text = math.ceil(levelTime);
      end
    end,
    0);
  
  interactable = true;

  -- Showing tool overlay when it's the first play
  local function listener(event)
    if(kiosk.on) then return; end
    storage.highScores[level] = 1;
    toolOverlay:removeSelf();
    toolOverlay = nil;
    restart();
  end

  if (storage.highScores[level] == 0) then
    toolOverlay = display.newImage('images/screens/tool_overlays/valve.png',0,0);
    toolOverlay.width = metrics.size.width;
    toolOverlay.height = metrics.size.height;
    toolOverlay.x = -cameraX + toolOverlay.width/2;
    toolOverlay.y = -cameraY + toolOverlay.height/2;
    layers[#layers]:insert(toolOverlay);

    toolOverlay:addEventListener("touch", listener)
  end

end

local function destroyLevel()
  if(destroyed) then return; end
  destroyed = true;
  
  print('DESTROYED');
  
  display.remove(toolOverlay);
  toolOverlay = nil;
    
  audio.stop(2);
  interactable = false;
  display.remove(lakeBg);
  lakeBg = nil;
  shrinker:kill();
  shrinker=nil;
  
  physicsLineFactory:kill();
  physicsLineFactory = nil;
  
  bg:removeEventListener( "tap" );
  bg:removeSelf();
  bg = nil;
  
  pipes:removeSelf();
  pipes=nil;

  for i=1,#valves do
    valves[i]:kill();
    valves[i]=nil;
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
  
  timer.cancel(lakeTimer);
  lakeTimer = nil;
  
  timer.cancel(stageTimer);
  stageTimer = nil;
  
  Runtime:removeEventListener("touch", reportTouch);
  
  killHUD();
  resetCamera();
  
  physics:stop();
  physics = nil;
  
  wipeAllLayers();
  
  collectgarbage("collect");
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

  if(kiosk.labels["entering_level_1"] == nil) then
    pushKioskFrame(function() end, 0, 0, "entering_level_1");
    
    pushKioskFrame(function()
      storage.highScores[level] = 1;
      toolOverlay:removeSelf();
      toolOverlay = nil;
      restart();
    end, 5000, 0, "starting_level_1");
    
    pushKioskFrame(function()
      generators[1]:switch();
    end, 1000, 0);
    
    createKioskCameraTween(100,500,-100,-50,0,0);
    
    pushKioskFrame(function()
      valves[1]:switch();
    end, 100, 0);
    
    createKioskCameraTween(100,500,-140,-50,-100,-50);
    
    pushKioskFrame(function()
      
    end, 0, 5000);
    
    pushKioskFrame(function()
      restart();
    end, 1000, 1000);
    
    pushKioskFrame(function()
      generators[1]:switch();
    end, 1000, 0);
    
    createKioskCameraTween(100,500,-100,-50,0,0);
    
    pushKioskFrame(function()
      valves[1]:switch();
    end, 100, 0);
    
    pushKioskFrame(function()
      valves[2]:switch();
    end, 1000, 0);
    
    createKioskCameraTween(100,500,-140,-50,-100,-50);
    
    pushKioskFrame(function()
      
    end, 0, 16000);
    
  end
        
end
 
-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
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
        
end
 
-- Called AFTER scene has finished moving offscreen:
function scene:didExitScene( event )
  storyboard.purgeScene( "assets.stages.stage1" );
        
end
 
 
-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )
  loseLevel = nil;
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




--Water removal after they hit the bottom of the screen.
local function onCollision( event )
  if(event.object1.tag == nil or event.object2.tag == nil) then return; end
  if ( event.phase == "began" ) then 
    if(event.object1.tag=='water' and event.object2.tag=='oob' ) then
      print('C: ' .. event.object1.x .. ', ' .. event.object1.y );
    elseif( event.object2.tag=='water' and event.object1.tag=='oob') then
      print( 'C: ' .. event.object2.x .. ', ' .. event.object2.y );
    end
  end
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
 
---------------------------------------------------------------------------------
 
return scene;