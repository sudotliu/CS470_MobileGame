print("\n----------------------------------------------\n");
print("Loading config...");
print("  Application...");
application = {
  content = {
    width = 320,
    height = 512,
    scale = "letterbox",
    xAlign = "center",
    yAlign = "center",
    imageSuffix = {
      ["@2x"] = 1.5,
      ["@4x"] = 3.0,
    },
  },
  notification = {
    iphone = {
      types = {
          "badge", "sound", "alert"
      }
    }
  }
}

print("  Model...");
local model = system.getInfo("model");

if string.sub(model,1,4) == "iPad" then
  application.content.width = 360;
  application.content.height = 480;
elseif string.sub(system.getInfo("model"),1,2) == "iP" and display.pixelHeight > 960 then
  application.content.width = 320;
  application.content.height = 568;
elseif string.sub(system.getInfo("model"),1,2) == "iP" then
  application.content.width = 320;
  application.content.height = 480;
elseif display.pixelHeight / display.pixelWidth > 1.72 then
  application.content.width = 320;
  application.content.height = 570;
end
print("Loaded config!\n");