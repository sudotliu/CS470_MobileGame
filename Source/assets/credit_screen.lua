-----------------------------------------------------------------------------------------
-- Group name: Aqueduct Adventures
-- File name: credit_screen.lua
-- Purpose: give credit for work done
-- Group 5:
--    Terry Liu
--    Raymond Ononiwu
--    William Thomas
-- Description:
--    This is the credits screen; the camera pans down to give it that "roll" effect.
-----------------------------------------------------------------------------------------

-- This sets up the credit screen of the game -----------------------------
print("Loading assets.credit_screen...");

-- Load storyboard and setup
local storyboard = require( "storyboard" );
local scene = storyboard.newScene();

require("assets.displaysetup");
 
local mode = nil;
local credit = nil;

---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

-- Touch event listener for background image
local function onSceneTouch( self, event )
  if event.phase == "began" then
    storyboard.gotoScene( "assets.logo_screen", "crossFade", 250 );
    return true;
  end
end

-- Called when the scene's view does not exist:
function scene:createScene( event )
 
  credit = display.newImage("images/screens/finalCredits.png", true);
  print ("IMG SIZE:" .. credit.width);
  credit.x = metrics.center.x;
  credit.y = 6.25 * metrics.center.y;
  credit.height = 6 * metrics.size.height;
  credit.width = metrics.size.width;
  layers[2]:insert(credit);

  credit:addEventListener('touch', function(event)
    if not kiosk.on then
      onSceneTouch(nil, event);
    end
  end);

  print("\ncredit: createScene event");
        
end
 
-- Called BEFORE scene has moved onscreen:
function scene:willEnterScene( event )
  resetCamera();
if(kiosk.labels["exiting_credits"] == nil) then    
    pushKioskFrame(function()
      clearKiosk();
    end, 1000*60, 0, "exiting_credits");
    
  end
end
 
-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
  print( "credit: enterScene event" );
  -- Remove previous scene's view
  -- Stop all previous sounds before playing credits music
  audio.stop();
  audio.rewind(music.credits);
  audio.play( music.credits, {channel=5, loops=-1});
  mode = "rollCredits";
end
 
 
-- Called when scene is about to move offscreen:
function scene:exitScene( event )
  print( "credit: exitScene event" );
  
  -- Remove touch listener for credit
  audio.stop();
  audio.rewind(music.credits);
  mode = nil;
end
 
-- Called AFTER scene has finished moving offscreen:
function scene:didExitScene( event )
display.remove(credit);
credit=nil;
  storyboard.purgeScene( "assets.credit_screen" );
        
end
 
-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )
  print( "((destroying credit_screen scene's view))" );
end
 
-- Called if/when overlay scene is displayed via storyboard.showOverlay()
function scene:overlayBegan( event )
        local overlay_scene = event.sceneName  -- overlay scene name        
end
 
-- Called if/when overlay scene is hidden/removed via storyboard.hideOverlay()
function scene:overlayEnded( event )
        local overlay_scene = event.sceneName  -- overlay scene name
end

function loop ( event )
  if (mode == "rollCredits" and  cameraY < 1601) then
    moveCamera(0,1);
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

-- Main game loop
Runtime:addEventListener( "enterFrame", loop );
 
---------------------------------------------------------------------------------
 
print("Loaded assets.credit_screen!\n");
print("Credits loaded!"); 

---------------------------------------------------------------------------
 
return scene;