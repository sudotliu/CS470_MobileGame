-----------------------------------------------------------------------------------------
-- Group name: Aqueduct Adventures
-- File name: map_screen.lua
-- Purpose: The code for the main map.
-- Group 5:
--    Terry Liu
--    Raymond Ononiwu
--    William Thomas
-- Description: 
--    This is map screen for the game, which leads to all of the levels and stages.
-----------------------------------------------------------------------------------------
local scene = storyboard.newScene();

local cameraQueue = nil;

--Images
local bg = nil;
local hudUp = false;
local hud = nil;

local levels = nil;
local focusedLevel = 1;

local exitButton = nil;

--Timers
local cameraTimer = nil;
local pullReady = true;

--For camera movement
local animating = false;
local fingerDown = false;

local destroyed = true;
 
---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------
local function magnitude(x,y)
  return math.sqrt((x*x) + (y*y));
end

local function positionHud()
  if(hudUp) then
    hud.x = hud.bg.width/2;
    hud.y = hud.bg.height/2-cameraY;
    
    hud.bg.x = hud.x;
    hud.bg.y = hud.y; 
    
    hud.lht.x = hud.x - 190;
    hud.lht.y = hud.y + 135;
    
    hud.rht.x = hud.x + 150;
    hud.rht.y = hud.y + 135;
    
    hud.hs.x = hud.x+75;
    hud.hs.y = hud.y-76;
  end
end

local function updateCamera()
  if(animating) then    
    atQueue = math.abs(-cameraQueue.y-cameraY) < 1;
    if(atQueue) then
      animating=false;
      placeCamera(cameraX,-cameraQueue.y);    
      if(not fingerDown) then pullReady = true; print('wefwefwefwefwfefew');end
    else      
      placeCamera(cameraX,cameraY+ (-cameraQueue.y-cameraY)/4);
    end
  end
  
  if(hud.bg ~= nil) then hud.bg.y = cameraY; end  
  
  exitButton.x = -cameraX+metrics.size.width-20;
  exitButton.y = -cameraY+20;
  
  
  positionHud();
end


local function startLevel(level)
  storyboard.gotoScene( levels[level].scene, "crossFade", 250 );
end

local function removeHud()
  if(not hudUp) then return; end
  
  hudUp=false;
  hud.bg:removeSelf();
  hud.bg=nil;
  
  display.remove(hud.hs);
  hud.hs = nil;
  
  hud.lht:removeEventListener("touch", function(e)
    if(e.phase == 'began' and  hudUp) then
      removeHud();
    end
  end);
  hud.lht:removeSelf();
  hud.lht=false;
  
  hud.rht:removeEventListener("touch", function(e)
    if(e.phase == 'began' and hudUp) then
      startLevel(focusedLevel);
    end
  end);
  hud.rht:removeSelf();
  hud.rht=false;
end

local function showHud(level)
  hudUp=true;
  
  playSoundEffect(sounds.blip);
  hud.bg = display.newImage(levels[level].hudImg);
  hud.bg.width = 480;
  hud.bg.height = 320;
  layers[4]:insert(hud.bg); 
  
  hud.hs = display.newText( storage.highScores[level], 0, 0, "Bebas Neue", 25 );
  hud.hs:setReferencePoint(display.CenterLeftReferencePoint);
  layers[4]:insert(hud.hs);
  
  hud.lht = display.newRect(0,0,100,50);
  hud.lht:setFillColor(255,0,0);
  layers[1]:insert(hud.lht);
  hud.lht:addEventListener("touch", function(e)
    if(e.phase == 'began' and  hudUp) then
      playSoundEffect(sounds.dismiss);
      removeHud();
    end
  end);
  
  hud.rht = display.newRect(0,0,180,50);
  hud.rht:setFillColor(0,255,0);
  layers[1]:insert(hud.rht);
  positionHud();
  hud.rht:addEventListener("touch", function(e)
    if(e.phase == 'began' and hudUp) then  
      playSoundEffect(sounds.blip);
      startLevel(level);
    end
  end);
  
  positionHud();
end

--Draggable camera
local fy = nil;
local function reportTouch(e)
  fingerDown=true;    
  if(not animating) then 
    if(e.phase == 'began' or fy==nil) then 
      fy = cameraY;
      
      print('S: '..e.y-fy);
      
    elseif(e.phase == 'moved' and not hudUp and pullReady ) then
      local dy=e.y-e.yStart;
      print(dy);
      if(math.abs(dy) >= 30 and ((focusedLevel < #levels and dy<0) or (focusedLevel >1 and dy>0))) then        
        animating=true;
        pullReady=false;
        if(dy<0) then focusedLevel = focusedLevel+1; else focusedLevel = focusedLevel-1; end
        cameraQueue.y=levels[focusedLevel].y;
      elseif(math.abs(dy) >= 30) then     
        animating = true;
        pullReady = false;
        cameraQueue.y=levels[focusedLevel].y;
        fy = nil;
      else   
        local ny = fy+dy;            
        placeCamera(cameraX, ny);
      end
      
    elseif(e.phase == 'ended' or e.phase == 'cancelled') then             
      atQueue = math.abs(cameraQueue.y-cameraY) < 1;      
      if(atQueue) then
        pullReady = true;
      else          
        pullReady = false; 
        animating = true;
        cameraQueue.y=levels[focusedLevel].y;
      end
      
      fy = nil;
    end 
  end     
  if(e.phase == 'ended' or e.phase == 'cancelled') then        
    fingerDown=false;
  end    
end
 
local function createMap()  
  audio.setVolume(0,{channel=2});
  hudUp = false;
  hud = {x=0,y=0,bg=nil,lht=nil,rht=nil,hs=nil};
  resetCamera();
  
  levels = {
    {
      name = "Mono Basin",
      y = 30,
      hudImg = 'images/screens/map_overlays/stage1.png',
      button = nil,
      open=true,
      scene="assets.history.history1_1"
    },
    { 
      name = "Owens Valley",
      y =90,
      hudImg = 'images/screens/map_overlays/stage2.png',
      button = nil,
      open=false,
      scene="assets.history.history1_2"
    },
    {
      name = "Lower Owens River",
      y = 470,
      hudImg = 'images/screens/map_overlays/stage3.png',
      button = nil,
      open=false,
      scene="assets.history.history2_1"
    },
    {
      name = "Southern District",
      y = 1130,
      hudImg = 'images/screens/map_overlays/stage4.png',
      button = nil,
      open=false,
      scene="assets.history.history2_2"
    }
  }
  pullReady = false;
  animating = true;
  fingerDown = false;
  
  focusedLevel = storage.upToStage;
  
  for i=1,storage.upToStage do
    levels[i].open=true;
  end
  
  cameraQueue = {y=levels[focusedLevel].y };
  
  --Loading bg
  bg = display.newImage("images/screens/mapHires.png", true);
  local r1=bg.width/bg.height;
  bg.width = 480;
  bg.height = bg.width/r1;
  bg.x = metrics.center.x;
  bg.y = bg.height/2;  
  layers[2]:insert(bg);
  placeCamera(cameraX,-bg.height/2);
  
  --Exit button
  exitButton = display.newImage("images/hud/exit_hires.png",true);
  exitButton.width = 30;
  exitButton.height = 30;
  layers[3]:insert(exitButton);
  exitButton:addEventListener('touch', function(event)
    if(event.phase=='began' and not hudUp) then      
      audio.stop(1);
      audio.rewind(music.menu);
      playSoundEffect(sounds.dismiss);
      --audio.play(music.menu,{channel=1,loops=-1});
      storyboard.gotoScene( "assets.menu_screen", "crossFade", 250 );
    end
  end);
  
  --Level buttons  
  for i=1,#levels do  
    local uri= "images/screens/mapdot.png";
    if(not levels[i].open) then uri="images/screens/mapdotgray.png"; end
    levels[i].button = display.newImage(uri);
    levels[i].button.width=30;
    levels[i].button.height=30;
    layers[3]:insert(levels[i].button);
    
    levels[i].button:addEventListener("touch", function(e)
      if(e.phase == 'began' and not hudUp and levels[i].open) then
        showHud(i);
      end
    end);
  end
  
  levels[1].button.x = 63;
  levels[1].button.y = 69;

  levels[2].button.x = 245;
  levels[2].button.y = 257;

  levels[3].button.x = 350;
  levels[3].button.y = 630;

  levels[4].button.x = 216;
  levels[4].button.y = 1291;

  Runtime:addEventListener("touch", reportTouch);
  
  cameraTimer = timer.performWithDelay(1,
    updateCamera,
    0); 
  
  destroyed=false;
end

local function destroyMap()  
  if(destroyed) then return; end
  destroyed = true
  
  display.remove(exitButton);
  exitButton=nil;
  
  bg:removeSelf();
  bg = nil;
  
  for i=1,#layers do
    local l = layers[i];
    for j=1,#l do
      if(l[j] ~= nil) then
        l[j]:removeSelf();
        l[j] = nil;
      end
    end
  end
  
  for i=1,#levels do
    levels[i].button:removeSelf();
    levels[i] = nil;
  end
  
  timer.cancel(cameraTimer);
  cameraTimer = nil;
  
  removeHud();
  
  Runtime:removeEventListener("touch", reportTouch);
  
  collectgarbage("collect");
end

function doubleTapped()
end;
 
-- Called when the scene's view does not exist:
function scene:createScene( event )
  createMap();
end
 
-- Called BEFORE scene has moved onscreen:
function scene:willEnterScene( event )
        print(storage.upToStage);
----Kiosk integration---------

  if(kiosk.labels["entering_map_1"] == nil and storage.upToStage==1) then
    pushKioskFrame(function() end, 0, 0, "entering_map_1");
    
    pushKioskFrame(function()
      showHud(1);
    end, 2000, 0, "opening_hud_1");
    
    pushKioskFrame(function()
      startLevel(1);
    end, 5000, 1000, "exiting_map_1");
  
  elseif(kiosk.labels["entering_map_2"] == nil and storage.upToStage==2) then
    pushKioskFrame(function() end, 0, 0, "entering_map_2");
    
    pushKioskFrame(function()
      showHud(2);
    end, 2000, 0, "opening_hud_2");
    
    pushKioskFrame(function()
      startLevel(2);
    end, 5000, 1000, "exiting_map_2");
  
  elseif(kiosk.labels["entering_map_3"] == nil and storage.upToStage==3) then
    pushKioskFrame(function() end, 0, 0, "entering_map_3");
    
    pushKioskFrame(function()
      showHud(3);
    end, 2000, 0, "opening_hud_3");
    
    pushKioskFrame(function()
      startLevel(3);
    end, 5000, 1000, "exiting_map_3");
  
  elseif(kiosk.labels["entering_map_4"] == nil and storage.upToStage==4) then
    pushKioskFrame(function() end, 0, 0, "entering_map_4");
    
    pushKioskFrame(function()
      showHud(4);
    end, 2000, 0, "opening_hud_4");
    
    pushKioskFrame(function()
      startLevel(4);
    end, 5000, 1000, "exiting_map_4");
  end

------------------------------
        
end
 
-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
       audio.stop(1);
       audio.rewind(music.map);
       audio.play(music.map, {channel=1,loops=-1});
        
end
 
 
-- Called when scene is about to move offscreen:
function scene:exitScene( event )
        
        
end
 
-- Called AFTER scene has finished moving offscreen:
function scene:didExitScene( event )

  wipeAllLayers();
  storyboard.purgeScene( "assets.map_screen" );
        
end
 
 
-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )
        
       
      destroyMap();
        
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