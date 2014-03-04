--on: boolean, true iff the kiosk is running
--beginningNode: KioskListNode, the node at the beginning of the chain
--currentNode: KioskListNode, the current node that's currently running the kiosk
--lastNode: KioskListNode, the last node of the kiosk, should go back to the menu screen and turn itself off
--labels: table, stirng-indexed, values are KioskListNodes
--frameNodes: table, int-indexed, values are KioskListNodes

kiosk = {
  on=false,
  beginningNode = nil,
  currentNode = nil,
  lastNode = nil,
  labels = {},
  frameNodes = {},
  overlay = nil
};

--Called when a kiosk node is executed
function kioskNodeEnded(event)
  kiosk.currentNode = event.node.child;
  if(kiosk.currentNode == nil) then stopKiosk(); end
end

function kioskTouch(event)
  if(kiosk~=nil and kiosk.on and event.phase=='began' and event.kiosk==nil) then
    stopKiosk();
  end
end

function stopKiosk()
  if(kiosk.on) then
    if(kiosk.currentNode~=nil) then kiosk.currentNode:stop(); end

    Runtime:removeEventListener("kioskNodeEnded", kioskNodeEnded);
    Runtime:removeEventListener("touch",  kioskTouch);
    
    display.remove(kiosk.overlay);
    kiosk.overlay=nil;
  
    kiosk.currentNode = nil;
    kiosk.on = false;
    
    storyboard.gotoScene( "assets.splash_screen", "crossFade", 250 );
    
    print('Kiosk mode off!');
    print('*************************************\n');
  end
end

function clearKiosk()
  stopKiosk();
  kiosk = {
    on=false,
    beginningNode = nil,
    currentNode = nil,
    lastNode = nil,
    labels = {},
    frameNodes = {},
    overlay = nil
  };
end
clearKiosk();

function pushKioskFrame(action, delayBefore, delayAfter, label)
  --First node
  if(#kiosk.frameNodes <= 0 or kiosk.beginningNode==nil) then
    local firstFrame = KioskListNode:new(action,delayBefore, delayAfter, nil,nil, true, {label=label});
    if(label~=nil) then kiosk.labels[label] = firstFrame; end
    kiosk.beginningNode = firstFrame;
    kiosk.lastNode = firstFrame;
    kiosk.frameNodes[1] = firstFrame;
  --Not first node
  else
    local newFrame = KioskListNode:new(action,delayBefore, delayAfter, kiosk.frameNodes[#kiosk.frameNodes] ,nil, true, {label=label});
    if(label~=nil) then kiosk.labels[label] = newFrame; end
    kiosk.lastNode.child = newFrame;
    kiosk.lastNode = newFrame;
    kiosk.frameNodes[#kiosk.frameNodes+1] = newFrame;
  end
end

function redirectKioskNode(fromLabel, toLabel)
  if(fromLabel == nil or toLabel == nil or kiosk.labels[fromLabel] == nil or kiosk.labels[toLabel] == nil) then
    kiosk.labels[fromLabel].child = kiosk.labels[toLabel];
  end
end

function startKiosk(restart)  
  if(kiosk.on and not restart) then return; end  
  
  clearMemory();

  Runtime:addEventListener("kioskNodeEnded", kioskNodeEnded);
  Runtime:addEventListener("touch",  kioskTouch);
  
  kiosk.on = true;

  print('Kiosk mode on!');
  print('*************************************\n');
  
  kiosk.overlay = display.newImage('images/kiosk/kioskoverlay.png',true);
  kiosk.overlay.width = metrics.size.width;
  kiosk.overlay.height = kiosk.overlay.height/2;
  kioskLayer:insert(kiosk.overlay);
  kiosk.overlay.x = metrics.center.x;
  kiosk.overlay.y = metrics.size.height - kiosk.overlay.height/2;
  
  if(restart and kiosk.beginningNode~=nil) then
    kiosk.currentNode = kiosk.beginningNode;
    KioskListNode.start(kiosk.currentNode);
  elseif(not restart and kiosk.currentNode ~= nil ) then 
    kiosk.currentNode.start();
  else stopKiosk(); end
end