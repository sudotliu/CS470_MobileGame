require('middleclass');
KioskListNode = class('KioskListNode') 

--action: function, the function to perform (nil calls nothing)
--delayBefore: number, the time (in ms) before calling the action (negative or nil for instant/no delay)
--delayAfter: number, the time (in ms) after executing the action before going to the next frame (negative or nil for instant/no delay)
--parent: KioskListNode, the parent (previous) node (nil if at front)
--child: KioskListNode, the child (next) node (nil if at end) 
--autoAdvance: boolean, if true, then when this node executes, it will start the next node
--customData: table, an arbitrary piece of data for this node to hold

function KioskListNode:initialize(action, delayBefore, delayAfter, parent, child, autoAdvance, customData)
  self.running = false;
  self.action = action;
  self.delayBefore = delayBefore;
  self.delayAfter = delayAfter;
  self.parent = parent;
  self.child = child;
  self.autoAdvance = autoAdvance;
  self.customData = customData;
  self.timer = nil;
  self.alive = true;
end

function KioskListNode:kill()
  if(self.timer ~= nil) then
    timer.cancel(self.timer);
    self.timer = nil;
  end
  self.running = false;
  self.action = nil;
  self.delayBefore = nil;
  self.delayAfter = nil;
  self.parent = nil;
  self.child = nil;
  self.autoAdvance = nil;
  self.customData = nil;
  self.timer = nil;
  self.alive = false;
end

--returns true iff this is at the end of the chain (last)
function KioskListNode:isLeaf()
  return self.child == nil;
end

--iteratively walks down the chain to the leaf and returns it
function KioskListNode:getLeaf()
  if(self:isLeaf()) then return self;
  else
    local current = self;
    while(not current:isLeaf()) do
      current = current.child;
    end
    return current;
  end
end

--returns true iff this is at the front of the chain (first)
function KioskListNode:isRoot()
  return self.parent == nil;
end

--iteratively walks up the chain to the root and returns it
function KioskListNode:getRoot()
  if(self:isRoot()) then return self;
  else
    local current = self;
    while(not current:isRoot()) do
      current = current.parent;
    end
    return current;
  end
end

--starts the timer
function KioskListNode:start()
  if(not self.running) then
    self.running = true;
    if(self.delayBefore == nil or self.delayBefore <= 0) then
      self:execute();
    else
      self.timer = timer.performWithDelay(self.delayBefore, function() self:execute(); end, 1);
    end
  end
end

--stops the timer and goes back to the beginning
function KioskListNode:stop()
  if(self.running) then
    if(self.timer~=nil) then timer.cancel(self.timer); end
    self.timer = nil;
    self.running = false;
  end
end
  
--executes the action and starts up second timer
function KioskListNode:execute()
  
  if(self.action~=nil) then self.action(); end
  
  local event = { name = "kioskNodeExecuted", target = Runtime, node = self };
  Runtime:dispatchEvent( event );
  
  if(self.delayAfter == nil or self.delayAfter <= 0) then
    self:advance();
  else   
    self.timer = timer.performWithDelay(self.delayAfter, function()
      self:advance();
    end, 1);
  end
end

--stops this node and starts the next node if auto-advancing
function KioskListNode:advance()  
  local event = { name = "kioskNodeEnded", target = Runtime, node = self };
  Runtime:dispatchEvent( event );
  
  self:stop();
  if(self.autoAdvance and not self:isLeaf()) then self.child:start(); end
end