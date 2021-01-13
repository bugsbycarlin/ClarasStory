
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

      Runtime:addEventListener("key", function(event)
        if event.phase == "up" then
          print("key")
          if self.paused == false then
            self:pause()
          else
            self:resume()
          end
        end
      end)
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

  self.chapter_structure = self.chapter_structures[self.current_chapter]

  composer.setVariable("view", self.view)

  self.stage = stage_class.create()
  composer.setVariable("stage", self.stage)

  self.timers = {}
  self.events = {}

  self.start_time = system.getTimer()
  self.pause_time = 0
  self.paused = false

  self.current_part_structure = self.chapter_structure.flow[self.chapter_structure.first_part]

  print(self.current_part_structure.name)
  print(self.current_part_structure.type)

  self:createPart()

  self.registerTimer(timer.performWithDelay(33, function() 
    self:update()
  end, 0))

  self.registerTimer(timer.performWithDelay(3000, function() 
    printDebugInformation()
  end, 0))

end


function scene:createPart()
  -- This function makes a new part from current_part_structure
  if self.current_part_structure.type == "scripted" then
    if self.scripted_part == nil then
      self.scripted_part = require("Source.scripted_part")
    end
    self.current_part = self.scripted_part:create()
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


function scene:skippart()

  print(self:getTime())

  -- animation.setPosition("finish_if_skipped", 100000)
end


function scene:gotoNextpart()


end


function scene:endChapter()


end


function scene:performBackgroundLoad()


end


function scene:computeBackgroundLoad()


end


function scene:registerEvent()


end


function scene:destroyEvents()


end


function scene:registerTimer()


end


function scene:destroyTimers()


end


function scene:destroy(event)
  --
  -- Destroy things before removing scene's view
  --
end
 
scene:addEventListener("show", scene)
scene:addEventListener("destroy", scene)
 
return scene