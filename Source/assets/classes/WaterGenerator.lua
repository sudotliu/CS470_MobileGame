require('middleclass');
require "assets.classes.WaterParticle";

WaterGenerator = class('WaterGenerator') 

function WaterGenerator:initialize(x,y,physics,group,interval, maxP)
  self.particles = {};
  self.interval = interval;
  self.max=maxP;
  self:setPos(x,y);
  self.physics = physics;
  self.group = group;
  self.count = 0;
  self.on = false;
  self.particleTimerID =   
    timer.performWithDelay( self.interval,
    function() 
      if(not self.on) then return; end;
      if(self.count < self.max) then
        self:makeParticle(self.x,self.y);
      else
        
      end
    end, 0 );
end

function WaterGenerator:setPos(x, y)
  self.x = x;
  self.y = y;
end

function WaterGenerator:makeParticle(x, y)
  if(self.particles == nil) then return; end;
  local particle = WaterParticle:new(x,y,(math.random()*2.5)+1, self.physics,self.group);
  self:createOOBListener(particle);
  self:createPUMPListener(particle);
  self.particles[#self.particles + 1] = particle;
  
  self.count = self.count+1;
end

function WaterGenerator:createOOBListener(particle)
  particle.image:addEventListener("collision",
  function(e)
    if(e.other.tag == 'oob') then
      particle:kill();
      particle = nil;
    end
  end
  );
end

function WaterGenerator:createPUMPListener(particle)
  particle.image:addEventListener("collision",
  function(e)
    if (e.other.tag == 'pump') then
      particle:useForce(0, -500);
    elseif (e.other.tag == 'pumpTurn') then
      particle:useForce(500, 0);
    end
  end
  );
end

function WaterGenerator:start()
  self.on = true;
end

function WaterGenerator:stop()
  self.on = false;
end

function WaterGenerator:kill()
  self:stop();
  for i=1,#self.particles do
    if(self.particles[i] ~= nil) then 
      self.particles[i]:kill(); 
      self.particles[i] = nil;
    end;
  end
  self.particles=nil;
  
  timer.cancel(self.particleTimerID);
  self.particleTimerID = nil;
end