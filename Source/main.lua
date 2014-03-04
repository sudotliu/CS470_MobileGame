-----------------------------------------------------------------------------------------
-- Group name: Aqueduct Adventures
-- File name: main.lua
-- Purpose: primary driver file, used to run the package
-- Group 5:
--    Terry Liu
--    Raymond Ononiwu
--    William Thomas
-- Description: 
--    As of 24 April 2013, this is just calling in all of the lua files
--    to make sure we can access them and maintain an organized file structure
-----------------------------------------------------------------------------------------

loadTime=math.random()*1000+2000;

-- Printing a star bar for readability --
print("**************************************************\n");

-- Set up all assets --
print("SETTING UP ALL THE ASSETS:\n");
--require("assets.displaysetup");
--require("assets.ui");
--require("assets.characters");
--require("assets.backgrounds");
--require("assets.sounds");
--require("assets.splash_screen");
--require("assets.selection_screen");
--require("assets.credit_screen");
--require("assets.level1");
--require("assets.level2");
--require("assets.scenes.mainmenu");
--require("assets.scenes.map");
--require("assets.scenes.splash");

-- Printing a star bar for readability --
print("**************************************************\n");

-- Set up all engines --
print("SETTING UP ALL THE ENGINES:\n");
require("storage");
--require("engines.accelerometer");
--require("engines.ai");
--require("engines.collisions");
--require("engines.menus");
require("engines.music");
--require("engines.physics");
require("engines.soundEffects");
--require("engines.touch");
--require("engines.vibration");
require "assets.displaysetup";
require "assets.classes.WaterParticle";
require "assets.classes.WaterGenerator";
require "assets.classes.Valve";
require "assets.classes.ValveII";
require "assets.classes.ValveSmall";
require "assets.classes.PhysicsLineFactory";
require "assets.classes.PhysicsLineFactoryII";
require "assets.classes.GeneratorValve";
require "assets.classes.GeneratorValveII";
require "assets.classes.GeneratorValveSmall";
require "assets.classes.TurboPump";
require "assets.classes.ShrinkerBlock";
require "assets.classes.KioskListNode";

require("engines.kiosk");

storyboard = require( "storyboard" );

-- Printing a star bar for readability --
print("**************************************************\n");

-- Show access of resources such as audio/, images/, scripts/, videos/ --
print("ACCESSING ALL OF THE RESOURCES:\n");
--require("audio.audio");
--require("images.images");
--require("scripts.scripts");
--require("videos.videos");

-- Printing a star bar for readability --
print("**************************************************\n");
print("**************************************************\n");

showNewHighScore = false;

local monitorMem = function()
    collectgarbage("collect")
end

--Runtime:addEventListener( "enterFrame", monitorMem );

local printMemInfo = function(e)
monitorMem();
    print( e.count );
    print( "MemUsage: " .. collectgarbage("count") );
    local textMem = system.getInfo( "textureMemoryUsed" ) --/ 1000000
    print( "TexMem:   " .. textMem );
    print( "");
end

local printMemInfoTimer = timer.performWithDelay(1000, printMemInfo, 0);

local storyboard = require("storyboard");
--storyboard.gotoScene( "assets.stages.stage4", "crossFade", 250 );
storyboard.gotoScene( "assets.logo_screen", "crossFade", 250 );

debugMode=false;