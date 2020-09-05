
local composer = require("composer")
local json = require("json")
local lfs = require("lfs")

local picture_info = require("Source.pictures")
local sound_info = require("Source.sounds")

local scene = composer.newScene()

local sprite = {}

local script_asset_count = 0

local mode = nil

local current_time = 0
local start_performance_time = 0
local stored_performance_time = 0
local total_performance_time = 0

local update_timer = nil

local load_start_time = 0

local music_loop = nil

local small_word_gap = 180
local large_word_gap = 160


function scene:perform(asset)
  print("Performing " .. asset.name)
  if asset.type == "sound" then
    asset.performance = audio.loadStream("Sound/" .. sound_info[asset.name].file_name)
    -- should only do if this is the main audio file
    audio.play(asset.performance, {loops = 0, onComplete=function() self:nextScene() end})
  elseif asset.type == "picture" then
    local picture = asset.name

    asset.performance = display.newSprite(self.performanceAssetGroup[asset.depth + 5], sprite[picture], {frames=picture_info[picture].frames})
    asset.performance.id = asset.id
    asset.performance.x = asset.x
    asset.performance.y = asset.y
    asset.performance.fixed_y = asset.y
    asset.performance.fixed_x = asset.x
    asset.performance.info = picture_info[picture]
    if asset.sketch == true then
      asset.performance.sketch = true
      asset.performance:setFrame(0)
      asset.performance.state = "sketching"
    else
      asset.performance.sketch = false
      asset.performance:setFrame(picture_info[picture]["sprite_count"])
      if asset.performance.info["animation_end"] ~= nil then
        asset.performance.state = "animating"
        asset.performance.animation_count = 0
      else
        asset.performance.state = "static"
      end
    end
    asset.performance.start_time = system.getTimer()
    asset.performance.x_scale = asset.x_scale
    asset.performance.y_scale = asset.y_scale
    asset.performance.xScale = asset.performance.x_scale
    asset.performance.yScale = asset.performance.y_scale
    asset.performance.disappear_time = asset.disappear_time
    asset.performance.disappear_method = asset.disappear_method
    asset.performance.squish_scale = asset.squish_scale
    asset.performance.squish_tilt = asset.squish_tilt
    asset.performance.squish_period = asset.squish_period
    self.sketch_sprites:add(asset.performance)
  end
end

function scene:clearPerformance()
  self.sketch_sprites:immediatelyRemoveAll()
  self.sketch_sprites.sprite_list = {}

  for i = 1, #self.script_assets do
    asset = self.script_assets[i]
    asset.performance = nil
  end

  for i = 1, 9 do
    while self.performanceAssetGroup[i].numChildren > 0 do
      local child = self.performanceAssetGroup[i][1]
      if child then child:removeSelf() end
    end
  end
end

function scene:updatePerformance()
  local last_update_time = total_performance_time
  updateTime()


  for i = 1, #self.script_assets do
    asset = self.script_assets[i]
    if asset.performance == nil and last_update_time <= asset.start_time and total_performance_time >= asset.start_time then
      self:perform(asset)
    end
  end
end

function updateTime()
  current_time = system.getTimer()

  total_performance_time = stored_performance_time + (current_time - start_performance_time)
end

function scene:poopStars(center_x, center_y, num_stars)
  local info = self.info
  colors = {"Green", "Yellow", "Blue", "Red", "Orange", "Purple", "Pink"}
  for i = 1, num_stars do
    local star_color = colors[math.random(#colors)]
    local picture = star_color .. "_Star"
    local star_sprite = display.newSprite(self.performanceAssetGroup, sprite[picture], {frames=picture_info[picture].frames})
    star_sprite.id = picture .. "_" .. 0
    star_sprite.x = center_x
    star_sprite.y = center_y
    star_sprite.fixed_y = star_sprite.y
    star_sprite.fixed_x = star_sprite.x
    star_sprite.info = picture_info[picture]
    star_sprite.sketch = false
    star_sprite:setFrame(picture_info[picture]["sprite_count"])
    star_sprite.state = "disappearing_gravity"
    star_sprite.start_time = system.getTimer()
    star_sprite.x_scale = 0.5
    star_sprite.y_scale = 0.5
    star_sprite.xScale = star_sprite.x_scale
    star_sprite.yScale = star_sprite.y_scale
    star_sprite.disappear_time = -1
    star_sprite.squish_scale = 1.04
    star_sprite.squish_tilt = 0
    star_sprite.squish_period = info.mpb
    star_sprite.x_vel = -20 + math.random(40)
    star_sprite.y_vel = -1 * (4 + math.random(6))
    self.sketch_sprites:add(star_sprite)
  end
end

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

    for i = -4, 4 do
      local layer = display.newGroup()
      self.performanceAssetGroup:insert(layer)
    end

    self.sketch_sprites = composer.getVariable("sketch_sprites")

    display.setDefault("background", 1, 1, 1)

    sprite = composer.getVariable("sprite")

    self.info = composer.getVariable("settings")
    self.chapter = composer.getVariable("chapter")
    self.next_scene = composer.getVariable("next_scene")
    self.script_assets = composer.getVariable("script_assets")
    print(self.script_assets)

    print("Making scene for " .. self.info.word)

    current_time = 0
    start_performance_time = 0
    stored_performance_time = 0
    total_performance_time = 0

    self:startScene()

    self.sketch_sprites.picture_info = picture_info
    self.sketch_sprites.sprite_info = sprite
    self.sketch_sprites.top_group = self.performanceAssetGroup[9]
    self.sketch_sprite_timer = timer.performWithDelay(35, function() 
      self.sketch_sprites:update(mode, total_performance_time)
    end, 0)

    -- Runtime:addEventListener("key", function(event) self:handleKeyboard(event) end)

  end
end

function scene:startScene()
  mode = "intro"

  local info = self.info
  local word = self.info.word

  self.sketch_sprites.picture_info = picture_info
  self.sketch_sprites.sprite_info = sprite
  self.sketch_sprites.top_group = self.performanceAssetGroup[9]

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

  if self.script_assets ~= nil and self.script_assets ~= "" then
    current_time = system.getTimer()
    start_performance_time = 0
    stored_performance_time = 0
    total_performance_time = 0

    self:clearPerformance()

    start_performance_time = system.getTimer()
    current_time = system.getTimer()

    self:updatePerformance()

    update_timer = timer.performWithDelay(35, function() 
      self:updatePerformance()
    end, 0)
  end

  local sound = audio.loadSound("Sound/Chapter_1/" .. info.word .. "_Intro.wav")
  audio.play(sound, {onComplete = function()
    mode = "interactive"
    self.interactive_measures = 1
    self.interactive_beats = 1

    self:setWordColor(self.current_letter_number)
  end})

  local picture = info.word

  local spelling_object_x = display.contentCenterX
  local spelling_object_y = display.contentCenterY - 100
  if info["object_x"] ~= nil then
    spelling_object_x = info["object_x"]
  end
  if info["object_y"] ~= nil then
    spelling_object_y = info["object_y"]
  end

  self.spelling_object = display.newSprite(self.performanceAssetGroup, sprite[picture], {frames=picture_info[picture].frames})
  self.spelling_object.id = picture .. "_" .. 0
  self.spelling_object.x = spelling_object_x
  self.spelling_object.y = spelling_object_y
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
  self.sketch_sprites:add(self.spelling_object)

  self.button_backings = {}
  self.button_letters = {}
  self.buttons = {}

  local gap = small_word_gap
  if string.len(info.word) >= 6 then
    gap = large_word_gap
  end

  for i = 1, string.len(info.word) do
    timer.performWithDelay(info.intro_letter_beats[i] * info.mpb, function()

      local picture = string.upper(info.word):sub(i,i)

      local button = display.newGroup()
      self.performanceAssetGroup:insert(button)

      local button_backing = display.newSprite(self.performanceAssetGroup, sprite["Letter_Box"], {frames=picture_info["Letter_Box"].frames})
      button_backing.id = "button_backing_" .. i
      button_backing.x = display.contentCenterX + gap * (i - string.len(info.word)/2 - 0.5)
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
      self.sketch_sprites:add(button_backing)
      table.insert(self.button_backings, button_backing)

      local button_letter = display.newSprite(self.performanceAssetGroup, sprite[picture], {frames=picture_info[picture].frames})
      button_letter.id = picture .. "_" .. i
      button_letter.x = display.contentCenterX + gap * (i - string.len(info.word)/2 - 0.5)
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
      self.sketch_sprites:add(button_letter)
      table.insert(self.button_letters, button_letter)

      local this_letter = i

      function poopStars(x, y, val)
        self:poopStars(x, y, val)
      end

      local button_event = function(event)
        if mode == "interactive" then
          print("Touching " .. self.current_letter_number)
          if self.current_letter_number >= 1 and self.current_letter_number <= string.len(info.word) and this_letter == self.current_letter_number then
            local sound = audio.loadSound("Sound/Touch_Letter.wav")
            audio.play(sound)

            poopStars(button_backing.x, button_backing.y, 3 + math.random(3))

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

            self:setWordColor(self.current_letter_number)
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

    -- on every other beat during interactives, update the color coding to fit the letter
  if mode == "interactive" then
    self:setWordColor(self.current_letter_number)
  end

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
        -- for i = 1, string.len(info.word) do
        --   if i ~= letter_num then
        --     self.button_backings[i]:setFrame(1)
        --     self.button_backings[i].squish_scale = 1
        --     self.button_backings[i].squish_tilt = 0
        --     self.button_backings[i].squish_period = info.mpb
        --     self.button_letters[i].squish_scale = 1
        --     self.button_letters[i].squish_tilt = 0
        --     self.button_letters[i].squish_period = info.mpb
        --   else
        --     self.button_backings[i].squish_scale = 1.02
        --     self.button_backings[i].squish_tilt = 8
        --     self.button_backings[i].squish_period = info.mpb
        --     self.button_letters[i].squish_scale = 1.02
        --     self.button_letters[i].squish_tilt = 8
        --     self.button_letters[i].squish_period = info.mpb
        --     if self.button_backings[i].frame == 1 then
        --       self.button_backings[i]:setFrame(2)
        --     else
        --       self.button_backings[i]:setFrame(1)
        --     end
        --   end
        -- end
        self:setWordColor(letter_num)
      end)
    end
    for letter_num = 1, string.len(info.word) do
      timer.performWithDelay(info.outro_sound_beats[letter_num] * info.mpb, function()
        -- for i = 1, string.len(info.word) do
        --   if i ~= letter_num then
        --     self.button_backings[i]:setFrame(1)
        --     self.button_backings[i].squish_scale = 1
        --     self.button_backings[i].squish_tilt = 0
        --     self.button_backings[i].squish_period = info.mpb
        --     self.button_letters[i].squish_scale = 1
        --     self.button_letters[i].squish_tilt = 0
        --     self.button_letters[i].squish_period = info.mpb
        --   else
        --     self.button_backings[i].squish_scale = 1.02
        --     self.button_backings[i].squish_tilt = 8
        --     self.button_backings[i].squish_period = info.mpb
        --     self.button_letters[i].squish_scale = 1.02
        --     self.button_letters[i].squish_tilt = 8
        --     self.button_letters[i].squish_period = info.mpb
        --     if self.button_backings[i].frame == 1 then
        --       self.button_backings[i]:setFrame(2)
        --     else
        --       self.button_backings[i]:setFrame(1)
        --     end
        --   end
        -- end
        self:setWordColor(letter_num)
      end)
    end
    timer.performWithDelay(info.outro_word_beat * info.mpb, function()
      -- for i = 1, string.len(info.word) do
      --   self.button_backings[i].squish_scale = 1.02
      --   self.button_backings[i].squish_tilt = 8
      --   self.button_backings[i].squish_period = info.mpb
      --   self.button_letters[i].squish_scale = 1.02
      --   self.button_letters[i].squish_tilt = 8
      --   self.button_letters[i].squish_period = info.mpb
      --   self.button_backings[i]:setFrame(2)
      -- end
      self:setWordColor("all")
    end)
    timer.performWithDelay((info.outro_word_beat + 1) * info.mpb, function()
      -- for i = 1, string.len(info.word) do
      --   self.button_backings[i]:setFrame(1)
      --   self.button_backings[i].squish_scale = 1
      --   self.button_backings[i].squish_tilt = 0
      --   self.button_backings[i].squish_period = info.mpb
      --   self.button_letters[i].squish_scale = 1
      --   self.button_letters[i].squish_tilt = 0
      --   self.button_letters[i].squish_period = info.mpb
      --   self.button_backings[i]:setFrame(1)
      -- end
      self:setWordColor("none")
    end)
  end

  if mode == "post_outro" then
    mode = "finished"
    -- timer.cancel(interactive_ui_timer)
    timer.cancel(self.sketch_sprite_timer)
    if update_timer ~= nil then
      timer.cancel(update_timer)
    end
    audio.stop()
    self.sketch_sprites:immediatelyRemoveAll()
    for i = 1, string.len(info.word) do
      self.buttons[i]:removeEventListener("tap", self.buttons[i].event)
      display.remove(self.buttons[i])
    end
    self.buttons = {}
    self.chapter:gotoScene(self.next_scene, nil)
  end
end

function scene:setWordColor(compare_value)
  local info = self.info
  local word = info.word
  for i = 1, string.len(word) do
    if i ~= nil and self.button_backings ~= nil and self.button_backings[i] ~= nil and self.button_backings[i]["squish_scale"] ~= nil then
      if compare_value == "none" or (compare_value ~= "all" and i ~= compare_value) then
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
        if compare_value == "all" then
          self.button_backings[i]:setFrame(2)
        elseif compare_value == "none" then
          self.button_backings[i]:setFrame(1)
        end
      end
    end
  end
end

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
