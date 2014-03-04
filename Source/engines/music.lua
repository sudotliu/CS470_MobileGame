-- This sets up the music engine of the game ------------------------------
print("Loading engines.music...");

music = {
  menu = audio.loadStream("audio/music/mainmenu.mp3"),
  map = audio.loadStream("audio/music/map.mp3"),
  stage1 = audio.loadStream("audio/music/stage1.mp3"),
  stage2 = audio.loadStream("audio/music/stage2.mp3"),
  stage3 = audio.loadStream("audio/music/stage3.mp3"),
  stage4 = audio.loadStream("audio/music/stage4.mp3"),
  credits = audio.loadStream("audio/music/newcredits.mp3"),
};

print("Loaded engines.music!\n");
---------------------------------------------------------------------------