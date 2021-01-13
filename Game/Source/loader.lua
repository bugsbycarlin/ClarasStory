
loader = {}
loader.__index = loader

--
-- This is the definition for a loader.
-- The loader grabs sprite assets from disk and loads them into memory.
-- It also removes objects when they're no longer needed.
--
function loader:create()

  local object = {}
  setmetatable(object, loader)


  function object:backgroundLoad(
    sprite_cache, -- object for referencing sprites stored in memory
    sprite_info, -- name indexed collection of info sheets about the sprites
    load_list, -- list of sprite names to load
    background_delay, -- time in milliseconds to delay between loads (for smoothness!)
    display_callback, -- callback function to display loading progress
    finished_callback) -- callback function to run when loading completes
    --
    -- Prepare and start a new background loading process.
    -- I don't know what would happen if you called this method
    -- and then called it again before the process was finished.
    --

    self.sprite_cache = sprite_cache
    self.sprite_info = sprite_info

    self.current_load_number = 1 -- counter for which thing is loading
    self.load_list = load_list

    self.background_delay = background_delay
    self.display_callback = display_callback
    self.finished_callback = finished_callback

    if self.load_list == nil or #self.load_list == 0 then
      return
    end

    -- Call the display callback every frame during loading.
    Runtime:addEventListener("enterFrame", function() self.display_callback(self:percent()) end)

    self:partialLoad()
  end


  function object:partialLoad()
    --
    -- This function loads one thing, then incrememnts the load number,
    -- then either sets up the next load, or stops the display_callback function (at 100)
    -- and runs the finished_callback.
    --

    sprite_name = self.load_list[self.current_load_number]
    self:loadSprite(sprite_name)

    self.current_load_number = self.current_load_number + 1
    if self.current_load_number <= #self.load_list then
      timer.performWithDelay(self.background_delay, function() self:partialLoad() end)
    else
      Runtime:removeEventListener("enterFrame", self.display_callback)
      self.display_callback(100)
      self.finished_callback()
    end
  end


  function object:loadSprite(sprite_name)
    --
    -- This function loads one sprite into memory
    --
    if sprite_name ~= nil and string.len(sprite_name) >= 1 then
      file_name = self.sprite_info[sprite_name]["file_name"]
      sheet = self.sprite_info[sprite_name]["sheet"]
      self.sprite_cache[sprite_name] = graphics.newImageSheet("Art/" .. file_name, sheet)
    end
  end


  function object:percent()
    --
    -- This function returns percent loaded
    --
    return math.min(100,math.floor((self.current_load_number / #self.load_list) * 100))
  end


  function object:unloadItems(unload_list)
    --
    -- This function unloads the items on the unload_list
    --
    if unload_list == nil then
      return
    end

    for i = 1, #unload_list do
      unload_item = unload_list[i]
      if self.sprite_cache[unload_item] ~= nil then
        self.sprite_cache[unload_item] = nil
      end
    end
  end


  function object:unloadAll()
    --
    -- This function unloads everything.
    --
    for sprite_name, sprite_value in pairs(self.sprite_cache) do
      self.sprite_cache[sprite_name] = nil
    end
  end

  return object
end

return loader