require('middleclass');
require "assets.classes.WaterParticle";

GeneratorValve = class('GeneratorValve') 

function GeneratorValve:initialize(x, y, xF, yF, r, startUp, physics, group, interval, maxP)
  self.r = r;
  self.particles = {};
  self.interval = interval;
  self.max = maxP;
  self.physics = physics;
  self.group = group;
  self.count = 0;
  self.on = false;
  -- Adding valve code for image
  self.addedImg = false;
  self.addedBod = false;
  --self.turned=turned
  self.body = nil;
  self.up = startUp;
  self.path = imagePath;
  self:setPos(x,y);
  self:updateImage();
  self.alive=true;
  self.deadParticles = 0;
  --self:updatePhysics();
  self.particleTimerID =   
    timer.performWithDelay( self.interval,
    function() 
      if(not self.on) then
      elseif(self.count < self.max) then
        self:makeParticle(self.x, self.y, xF, yF);
      else
        self:stop();
      end
    end, 0 );
end

function GeneratorValve:setPos(x, y)
  self.x = x;
  self.y = y;
  -- Adding valve code for image
  self:updateImage();
  --self:updatePhysics();
end

-- Adding valve code for image - turning disabled
function GeneratorValve:updateImage()
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
  --if(self.turned) then self.image.rotation = 90; end
  
  self.group:insert(self.image);
  self.addedImg=true;
  
  self.image:addEventListener( "touch", 
    function(event)
      if(event.phase == 'began') then self:switch(); end
    end
  );
end

function GeneratorValve:switch()
  playSoundEffect(sounds.valve);  
  if(self.up) then self.up=false
  else self.up = true
  end
  
  if (self.on) then
    self:stop();
  else
    self:start();
  end

  self:updateImage();
  --self:updatePhysics();
end

function GeneratorValve:makeParticle(x, y, xForce, yForce)
  local offset = self.image.width / 2 + 2;
  if(self.particles == nil) then return; end;
  -- First particle stream
  local particle = WaterParticle:new(x+offset,y-2,(math.random()*2.5)+1, self.physics,self.group);
  self:createOOBListener(particle);
  self:createPUMPListener(particle);
  particle:useForce(xForce, yForce);
  self.particles[#self.particles + 1] = particle;
  self.count = self.count+1;
  -- Second particle stream
  local particle2 = WaterParticle:new(x+offset,y+2,(math.random()*2.5)+1, self.physics,self.group);
  self:createOOBListener(particle2);
  self:createPUMPListener(particle2);
  particle2:useForce(xForce, yForce);
  self.particles[#self.particles + 1] = particle2;
  self.count = self.count+1;
  -- Third particle stream
  local particle3 = WaterParticle:new(x+offset,y+6,(math.random()*2.5)+1, self.physics,self.group);
  self:createOOBListener(particle3);
  self:createPUMPListener(particle3);
  particle3:useForce(xForce, yForce);
  self.particles[#self.particles + 1] = particle3;
  self.count = self.count+1;

end

function GeneratorValve:createOOBListener(particle)
  particle.image:addEventListener("collision",
  function(e)
    if(e.other.tag == 'oob') then
      particle:kill();
      particle = nil;
      self.deadParticles = self.deadParticles+1;
    end
  end
  );
end

function GeneratorValve:createPUMPListener(particle)
  particle.image:addEventListener("collision",
  function(e)
    if (e.other.tag == 'pump') then
      playSoundEffect(sounds.pump, -1, 3);
      audio.setVolume(0.9, {channel = 3});
      particle:useForce(0, -500);
    elseif (e.other.tag == 'pumpTurn') then
      playSoundEffect(sounds.pump, -1, 3);
      audio.setVolume(0.9, {channel = 3});
      particle:useForce(500, 0);
    end
  end
  );
end

function GeneratorValve:start()
  self.on = true;
end

function GeneratorValve:stop()
  self.on = false;
end

function GeneratorValve:kill()
  self:stop();
  for i=1,#self.particles do
    if(self.particles[i] ~= nil) then self.particles[i]:kill(); end;
  end
  self.particles=nil;
  timer.cancel(self.particleTimerID);
  -- Added code from valve
  self.image:removeSelf();
  self.image = nil;
  self.body = nil;
  self.alive=false;
end