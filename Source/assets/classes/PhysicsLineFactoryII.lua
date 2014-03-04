require('middleclass');

PhysicsLineFactoryII = class('PhysicsLineFactoryII')

function PhysicsLineFactoryII:initialize(physics, layer)
  self.physics = physics;
  self.layer = layer;
  self.lines = {};
  self.alive=true;
end; 

function PhysicsLineFactoryII:makePhysicsLine(x0,y0,x1,y1,tag)
  local s = {x0,y0,x1,y1};
  local i = display.newImage("images/blank.png");
  self.layer:insert(i);
  self.physics.addBody(i,"static",
  {friction=0,bounce=0.1,density=1,shape=s});
  if(tag ~= nil) then i.tag = tag; end
  self.lines[#self.lines + 1] = i;
end; 
 
function PhysicsLineFactoryII:makeHorizPipeLine(x,y,w,h,tag)
  self:makePhysicsLine(x,y,x+w,y,tag);
  self:makePhysicsLine(x,y+h,x+w,y+h,tag);
end; 

function PhysicsLineFactoryII:makeVertPipeLine(x,y,w,h,tag)
  self:makePhysicsLine(x,y,x,y+h,tag);
  self:makePhysicsLine(x+w,y,x+w,y+h,tag);
end;

function PhysicsLineFactoryII:makeNorthTPipe(x,y,w,h,tag)
  self:makePhysicsLine(x,y,x,y+h,tag);
  self:makePhysicsLine(x+w,y,x+w,y+h,tag);
  self:makePhysicsLine(x-w,y+h,x,y+h,tag);
  self:makePhysicsLine(x+2*w,y+h,x+w,y+h,tag);
  self:makePhysicsLine(x-w,y+2*h,x+2*w,y+2*h,tag);  
end;

function PhysicsLineFactoryII:makeSouthTPipe(x,y,w,h,tag)
  self:makePhysicsLine(x,y,x,y-h,tag);
  self:makePhysicsLine(x+w,y,x+w,y-h,tag);
  self:makePhysicsLine(x-w,y-h,x,y-h,tag);
  self:makePhysicsLine(x+2*w,y-h,x+w,y-h,tag);
  self:makePhysicsLine(x-w,y-2*h,x+2*w,y-2*h,tag);  
end;

function PhysicsLineFactoryII:makeWestTPipe(x,y,w,h,tag)
  self:makePhysicsLine(x,y,x+w,y,tag);
  self:makePhysicsLine(x,y+h,x+w,y+h,tag);
  self:makePhysicsLine(x+w,y-h,x+w,y,tag);
  self:makePhysicsLine(x+w,y+h,x+w,y+2*h,tag);
  self:makePhysicsLine(x+2*w,y-h,x+2*w,y+2*h,tag);
end;

function PhysicsLineFactoryII:makeEastTPipe(x,y,w,h,tag)
  self:makePhysicsLine(x,y,x-w,y,tag);
  self:makePhysicsLine(x,y+h,x-w,y+h,tag);
  self:makePhysicsLine(x-w,y-h,x-w,y,tag);
  self:makePhysicsLine(x-w,y+h,x-w,y+2*h,tag);
  self:makePhysicsLine(x-2*w,y-h,x-2*w,y+2*h,tag);
end;

-- y is inverted
-- r is the radius of the turn, not the pipe dimensions
function PhysicsLineFactoryII:makeNECurvePipe(x, y, r, g, tag)
  -- Using 8 line segments; can use more if needed
  -- Connects 9 points using circular intersections 
  -- divided by 5 in both x and y directions
  local d = r / 5;

  local y1 = y - math.sqrt(r^2 - (1*d)^2);
  local y2 = y - math.sqrt(r^2 - (2*d)^2);
  local y3 = y - math.sqrt(r^2 - (3*d)^2);
  local y4 = y - math.sqrt(r^2 - (4*d)^2);
  local y5 = y - math.sqrt(r^2 - (5*d)^2);
  local x6 = x + math.sqrt(r^2 - (3*d)^2);
  local x7 = x + math.sqrt(r^2 - (2*d)^2);
  local x8 = x + math.sqrt(r^2 - (1*d)^2);

  -- Outside curve
  cst = {
   { x, y-r, x+1*d, y1, },
   { x+1*d, y1, x+2*d, y2, },
   { x+2*d, y2, x+3*d, y3, },
   { x+3*d, y3, x+4*d, y4, },
   { x+4*d, y4, x6, y-3*d, },
   { x6, y-3*d, x7, y-2*d, },
   { x7, y-2*d, x8, y-1*d, },
   { x8, y-1*d, x+r, y, },
  };
  for j=1,#cst do
    local sh = cst[j];
    self:makePhysicsLine(sh[1],sh[2],sh[3],sh[4],tag);
  end

  -- g is girth of the pipe itself
  r = r - g;
  d = r / 5;

  local y1 = y - math.sqrt(r^2 - (1*d)^2);
  local y2 = y - math.sqrt(r^2 - (2*d)^2);
  local y3 = y - math.sqrt(r^2 - (3*d)^2);
  local y4 = y - math.sqrt(r^2 - (4*d)^2);
  local y5 = y - math.sqrt(r^2 - (5*d)^2);
  local x6 = x + math.sqrt(r^2 - (3*d)^2);
  local x7 = x + math.sqrt(r^2 - (2*d)^2);
  local x8 = x + math.sqrt(r^2 - (1*d)^2);

  -- Inside curve
  cst = {
   { x, y-r, x+1*d, y1, },
   { x+1*d, y1, x+2*d, y2, },
   { x+2*d, y2, x+3*d, y3, },
   { x+3*d, y3, x+4*d, y4, },
   { x+4*d, y4, x6, y-3*d, },
   { x6, y-3*d, x7, y-2*d, },
   { x7, y-2*d, x8, y-1*d, },
   { x8, y-1*d, x+r, y, },
  };
  for j=1,#cst do
    local sh = cst[j];
    self:makePhysicsLine(sh[1],sh[2],sh[3],sh[4],tag);
  end
end; 

function PhysicsLineFactoryII:makeNWCurvePipe(x, y, r, g, tag)
  -- Using 8 line segments; can use more if needed
  -- Connects 9 points using circular intersections 
  -- divided by 5 in both x and y directions
  local d = -r / 5;

  local y1 = y - math.sqrt(r^2 - (1*d)^2);
  local y2 = y - math.sqrt(r^2 - (2*d)^2);
  local y3 = y - math.sqrt(r^2 - (3*d)^2);
  local y4 = y - math.sqrt(r^2 - (4*d)^2);
  local y5 = y - math.sqrt(r^2 - (5*d)^2);
  local x6 = x - math.sqrt(r^2 - (3*d)^2);
  local x7 = x - math.sqrt(r^2 - (2*d)^2);
  local x8 = x - math.sqrt(r^2 - (1*d)^2);

  -- Outside curve
  cst = {
   { x, y-r, x+1*d, y1, },
   { x+1*d, y1, x+2*d, y2, },
   { x+2*d, y2, x+3*d, y3, },
   { x+3*d, y3, x+4*d, y4, },
   { x+4*d, y4, x6, y+3*d, },
   { x6, y+3*d, x7, y+2*d, },
   { x7, y+2*d, x8, y+1*d, },
   { x8, y+1*d, x-r, y, },
  };
  for j=1,#cst do
    local sh = cst[j];
    self:makePhysicsLine(sh[1],sh[2],sh[3],sh[4],tag);
  end

  -- g is girth of the pipe itself
  r = r - g;
  d = -r / 5;
  local y1 = y - math.sqrt(r^2 - (1*d)^2);
  local y2 = y - math.sqrt(r^2 - (2*d)^2);
  local y3 = y - math.sqrt(r^2 - (3*d)^2);
  local y4 = y - math.sqrt(r^2 - (4*d)^2);
  local y5 = y - math.sqrt(r^2 - (5*d)^2);
  local x6 = x - math.sqrt(r^2 - (3*d)^2);
  local x7 = x - math.sqrt(r^2 - (2*d)^2);
  local x8 = x - math.sqrt(r^2 - (1*d)^2);

  -- Inside curve
  cst = {
   { x, y-r, x+1*d, y1, },
   { x+1*d, y1, x+2*d, y2, },
   { x+2*d, y2, x+3*d, y3, },
   { x+3*d, y3, x+4*d, y4, },
   { x+4*d, y4, x6, y+3*d, },
   { x6, y+3*d, x7, y+2*d, },
   { x7, y+2*d, x8, y+1*d, },
   { x8, y+1*d, x-r, y, },
  };
  for j=1,#cst do
    local sh = cst[j];
    self:makePhysicsLine(sh[1],sh[2],sh[3],sh[4],tag);
  end
end;

function PhysicsLineFactoryII:makeSWCurvePipe(x, y, r, g, tag)
  -- Using 8 line segments; can use more if needed
  -- Connects 9 points using circular intersections 
  -- divided by 5 in both x and y directions
  local d = -r / 5;

  local y1 = y + math.sqrt(r^2 - (1*d)^2);
  local y2 = y + math.sqrt(r^2 - (2*d)^2);
  local y3 = y + math.sqrt(r^2 - (3*d)^2);
  local y4 = y + math.sqrt(r^2 - (4*d)^2);
  local y5 = y + math.sqrt(r^2 - (5*d)^2);
  local x6 = x - math.sqrt(r^2 - (3*d)^2);
  local x7 = x - math.sqrt(r^2 - (2*d)^2);
  local x8 = x - math.sqrt(r^2 - (1*d)^2);

  -- Outside curve
  cst = {
   { x, y+r, x+1*d, y1, },
   { x+1*d, y1, x+2*d, y2, },
   { x+2*d, y2, x+3*d, y3, },
   { x+3*d, y3, x+4*d, y4, },
   { x+4*d, y4, x6, y-3*d, },
   { x6, y-3*d, x7, y-2*d, },
   { x7, y-2*d, x8, y-1*d, },
   { x8, y-1*d, x-r, y, },
  };
  for j=1,#cst do
    local sh = cst[j];
    self:makePhysicsLine(sh[1],sh[2],sh[3],sh[4],tag);
  end

  -- g is girth of the pipe itself
  r = r - g;
  d = -r / 5;
  local y1 = y + math.sqrt(r^2 - (1*d)^2);
  local y2 = y + math.sqrt(r^2 - (2*d)^2);
  local y3 = y + math.sqrt(r^2 - (3*d)^2);
  local y4 = y + math.sqrt(r^2 - (4*d)^2);
  local y5 = y + math.sqrt(r^2 - (5*d)^2);
  local x6 = x - math.sqrt(r^2 - (3*d)^2);
  local x7 = x - math.sqrt(r^2 - (2*d)^2);
  local x8 = x - math.sqrt(r^2 - (1*d)^2);

  -- Inside curve
  cst = {
   { x, y+r, x+1*d, y1, },
   { x+1*d, y1, x+2*d, y2, },
   { x+2*d, y2, x+3*d, y3, },
   { x+3*d, y3, x+4*d, y4, },
   { x+4*d, y4, x6, y-3*d, },
   { x6, y-3*d, x7, y-2*d, },
   { x7, y-2*d, x8, y-1*d, },
   { x8, y-1*d, x-r, y, },
  };
  for j=1,#cst do
    local sh = cst[j];
    self:makePhysicsLine(sh[1],sh[2],sh[3],sh[4],tag);
  end
end;

function PhysicsLineFactoryII:makeSECurvePipe(x, y, r, g, tag)
  -- Using 8 line segments; can use more if needed
  -- Connects 9 points using circular intersections 
  -- divided by 5 in both x and y directions
  local d = r / 5;

  local y1 = y + math.sqrt(r^2 - (1*d)^2);
  local y2 = y + math.sqrt(r^2 - (2*d)^2);
  local y3 = y + math.sqrt(r^2 - (3*d)^2);
  local y4 = y + math.sqrt(r^2 - (4*d)^2);
  local y5 = y + math.sqrt(r^2 - (5*d)^2);
  local x6 = x + math.sqrt(r^2 - (3*d)^2);
  local x7 = x + math.sqrt(r^2 - (2*d)^2);
  local x8 = x + math.sqrt(r^2 - (1*d)^2);

  -- Outside curve
  cst = {
   { x, y+r, x+1*d, y1, },
   { x+1*d, y1, x+2*d, y2, },
   { x+2*d, y2, x+3*d, y3, },
   { x+3*d, y3, x+4*d, y4, },
   { x+4*d, y4, x6, y+3*d, },
   { x6, y+3*d, x7, y+2*d, },
   { x7, y+2*d, x8, y+1*d, },
   { x8, y+1*d, x+r, y, },
  };
  for j=1,#cst do
    local sh = cst[j];
    self:makePhysicsLine(sh[1],sh[2],sh[3],sh[4],tag);
  end

  -- g is girth of the pipe itself
  r = r - g;
  d = r / 5;

  local y1 = y + math.sqrt(r^2 - (1*d)^2);
  local y2 = y + math.sqrt(r^2 - (2*d)^2);
  local y3 = y + math.sqrt(r^2 - (3*d)^2);
  local y4 = y + math.sqrt(r^2 - (4*d)^2);
  local y5 = y + math.sqrt(r^2 - (5*d)^2);
  local x6 = x + math.sqrt(r^2 - (3*d)^2);
  local x7 = x + math.sqrt(r^2 - (2*d)^2);
  local x8 = x + math.sqrt(r^2 - (1*d)^2);

  -- Inside curve
  cst = {
   { x, y+r, x+1*d, y1, },
   { x+1*d, y1, x+2*d, y2, },
   { x+2*d, y2, x+3*d, y3, },
   { x+3*d, y3, x+4*d, y4, },
   { x+4*d, y4, x6, y+3*d, },
   { x6, y+3*d, x7, y+2*d, },
   { x7, y+2*d, x8, y+1*d, },
   { x8, y+1*d, x+r, y, },
  };
  for j=1,#cst do
    local sh = cst[j];
    self:makePhysicsLine(sh[1],sh[2],sh[3],sh[4],tag);
  end
end; 

function PhysicsLineFactoryII:makeSouthHorseshoePipe(x, y, r, g, tag)
  local offset = 2;
  self:makeSECurvePipe(x - offset, y, r, g, tag);
  self:makeSWCurvePipe(x, y, r, g, tag);
   
end; 

function PhysicsLineFactoryII:makeNorthHorseshoePipe(x, y, r, g, tag)
  local offset = 4;
  self:makeNECurvePipe(x - offset, y, r, g, tag);
  self:makeNWCurvePipe(x, y, r, g, tag);
   
end; 

function PhysicsLineFactoryII:makeEastHorseshoePipe(x, y, r, g, tag)
  local offset = 4;
  self:makeNECurvePipe(x, y+offset, r, g, tag);
  self:makeSECurvePipe(x, y, r, g, tag);
   
end; 

function PhysicsLineFactoryII:makeWestHorseshoePipe(x, y, r, g, tag)
  local offset = 4;
  self:makeSWCurvePipe(x, y-offset, r, g, tag);
  self:makeNWCurvePipe(x, y, r, g, tag);
  self:makeHorizPipeLine(x, y-r, offset, g, tag);
  self:makeHorizPipeLine(x, y+r-g-0.5-offset, offset, g, tag);

end; 

function PhysicsLineFactoryII:kill()
  if(not self.alive) then return; end;
  
  for i=1,#self.lines do
    self.lines[i]:removeSelf();
    self.lines[i] = nil;
  end
  
  self.alive = false;
end