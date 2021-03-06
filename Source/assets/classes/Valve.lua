require('middleclass');

Valve = class('Valve') 

function Valve:initialize(x,y,r,startUp,group,turned,physics)
  self.r = r;
  self.addedImg=false;
  self.addedBod=false;
  self.turned=turned
  self.body=nil
  self.up = startUp;
  self.path = imagePath;
  self.group=group;
  self.physics = physics
  self:setPos(x,y);
  self:updateImage();
  self:updatePhysics();
end

function Valve:setPos(x, y)
  self.x = x;
  self.y = y;
  self:updateImage();
  self:updatePhysics();
end

function Valve:updateImage()
  if self.addedImg then
    self.image:removeSelf()
    self.image = nil
  end
  
  if(self.up) then
    self.image = display.newImage("images/pipes/valve-up.png")
  else
    self.image = display.newImage("images/pipes/valve-right.png")
  end
  
  self.image.x = self.x;
  self.image.y = self.y;
  self.image.width = self.image.width/self.r;
  self.image.height = self.image.height/self.r;
  if(self.turned) then self.image.rotation = 90; end
  
  self.group:insert(self.image);
  self.addedImg=true;
  
  self.image:addEventListener( "touch", 
    function(event)
      if(event.phase == 'began' and not kiosk.on ) then self:switch(); end
    end
  );
end

function Valve:switch()
  playSoundEffect(sounds.valve);

  if(self.up) then self.up=false
  else self.up = true
  end
  
  self:updateImage();
  self:updatePhysics();
end

function Valve:updatePhysics()
  if(self.bi) then
    self.bi:removeSelf()
    self.bi = nil
  end
  
  self.bi = display.newImage("images/blank.png");
  self.group:insert(self.bi);
  local bs = nil
  
  if(not self.turned) then  
    if(self.up) then
      bs1 = {self.x+5,self.y-3,self.x+5,self.y+7}
    else
      bs1 = {self.x-23,self.y+7,self.x+23,self.y+7}
    end
    bs2 = {self.x-23,self.y-3,self.x+23,self.y-3}
    bs3 ={self.x-23,self.y+7,self.x-5,self.y+7}
    bs4 ={self.x+5,self.y+7,self.x+23,self.y+7}  
  else
    if(self.up) then
      bs1 = {self.x-8,self.y+5,self.x+3,self.y+5}
    else
      bs1 = {self.x-8,self.y-5,self.x-8,self.y+5}
    end
    bs2 = {self.x+3,self.y-23,self.x+3,self.y+23}
    bs3 ={self.x-8,self.y-23,self.x-8,self.y-5}
    bs4 ={self.x-8,self.y+5,self.x-8,self.y+23}
  end
  
  self.physics.addBody(self.bi,"static",
  {friction=0,bounce=0.1,density=1,shape=bs1},
  {friction=0,bounce=0.1,density=1,shape=bs2},
  {friction=0,bounce=0.1,density=1,shape=bs3},
  {friction=0,bounce=0.1,density=1,shape=bs4});
  
  
  self.addedBod =true
end

function Valve:kill()
  self.bi:removeSelf();
  self.bi = nil;
  self.image:removeSelf();
  self.image = nil;
  self.body = nil;
end;