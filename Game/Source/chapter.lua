
local composer = require("composer")
local animation = require("plugin.animation")

local stage_class = require("Source.stage")
local utilities = require("Source.utilities")

local scene = composer.newScene()

--
-- This is the definition for a chapter. Chapter manages the linking structures
-- between different parts in a chapter. This includes holding and tearing down
-- all timers, all animations, and all events. It also includes background loading
-- and unloading, end of chapter cleanup, pause, resume, skip (and the timing calculations
-- to make these work), debug printing on a slow timer, and last but not least,
-- the transition between parts.
--

function scene:show(event)
  --
  -- This function runs when the scene has loaded
  --

    -- Remove any other scenes
    composer.removeHidden()

    -- White background
    display.setDefault("background", 1, 1, 1)
 
    if (event.phase == "did") then
      self:initializeChapter()
      self:initializeNav()
      self:createPart()
      self:startPart()  
    end    
end


function scene:initializeChapter()
  --
  -- This function starts the chapter, loading all the background information,
  -- setting up the managing structures, creating the first part, and starting it.
  --
  composer.setVariable("chapter", self)

  self.chapter_structures = composer.getVariable("chapter_structures")
  self.sprite_cache = composer.getVariable("sprite_cache")
  self.sprite_info = composer.getVariable("sprite_info")
  self.current_chapter = composer.getVariable("current_chapter")
  self.loader = composer.getVariable("loader")
  self.editor_mode_allowed = composer.getVariable("editor_mode_allowed")

  self.chapter_structure = self.chapter_structures[self.current_chapter]

  composer.setVariable("view", self.view)

  self.stage = stage_class.create()
  composer.setVariable("stage", self.stage)

  if self.editor_mode_allowed then
    editor = require("Source.editor")
    editor:augment(self)
  end

  self.timers = {}
  self.events = {}

  self.snapshots = {}

  self.current_part_structure = self.chapter_structure.flow[self.chapter_structure.first_part]

  print(self.current_part_structure.name)
  print(self.current_part_structure.type)
end


function scene:initializeNav()
  self.nav_group = display.newGroup()
  self.nav_group.alpha = 0.5
  self.view:insert(self.nav_group)

  local nav_size = 48

  local home_button = display.newImageRect(self.nav_group, "Art/Nav/home_button.png", nav_size, nav_size)
  home_button.x = 0.5*nav_size
  home_button.y = display.contentHeight - 0.5*nav_size

  local skip_back_button = display.newImageRect(self.nav_group, "Art/Nav/skip_back_button.png", nav_size, nav_size)
  skip_back_button.x = 1.5*nav_size
  skip_back_button.y = display.contentHeight - 0.5*nav_size

  local pause_button = display.newImageRect(self.nav_group, "Art/Nav/pause_button.png", nav_size, nav_size)
  pause_button.x = 2.5*nav_size
  pause_button.y = display.contentHeight - 0.5*nav_size

  local play_button = display.newImageRect(self.nav_group, "Art/Nav/play_button.png", nav_size, nav_size)
  play_button.x = 2.5*nav_size
  play_button.y = display.contentHeight - 0.5*nav_size
  play_button.isVisible = false

  local skip_forward_button = display.newImageRect(self.nav_group, "Art/Nav/skip_forward_button.png", nav_size, nav_size)
  skip_forward_button.x = 3.5*nav_size
  skip_forward_button.y = display.contentHeight - 0.5*nav_size

  local refresh_button = display.newImageRect(self.nav_group, "Art/Nav/refresh_button.png", nav_size, nav_size)
  refresh_button.x = 4.5*nav_size
  refresh_button.y = display.contentHeight - 0.5*nav_size

  if self.editor_mode_allowed then
    local gear_button = display.newImageRect(self.nav_group, "Art/Nav/gear_button.png", nav_size, nav_size)
    gear_button.x = 5.5*nav_size
    gear_button.y = display.contentHeight - 0.5*nav_size

    gear_button.event = gear_button:addEventListener("tap", function(event)
      if self.editor_mode == false then
        self:startEditor()
      else
        self:stopEditor()
      end
    end)
  end

  home_button.event = home_button:addEventListener("tap", function(event)
    if self.paused == false then
      self:pause()
    end
    self:endChapter()
  end)

  skip_back_button.event = skip_back_button:addEventListener("tap", function(event)
    self:skipToPreviousPart()
  end)

  pause_button.event = pause_button:addEventListener("tap", function(event)
    if self.paused == false then
      self:pause()
    end
    pause_button.isVisible = false
    play_button.isVisible = true
  end)

  play_button.event = play_button:addEventListener("tap", function(event)
    if self.paused == true then
      self:resume()
    end
    play_button.isVisible = false
    pause_button.isVisible = true
  end)

  skip_forward_button.event = skip_forward_button:addEventListener("tap", function(event)
    self:skipToNextPart()
  end)

  refresh_button.event = refresh_button:addEventListener("tap", function(event)
    self:resetCurrentPart()
  end)

  self.pause_button = pause_button
  self.play_button = play_button
end


function scene:createPart()
  -- This function makes a new part from current_part_structure
  if self.current_part_structure.type == "scripted" then
    self:lightNav()
    if self.scripted_part == nil then
      self.scripted_part = require("Source.scripted_part")
    end

    self.current_part = self.scripted_part:create()
    self.current_part:initialize()

    self:performBackgroundLoad()
  elseif self.current_part_structure.type == "mandala" then
    self:darkNav()
    if self.mandala_part == nil then
      self.mandala_part = require("Source.mandala_part")
    end
    self.current_part = self.mandala_part:create()
    self.current_part:initialize()
  end
end


function scene:startPart()
  self.start_time = system.getTimer()
  self.pause_time = 0
  self.pause_start = nil
  self.paused = false
  self.pause_button.isVisible = true
  self.play_button.isVisible = false

  self:registerTimer(timer.performWithDelay(33, function() 
    self:update()
  end, 0))

  self:registerTimer(timer.performWithDelay(3000, function() 
    printDebugInformation()
  end, 0))
end


function scene:lightNav()
  for i = 1, self.nav_group.numChildren do
    self.nav_group[i]:setFillColor(1,1,1)
  end
end


function scene:darkNav()
  for i = 1, self.nav_group.numChildren do
    self.nav_group[i]:setFillColor(0,0,0)
  end
end


function scene:update()
  --
  -- This function updates the current part and ... uh...
  -- ... anything else that needs regular updating.
  --
  if self.current_part ~= nil then
    self.current_part:update()
  end

  self.stage:update()
end


function scene:pause()
  --
  -- This function pauses, which stops time from counting up, and pauses all timers (including update)
  --
  print("pausing")
  if self.paused == false and self.pause_start == nil then
    self.paused = true;
    self.pause_start = system.getTimer()

    audio.pause()

    animation.pause("game")

    timer.pauseAll()
  end
end


function scene:resume()
  --
  -- This function resumes from a pause, which starts counting time again,
  -- and 
  print("resuming")
  if self.paused == true and self.pause_start ~= nil then
    self.pause_time = self.pause_time + system.getTimer() - self.pause_start
    self.pause_start = nil
    self.paused = false;

    audio.resume()

    animation.resume("game")

    timer.resumeAll()
  end
end


function scene:getTime()
  if self.paused == false then
    return system.getTimer() - self.start_time - self.pause_time
  else
    -- if we're paused, we need to factor in time since pause start
    return self.pause_start - self.start_time - self.pause_time
  end
end


-- function scene:setTime()


-- end


function scene:skipToPreviousPart()
  --
  -- Skip back to the previous part of the chapter.
  --
  if self.current_part_structure.prev ~= nil then
    animation.setPosition("game", 500000)
    audio.stop()

    self:destroyEvents()
    self:destroyTimers()

    self.stage:resetStage()

    if self.snapshots[self.current_part_structure.prev] ~= nil then
      self.stage:restoreSnapshot(self.snapshots[self.current_part_structure.prev])
    end

    self.current_part_structure = self.chapter_structure.flow[self.current_part_structure.prev]

    self:createPart()

    self:startPart()
  else
    self:resetCurrentPart()
  end

end


function scene:skipToNextPart()
  --
  -- Skip ahead to the next part of the chapter.
  -- This requires some cleanup to make sure things look like they're supposed to look at the end of this part.
  --

  -- deactivate the nav for a moment and put up the spinny loading icon
    -- deactivate here

  animation.setPosition("game", 500000)
  audio.stop()

  self:pause()

  -- make necessary new sprites and set necessary old ones to inactive
  self.current_part:skipToEnd()

  -- update the stage, forcing a recycle of the dead old sprites
  self.stage:update()

  -- take a moment to do a short load
    -- short load here

  self:resume()

  -- reactive the nav
    -- reactivate here

  self:gotoNextPart()
end


function scene:resetCurrentPart()
  animation.setPosition("game", 500000)
  audio.stop()

  self:destroyEvents()
  self:destroyTimers()

  self.stage:resetStage()

  if self.snapshots[self.current_part_structure.name] ~= nil then
    self.stage:restoreSnapshot(self.snapshots[self.current_part_structure.name])
  end

  self:createPart()

  self:startPart()
end


function scene:gotoNextPart()
  --
  -- Go to the next part of the chapter.
  --
  self:destroyEvents()
  self:destroyTimers()

  if self.current_part_structure.cleanup == true then
    self.stage:resetStage()
  end

  -- Take a snapshot and save it under the label of the next part.
  -- We'll use this for refreshes and backwards skips.
  if self.current_part_structure.next ~= nil then
    self.snapshots[self.current_part_structure.next] = self.stage:takeSnapshot()
  end

  if self.current_part_structure.next ~= nil then
    self.current_part_structure = self.chapter_structure.flow[self.current_part_structure.next]

    if self.current_part_structure == nil then
      error("Cannot find definition for next part of chapter!")
    end

    print(self.current_part_structure.name)
    print(self.current_part_structure.type)

    self:createPart()

    self:startPart()
  else
    self:endChapter()
  end
end


function scene:endChapter()
  audio.stop()
  self:destroyEvents()
  self:destroyTimers()
  self.stage:resetStage()
  self.loader:unloadAll()
  composer.gotoScene("Source.chapter_select")
end


function scene:performBackgroundLoad()
  local items = self:computeBackgroundLoad()
  local load_items = items[1]
  local unload_items = items[2]

  self.loader:backgroundLoad(
    self.sprite_cache,
    self.sprite_info,
    load_items,
    500,
    function(percent) end,
    function() print("Finished loading items in the background!") end)

  self.loader:unloadItems(unload_items)
end


function scene:computeBackgroundLoad()
  --
  -- This function decides the content to send to the next backgroud load task.
  --

  -- Find the next scripted part. We will load content from this.
  scene_to_load = self.current_part_structure.next
  while scene_to_load ~= nil do
    structure = self.chapter_structure.flow[scene_to_load]
    if structure.type == "scripted" then
      break
    else
      scene_to_load = structure.next
    end
  end

  background_load_dict = {}
  if scene_to_load ~= nil then
    script = self.chapter_structure.flow[scene_to_load].script
    for i = 1, #script do
      background_load_dict[script[i].picture] = 1
    end
  end
  background_load_items = {}
  for picture, val in pairs(background_load_dict) do
    if self.sprite_info[picture] ~= nil and self.sprite_cache[picture] == nil then
      print("Adding " .. picture .. " to load items.")
      table.insert(background_load_items, picture)
    end
  end

  background_unload_items = {}
  return {background_load_items, background_unload_items}
end


function scene:registerEvent(new_event)
  table.insert(self.events, new_event)
end


function scene:destroyEvents()
  for i = 1, #self.events do
    -- ???
  end
  self.events = {}
end


function scene:registerTimer(new_timer)
  print("Registering")
  print(new_timer)
  table.insert(self.timers, new_timer)
end


function scene:destroyTimers()
  for i = 1, #self.timers do
    timer.cancel(self.timers[i])
  end
  self.timers = {}
end


function scene:destroy(event)
  --
  -- Destroy things before removing scene's view
  --
  display.remove(self.nav_group)
end
 
scene:addEventListener("show", scene)
scene:addEventListener("destroy", scene)
 
return scene