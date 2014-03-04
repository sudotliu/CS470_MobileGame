-----------------------------------------------------------------------------------------
-- Group name: Aqueduct Adventures
-- File name: completion_screen.lua
-- Purpose: show Aqueduct Futures completion upon beating game
-- Group 5:
--    Terry Liu
--    Raymond Ononiwu
--    William Thomas
-- Description: 
--    This will show when the final stage is passed.
-----------------------------------------------------------------------------------------

-- This sets up the completion screen of the game -------------------------------------
print("Loading assets.completion_screen...");

-- Load storyboard and setup
local storyboard = require( "storyboard" );
local scene = storyboard.newScene();
require("assets.displaysetup");
 
---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

-- Image
local completion;

-- Touch event listener for background image
local function onSceneTouch( self, event )
  if event.phase == "began" then

    storyboard.gotoScene( "assets.credit_screen", "crossFade", 250 );

    return true;
  end
end


-- Called when the scene's view does not exist:
function scene:createScene( event )
  local screenGroup = layers[1];
 
  completion = display.newImage("images/screens/completion.png", true);
  completion.x = metrics.center.x;
  completion.y = metrics.center.y;
  completion.height = metrics.size.height;
  completion.width = metrics.size.width;

  screenGroup:insert(completion);

  completion:addEventListener('touch', function(event)
    if not kiosk.on then
      onSceneTouch(nil, event);
    end
  end);

  print( "\ncompletion: createScene event");
end

 
-- Called BEFORE scene has moved onscreen:
function scene:willEnterScene( event )
  resetCamera();
  if(kiosk.labels["exiting_completion_game"] == nil) then    
    pushKioskFrame(function()
      storyboard.gotoScene( "assets.credit_screen", "crossFade", 250 );
    end, 5000, 1000, "exiting_completion_game");
    
  end
end
 
-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
  -- Stop all previous sounds before playing completion sfx
  audio.stop();
  playSoundEffect(sounds.fin);

  print( "completion: enterScene event" );
end
 
 
-- Called when scene is about to move offscreen:
function scene:exitScene( event )

  print( "completion: exitScene event" );
  -- Remove touch listener for completion
end
 
-- Called AFTER scene has finished moving offscreen:
function scene:didExitScene( event )
  display.remove(completion);
  completion=nil;
  storyboard.purgeScene( "assets.completion_screen" );
end
 
 
-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )
  print( "((destroying completion_screen scene's view))" );        
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
 
print("Loaded assets.completion_screen!\n");
print("completion loaded!"); 

---------------------------------------------------------------------------
 
return scene;