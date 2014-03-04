require('middleclass');

WaterParticle = class('WaterParticle') 

function WaterParticle:initialize(x,y,r,physics,group)
  self.r=r;
  self.alive = true;
  self.image = display.newImage("images/water.png",x,y);
  self.image.tag = 'water';
  self:setPos(x,y);  
  group:insert(self.image);
  
  physics.addBody(self.image, {friction=0.0,bounce=0.01,density=0,radius=(self.r/2)});
end

function WaterParticle:setPos(x, y)
  self.x = x;
  self.y = y;
  self:updateImage();
end

function WaterParticle:updateImage()  
  self.image.x = self.x;
  self.image.y = self.y;
  self.image.width = self.r*2;
  self.image.height = self.r*2;
end

function WaterParticle:useForce(xF, yF)
  self.image:setLinearVelocity( xF, yF );
end

function WaterParticle:kill()
  if(not self.alive) then return end
  
  self.image.tag = nil;
  self.image:removeSelf();
  self.image=nil;
  
  self.r = nil;
  self.x=nil;
  self.y=nil;
  
  self.alive=false;
end