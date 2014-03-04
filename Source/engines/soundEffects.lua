-- This sets up the soundEffects engine of the game -----------------------
print("Loading engines.soundEffects...");

sounds = 
{
  blip = audio.loadSound("audio/sfx/blip.wav"),
  valve = audio.loadSound("audio/sfx/valve.wav"),
  dismiss = audio.loadSound("audio/sfx/dismiss.wav"),
  water = audio.loadSound("audio/sfx/water.mp3"),
  pump = audio.loadSound("audio/sfx/pump.wav"),
  fin = audio.loadSound("audio/sfx/fin.wav"),
};

--Channel 1 reserved for music
--Channel 2 reserved for water
--Channel 3 reserved for pump
function playSoundEffect(sfx, loops, channel)
  if(channel == nil) then
    channel = audio.findFreeChannel(4);
    if(channel == 0) then return; end
  end
  
  if(loops==nil) then loops=0; end
  audio.stop(channel);
  audio.play(sfx, {channel=channel, loops=loops});
end

print("Loaded engines.soundEffects!\n");
---------------------------------------------------------------------------