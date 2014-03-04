require('middleclass');
require "assets.classes.WaterParticle";
require "assets.classes.PhysicsLineFactoryII";

TurboPump = class('TurboPump') 

function TurboPump:initialize(x, y, r, physics, group, turned, inverted)
  self.r = r;
  self.physics = physics;
  self.group = group;
  self.turned = turned;
  self.inverted = inverted;
  self.addedImg = false;
  self.addedBod = false;
  self.body = nil
  self.path = imagePath;
  self.on = false;
  self:setPos(x,y);
  self:updateImage();
end

function TurboPump:setPos(x, y)
  self.x = x;
  self.y = y;
  self:updateImage();
end

function TurboPump:updateImage()
  if self.addedImg then
    self.image:removeSelf()
    self.image = nil
  end
  
  self.image = display.newImage("images/pipes/vert_pump.png")
  self.image.x = self.x;
  self.image.y = self.y;
  self.image.width = self.image.width/self.r;
  self.image.height = self.image.height/self.r;
  if(self.turned) then self.image.rotation = 90; end
  self.group:insert(self.image);
  self.addedImg=true;
end

function TurboPump:start()
  local leftX, rightX = self.x-14/self.r, self.x+14/self.r;
  local topY, bottomY = self.y-60/self.r, self.y+70/self.r;
  local midX = (leftX + rightX) / 2;
  
  physicsLineFactoryII = PhysicsLineFactoryII:new(physics,layers[4]);

  if (self.turned) then
    physicsLineFactoryII:makePhysicsLine(self.x-60/self.r, self.y-18/self.r, self.x+70/self.r, self.y-18/self.r, 'pumpTurn');
    physicsLineFactoryII:makePhysicsLine(self.x-60/self.r, self.y+10/self.r, self.x+70/self.r, self.y+10/self.r, 'pumpTurn');
    physicsLineFactoryII:makePhysicsLine(self.x-70/self.r, self.y, self.x+80/self.r, self.y, 'pumpTurn');
  elseif (self.inverted) then
    physicsLineFactoryII:makePhysicsLine(leftX-1, bottomY-5, leftX-1, topY+5, 'pumpDown');
    physicsLineFactoryII:makePhysicsLine(rightX+1, bottomY-5, rightX+1, topY+5, 'pumpDown');
    physicsLineFactoryII:makePhysicsLine(midX, bottomY-5, midX, topY+5, 'pumpDown');
  else
    physicsLineFactoryII:makePhysicsLine(leftX, bottomY, leftX, topY, 'pump');
    physicsLineFactoryII:makePhysicsLine(rightX, bottomY, rightX, topY, 'pump');
    physicsLineFactoryII:makePhysicsLine(midX, bottomY+14/self.r, midX, topY, 'pump');
  end

  self.on = true;
end

function TurboPump:stop()
  self.on = false;
end

function TurboPump:kill()
  self.image:removeSelf();
  self.image = nil;
  self.body = nil;
  self.addedImg = nil;
  self.addedBod = nil;
  self.r = nil;
  self.group = nil;
  self.turned = nil;
  self.path = nil;
  self.on = nil;
end;
