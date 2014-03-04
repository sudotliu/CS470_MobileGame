-----------------------------------------------------------------------------------------
-- Group name: Aqueduct Adventures
-- File name: logo_screen.lua
-- Purpose: show Aqueduct Futures logo
-- Group 5:
--    Terry Liu
--    Raymond Ononiwu
--    William Thomas
-- Description: 
--    This will show before the splash_screen.
-----------------------------------------------------------------------------------------

-- This sets up the logo screen of the game -------------------------------------
print("Loading assets.logo_screen...");

-- Load storyboard and setup
local scene = storyboard.newScene();
 
---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

-- Image
local logo;

-- Touch event listener for background image
local function onSceneTouch( self, event )
  if event.phase == "began" then
    --storyboard.gotoScene( "assets.splash_screen", "crossFade", 250 );
    return true;
  end
end


-- Called when the scene's view does not exist:
function scene:createScene( event )
  local screenGroup = self.view;
 
  logo = display.newImage("images/screens/logo.png", true);
  logo.x = metrics.center.x;
  logo.y = metrics.center.y;
  logo.height = metrics.size.height;
  logo.width = metrics.size.width;

  screenGroup:insert(logo);

  logo.touch = onSceneTouch;

  print( "\nlogo: createScene event");
end

 
-- Called BEFORE scene has moved onscreen:
function scene:willEnterScene( event )
  local loadTimer = timer.performWithDelay(2000, function()
    storyboard.gotoScene( "assets.splash_screen", "fade", 1000);
  end, 1);
end
 
-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
  
  audio.stop();
  audio.rewind(music.menu);

  print( "logo: enterScene event" );
  logo:addEventListener( "touch", logo );
end
 
 
-- Called when scene is about to move offscreen:
function scene:exitScene( event )

  print( "logo: exitScene event" );
  -- Remove touch listener for logo
  logo:removeEventListener( "touch", logo );
end
 
-- Called AFTER scene has finished moving offscreen:
function scene:didExitScene( event )
        
        -----------------------------------------------------------------------------
                
        --      This event requires build 2012.782 or later.
        
        -----------------------------------------------------------------------------
        
end
 
 
-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )

  print( "((destroying logo_screen scene's view))" );        
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
 
print("Loaded assets.logo_screen!\n");
print("Logo loaded!"); 

---------------------------------------------------------------------------
 
return scene;