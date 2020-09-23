
loader = {}
loader.__index = loader

function loader:create()

  local object = {}
  setmetatable(object, loader)

  function object:backgroundLoad(
    sprites,
    picture_info,
    load_list,
    unload_list,
    background_delay,
    display_callback,
    finished_callback)

    self.sprites = sprites
    self.picture_info = picture_info

    self.partialLoadNumber = 1
    self.partialLoadObjects = load_list

    self.unload_list = unload_list

    self.background_delay = background_delay
    self.display_callback = display_callback
    self.finished_callback = finished_callback

    if #self.partialLoadObjects == 0 then
      return
    end

    Runtime:addEventListener("enterFrame", function() self.display_callback(self:percent()) end)

    self.load_start_time = system.getTimer()

    self:partialLoad()

    self:unloadItems()
  end

  function object:partialLoad()

    picture_name = self.partialLoadObjects[self.partialLoadNumber]
    if string.len(picture_name) >= 1 then
      file_name = self.picture_info[picture_name]["file_name"]
      sheet = self.picture_info[picture_name]["sheet"]
      self.sprites[picture_name] = graphics.newImageSheet("Art/" .. file_name, sheet)
    end
    print("Loaded " .. picture_name)

    self.partialLoadNumber = self.partialLoadNumber + 1
    if self.partialLoadNumber <= #self.partialLoadObjects then
      timer.performWithDelay(self.background_delay, function() self:partialLoad() end)
    else
      Runtime:removeEventListener("enterFrame", self.display_callback)
      self.display_callback(100)
      local load_time_total = system.getTimer() - self.load_start_time
      print("Load time was " .. load_time_total)
      self.finished_callback()
    end
  end

  function object:percent()
    return math.floor((self.partialLoadNumber / #self.partialLoadObjects) * 100)
  end

  function object:unloadItems()
    if self.unload_list == nil then
      return
    end

    for i = 1, #self.unload_list do
      unload_item = self.unload_list[i]
      print("Unloading " .. unload_item)
      if self.sprites[unload_item] ~= nil then
        self.sprites[unload_item] = nil
      end
    end
  end

  return object
end

return loader