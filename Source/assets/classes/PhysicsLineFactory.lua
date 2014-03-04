require('middleclass');

PhysicsLineFactory = class('PhysicsLineFactory')

function PhysicsLineFactory:initialize(physics, layer)
  self.physics = physics;
  self.layer = layer;
  self.lines = {};
  self.alive=true;
end; 

function PhysicsLineFactory:makePhysicsLine(x0,y0,x1,y1,tag)
  local s = {x0,y0,x1,y1};
  local i = display.newImage("images/blank.png");
  self.layer:insert(i);
  self.physics.addBody(i,"static",
  {friction=0,bounce=0.1,density=1,shape=s});
  if(tag ~= nil) then i.tag = tag; end
  self.lines[#self.lines + 1] = i;
end; 
 
function PhysicsLineFactory:makeHorizPipeLine(x,y,w,h,tag)
  self:makePhysicsLine(x,y,x+w,y,tag);
  self:makePhysicsLine(x,y+h,x+w,y+h,tag);
end; 

function PhysicsLineFactory:makeVertPipeLine(x,y,w,h,tag)
  self:makePhysicsLine(x,y,x,y+h,tag);
  self:makePhysicsLine(x+w,y,x+w,y+h,tag);
end; 

function PhysicsLineFactory:makeSWCurvePipeline(x,y,h,tag)

  
  --Inside curve 
  local cst = {
   { x-1, y+h,  x+2, y+0+h, },
   { x+2, y+0+h,  x+5, y+1+h, },
   { x+5, y+1+h,  x+6, y+1+h, },
   { x+6, y+1+h,  x+9, y+3+h, },
   { x+9, y+3+h,  x+11, y+4+h, },
   { x+11, y+4+h,  x+13, y+6+h, },
   { x+13, y+6+h,  x+14, y+9+h, },
   { x+14, y+9+h,  x+15, y+12+h, },
   { x+15, y+12+h,  x+16, y+15+h, },
   { x+16, y+15+h,  x+15, y+16+h, }
  };
  for j=1,#cst do
    local sh = cst[j];
    self:makePhysicsLine(sh[1],sh[2],sh[3],sh[4],tag);
  end
  
  --Outside curve
  cst = {
   { x, y,  x+3, y+0, },
   { x+3, y+0,  x+6, y+1, },
   { x+6, y+1,  x+8, y+1, },
   { x+8, y+1,  x+12, y+3, },
   { x+12, y+3,  x+14, y+4, },
   { x+14, y+4,  x+18, y+7, },
   { x+18, y+7,  x+20, y+9, },
   { x+20, y+9,  x+22, y+11, },
   { x+22, y+11,  x+23, y+13, },
   { x+23, y+13,  x+24, y+17, },
   { x+24, y+17,  x+25, y+20, },
   { x+25, y+20,  x+26, y+23, },
   { x+26, y+23,  x+26, y+25, }
  };
  for j=1,#cst do
    local sh = cst[j];
    self:makePhysicsLine(sh[1],sh[2],sh[3],sh[4],tag);
  end
end;

function PhysicsLineFactory:makeNECurvePipeline(x,y,h,tag)

  
  --Inside curve 
  local cst = {
   { x+h, y,  x+0+h, y+2, },
   { x+0+h, y+2,  x+0+h, y+3, },
   { x+0+h, y+3,  x+1+h, y+5, },
   { x+1+h, y+5,  x+2+h, y+8, },
   { x+2+h, y+8,  x+3+h, y+9, },
   { x+3+h, y+9,  x+4+h, y+11, },
   { x+4+h, y+11,  x+5+h, y+12, },
   { x+5+h, y+12,  x+7+h, y+13, },
   { x+7+h, y+13,  x+8+h, y+14, },
   { x+8+h, y+14,  x+10+h, y+15, },
   { x+10+h, y+15,  x+13+h, y+16, },
   { x+13+h, y+16,  x+15+h, y+17, },
   { x+15+h, y+17,  x+17+h, y+17, },
  };
  for j=1,#cst do
    local sh = cst[j];
    self:makePhysicsLine(sh[1],sh[2],sh[3],sh[4],tag);
  end
  
  --Outside curve
  cst = {
   { x, y,  x+0, y+1, },
   { x+0, y+1,  x+1, y+3, },
   { x+1, y+3,  x+2, y+7, },
   { x+2, y+7,  x+2, y+9, },
   { x+2, y+9,  x+4, y+13, },
   { x+4, y+13,  x+6, y+15, },
   { x+6, y+15,  x+8, y+17, },
   { x+8, y+17,  x+9, y+19, },
   { x+9, y+19,  x+11, y+21, },
   { x+11, y+21,  x+15, y+23, },
   { x+15, y+23,  x+17, y+24, },
   { x+17, y+24,  x+21, y+25, },
   { x+21, y+25,  x+23, y+26, },
   { x+23, y+26,  x+25, y+26, },
   { x+25, y+26,  x+28, y+26, }
  };
  for j=1,#cst do
    local sh = cst[j];
    self:makePhysicsLine(sh[1],sh[2],sh[3],sh[4],tag);
  end
end;

function PhysicsLineFactory:makeEastHorseshoePipeline(x,y,h,tag)

  
  --Inside curve 
  local cst = {
   { x, y+h,  x+-2, y+0+h, },
   { x+-2, y+0+h,  x+-5, y+0+h, },
   { x+-5, y+0+h,  x+-9, y+2+h, },
   { x+-9, y+2+h,  x+-13, y+6+h, },
   { x+-13, y+6+h,  x+-14, y+9+h, },
   { x+-14, y+9+h,  x+-15, y+12+h, },
   { x+-15, y+12+h,  x+-15, y+14+h, },
   { x+-15, y+14+h,  x+-15, y+18+h, },
   { x+-15, y+18+h,  x+-14, y+21+h, },
   { x+-14, y+21+h,  x+-12, y+25+h, },
   { x+-12, y+25+h,  x+-11, y+26+h, },
   { x+-11, y+26+h,  x+-8, y+29+h, },
   { x+-8, y+29+h,  x+-6, y+29+h, },
   { x+-6, y+29+h,  x+-5, y+31+h, },
   { x+-5, y+31+h,  x+-3, y+31+h, },
   { x+-3, y+31+h,  x+1, y+31+h, },
  };
  for j=1,#cst do
    local sh = cst[j];
    self:makePhysicsLine(sh[1],sh[2],sh[3],sh[4],tag);
  end
  
  --Outside curve
  cst = {
    { x, y,  x+-3, y+0, },
    { x+-3, y+0,  x+-5, y+0, },
    { x+-5, y+0,  x+-6, y+1, },
    { x+-6, y+1,  x+-8, y+1, },
    { x+-8, y+1,  x+-11, y+2, },
    { x+-11, y+2,  x+-13, y+3, },
    { x+-13, y+3,  x+-14, y+4, },
    { x+-14, y+4,  x+-16, y+6, },
    { x+-16, y+6,  x+-18, y+7, },
    { x+-18, y+7,  x+-21, y+12, },
    { x+-21, y+12,  x+-22, y+15, },
    { x+-22, y+15,  x+-23, y+16, },
    { x+-23, y+16,  x+-23, y+17, },
    { x+-23, y+17,  x+-24, y+19, },
    { x+-24, y+19,  x+-24, y+21, },
    { x+-24, y+21,  x+-25, y+25, },
    { x+-25, y+25,  x+-25, y+29, },
    { x+-25, y+29,  x+-23, y+33, },
    { x+-23, y+33,  x+-23, y+34, },
    { x+-23, y+34,  x+-21, y+37, },
    { x+-21, y+37,  x+-19, y+41, },
    { x+-19, y+41,  x+-16, y+43, },
    { x+-16, y+43,  x+-14, y+45, },
    { x+-14, y+45,  x+-12, y+47, },
    { x+-12, y+47,  x+-8, y+48, },
    { x+-8, y+48,  x+-5, y+49, },
    { x+-5, y+49,  x+-1, y+50, },
    { x+-1, y+50,  x+1, y+50, }
  };
  for j=1,#cst do
    local sh = cst[j];
    self:makePhysicsLine(sh[1],sh[2],sh[3],sh[4],tag);
  end
end;

function PhysicsLineFactory:makeWestHorseshoePipeline(x,y,h,tag)

  
  --Inside curve 
  local cst = {
   { x, y+h,  x+3, y+0+h, },
   { x+3, y+0+h,  x+6, y+1+h, },
   { x+6, y+1+h,  x+9, y+4+h, },
   { x+9, y+4+h,  x+11, y+6+h, },
   { x+11, y+6+h,  x+12, y+9+h, },
   { x+12, y+9+h,  x+14, y+13+h, },
   { x+14, y+13+h,  x+13, y+18+h, },
   { x+13, y+18+h,  x+13, y+22+h, },
   { x+13, y+22+h,  x+10, y+26+h, },
   { x+10, y+26+h,  x+9, y+29+h, },
   { x+9, y+29+h,  x+5, y+30+h, },
   { x+5, y+30+h,  x+2, y+31+h, },
   { x+2, y+31+h,  x+-2, y+32+h, }
  };
  for j=1,#cst do
    local sh = cst[j];
    self:makePhysicsLine(sh[1],sh[2],sh[3],sh[4],tag);
  end
  
  --Outside curve
  cst = {
   { x, y,  x+2, y+0, },
   { x+2, y+0,  x+6, y+1, },
   { x+6, y+1,  x+9, y+2, },
   { x+9, y+2,  x+12, y+4, },
   { x+12, y+4,  x+15, y+5, },
   { x+15, y+5,  x+17, y+7, },
   { x+17, y+7,  x+19, y+10, },
   { x+19, y+10,  x+21, y+13, },
   { x+21, y+13,  x+23, y+16, },
   { x+23, y+16,  x+24, y+20, },
   { x+24, y+20,  x+25, y+23, },
   { x+25, y+23,  x+24, y+27, },
   { x+24, y+27,  x+24, y+31, },
   { x+24, y+31,  x+22, y+36, },
   { x+22, y+36,  x+20, y+38, },
   { x+20, y+38,  x+18, y+42, },
   { x+18, y+42,  x+13, y+46, },
   { x+13, y+46,  x+9, y+48, },
   { x+9, y+48,  x+5, y+50, },
   { x+5, y+50,  x+2, y+50, },
   { x+2, y+50,  x+-1, y+51, },
   { x+-1, y+51,  x+-4, y+51, }
  };
  for j=1,#cst do
    local sh = cst[j];
    self:makePhysicsLine(sh[1],sh[2],sh[3],sh[4],tag);
  end
end;

function PhysicsLineFactory:kill()
  if(not self.alive) then return; end;
  
  for i=1,#self.lines do
    self.lines[i]:removeSelf();
    self.lines[i] = nil;
  end
  
  self.alive = false;
end