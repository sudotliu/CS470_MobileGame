local loadsave = require("lib.loadsave");

function loadMemory()
  storage = loadsave.loadTable("storage.json");
end

function saveMemory()
  loadsave.saveTable(storage, "storage.json")
end;

--Default storage elements
function clearMemory()
  storage = {
    highScores = {0,0,0,0},
    upToStage = 1
  }
end

loadMemory();
if(storage==nil) then clearMemory(); end

