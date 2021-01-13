
local json = require("json")

function loadPartScript(scene_name)
  --
  -- This function loads a script file and reads it as a set of script assets.
  --

  local scene_file = system.pathForFile("ChapterScripts/" .. scene_name .. ".json", system.ResourceDirectory)
  local file = io.open(scene_file, "r")
  local script = {}
  if file then
    local contents = file:read("*a")
    io.close(file)
    script = json.decode(contents)
  end

  if script == nil or #script == 0 then
    script = {}
  end

  return script
end


function printDebugInformation()
  --
  -- This function prints general debug information, such as memory usage.
  --
  local memUsed = (collectgarbage("count"))
  local texUsed = system.getInfo( "textureMemoryUsed" ) / 1048576 -- Reported in Bytes
 
  print("\n---------MEMORY USAGE INFORMATION---------")
  print("System Memory: ", string.format("%.00f", memUsed), "KB")
  print("Texture Memory:", string.format("%.03f", texUsed), "MB")
  print("------------------------------------------\n")
end