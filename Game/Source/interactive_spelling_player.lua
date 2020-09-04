
local composer = require("composer")
local json = require("json")
local lfs = require("lfs")

local picture_info = require("Source.pictures")
local sound_info = require("Source.sounds")

local sketch_sprites_class = require("Source.sketch_sprites")

local scene = composer.newScene()

local sketch_sprites

local sprite = {}

local script_asset_count = 0
local script_assets = {}

local mode = nil

local current_time = 0
local start_performance_time = 0
local stored_performance_time = 0
local total_performance_time = 0

local update_timer = nil

local load_start_time = 0

local music_loop = nil

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create(event)

  local sceneGroup = self.view
  -- Code here runs when the scene is first created but has not yet appeared on screen
end


-- show()
function scene:show(event)

  self.sceneGroup = self.view
  local phase = event.phase

  if (phase == "will") then
    -- Code here runs when the scene is still off screen (but is about to come on screen)
    
  elseif (phase == "did") then
    -- Code here runs when the scene is entirely on screen

    self.performanceAssetGroup = display.newGroup()
    self.sceneGroup:insert(self.performanceAssetGroup)

    sketch_sprites = sketch_sprites_class:create()


    display.setDefault("background", 1, 1, 1)

    sprite = composer.getVariable("sprite")

    self.info = composer.getVariable("interactive_settings")
    self.chapter = composer.getVariable("chapter")
    self.next_scene = composer.getVariable("next_scene")

    print("Making scene for " .. self.info.word)

    current_time = 0
    start_performance_time = 0
    stored_performance_time = 0
    total_performance_time = 0

    self:startScene()

    self.sketch_sprite_timer = timer.performWithDelay(35, function() 
      sketch_sprites:update(mode, total_performance_time)
    end, 0)

    -- Runtime:addEventListener("key", function(event) self:handleKeyboard(event) end)

  end
end

function scene:startScene()
  mode = "intro"

  local info = self.info

  self.current_letter_number = 1

  music_loop = audio.loadStream("Sound/Chapter_1_Interactive_Loop.wav")
  audio.play(music_loop, {loops=-1})

  self.start_performance_time = system.getTimer()
  self.measures = 1
  self.interactive_measures = 0
  self.beats = 1
  self.interactive_beats = 0

  self.beat_timer = timer.performWithDelay(1, function() 
    self:beatTimerCheck()
  end, 0)

  local sound = audio.loadSound("Sound/Chapter_1/" .. info.word .. "_Intro.wav")
  audio.play(sound, {onComplete = function()
    mode = "interactive"
    self.interactive_measures = 1
    self.interactive_beats = 1
  end})

  local picture = info.word

  self.spelling_object = display.newSprite(self.performanceAssetGroup, sprite[picture], {frames=picture_info[picture].frames})
  self.spelling_object.id = picture .. "_" .. 0
  self.spelling_object.x = display.contentCenterX
  self.spelling_object.y = display.contentCenterY - 100
  self.spelling_object.fixed_y = self.spelling_object.y
  self.spelling_object.fixed_x = self.spelling_object.x
  self.spelling_object.info = picture_info[picture]
  self.spelling_object.sketch = true
  self.spelling_object:setFrame(0)
  self.spelling_object.state = "outline_sketching"
  self.spelling_object.start_time = system.getTimer()
  self.spelling_object.x_scale = 1
  self.spelling_object.y_scale = 1
  self.spelling_object.xScale = self.spelling_object.x_scale
  self.spelling_object.yScale = self.spelling_object.y_scale
  self.spelling_object.disappear_time = -1
  self.spelling_object.squish_scale = 1.02
  self.spelling_object.squish_tilt = 8
  self.spelling_object.squish_period = info.mpb
  sketch_sprites:add(self.spelling_object)

  self.button_backings = {}
  self.button_letters = {}
  self.buttons = {}

  for i = 1, string.len(info.word) do
    timer.performWithDelay(info.intro_letter_beats[i] * info.mpb, function()

      local picture = string.upper(info.word):sub(i,i)

      local button = display.newGroup()
      self.performanceAssetGroup:insert(button)

      local button_backing = display.newSprite(self.performanceAssetGroup, sprite["Letter_Box"], {frames=picture_info["Letter_Box"].frames})
      button_backing.id = "button_backing_" .. i
      button_backing.x = display.contentCenterX + 180 * (i - string.len(info.word)/2 - 0.5)
      button_backing.y = display.contentCenterY + 250
      button_backing.fixed_y = button_backing.y
      button_backing.fixed_x = button_backing.x
      button_backing.info = picture_info["Letter_Box"]
      button_backing.sketch = false
      button_backing:setFrame(1)
      button_backing.state = "static"
      button_backing.start_time = system.getTimer()
      button_backing.x_scale = 0.75
      button_backing.y_scale = 0.75
      button_backing.xScale = button_backing.x_scale
      button_backing.yScale = button_backing.y_scale
      button_backing.disappear_time = -1
      button_backing.squish_scale = 1
      button_backing.squish_tilt = 0
      button_backing.squish_period = info.mpb
      sketch_sprites:add(button_backing)
      table.insert(self.button_backings, button_backing)

      local button_letter = display.newSprite(self.performanceAssetGroup, sprite[picture], {frames=picture_info[picture].frames})
      button_letter.id = picture .. "_" .. i
      button_letter.x = display.contentCenterX + 180 * (i - string.len(info.word)/2 - 0.5)
      button_letter.y = display.contentCenterY + 250
      button_letter.fixed_y = button_letter.y
      button_letter.fixed_x = button_letter.x
      button_letter.info = picture_info[picture]
      button_letter.sketch = false
      button_letter:setFrame(picture_info[picture]["sprite_count"])
      button_letter.state = "static"
      button_letter.start_time = system.getTimer()
      button_letter.x_scale = 0.75
      button_letter.y_scale = 0.75
      button_letter.xScale = button_letter.x_scale
      button_letter.yScale = button_letter.y_scale
      button_letter.disappear_time = -1
      button_letter.squish_scale = 1
      button_letter.squish_tilt = 0
      button_letter.squish_period = info.mpb
      sketch_sprites:add(button_letter)
      table.insert(self.button_letters, button_letter)

      local this_letter = i

      local button_event = function(event)
        if mode == "interactive" then
          print("Touching " .. self.current_letter_number)
          if self.current_letter_number >= 1 and self.current_letter_number <= string.len(info.word) and this_letter == self.current_letter_number then
            local sound = audio.loadSound("Sound/Touch_Letter.wav")
            audio.play(sound)

            self.current_letter_number = self.current_letter_number + 1
            local c = self.current_letter_number

            self.button_backings[c - 1]:setFrame(1)
            self.button_backings[c - 1].squish_scale = 1
            self.button_backings[c - 1].squish_tilt = 0
            self.button_backings[c - 1].squish_period = info.mpb
            self.button_letters[c - 1].squish_scale = 1
            self.button_letters[c - 1].squish_tilt = 0
            self.button_letters[c - 1].squish_period = info.mpb

            if c <= string.len(info.word) then
              self.button_backings[c].squish_scale = 1.02
              self.button_backings[c].squish_tilt = 8
              self.button_backings[c].squish_period = info.mpb
              self.button_letters[c].squish_scale = 1.02
              self.button_letters[c].squish_tilt = 8
              self.button_letters[c].squish_period = info.mpb
            end

            if c > string.len(info.word) then
              -- we're done!
              mode = "pre_outro"
              self.spelling_object.state = "sketching"
            end
          end
        end
      end
      button_backing:addEventListener("tap", button_event)
      button.event = button_event

      table.insert(self.buttons, button)
    end, 1)
  end
end



function scene:beatTimerCheck()
  current_time = system.getTimer()
  if current_time - self.start_performance_time > (self.info.mpb * self.info.time_sig) * self.measures then
    self:measureActions()
    self.measures = self.measures + 1
    if mode == "interactive" then
      self.interactive_measures = self.interactive_measures + 1
    end
  end

  if current_time - self.start_performance_time > self.info.mpb * self.beats then
    self:beatActions()
    self.beats = self.beats + 1
    if mode == "interactive" then
      self.interactive_beats = self.interactive_beats + 1
    end
  end
end

function scene:beatActions()
  print("on interactive beat " .. self.interactive_beats)

  local info = self.info
  local word = string.lower(self.info.word)

  -- on interactives, on the 3rd out of every 8 beats, tell the player to press a button.
  -- the sound is delayed by one beat (to capture the pre-beat sound), so this will actually
  -- land right on the measure mark.
  if mode == "interactive" and self.interactive_beats % 8 == 3 then
    if self.current_letter_number >= 1 and self.current_letter_number <= string.len(word) then
      print("I should be playing this sound")
      current_letter = word:sub(self.current_letter_number, self.current_letter_number)
      randomizer = math.random(4)
      local sound = audio.loadSound("Sound/Interactive_Letters_".. info.bpm .. "/" .. current_letter .. "_" .. randomizer .. ".wav")
      audio.play(sound)
    end
  end
end

function scene:measureActions()
  print("on measure")

  local info = self.info
  local word = string.lower(self.info.word)

  -- on every measure during interactives, update the color coding to fit the letter
  if mode == "interactive" then
    for i = 1, string.len(word) do
      if i ~= nil and self.button_backings ~= nil and self.button_backings[i] ~= nil and self.button_backings[i]["squish_scale"] ~= nil then
        if i ~= self.current_letter_number then
          self.button_backings[i]:setFrame(1)
          self.button_backings[i].squish_scale = 1
          self.button_backings[i].squish_tilt = 0
          self.button_backings[i].squish_period = info.mpb
          self.button_letters[i].squish_scale = 1
          self.button_letters[i].squish_tilt = 0
          self.button_letters[i].squish_period = info.mpb
        else
          self.button_backings[i].squish_scale = 1.02
          self.button_backings[i].squish_tilt = 8
          self.button_backings[i].squish_period = info.mpb
          self.button_letters[i].squish_scale = 1.02
          self.button_letters[i].squish_tilt = 8
          self.button_letters[i].squish_period = info.mpb
          if self.button_backings[i].frame == 1 then
            self.button_backings[i]:setFrame(2)
          else
            self.button_backings[i]:setFrame(1)
          end
        end
      end
    end
  end

  if mode == "pre_outro" then
    mode = "outro"

    -- play the outro sound
    local sound = audio.loadSound("Sound/Chapter_1/" .. info.word .. "_Outro.wav")
    audio.play(sound, {onComplete = function()
      mode = "post_outro"
    end})

    -- load up some letter timing for show
    for letter_num = 1, string.len(info.word) do
      timer.performWithDelay(info.outro_letter_beats[letter_num] * info.mpb, function()
        for i = 1, string.len(info.word) do
          if i ~= letter_num then
            self.button_backings[i]:setFrame(1)
            self.button_backings[i].squish_scale = 1
            self.button_backings[i].squish_tilt = 0
            self.button_backings[i].squish_period = info.mpb
            self.button_letters[i].squish_scale = 1
            self.button_letters[i].squish_tilt = 0
            self.button_letters[i].squish_period = info.mpb
          else
            self.button_backings[i].squish_scale = 1.02
            self.button_backings[i].squish_tilt = 8
            self.button_backings[i].squish_period = info.mpb
            self.button_letters[i].squish_scale = 1.02
            self.button_letters[i].squish_tilt = 8
            self.button_letters[i].squish_period = info.mpb
            if self.button_backings[i].frame == 1 then
              self.button_backings[i]:setFrame(2)
            else
              self.button_backings[i]:setFrame(1)
            end
          end
        end
      end)
    end
    for letter_num = 1, string.len(info.word) do
      timer.performWithDelay(info.outro_sound_beats[letter_num] * info.mpb, function()
        for i = 1, string.len(info.word) do
          if i ~= letter_num then
            self.button_backings[i]:setFrame(1)
            self.button_backings[i].squish_scale = 1
            self.button_backings[i].squish_tilt = 0
            self.button_backings[i].squish_period = info.mpb
            self.button_letters[i].squish_scale = 1
            self.button_letters[i].squish_tilt = 0
            self.button_letters[i].squish_period = info.mpb
          else
            self.button_backings[i].squish_scale = 1.02
            self.button_backings[i].squish_tilt = 8
            self.button_backings[i].squish_period = info.mpb
            self.button_letters[i].squish_scale = 1.02
            self.button_letters[i].squish_tilt = 8
            self.button_letters[i].squish_period = info.mpb
            if self.button_backings[i].frame == 1 then
              self.button_backings[i]:setFrame(2)
            else
              self.button_backings[i]:setFrame(1)
            end
          end
        end
      end)
    end
    timer.performWithDelay(info.outro_word_beat * info.mpb, function()
      for i = 1, string.len(info.word) do
        self.button_backings[i].squish_scale = 1.02
        self.button_backings[i].squish_tilt = 8
        self.button_backings[i].squish_period = info.mpb
        self.button_letters[i].squish_scale = 1.02
        self.button_letters[i].squish_tilt = 8
        self.button_letters[i].squish_period = info.mpb
        self.button_backings[i]:setFrame(2)
      end
    end)
    timer.performWithDelay((info.outro_word_beat + 1) * info.mpb, function()
      for i = 1, string.len(info.word) do
        self.button_backings[i]:setFrame(1)
        self.button_backings[i].squish_scale = 1
        self.button_backings[i].squish_tilt = 0
        self.button_backings[i].squish_period = info.mpb
        self.button_letters[i].squish_scale = 1
        self.button_letters[i].squish_tilt = 0
        self.button_letters[i].squish_period = info.mpb
        self.button_backings[i]:setFrame(1)
      end
    end)
  end

  if mode == "post_outro" then
    mode = "finished"
    -- timer.cancel(interactive_ui_timer)
    timer.cancel(self.sketch_sprite_timer)
    audio.stop()
    sketch_sprites:immediatelyRemoveAll()
    for i = 1, string.len(info.word) do
      self.buttons[i]:removeEventListener("tap", self.buttons[i].event)
      display.remove(self.buttons[i])
    end
    self.buttons = {}
    self.chapter:gotoScene(self.next_scene, nil)
  end
end

-- function scene:updateInteractiveUI()
--   print("updating interactive UI")
--   if mode == "intro" then
--     mode = "interactive"
--   end
--   if mode ~= "finished" then
--     local info = self.info
--     local word = string.lower(self.info.word)
--     if self.current_letter_number >= 1 and self.current_letter_number <= string.len(word) then
--       current_letter = word:sub(self.current_letter_number, self.current_letter_number)
--       if self.interactive_rounds % 8 == 0 then
--         randomizer = math.random(4)
--         local sound = audio.loadSound("Sound/Interactive_Letters/" .. info.bpm .. "_" .. current_letter .. "_" .. randomizer .. ".wav")
--         audio.play(sound)
--       end

--       for i = 1, string.len(info.word) do
--         if i ~= nil and self.button_backings ~= nil and self.button_backings[i] ~= nil and self.button_backings[i]["squish_scale"] ~= nil then
--           if i ~= self.current_letter_number then
--             self.button_backings[i]:setFrame(1)
--             self.button_backings[i].squish_scale = 1
--             self.button_backings[i].squish_tilt = 0
--             self.button_backings[i].squish_period = 545
--             self.button_letters[i].squish_scale = 1
--             self.button_letters[i].squish_tilt = 0
--             self.button_letters[i].squish_period = 545
--           else
--             self.button_backings[i].squish_scale = 1.02
--             self.button_backings[i].squish_tilt = 8
--             self.button_backings[i].squish_period = 545
--             self.button_letters[i].squish_scale = 1.02
--             self.button_letters[i].squish_tilt = 8
--             self.button_letters[i].squish_period = 545
--             if self.button_backings[i].frame == 1 then
--               self.button_backings[i]:setFrame(2)
--             else
--               self.button_backings[i]:setFrame(1)
--             end
--           end
--         end
--       end
--     else
--       if self.end_phrase > 1 and self.end_phrase <= 5 then
--         self.letter_stagger = self.letter_stagger + 1
        
--         for i = 1, string.len(info.word) do
--           if i ~= self.letter_stagger / 2 then
--             self.button_backings[i]:setFrame(1)
--             self.button_backings[i].squish_scale = 1
--             self.button_backings[i].squish_tilt = 0
--             self.button_backings[i].squish_period = 545
--             self.button_letters[i].squish_scale = 1
--             self.button_letters[i].squish_tilt = 0
--             self.button_letters[i].squish_period = 545
--           else
--             self.button_backings[i].squish_scale = 1.02
--             self.button_backings[i].squish_tilt = 8
--             self.button_backings[i].squish_period = 545
--             self.button_letters[i].squish_scale = 1.02
--             self.button_letters[i].squish_tilt = 8
--             self.button_letters[i].squish_period = 545
--             if self.button_backings[i].frame == 1 then
--               self.button_backings[i]:setFrame(2)
--             else
--               self.button_backings[i]:setFrame(1)
--             end
--           end
--         end
--       end
--       if self.interactive_rounds % 4 == 0 then
--         if self.end_phrase == 1 then
--           local sound = audio.loadSound("Sound/Interactive_" .. info.word .. "/" .. info.bpm .. "_spelling.wav")
--           audio.play(sound)
--           self.letter_stagger = 1
--         elseif self.end_phrase == 3 then
--           local sound = audio.loadSound("Sound/Interactive_" .. info.word .. "/" .. info.bpm .. "_pronunciation.wav")
--           audio.play(sound)
--           self.letter_stagger = 1
--         elseif self.end_phrase == 5 then
--           local sound = audio.loadSound("Sound/Interactive_" .. info.word .. "/" .. info.bpm .. "_success_word.wav")
--           audio.play(sound)
--           for i = 1, string.len(info.word) do
--             self.button_backings[i].squish_scale = 1.02
--             self.button_backings[i].squish_tilt = 8
--             self.button_backings[i].squish_period = 545
--             self.button_letters[i].squish_scale = 1.02
--             self.button_letters[i].squish_tilt = 8
--             self.button_letters[i].squish_period = 545
--             if self.button_backings[i].frame == 1 then
--               self.button_backings[i]:setFrame(2)
--             else
--               self.button_backings[i]:setFrame(1)
--             end
--           end
--         elseif self.end_phrase == 6 then
--           local sound = audio.loadSound("Sound/Interactive_" .. info.word .. "/" .. info.bpm .. "_success_praise.wav")
--           audio.play(sound)

--           for i = 1, string.len(info.word) do
--             self.button_backings[i]:setFrame(1)
--             self.button_backings[i].squish_scale = 1
--             self.button_backings[i].squish_tilt = 0
--             self.button_backings[i].squish_period = 545
--             self.button_letters[i].squish_scale = 1
--             self.button_letters[i].squish_tilt = 0
--             self.button_letters[i].squish_period = 545
--           end
--         elseif self.end_phrase == 8 then
--           -- this is a reset that removes everything
--           print("Trying to cancel this damned function")
--           print(interactive_ui_timer)
--           timer.cancel(interactive_ui_timer)
--           print(interactive_ui_timer)
--           timer.cancel(self.sketch_sprite_timer)
--           audio.stop()
--           sketch_sprites:immediatelyRemoveAll()
--           for i = 1, string.len(info.word) do
--             self.buttons[i]:removeEventListener("tap", self.buttons[i].event)
--             display.remove(self.buttons[i])
--           end
--           self.buttons = {}
--           -- mode = "pre_outro"
--           self.chapter:gotoScene(self.next_scene, nil)
--         end

--         self.end_phrase = self.end_phrase + 1
--       end
--     end

--     self.interactive_rounds = self.interactive_rounds + 1
--   end
-- end

-- asset_start_x = 0
-- asset_start_y = 0
-- function scene:handleMouse(event)
--   -- if mode == "editing" then
--   --   local asset = getSelectedAsset()

--   --   if asset ~= nil and asset.type == "picture" and asset.performance ~= nil then
--   --     if event.phase == "began" then
--   --       asset_start_x = asset.performance.fixed_x
--   --       asset_start_y = asset.performance.fixed_y
--   --       if asset_start_x == nil then
--   --         asset_start_x = 0
--   --         asset_start_y = 0
--   --       end
--   --     elseif event.phase == "moved" or event.phase == "ended" or event.phase == "cancelled" then
--   --       asset.performance.fixed_x = asset_start_x + event.x - event.xStart
--   --       asset.performance.fixed_y = asset_start_y + event.y - event.yStart
--   --       asset.fixed_x = asset.performance.fixed_x
--   --       asset.fixed_y = asset.performance.fixed_y
--   --       asset.x = asset.fixed_x
--   --       asset.y = asset.fixed_y
--   --     end
--   --   end
--   -- end
-- end

-- hide()
function scene:hide(event)

  local sceneGroup = self.view
  local phase = event.phase

  if (phase == "will") then
    -- Code here runs when the scene is on screen (but is about to go off screen)

  elseif (phase == "did") then
    -- Code here runs immediately after the scene goes entirely off screen
  end
end


-- destroy()
function scene:destroy(event)

  local sceneGroup = self.view
  -- Code here runs prior to the removal of scene's view
  -- Runtime:removeEventListener("key")
  Runtime:removeEventListener("touch")
  mui.destroy()
end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)
-- -----------------------------------------------------------------------------------

return scene
