require('middleclass');

ValveSmall = class('ValveSmall') 

function ValveSmall:initialize(x,y,r,startUp,group,turned,right)
  self.r = r;
  self.addedImg=false;
  self.addedBod=false;
  self.turned=turned;
  self.right=right;
  self.body=nil;
  self.up = startUp;
  self.path = imagePath;
  self.group=group;
  self:setPos(x,y);
  self:updateImage();
  self:updatePhysics();
end

function ValveSmall:setPos(x, y)
  self.x = x;
  self.y = y;
  self:updateImage();
  self:updatePhysics();
end

function ValveSmall:updateImage()
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

function ValveSmall:switch()
  playSoundEffect(sounds.valve);
  if(self.up) then self.up=false
  else self.up = true
  end
  
  self:updateImage();
  self:updatePhysics();
end

function ValveSmall:updatePhysics()
  if(self.bi) then
    self.bi:removeSelf()
    self.bi = nil
  end
  
  self.bi = display.newImage("images/blank.png");
  self.group:insert(self.bi);
  --local bs = nil
  
  local off1 = 6;
  local off2 = 20;
  local highG = 2;
  local lowG = 8;
  local off5 = 10;
  -- Horizontal Valve
  if(not self.turned) then  
    if(self.up) then
      bs1 = {self.x+off1, self.y-highG, self.x+off1, self.y+lowG}
    else
      bs1 = {self.x-off2, self.y+lowG, self.x+off2, self.y+lowG}
    end
    bs2 = {self.x-off2, self.y-highG, self.x+off2, self.y-highG}
    bs3 ={self.x-off2, self.y+lowG, self.x-off1, self.y+lowG}
    bs4 ={self.x+off1, self.y+lowG, self.x+off2, self.y+lowG}
    -- Vertical Valve FACING RIGHT
  elseif(self.right) then
    off5 = off5 / 1.2;
    if(self.up) then
      bs1 = {self.x-off5, self.y+off1, self.x+highG, self.y+off1}
    else
      bs1 = {self.x+highG, self.y-off1, self.x+highG, self.y+off1}
    end
    bs2 = {self.x+highG, self.y-off2, self.x+highG, self.y-off1}
    bs3 = {self.x+highG, self.y+off1, self.x+highG, self.y+off2}
    bs4 ={self.x-off5, self.y-off2, self.x-off5, self.y+off2} 
  -- Vertical Valve
  else
    if(self.up) then
      bs1 = {self.x-off5, self.y+off1, self.x+highG, self.y+off1}
    else
      bs1 = {self.x-off5, self.y-off1, self.x-off5, self.y+off1}
    end
    bs2 = {self.x+highG, self.y-off2, self.x+highG, self.y+off2}
    bs3 ={self.x-off5, self.y-off2, self.x-off5, self.y-off1}
    bs4 ={self.x-off5, self.y+off1, self.x-off5, self.y+off2}
  end
  
  physics.addBody(self.bi,"static",
  {friction=0,bounce=0.1,density=1,shape=bs1},
  {friction=0,bounce=0.1,density=1,shape=bs2},
  {friction=0,bounce=0.1,density=1,shape=bs3},
  {friction=0,bounce=0.1,density=1,shape=bs4});
  
  
  self.addedBod =true
end

function ValveSmall:kill()
  self.bi:removeSelf();
  self.bi = nil;
  self.image:removeSelf();
  self.image = nil;
  self.body = nil;
end;