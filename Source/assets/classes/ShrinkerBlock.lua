require('middleclass');
require "assets.classes.WaterParticle";

ShrinkerBlock = class('ShrinkerBlock') 

function ShrinkerBlock:initialize(x,y,width,height,color,group,initialFillRatio)
  self.initialFillRatio = initialFillRatio;
  self.color = color;
  self.width = width;
  self.height = height;
  self:setPos(x,y);
  self:updateFillRatio(initialFillRatio);
  self.group = group;
  self.box = nil;
end

function ShrinkerBlock:setPos(x, y)
  self.x = x;
  self.y = y;
end

function ShrinkerBlock:draw()
  display.remove(self.box);
  self.box = nil;
  
  local h = (1-self.ratio)*self.height;
  self.box = display.newRect(self.x, self.y+h, self.width, self.height);
  self.box:setFillColor(self.color.r,self.color.g,self.color.b);
  self.group:insert(self.box);
end

function ShrinkerBlock:updateFillRatio(r)
  self.ratio = r;
  if(r < 0) then self.ratio=0
  elseif(r > 1) then self.ratio=1
  end
end

function ShrinkerBlock:kill()
  display.remove(self.box);
  self.box = nil;
end