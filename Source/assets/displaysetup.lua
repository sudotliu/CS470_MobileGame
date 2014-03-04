-- This sets up the camera/layering/display system ------------------------
print("Loading assets.ui...");
ui = require("assets.ui");
print("Loaded assets.ui!\n");

print("Setting up display...");
print("  Metrics...");
metrics = {
  center = {
    x = display.contentWidth/2,
    y = display.contentHeight/2
  },
  size = {    
    height = display.contentHeight,
    width = display.contentWidth
  }
};
print("  Layers...");
layers = {
  display.newGroup(),
  display.newGroup(),
  display.newGroup(),
  display.newGroup(),
  display.newGroup(),
  display.newGroup(),
  display.newGroup(),
  display.newGroup(),
  display.newGroup(),
  display.newGroup()
};
kioskLayer = display.newGroup();
print("  Camera...");

function moveCamera(dx,dy)
  for i=1,#layers do
    layers[i].x = layers[i].x-dx;
    layers[i].y = layers[i].y-dy;
  end
  cameraX = cameraX + dx;
  cameraY = cameraY + dy;
end

function wipeAllLayers()
  for l=1,#layers do
    local layer = layers[l];
    for i=1,#layer do
      display.remove(layer[i]);
      layer[i]=nil;
    end
  end
end

function placeCamera(x,y)
  for i=1,#layers do
    layers[i].x = x;
    layers[i].y = y;
  end
  cameraX = x;
  cameraY = y;
end

function resetCamera()
  placeCamera(0,0);
end

resetCamera();

display.setStatusBar( display.HiddenStatusBar );
print("Display setup complete!\n");
---------------------------------------------------------------------------

