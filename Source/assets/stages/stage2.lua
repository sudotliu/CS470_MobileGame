-----------------------------------------------------------------------------------------
-- Group name: Aqueduct Adventures
-- File name: stage2.lua
-- Purpose: The code for stage 2 of the game.
-- Group 5:
--    Terry Liu
--    Raymond Ononiwu
--    William Thomas
-- Description: 
--    This is stage 2 of the game: Long Valley.
-----------------------------------------------------------------------------------------

local level = 2;

local scene = storyboard.newScene();
local loseLevel = nil;

require("assets.displaysetup");


local mode = "normal";
local destroyed = false;

-- Images
local bg = nil;
local pipes = nil;

local lakeBg = nil;
local shrinker = nil;

local toolOverlay = nil;

--Timers
local tankTimer = nil;
local lakeTimer = nil;

-- Classes
local physicsLineFactoryII = nil;
local valves = {};
local generators = {};
local pumps = {};

-- HUD
local hud = nil;

-- Water win requirement
local totalWater = nil;
local requiredWater = nil;

local stageTimer = nil;
local levelTime = nil;
local score = nil;
local dt = nil;

local loseScreen = {};

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

local won = false;
 
---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

---[[ WILL'S CODE
local function restart()
  storyboard.gotoScene( "assets.stages.stage2", "crossFade", 250 );
  
end;

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
  
local function winLevel()
  won=true;
  if(score > storage.highScores[level]) then
    storage.highScores[level] = score;
    showNewHighScore = true;
  end
  
  if(storage.upToStage<(level+1)) then storage.upToStage = (level+1) end;
  storyboard.gotoScene( "assets.exit.exit1_2", "crossFade", 250 );
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
  loseScreen = {};
  playSoundEffect(sounds.water, -1, 2);
  destroyed=false;
  resetCamera();
  levelTime = 45;
  score = levelTime*1000;
  dt = 0.1;
  requiredWater = 0.6;
  if(kiosk.on) then requiredWater = 0.3; end
  
  physics = require("physics");

  physics.start();
  if(debugMode) then physics.setDrawMode("hybrid");
  else physics.setDrawMode("normal");
  end
  physics.setGravity(0, 7);

  physicsLineFactoryII = PhysicsLineFactoryII:new(physics,layers[6]);
  
  -- Loading bg
  bg = display.newImage("images/bg/stages/1_2_bg.png", true);
  --bg.width = levelWidth;
  --bg.height = levelHeight;
  bg.width = 480*3;
  bg.height = 320*2;

  bg.x = bg.width / 2;
  bg.y = bg.height / 2;
  layers[3]:insert(bg);

  -- Loading pipe image layer
  pipes = display.newImage("images/pipes/stages/1_2_pipes.png", true);
  pipes.width = bg.width;
  pipes.height = bg.height;
  pipes.x = bg.x;
  pipes.y = bg.y;
  layers[6]:insert(pipes);

  -- *****IMPORTANT***** 
  -- Pipe Parts are all shifted by a Y-offset to match background
  -- Also be sure to include this offset in the reservoir boundary for winning conditions
  local yOff = -89;
  --Generators
  -- Parameters: x, y, xF, yF, r, startUp, physics, group, interval, maxP
  generators[1] = GeneratorValve:new(103, 342.5+yOff, 250, 0, 2, true, physics, layers[4], 60, 300);
  
  totalWater = generators[1].max;
  
  -- Valves
  -- Replaced first valve with GeneratorValve above
  valves[1] = ValveII:new(514.5, 406.5+yOff, 2, true, layers[6], false);
  valves[2] = ValveII:new(1026.5, 575+yOff, 2, true, layers[6], false);
  valves[3] = ValveII:new(747, 411+yOff, 2, true, layers[6], true);

  -- Pumps
  pumps[1] = TurboPump:new(218.5, 456+yOff, 2, physics, layers[6], false, false);
  pumps[1]:start();
  pumps[2] = TurboPump:new(744.5, 575+yOff, 2, physics, layers[6], false, false);
  pumps[2]:start();
  pumps[3] = TurboPump:new(659, 637+yOff, 2, physics, layers[6], true, false);
  pumps[3]:start();
  pumps[4] = TurboPump:new(1085, 690.5+yOff, 2, physics, layers[6], true, false);
  pumps[4]:start();
  pumps[5] = TurboPump:new(1205, 590+yOff, 2, physics, layers[6], false, false);
  pumps[5]:start();

  -- Physical pipes
  -- GeneratorValve
  physicsLineFactoryII:makeHorizPipeLine(120, 338+yOff, 20, 15);
  physicsLineFactoryII:makeNECurvePipe(133, 375.5+yOff, 37, 14);
  physicsLineFactoryII:makeVertPipeLine(156, 374+yOff, 14, 115);  
  physicsLineFactoryII:makeSouthHorseshoePipe(191.5, 487+yOff, 36, 14);
  -- TurboPump1
  physicsLineFactoryII:makeVertPipeLine(211.5, 319+yOff, 14, 115);  
  physicsLineFactoryII:makeNWCurvePipe(250, 319+yOff, 39, 14);
  -- Add a horizontal line to help guide water over jump
  physicsLineFactoryII:makePhysicsLine(246, 280+yOff, 300, 280+yOff);
  physicsLineFactoryII:makeNECurvePipe(313, 320+yOff, 38, 15);
  -- Water jumps across pipes, broken pipe with rock to catch lost water
  physicsLineFactoryII:makePhysicsLine(247, 321+yOff, 336, 379+yOff);
  --physicsLineFactoryII:makeVertPipeLine(337, 319+yOff, 15, 65);  
  -- Above pipe is "broken"; use vertical line instead
  physicsLineFactoryII:makePhysicsLine(350.5, 313+yOff, 350.5, 378+yOff);
  physicsLineFactoryII:makeSWCurvePipe(373, 378+yOff, 38, 15);
  physicsLineFactoryII:makeHorizPipeLine(373, 400.5+yOff, 120, 15);
  -- Valve1
  physicsLineFactoryII:makeVertPipeLine(506, 416+yOff, 16, 20);  
  physicsLineFactoryII:makeHorizPipeLine(530, 400.5+yOff, 75, 15);
  physicsLineFactoryII:makeNECurvePipe(602, 439.5+yOff, 39, 15);
  physicsLineFactoryII:makeVertPipeLine(625.6, 435+yOff, 15, 120);  
  physicsLineFactoryII:makeSECurvePipe(603, 549.5+yOff, 38, 15);
  physicsLineFactoryII:makeWestHorseshoePipe(601, 609+yOff, 37, 15);
  physicsLineFactoryII:makeHorizPipeLine(602, 627+yOff, 115, 15);
  -- TurboPump2
  physicsLineFactoryII:makeSECurvePipe(714, 604.5+yOff, 38, 15);
  -- TurboPump3
  physicsLineFactoryII:makeVertPipeLine(737.5, 385+yOff, 15, 165);
  -- Valve2  
  physicsLineFactoryII:makeNWCurvePipe(776, 386+yOff, 39, 15);
  physicsLineFactoryII:makeHorizPipeLine(776, 347+yOff, 115, 15);
  physicsLineFactoryII:makeEastHorseshoePipe(886, 380+yOff, 37, 15);
  physicsLineFactoryII:makeWestHorseshoePipe(884, 439+yOff, 37, 15);
  physicsLineFactoryII:makeEastHorseshoePipe(886, 490+yOff, 37, 15);
  physicsLineFactoryII:makeSouthTPipe(857, 543+yOff, 17, 16);
  physicsLineFactoryII:makeWestHorseshoePipe(845, 550+yOff, 38, 15);
  physicsLineFactoryII:makeNorthTPipe(857, 552+yOff, 17, 16);
  physicsLineFactoryII:makeHorizPipeLine(890, 569+yOff, 115, 15);
  -- Valve3
  physicsLineFactoryII:makeVertPipeLine(1020, 585+yOff, 14, 75);
  physicsLineFactoryII:makeSWCurvePipe(1057, 658+yOff, 38, 15);
  -- TurboPump4
  physicsLineFactoryII:makeHorizPipeLine(1120, 681+yOff, 60, 15);
  physicsLineFactoryII:makeSECurvePipe(1173, 658.5+yOff, 39, 16);
  physicsLineFactoryII:makeVertPipeLine(1197, 548+yOff, 15, 115);
  -- TurboPump5
  physicsLineFactoryII:makeNWCurvePipe(1235.5, 548+yOff, 39, 15);
  physicsLineFactoryII:makeHorizPipeLine(1234, 509+yOff, 50, 15);
  -- Back to failure path
  physicsLineFactoryII:makeHorizPipeLine(1050, 569+yOff, 15, 15);
  physicsLineFactoryII:makeNECurvePipe(1056, 607+yOff, 38, 15);
  physicsLineFactoryII:makeSouthHorseshoePipe(1115, 607+yOff, 37, 15);
  physicsLineFactoryII:makeVertPipeLine(1135, 496+yOff, 15, 115);
  -- End failure path - incomplete; impossible to get past this point
  -- Final T-junction
  physicsLineFactoryII:makeWestTPipe(1279, 508+yOff, 16, 16);
  physicsLineFactoryII:makeVertPipeLine(1294, 568+yOff, 17, 50);
  -- Reservoir Tank
  --physicsLineFactoryII:makePhysicsLine(1223,625+yOff,1381,625+yOff);
  physicsLineFactoryII:makePhysicsLine(1223,685+yOff,1381,685+yOff);
  physicsLineFactoryII:makePhysicsLine(1223,625+yOff,1223,685+yOff);
  physicsLineFactoryII:makePhysicsLine(1381,625+yOff,1381,685+yOff);

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
    if(getParticlesInTankRatio(1223,625+yOff,1381,685+yOff) >= requiredWater) then winLevel(); 
    elseif(loseLevel ~= nil and generators[1].max > 0 and generators[1].deadParticles/generators[1].max > (1-requiredWater)) then loseLevel('water'); end
  end,
  0);
  
  --Shrinker block for lake.
  lakeBg = display.newRect(-5,245,80,21);
  lakeBg:setFillColor(106,75,39);
  layers[1]:insert(lakeBg);
  
  --(x,y,width,height,color,group,initialFillRatio)
  shrinker = ShrinkerBlock:new(-5,245,80,21,{r=181,g=246,b=248},layers[2],1)
  shrinker:draw();  
    
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
        print("Score: "..score);
        hud.text.text = math.ceil(levelTime);
      end
    end,
    0);

  -- Showing tool overlay when it's the first play
  local function listener(event)
    if(kiosk.on) then return; end
    storage.highScores[level] = 1;
    toolOverlay:removeSelf();
    toolOverlay = nil;
    restart();
  end

  if (storage.highScores[level] == 0) then
    toolOverlay = display.newImage('images/screens/tool_overlays/turbopump.png',0,0);
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
  display.remove(toolOverlay);
  toolOverlay = nil;
  
  audio.stop(2);
  destroyed = true;
  display.remove(lakeBg);
  lakeBg = nil;
  shrinker:kill();
  shrinker=nil;
  
  timer.cancel(lakeTimer);
  lakeTimer = nil;
  
  timer.cancel(stageTimer);
  stageTimer = nil;
  
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
  
  Runtime:removeEventListener("touch", reportTouch);
  killHUD();
  resetCamera();
  
  physics:stop();
  physics= nil;
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

  if(kiosk.labels["entering_level_2"] == nil) then
    pushKioskFrame(function() end, 0, 0, "entering_level_2");
    
    pushKioskFrame(function()
      storage.highScores[level] = 1;
      toolOverlay:removeSelf();
      toolOverlay = nil;
      restart();
    end, 5000, 0, "starting_level_2");
    
    pushKioskFrame(function()
      generators[1]:switch();
    end, 1000, 0);
    
    createKioskCameraTween(100,500,-100,-150,0,0);
    
    pushKioskFrame(function() end, 10000, 0);
    
    --Lose purpisely 
    
    pushKioskFrame(function()
      restart();
    end, 1000, 1000);
    
    pushKioskFrame(function()
      generators[1]:switch();
    end, 1000, 0);
    
    createKioskCameraTween(100,500,-100,-150,0,0);
    
    pushKioskFrame(function()
      valves[1]:switch();
    end, 500, 0);
    
    createKioskCameraTween(70,200,-300,-120,-100,-150);
    
    pushKioskFrame(function()
      valves[3]:switch();
    end, 100, 0);
    
    createKioskCameraTween(100,300,-400,50,-400,-270);
    
    pushKioskFrame(function() end, 1000, 0);
    
    createKioskCameraTween(100,300,-150,-100,-800,-220);
    
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
  storyboard.purgeScene( "assets.stages.stage2" );
        
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