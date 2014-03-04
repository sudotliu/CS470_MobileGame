-----------------------------------------------------------------------------------------
-- Group name: Aqueduct Adventures
-- File name: splash_screen.lua
-- Purpose: show project name, load bar, play music
-- Group 5:
--    Terry Liu
--    Raymond Ononiwu
--    William Thomas
-- Description: 
--    This is the first screen players will see when they start your game. It should 
--    contain your game title, and an indication to the player that your game is loading. You 
--    will probably texture map an image file with this information. You should play some 
--    music when this is loading.
-----------------------------------------------------------------------------------------

-- This sets up the splash screen of the game -----------------------------

print("Loading assets.splash_screen...");

-- Load storyboard and setup
local storyboard = require( "storyboard" );
local scene = storyboard.newScene();
local load = nil;
require("assets.displaysetup");

local kioskTimer=nil;
 
---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------
 
local splash;


-- Called when the scene's view does not exist:
function scene:createScene( event )
  
  local screenGroup = self.view;
 
  splash = display.newImage("images/screens/splash.png", true);
  splash.x = metrics.center.x;
  splash.y = metrics.center.y;
  splash.height = metrics.size.height;
  splash.width = metrics.size.width;

  screenGroup:insert(splash);
  
  load =  display.newImage("images/loading.png", true);
  screenGroup:insert(load);

  print( "\nsplash: createScene event");
        
end

local function spinLoad()
load.rotation = load.rotation+4;
end
 
-- Called BEFORE scene has moved onscreen:
function scene:willEnterScene( event )
        
        
  load.x = metrics.center.x;
  load.y = metrics.center.y+75;
  load.width = 50;
  load.height = 50;
  load.rotation = 0;
  
  Runtime:addEventListener('enterFrame', spinLoad);

  local loadTimer = timer.performWithDelay(loadTime, function()
    storyboard.gotoScene( "assets.menu_screen", "crossFade", 250);
  end, 1);
  
end
 
-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
  print( "splash: enterScene event" );
  
  -- Remove previous scene's view
  storyboard.purgeScene( "assets.logo_screen" );
  
end
 
 
-- Called when scene is about to move offscreen:
function scene:exitScene( event )
  print( "splash: exitScene event" );
end
 
-- Called AFTER scene has finished moving offscreen:
function scene:didExitScene( event )
  
  Runtime:removeEventListener('enterFrame', spinLoad);
  wipeAllLayers();
        
end
 
 
-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )
  print( "((destroying splash_screen scene's view))" );
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

-- Main game loop
--Runtime:addEventListener( "enterFrame", loop );
 
---------------------------------------------------------------------------------
 
print("Loaded assets.splash_screen!\n");
print("Splash loaded!"); 

---------------------------------------------------------------------------
 
return scene;