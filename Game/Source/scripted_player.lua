
local composer = require("composer")
local json = require("json")
local lfs = require("lfs")

local animation = require("plugin.animation")

local picture_info = require("Source.pictures")
local sound_info = require("Source.sounds")
local loader = require("Source.loader")

local scene = composer.newScene()

local small_word_gap = 180
local large_word_gap = 160

local printMemUsage = function()  
  local memUsed = (collectgarbage("count"))
  local texUsed = system.getInfo( "textureMemoryUsed" ) / 1048576 -- Reported in Bytes
 
  print("\n---------MEMORY USAGE INFORMATION---------")
  print("System Memory: ", string.format("%.00f", memUsed), "KB")
  print("Texture Memory:", string.format("%.03f", texUsed), "MB")
  print("------------------------------------------\n")
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
    self.loader = loader:create()

    self.performanceAssetGroup = display.newGroup()
    self.sceneGroup:insert(self.performanceAssetGroup)

    for i = -4, 4 do
      local layer = display.newGroup()
      self.performanceAssetGroup:insert(layer)
    end

    display.setDefault("background", 1, 1, 1)

    self.memory_log_timer = timer.performWithDelay(3000, function() 
      printMemUsage()
    end, 0)

    self:initializeFromChapter()
    -- self:initializeScene()
    if self.scene_type == "scripted" then
      self:startScripted()
    elseif self.scene_type == "interactive_spelling" then
      self:startInteractiveSpelling()
    end

    self:setupLoading()
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
  -- Runtime:removeEventListener("touch")
end
-- -----------------------------------------------------------------------------------



-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)
-- -----------------------------------------------------------------------------------



-- -----------------------------------------------------------------------------------
-- Helper functions
-- -----------------------------------------------------------------------------------
function scene:updateTime()
  self.current_time = system.getTimer()

  if self.mode == "performing" then
    self.total_performance_time = self.stored_performance_time + (self.current_time - self.start_performance_time)
  end
end

function scene:perform(asset)
  if asset.type == "sound" then
    asset.performance = audio.loadStream("Sound/" .. sound_info[asset.name].file_name)
    -- should only do if this is the main audio file
    audio.play(asset.performance, {loops = 0, onComplete=function() self:nextScene() end})
  elseif asset.type == "picture" then
    local picture = asset.name

    asset.performance = display.newSprite(self.performanceAssetGroup[asset.depth + 5], self.sprite[picture], {frames=picture_info[picture].frames})
    asset.performance.name = asset.name
    asset.performance.id = asset.id
    asset.performance.x = asset.x
    asset.performance.y = asset.y
    asset.performance.fixed_y = asset.y
    asset.performance.fixed_x = asset.x
    asset.performance.x_vel = 0
    asset.performance.y_vel = 0
    asset.performance.info = picture_info[picture]
    asset.performance.intro = asset.intro
    if asset.intro == "sketch" then
      asset.performance:setFrame(1)
      asset.performance.state = "sketching"
    elseif asset.intro == "fade_in" then
      asset.performance:setFrame(1)
      asset.performance.state = "fade_in"
      asset.performance.alpha = 0.01
    elseif asset.intro == "rise" then
      asset.performance:setFrame(1)
      asset.performance.state = "rise"
      local height = asset.performance.info.sprite_size
      if asset.performance.info["sprite_height"] ~= nil then
        height = asset.performance.info["sprite_height"]
      end
      asset.performance.y = asset.y + height
      asset.performance.fixed_y = asset.performance.y
    else
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
  local last_update_time = self.total_performance_time
  self:updateTime()

  for i = 1, #self.script_assets do
    asset = self.script_assets[i]
    if asset.performance == nil and last_update_time <= asset.start_time and self.total_performance_time >= asset.start_time then
      self:perform(asset)
    end
  end
end

function scene:nextScene()
  self.mode = nil

  timer.cancel(self.sketch_sprite_timer)
  if self.update_timer ~= nil then
    timer.cancel(self.update_timer)
  end

  if self.special_timer ~= nil then
    timer.cancel(self.special_timer)
  end

  if self.info["cleanup"] == nil or self.info["cleanup"] ~= false then
    self:clearPerformance()
    self.sketch_sprites.picture_info = nil
    self.sketch_sprites.sprite_info = nil
    self.sketch_sprites.top_group = nil
  end

  if self.next_scene ~= "end" and self.chapter_flow[self.next_scene] ~= nil then
    self:initializeScene()
  else
    self.chapter:finish()
  end

  if self.scene_type == "scripted" then
    self:startScripted()
  elseif self.scene_type == "interactive_spelling" then
    self:startInteractiveSpelling()
  end

  -- start loading the next stuff
  self:setupLoading()
end

function scene:initializeFromChapter()
  self.sketch_sprites = composer.getVariable("sketch_sprites")
  self.sprite = composer.getVariable("sprite")
  self.scene_name = composer.getVariable("scene_name")
  self.info = composer.getVariable("settings")
  self.chapter = composer.getVariable("chapter")
  self.next_scene = composer.getVariable("next_scene")
  self.sprite = composer.getVariable("sprite")
  self.script_assets = composer.getVariable("script_assets")
  self.chapter_flow = composer.getVariable("chapter_flow")
  self.scene_type = self.info["type"]

  self.sketch_sprite_timer = timer.performWithDelay(35, function() 
    self.sketch_sprites:update(self.mode, self.total_performance_time)
  end, 0)
end

function scene:initializeScene()

  print("New scene: " .. self.next_scene)
  local new_scene = self.chapter_flow[self.next_scene]

  self.scene_name = new_scene.name
  self.info = new_scene
  self.scene_type = self.info["type"]
  if new_scene.script ~= nil then
    self.script_assets = new_scene.script
  else
    self.script_assets = ""
  end
  if new_scene.next ~= nil then
    self.next_scene = new_scene.next
  else
    self.next_scene = "end"
  end

  self.sketch_sprite_timer = timer.performWithDelay(35, function() 
    self.sketch_sprites:update(self.mode, self.total_performance_time)
  end, 0)
end

function scene:startScripted()
  self.mode = "performing"

  self.stored_performance_time = 0
  self.total_performance_time = 0
  self.start_performance_time = system.getTimer()
  self.current_time = system.getTimer()

  self:updatePerformance()

  self.update_timer = timer.performWithDelay(35, function() 
    self:updatePerformance()
  end, 0)

  -- Special functions
  if self.scene_name == "Chapter_2_Scene_1" then
    local back_row = 6
    local front_row = 7
    self.chapter_2_scoot_counter = 0
    scoot = function()
      self.chapter_2_scoot_counter = self.chapter_2_scoot_counter + 1
      if self.chapter_2_scoot_counter % 4 == 1 then
        self.performanceAssetGroup[back_row].x = self.performanceAssetGroup[back_row].x - 1024
        self.performanceAssetGroup[front_row].x = self.performanceAssetGroup[front_row].x + 1024
      end
      current_x = self.performanceAssetGroup[back_row].x
      animation.to(self.performanceAssetGroup[back_row], {x=current_x + 256}, {time=750 / 4 * 0.7, easing=easing.outExp})

      -- scoot left
      timer.performWithDelay(750 * 3 / 4, function()
        current_x = self.performanceAssetGroup[front_row].x
        animation.to(self.performanceAssetGroup[front_row], {x=current_x - 256}, {time=750 / 4 * 0.7, easing=easing.outExp})
      end, 1)
    end

    scoot()
    self.special_timer = timer.performWithDelay(1500, function()
      scoot()
    end, 0)
  end
end

function scene:setupLoading()
  local items = self:computeNextLoad()
  local load_items = items[1]
  local unload_items = items[2]
  print("Got " .. #load_items .. " to load for next scene.")
  for i = 1, #load_items do
    print("Gotta load " .. load_items[i])
  end
  print("Got " .. #unload_items .. " to unload for next scene.")
  for i = 1, #unload_items do
    print("Gotta unload " .. unload_items[i])
  end
  self.loader:backgroundLoad(
    self.sprite,
    picture_info,
    load_items,
    unload_items,
    300,
    function(percent) end,
    function() print("Finished loading items in the background!") end)
end

function scene:computeNextLoad()
  local background_load_items = {}

  local keep_loading = (self.next_scene ~= nil and self.next_scene ~= "end")
  local current_scene_name = self.next_scene
  while keep_loading do
    local load_scene = self.chapter_flow[current_scene_name]
    if load_scene.word ~= nil then
      background_load_items[load_scene.word] = 1
    end

    if load_scene.script ~= nil then
      for asset_name, asset_value in pairs(load_scene.script) do
        background_load_items[asset_value.name] = 1
      end
    end

    -- keep going until we've checked a scripted scene.
    keep_loading = (load_scene.type ~= "scripted" and load_scene.next ~= nil)
    current_scene_name = load_scene.next
  end

  local clean_load_items = {}
  for picture, info in pairs(picture_info) do
    if background_load_items[picture] == 1 and self.sprite[picture] == nil then
      table.insert(clean_load_items, picture)
    end
  end
  background_load_items = clean_load_items

  local background_unload_items = {}
  local safe_list = {}
  -- add everything in the performance to the safe list
  for i = 1, 9 do
    for j = 1, self.performanceAssetGroup[i].numChildren do
      local asset = self.performanceAssetGroup[i][j]
      safe_list[asset.name] = 1
    end
  end
  -- add everything from the future to the safe list
  keep_loading = (self.next_scene ~= nil)
  current_scene_name = self.scene_name
  while keep_loading do
    local load_scene = self.chapter_flow[current_scene_name]
    if load_scene.word ~= nil then
      safe_list[load_scene.word] = 1
    end

    if load_scene.script ~= nil then
      for asset_name, asset_value in pairs(load_scene.script) do
        safe_list[asset_value.name] = 1
      end
    end

    -- keep going until we've checked everything
    keep_loading = load_scene.next ~= nil
    current_scene_name = load_scene.next
  end

  -- now we have a safe list. unload anything in sprites that isn't on the safe_list.
  for sprite_name, sprite_value in pairs(self.sprite) do
    if (safe_list[sprite_name] == nil and picture_info[sprite_name].always_load ~= true) then
      background_unload_items[sprite_name] = 1
    end
  end

  local clean_unload_items = {}
  for sprite_name, sprite_value in pairs(background_unload_items) do
    table.insert(clean_unload_items, sprite_name)
  end
  background_unload_items = clean_unload_items

  return {background_load_items, background_unload_items}
end

function scene:poopStars(center_x, center_y, num_stars)
  local info = self.info
  colors = {"Green", "Yellow", "Blue", "Red", "Orange", "Purple", "Pink"}
  for i = 1, num_stars do
    local star_color = colors[math.random(#colors)]
    local picture = star_color .. "_Star"
    local star_sprite = display.newSprite(self.performanceAssetGroup, self.sprite[picture], {frames=picture_info[picture].frames})
    star_sprite.id = picture .. "_" .. 0
    star_sprite.x = center_x
    star_sprite.y = center_y
    star_sprite.fixed_y = star_sprite.y
    star_sprite.fixed_x = star_sprite.x
    star_sprite.info = picture_info[picture]
    star_sprite.intro = "static"
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

function scene:startInteractiveSpelling()
  self.mode = "intro"

  local info = self.info
  local word = self.info.word

  self.sketch_sprites.picture_info = picture_info
  self.sketch_sprites.sprite_info = sprite
  self.sketch_sprites.top_group = self.performanceAssetGroup[9]

  self.current_letter_number = 1

  self.music_loop = audio.loadStream("Sound/Chapter_1_Interactive_Loop.wav")
  audio.play(self.music_loop, {loops=-1})

  self.start_performance_time = system.getTimer()
  self.stored_performance_time = 0
  self.total_performance_time = 0
  self.current_time = system.getTimer()
  self.measures = 1
  self.interactive_measures = 0
  self.beats = 1
  self.interactive_beats = 0

  self.beat_timer = timer.performWithDelay(1, function() 
    self:beatTimerCheck()
  end, 0)

  if self.script_assets ~= nil and self.script_assets ~= "" then

    self:updatePerformance()

    self.update_timer = timer.performWithDelay(35, function() 
      self:updatePerformance()
    end, 0)
  end

  local sound = audio.loadSound("Sound/Chapter_1/" .. info.word .. "_Intro.wav")
  audio.play(sound, {onComplete = function()
    self.mode = "interactive"
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

  self.spelling_object = display.newSprite(self.performanceAssetGroup, self.sprite[picture], {frames=picture_info[picture].frames})
  self.spelling_object.id = picture .. "_" .. 0
  self.spelling_object.x = spelling_object_x
  self.spelling_object.y = spelling_object_y
  self.spelling_object.fixed_y = self.spelling_object.y
  self.spelling_object.fixed_x = self.spelling_object.x
  self.spelling_object.info = picture_info[picture]
  self.spelling_object.intro = "sketch"
  self.spelling_object:setFrame(1)
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

      local button_backing = display.newSprite(self.performanceAssetGroup, self.sprite["Letter_Box"], {frames=picture_info["Letter_Box"].frames})
      button_backing.id = "button_backing_" .. i
      button_backing.x = display.contentCenterX + gap * (i - string.len(info.word)/2 - 0.5)
      button_backing.y = display.contentCenterY + 250
      button_backing.fixed_y = button_backing.y
      button_backing.fixed_x = button_backing.x
      button_backing.info = picture_info["Letter_Box"]
      button_backing.intro = "static"
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

      local button_letter = display.newSprite(self.performanceAssetGroup, self.sprite[picture], {frames=picture_info[picture].frames})
      button_letter.id = picture .. "_" .. i
      button_letter.x = display.contentCenterX + gap * (i - string.len(info.word)/2 - 0.5)
      button_letter.y = display.contentCenterY + 250
      button_letter.fixed_y = button_letter.y
      button_letter.fixed_x = button_letter.x
      button_letter.info = picture_info[picture]
      button_letter.intro = "static"
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
        if self.mode == "interactive" then
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
              self.mode = "pre_outro"
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
  self.current_time = system.getTimer()
  if self.current_time - self.start_performance_time > (self.info.mpb * self.info.time_sig) * self.measures then
    self:measureActions()
    -- measure action could finish the scene, so check for that before going on
    if self.mode ~= "finished" then
      self.measures = self.measures + 1
      if self.mode == "interactive" then
        self.interactive_measures = self.interactive_measures + 1
      end
    end
  end

  if self.mode ~= "finished" and self.current_time - self.start_performance_time > self.info.mpb * self.beats then
    self:beatActions()
    self.beats = self.beats + 1
    if self.mode == "interactive" then
      self.interactive_beats = self.interactive_beats + 1
    end
  end

  if self.mode == "finished" then
    timer.cancel(self.beat_timer)
    
    audio.stop()

    for i = 1, string.len(self.info.word) do
      self.buttons[i]:removeEventListener("tap", self.buttons[i].event)
      display.remove(self.buttons[i])
    end
    self.buttons = {}

    self:nextScene()
  end
end

function scene:beatActions()
  -- print("on interactive beat " .. self.interactive_beats)

  local info = self.info
  local word = string.lower(self.info.word)

    -- on every other beat during interactives, update the color coding to fit the letter
  if self.mode == "interactive" then
    self:setWordColor(self.current_letter_number)
  end

  -- on interactives, on the 3rd out of every 8 beats, tell the player to press a button.
  -- the sound is delayed by one beat (to capture the pre-beat sound), so this will actually
  -- land right on the measure mark.
  if self.mode == "interactive" and self.interactive_beats % 8 == 3 then
    if self.current_letter_number >= 1 and self.current_letter_number <= string.len(word) then
      current_letter = word:sub(self.current_letter_number, self.current_letter_number)
      randomizer = math.random(4)
      local sound = audio.loadSound("Sound/Interactive_Letters_".. info.bpm .. "/" .. current_letter .. "_" .. randomizer .. ".wav")
      audio.play(sound)
    end
  end
end

function scene:measureActions()
  -- print("on measure")

  local info = self.info
  local word = string.lower(self.info.word)

  if self.mode == "pre_outro" then
    self.mode = "outro"

    -- play the outro sound
    local sound = audio.loadSound("Sound/Chapter_1/" .. info.word .. "_Outro.wav")
    audio.play(sound, {onComplete = function()
      self.mode = "post_outro"
    end})

    -- load up some letter timing for show
    for letter_num = 1, string.len(info.word) do
      timer.performWithDelay(info.outro_letter_beats[letter_num] * info.mpb, function()
        self:setWordColor(letter_num)
      end)
    end
    for letter_num = 1, string.len(info.word) do
      timer.performWithDelay(info.outro_sound_beats[letter_num] * info.mpb, function()
        self:setWordColor(letter_num)
      end)
    end
    timer.performWithDelay(info.outro_word_beat * info.mpb, function()
      self:setWordColor("all")
    end)
    timer.performWithDelay((info.outro_word_beat + 1) * info.mpb, function()
      self:setWordColor("none")
    end)
  end

  if self.mode == "post_outro" then
    self.mode = "finished"
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


-- -----------------------------------------------------------------------------------



return scene
