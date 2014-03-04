-----------------------------------------------------------------------------------------
-- Group name: Aqueduct Adventures
-- File name: exit2_2.lua
-- Purpose: show historical info slide for level 2, stage 2
-- Group 5:
--    Terry Liu
--    Raymond Ononiwu
--    William Thomas
-- Description: 
--    This will show before level 2, stage 2. Click to continue
-----------------------------------------------------------------------------------------

-- This sets up an exit screen of the game -------------------------------------
print("Loading assets.exit.exit2_2...");

-- Load storyboard and setup
local storyboard = require( "storyboard" );
local scene = storyboard.newScene();
require("assets.displaysetup");
 
---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

-- Image
local exit;
local hs = nil;

-- Touch event listener for background image
local function onSceneTouch( self, event )
  if event.phase == "began" then
    
    storyboard.gotoScene( "assets.exit.level2", "crossFade", 250 );

    return true;
  end
end

-- Called when the scene's view does not exist:
function scene:createScene( event )
  local screenGroup = layers[1];
 
  exit = display.newImage("images/exit/stage4complete.png", true);
  exit.x = metrics.center.x;
  exit.y = metrics.center.y;
  exit.height = metrics.size.height;
  exit.width = metrics.size.width;

  screenGroup:insert(exit);
  
  if(showNewHighScore) then
    hs =  display.newImage("images/highscore.png", false);
    hs.width = hs.width/2;
    hs.height = hs.height/2;
    hs.x = metrics.center.x;
    screenGroup:insert(hs);
  end
  exit:addEventListener('touch', function(event)
    if not kiosk.on then
      onSceneTouch(nil, event);
    end
  end);

  print( "\nexit: createScene event");
end

 
-- Called BEFORE scene has moved onscreen:
function scene:willEnterScene( event )
  resetCamera();
  if(kiosk.labels["exiting_completion_s4"] == nil) then    
    pushKioskFrame(function()
      storyboard.gotoScene( "assets.exit.level2", "crossFade", 250 );
    end, 1000, 1000, "exiting_completion_s4");
    
  end
end
 
-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )

  print( "exit: enterScene event" );
  exit:addEventListener( "touch", exit );
end
 
 
-- Called when scene is about to move offscreen:
function scene:exitScene( event )

  print( "exit: exitScene event" );
  -- Remove touch listener for exit
  exit:removeEventListener( "touch", exit );
end
 
-- Called AFTER scene has finished moving offscreen:
function scene:didExitScene( event )
        
        -----------------------------------------------------------------------------
                
        --      This event requires build 2012.782 or later.
        
        -----------------------------------------------------------------------------
  storyboard.purgeScene( "assets.exit.exit2_2" );
        
end
 
 
-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )
  if(showNewHighScore) then
    showNewHighScore = false;
    display.remove(hs);
  end
  display.remove(exit);
  exit=nil;
  print( "((destroying exit2_2 scene's view))" );        
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
 
print("Loaded assets.exit.exit2_2!\n");

---------------------------------------------------------------------------
 
return scene;

