
local composer = require("composer")
local animation = require("plugin.animation")

local sound_info = require("Source.sound_info")


scripted_part = {}
scripted_part.__index = scripted_part

--
-- This is the definition for a scripted part. It handles the part specific functions
-- of a scripted part, including updating the stage per the script, and waiting
-- for timing/music completion to ask the Chapter to move to the next scene.
--

function scripted_part:create()

  local object = {}
  setmetatable(object, scripted_part)

  object.sprite_list = {}


  function object:initialize()
    self.chapter = composer.getVariable("chapter")
    self.stage = composer.getVariable("stage")
    self.part_structure = self.chapter.current_part_structure
    self.script = self.part_structure.script
    self.additional_actions = self.part_structure.additional_actions

    self.last_update_time = 0

    if self.part_structure.music ~= nil and self.part_structure.music ~= "" then

      self.music = audio.loadStream("Sound/" .. sound_info[self.part_structure.music].file_name)
      audio.play(self.music, {loops = 0, onComplete=function(event)
        if event.completed == true then
          self:nextScene()
        end
      end})
    else
      -- throw an error, because scripted scenes are supposed to have music.
      error("Scripted parts require music")
    end
  end

  function object:update()
    current_time = self.chapter:getTime()

    for i = 1, #self.script do
      script_element = self.script[i]
      if not self.stage:has(script_element.id) and self.last_update_time <= script_element.start_time and current_time >= script_element.start_time then
        local x = self.stage:perform(script_element)
        print(x.id)
      end    
    end

    for i = 1, #self.additional_actions do
      action = self.additional_actions[i]
      if self.last_update_time <= action.start_time and current_time >= action.start_time then
        action.action(self)
      end    
    end

    self.last_update_time = current_time

  end

  function object:nextScene()
    self.chapter:gotoNextpart()
  end

  object:initialize()
  return object
end

return scripted_part