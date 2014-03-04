-----------------------------------------------------------------------------------------
-- Group name: Aqueduct Adventures
-- File name: history1_1.lua
-- Purpose: show historical info slide for level 1, stage 1
-- Group 5:
--    Terry Liu
--    Raymond Ononiwu
--    William Thomas
-- Description: 
--    This will show before level 1, stage 1. Click to continue
-----------------------------------------------------------------------------------------

-- This sets up the history screen of the game -------------------------------------
print("Loading assets.history.history1_1...");

-- Load storyboard and setup
local storyboard = require( "storyboard" );
local scene = storyboard.newScene();
require("assets.displaysetup");
 
---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

-- Image
local history;

-- Touch event listener for background image
local function onSceneTouch( self, event )
    
  if event.phase == "began" then

 audio.stop(1);
 audio.rewind(music.stage1);
 audio.play(music.stage1, {channel=1,loops=-1});
 
    storyboard.gotoScene( "assets.stages.stage1", "crossFade", 250 );

    return true;
  end
end
 
-- Called when the scene's view does not exist:
function scene:createScene( event )
  resetCamera();
  local screenGroup = self.view;
 
  history = display.newImage("images/history/1_1.png", true);
  history.height = metrics.size.height;
  history.width = metrics.size.width;

  layers[1]:insert(history);
  history.x = metrics.center.x;
  history.y = metrics.center.y;
  
  history:addEventListener('touch',function(event) 
    if(kiosk.on) then return; end
    onSceneTouch(history, event);
  end);

  print( "\nhistory: createScene event");
end

 
-- Called BEFORE scene has moved onscreen:
function scene:willEnterScene( event )
        
  if(kiosk.labels["entering_history_1"] == nil) then
    pushKioskFrame(function() end, 0, 0, "entering_history_1");
    
    pushKioskFrame(function()
      onSceneTouch( nil, {phase='began'} );
    end, 8000, 0, "exiting_history_1");
    
  end
        
end
 
-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )

  print( "history: enterScene event" );
end
 
 
-- Called when scene is about to move offscreen:
function scene:exitScene( event )

  print( "history: exitScene event" );
  -- Remove touch listener for history
  display.remove(history);
  history=nil;
end
 
-- Called AFTER scene has finished moving offscreen:
function scene:didExitScene( event )
 
  wipeAllLayers();
  storyboard.purgeScene( "assets.history.history1_1" );
        
end
 
 
-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )

  print( "((destroying history_1_1 scene's view))" );        
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
 
print("Loaded assets.history_screen!\n");
print("Logo loaded!"); 

---------------------------------------------------------------------------
 
return scene;