-----------------------------------------------------------------------------------------
-- Group name: Aqueduct Adventures
-- File name: menu_screen.lua
-- Purpose: show main menu
-- Group 5:
--    Terry Liu
--    Raymond Ononiwu
--    William Thomas
-- Description: 
--    This is the second screen players will see. Options will minimally 
--    include: start new game, load prior game, save current game, and exit. 
-----------------------------------------------------------------------------------------

-- This sets up the menu screen of the game -----------------------------
print("Loading assets.menu_screen...");

loadTime=100;

-- Require the widget library
local widget = require( "widget" )
local kioskTimer = nil;

-- Load storyboard and setup
local scene = storyboard.newScene();
require("assets.displaysetup");
 
---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------
 
local menu;

-- Called when the scene's view does not exist:
function scene:createScene( event )
  local screenGroup = self.view;
 
  menu = display.newImage("images/screens/menu.png", true);
  menu.x = metrics.center.x;
  menu.y = metrics.center.y;
  menu.height = metrics.size.height;
  menu.width = metrics.size.width;

  screenGroup:insert(menu);
  

  print( "\nmenu: createScene event");

-- These are the functions triggered by the buttons
local playGamePress = function( event )
  playSoundEffect(sounds.dismiss);
end
local playGameRelease = function( event )
  clearMemory();
  playSoundEffect(sounds.blip);
  
    if(kioskTimer ~= nil) then
      timer.cancel(kioskTimer);
      ioskTimer=nil;
    end
  storyboard.gotoScene( "assets.map_screen", "crossFade", 250 );
end

local saveGamePress = function( event )
  playSoundEffect(sounds.dismiss);
end
local saveGameRelease = function( event )
  saveMemory();
  playSoundEffect(sounds.blip);
end

local loadGamePress = function( event )
  playSoundEffect(sounds.dismiss);
end
local loadGameRelease = function( event )
  loadMemory();
  playSoundEffect(sounds.blip);
  storyboard.gotoScene( "assets.map_screen", "crossFade", 250 );
end

local exitPress = function( event )
  playSoundEffect(sounds.dismiss);
end
local exitRelease = function( event )
  playSoundEffect(sounds.blip);
  storyboard.gotoScene( "assets.logo_screen", "crossFade", 250 );
end

local creditsPress = function( event )
  playSoundEffect(sounds.dismiss);
end
local creditsRelease = function( event )
  playSoundEffect(sounds.blip);
  storyboard.gotoScene( "assets.credit_screen", "crossFade", 250 );
end

-- Buttons and their properties
local playBtn = widget.newButton
{
  id = "playBtn",
  defaultFile = "images/screens/menu/playBtn.png",
  overFile = "images/screens/menu/playOver.png",
  --label = "Button 1 Label",
  emboss = true,
  onPress = playGamePress,
  onRelease = playGameRelease,
  width = 241 / 2,
  height = 75 / 2
}

local saveBtn = widget.newButton
{
  id = "saveBtn",
  defaultFile = "images/screens/menu/saveBtn.png",
  overFile = "images/screens/menu/saveOver.png",
  --label = "Button 1 Label",
  emboss = true,
  onPress = saveGamePress,
  onRelease = saveGameRelease,
  width = 241 / 2,
  height = 75 / 2
}

local loadBtn = widget.newButton
{
  id = "loadBtn",
  defaultFile = "images/screens/menu/loadBtn.png",
  overFile = "images/screens/menu/loadOver.png",
  --label = "Button 1 Label",
  emboss = true,
  onPress = loadGamePress,
  onRelease = loadGameRelease,
  width = 241 / 2,
  height = 75 / 2
}

local exitBtn = widget.newButton
{
  id = "exitBtn",
  defaultFile = "images/screens/menu/exitBtn.png",
  overFile = "images/screens/menu/exitOver.png",
  --label = "Button 2 Label",
  labelColor = 
  { 
    default = { 51, 51, 51, 255 },
  },
  font = "Trebuchet-BoldItalic",
  fontSize = 22,
  emboss = true,
  onPress = exitPress,
  onRelease = exitRelease,
  width = 241 / 2,
  height = 76 / 2
}

local creditsBtn = widget.newButton
{
  id = "creditsBtn",
  defaultFile = "images/screens/menu/creditsBtn.png",
  overFile = "images/screens/menu/creditsOver.png",
  --label = "Button 3 Label",
  font = "MarkerFelt-Thin",
  fontSize = 28,
  emboss = true,
  onPress = creditsPress,
  onRelease = creditsRelease,
  width = 241 / 2,
  height = 76 / 2
}

playBtn.x = 238; playBtn.y = 73
saveBtn.x = 238; saveBtn.y = 114
loadBtn.x = 238; loadBtn.y = 154
exitBtn.x = 238; exitBtn.y = 194
creditsBtn.x = 238; creditsBtn.y = 235

screenGroup:insert(playBtn);
screenGroup:insert(saveBtn);
screenGroup:insert(loadBtn);
screenGroup:insert(exitBtn);
screenGroup:insert(creditsBtn);

end
 
-- Called BEFORE scene has moved onscreen:
function scene:willEnterScene( event )  

clearKiosk();
  
audio.stop();
audio.rewind(music.menu);
audio.play( music.menu, { channel=1, loops=-1} );

----Kiosk integration---------

  if(kiosk.labels["leaving_menu"] == nil) then
    pushKioskFrame(function()
      clearMemory();
      storyboard.gotoScene( "assets.map_screen", "crossFade", 250 );
    end, 1000, 1000, "leaving_menu");
  end
  
  
  kioskTimer = timer.performWithDelay(15000, function()
    print('Starting kiosk mode...'); 
    if(kioskTimer ~= nil) then
      timer.cancel(kioskTimer);
      kioskTimer=nil;
    end
    startKiosk(true);
  end, 1);

------------------------------

end
 
-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
  print( "menu: enterScene event" );
  
  -- Remove previous scene's view
  storyboard.purgeScene( "assets.logo_screen" );
  --menu:addEventListener( "touch", menu );
end
 
 
-- Called when scene is about to move offscreen:
function scene:exitScene( event )
    if(kioskTimer ~= nil) then
      timer.cancel(kioskTimer);
      ioskTimer=nil;
    end
  print( "menu: exitScene event" );
  
  -- Remove touch listener for menu
  --menu:removeEventListener( "touch", menu );
end
 
-- Called AFTER scene has finished moving offscreen:
function scene:didExitScene( event )

  wipeAllLayers();     
end
 
 -- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )
  print( "((destroying menu_screen scene's view))" );
  playBtn:removeSelf();
  playBtn = nil;
  exitBtn:removeSelf();
  exitBtn = nil;
  creditsBtn:removeSelf();
  creditsBtn = nil;
  screenGroup = nil;
end
 
-- Called if/when overlay scene is displayed via storyboard.showOverlay()
function scene:overlayBegan( event )
        local overlay_scene = event.sceneName  -- overlay scene name      
        
end
 
-- Called if/when overlay scene is hidden/removed via storyboard.hideOverlay()
function scene:overlayEnded( event )
        local overlay_scene = event.sceneName  -- overlay scene name
        
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
--Runtime:addEventListener( "enterFrame", loop );
 
---------------------------------------------------------------------------------
 
print("Loaded assets.menu_screen!\n");
print("menu loaded!"); 

---------------------------------------------------------------------------
 
return scene;