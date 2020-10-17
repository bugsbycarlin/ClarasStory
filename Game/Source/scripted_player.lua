
local composer = require("composer")
local json = require("json")
local lfs = require("lfs")

local animation = require("plugin.animation")

-- local picture_info = require("Source.pictures")
local sound_info = require("Source.sounds")
local loader = require("Source.loader")

local interactive_spelling_player = require("Source.interactive_spelling_player")
local interactive_choice_player = require("Source.interactive_choice_player")

local scene = composer.newScene()

-- local small_word_gap = 180
-- local large_word_gap = 160

local printMemUsage = function()  
  local memUsed = (collectgarbage("count"))
  local texUsed = system.getInfo( "textureMemoryUsed" ) / 1048576 -- Reported in Bytes
 
  print("\n---------MEMORY USAGE INFORMATION---------")
  print("System Memory: ", string.format("%.00f", memUsed), "KB")
  print("Texture Memory:", string.format("%.03f", texUsed), "MB")
  print("------------------------------------------\n")
end

local const_allow_editor = true

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

    self.picture_info = require("Source.pictures")

    interactive_spelling_player:augment(self)
    interactive_choice_player:augment(self)

    self.const_half_layers = 10
    self.const_num_layers = 2 * self.const_half_layers + 1

    for i = -1 * self.const_half_layers, self.const_half_layers do
      local layer = display.newGroup()
      self.performanceAssetGroup:insert(layer)
    end

    self.top_group = self.performanceAssetGroup[self.const_num_layers]

    display.setDefault("background", 1, 1, 1)

    self.memory_log_timer = timer.performWithDelay(3000, function() 
      printMemUsage()
    end, 0)

    self:initializeFromChapter()

    if const_allow_editor == true then
      editor = require("Source.editor_2")
      editor:augment(self)
    end

    if self.chapter_number == 2 then
      scene_actions_chapter_2 = require("Source.scene_actions_chapter_2")
      scene_actions_chapter_2:augment(self)
    end

    self:setupLoading()

    if self.scene_type == "scripted" then
      self:startScripted()
    elseif self.scene_type == "interactive_spelling" then
      self:startInteractiveSpelling()
    elseif scene.scene_type == "interactive_choice" then
      self:startInteractiveChoice()
    end

    self.skip_scene_button = display.newImageRect(self.sceneGroup, "Art/skip_scene.png", 40, 40)
    self.skip_scene_button.x = display.contentWidth - 35
    self.skip_scene_button.y = display.contentHeight - 30
    self.skip_scene_button.alpha = 0.3
    self.skip_scene_button.last_skip = system.getTimer() - 1
    self.skip_scene_button:addEventListener("tap", function(event)
      if (system.getTimer() - self.skip_scene_button.last_skip > 1) then
        self.skip_scene_button.last_skip = system.getTimer()
        self:skipPerformanceToTime(100000)
        if self.special_timer ~= nil then
          timer.cancel("special")
        end
        if self.scene_type == "scripted" then
          audio.stop()
          self:nextScene()
        elseif self.scene_type == "interactive_spelling" then
          self:finishSpellingScene()
        elseif self.scene_type == "interactive_choice" then
          self:finishChoiceScene()
        end
      end
    end)
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

  if self.mode ~= "editing" then
    self.total_performance_time = self.stored_performance_time + (self.current_time - self.start_performance_time)
  end
end

function scene:perform(asset)
  -- print(self.chapter_number)
  print(self)
  print(asset)
  print("I AM PERFORMING " .. asset.name)
  print("Asset has type " .. asset.type)
  if asset.type == "sound" then
    asset.performance = audio.loadStream("Sound/" .. sound_info[asset.name].file_name)
    -- should only do if this is the main audio file
    audio.play(asset.performance, {loops = 0, onComplete=function(event)
      if event.completed == true then
        self:nextScene()
      end
    end})
  elseif asset.type == "picture" then
    local picture = asset.name

    print(asset.id)
    print(asset.choice_value)
    print(picture)
    if asset.choice_value ~= nil and asset.choice_value ~= "" then
      picture = asset.choice_value
      print("I am setting this picture using choice value instead")
    end

    -- guard against trying to use an unloaded sprite.
    -- sometimes this is triggered intentionally rather than loading some oddball thing.
    if self.sprite[picture] == nil then
      print("Attempting last minute load for " .. picture)
      self.loader:loadPicture(picture)
    end

    asset.performance = display.newSprite(self.performanceAssetGroup[asset.depth + self.const_half_layers + 1], self.sprite[picture], {frames=self.picture_info[picture].frames})
    asset.performance.name = asset.name
    asset.performance.id = asset.id
    asset.performance.x = asset.x
    asset.performance.y = asset.y
    asset.performance.fixed_y = asset.y
    asset.performance.fixed_x = asset.x
    asset.performance.x_vel = 0
    asset.performance.y_vel = 0
    asset.performance.info = self.picture_info[picture]
    asset.performance.intro = asset.intro
    self:setInitialPerformanceState(asset.performance, asset.intro, picture)
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

function scene:setInitialPerformanceState(performance_object, intro, picture)
  performance_object.intro = intro
  if intro == "sketch" then
    performance_object:setFrame(1)
    performance_object.state = "sketching"
  elseif intro == "splash" then
    performance_object.animation_count = 0
    performance_object:setFrame(1)
    performance_object.state = "splash"
  elseif intro == "outline_sketching" then
    performance_object:setFrame(1)
    performance_object.state = "outline_sketching"
  elseif intro == "fade_in" then
    performance_object:setFrame(self.picture_info[picture]["sprite_count"])
    performance_object.state = "fade_in"
    performance_object.alpha = 0.01
  elseif intro == "punch" then
    performance_object:setFrame(self.picture_info[picture]["sprite_count"])
    performance_object.state = "punch"
  elseif intro == "rise" then
    performance_object:setFrame(self.picture_info[picture]["sprite_count"])
    performance_object.state = "rise"
    local height = performance_object.info.sprite_size
    if performance_object.info["sprite_height"] ~= nil then
      height = performance_object.info["sprite_height"]
    end
    performance_object.y = asset.y + height
    performance_object.fixed_y = performance_object.y
  elseif intro == "poof" then
    performance_object:setFrame(self.picture_info[picture]["sprite_count"])
    performance_object.state = "poof"
    performance_object.alpha = 0.01
    animation.to(performance_object, {alpha = 1}, {time=self.mpb * 0.5, easing=easing.outExp})
  else
    performance_object:setFrame(self.picture_info[picture]["sprite_count"])
    if performance_object.info["animation_end"] ~= nil then
      performance_object.state = "animating"
      performance_object.animation_count = 0
    else
      performance_object.state = "static"
    end
  end
end

function scene:clearPerformance()
  self.sketch_sprites:immediatelyRemoveAll()
  self.sketch_sprites.sprite_list = {}

  for i = 1, #self.script_assets do
    asset = self.script_assets[i]
    asset.performance = nil
  end

  for i = 1, self.const_num_layers do
    while self.performanceAssetGroup[i].numChildren > 0 do
      local child = self.performanceAssetGroup[i][1]
      if child then child:removeSelf() end
    end
  end

  for i = 1, self.const_num_layers do
    self.performanceAssetGroup[i].x = 0
  end
  self.performanceAssetGroup.x = 0
  self.performanceAssetGroup.y = 0
end

function scene:updatePerformance()
  local last_update_time = self.total_performance_time
  self:updateTime()

  if basic_info_text ~= nil and basic_info_text.isVisible == true then
    local objects_in_performance = 0
    for i = 1, self.const_num_layers do
      objects_in_performance = objects_in_performance + self.performanceAssetGroup[i].numChildren
    end 
    basic_info_text.text = "Time: " .. math.floor(self.total_performance_time) / 1000.0 .. ", Objects: " .. objects_in_performance
  end

  if (self.mode ~= "editing") then
    for i = 1, #self.script_assets do
      asset = self.script_assets[i]
      if asset.performance == nil and last_update_time <= asset.start_time and self.total_performance_time >= asset.start_time then
        self:perform(asset)
      end
    end
  end
end

function scene:skipPerformanceToTime(time_value)
  -- self.total_performance_time = time_value -- this won't work because of the way those update.

  for i = 1, #self.script_assets do
    asset = self.script_assets[i]
    if asset.performance == nil and time_value >= asset.start_time and (asset.disappear_time <= 0 or time_value < asset.disappear_time) then
      self:perform(asset)
    end
  end

  copy_sprite_list = {}
  for i = 1, #self.sketch_sprites.sprite_list do
    local sprite = self.sketch_sprites.sprite_list[i]
    -- print(sprite.name)
    -- print(sprite.disappear_method)
    -- print(sprite.disappear_time)
    if sprite and sprite.disappear_method ~= nil and sprite.disappear_method ~= "" and sprite.disappear_time > 0 and time_value > sprite.disappear_time then
      -- print("killing it")
      animation.cancel(sprite)
      display.remove(sprite)
    else
      -- print("saving it")
      table.insert(copy_sprite_list, sprite)
    end
  end
  self.sketch_sprites.sprite_list = copy_sprite_list
end

function scene:nextScene()
  self.mode = nil

  timer.cancel(self.sketch_sprite_timer)
  if self.update_timer ~= nil then
    timer.cancel(self.update_timer)
  end

  if self.special_timer ~= nil then
    timer.cancel("special")
  end

  if self.info["cleanup"] == nil or self.info["cleanup"] ~= false then
    self:clearPerformance()
    self.sketch_sprites.picture_info = nil
    self.sketch_sprites.sprite = nil
    self.sketch_sprites.top_group = nil
  end
  if self.scene_type == "interactive_spelling" then
    -- print("I AM CLEARING THE SPELLING")
    self:clearSpellingMaterial()
  end

  if self.next_scene ~= "end" and self.chapter_flow[self.next_scene] ~= nil then
    self:initializeScene()
  else
    self.scene_type = nil
    self.script_assets = nil
    self.chapter:finish()
  end

  if self.scene_type == "scripted" then
    self:startScripted()
  elseif self.scene_type == "interactive_spelling" then
    self:startInteractiveSpelling()
  elseif self.scene_type == "interactive_choice" then
    self:startInteractiveChoice()
  end

  -- start loading the next stuff
  self:setupLoading()
end

function scene:initializeFromChapter()
  self.chapter = composer.getVariable("chapter")
  self.sketch_sprites = composer.getVariable("sketch_sprites")
  self.sprite = composer.getVariable("sprite")
  self.scene_name = composer.getVariable("scene_name")
  self.info = composer.getVariable("settings")
  self.chapter_number = composer.getVariable("chapter_number")
  self.next_scene = composer.getVariable("next_scene")
  self.sprite = composer.getVariable("sprite")
  self.script_assets = composer.getVariable("script_assets")
  self.chapter_flow = composer.getVariable("chapter_flow")
  self.bpm = composer.getVariable("bpm")
  self.mpb = composer.getVariable("mpb")
  self.time_sig = composer.getVariable("time_sig")
  self.scene_type = self.info["type"]

  self.sketch_sprites.picture_info = self.picture_info
  self.sketch_sprites.sprite = self.sprite
  self.sketch_sprites.top_group = self.top_group

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

  self.sketch_sprites.picture_info = self.picture_info
  self.sketch_sprites.sprite = self.sprite
  self.sketch_sprites.top_group = self.top_group

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
  print(self.sceneActions)
  print(self.scene_name)
  print(self.sceneActions[self.scene_name])
  if self.sceneActions ~= nil and self.sceneActions[self.scene_name] ~= nil then
    print("I found my scene actions")
    self.sceneActions[self.scene_name]()
  end

  -- if self.scene_name == "chapter_2_scene_1" then
  --   self.performanceAssetGroup.y = 1024
  --   animation.to(self.performanceAssetGroup, {y = 0}, {time = 375 * 16, easing = easing.inOutQuart})

  --   local back_row = 1 + self.const_half_layers + 1
  --   local front_row = 2 + self.const_half_layers + 1

  --   local super_back_row = -5 + self.const_half_layers + 1
  --   local super_front_row = -4 + self.const_half_layers + 1
  --   self.chapter_2_scoot_counter = 0
  --   scoot = function()
  --     print("SCOOT")
  --     self.chapter_2_scoot_counter = self.chapter_2_scoot_counter + 1
  --     if self.chapter_2_scoot_counter % 4 == 1 then
  --       self.performanceAssetGroup[back_row].x = self.performanceAssetGroup[back_row].x - 1024
  --       self.performanceAssetGroup[front_row].x = self.performanceAssetGroup[front_row].x + 1024
  --       self.performanceAssetGroup[super_back_row].x = self.performanceAssetGroup[super_back_row].x - 1024
  --       -- self.performanceAssetGroup[super_front_row].x = self.performanceAssetGroup[super_front_row].x + 1024
  --     end
  --     current_x = self.performanceAssetGroup[back_row].x
  --     current_super = self.performanceAssetGroup[super_back_row].x
  --     animation.to(self.performanceAssetGroup[back_row], {x=current_x + 256}, {time=750 / 4 * 0.7, easing=easing.outExp})
  --     animation.to(self.performanceAssetGroup[super_back_row], {x=current_super + 256}, {time=750 / 4 * 0.7, easing=easing.outExp})

  --     -- scoot left
  --     timer.performWithDelay(750 * 3 / 4, function()
  --       current_x = self.performanceAssetGroup[front_row].x
  --       animation.to(self.performanceAssetGroup[front_row], {x=current_x - 256}, {time=750 / 4 * 0.7, easing=easing.outExp})
  --       current_super = self.performanceAssetGroup[super_front_row].x
  --       -- animation.to(self.performanceAssetGroup[super_front_row], {x=current_super - 256}, {time=750 / 4 * 0.7, easing=easing.outExp})
  --     end, 1)

  --     if math.random(10) >= 6 then
  --       -- print("honking")
  --       local honk_image = display.newImageRect(self.top_group, "Art/honk.png", 256, 256)
  --       honk_image.x = 100 + math.random(824)
  --       honk_image.y = 192 + 50 + math.random(384 - 100)
  --       timer.performWithDelay(self.mpb * 3 / 4, function()
  --         display.remove(honk_image)
  --       end, 1)
  --     end
  --   end

  --   scoot()
  --   self.special_timer = timer.performWithDelay(1500, function()
  --     scoot()
  --   end, 0, "special")


  --   -- honks!
  --   honk_images = {}
  --   --22500
  --   -- fix this so skipping cancels it
  --   for i = 1,8 do
  --     timer.performWithDelay(22500 - (375/2) + (self.mpb / 2) * i, function()
  --       -- print("MAKING A HONK")
  --       local honk_image = display.newImageRect(self.top_group, "Art/honk.png", 256, 256)
  --       honk_image.x = 100 + 100 * i
  --       honk_image.y = 192 + 50 + math.random(384 - 100)
  --       table.insert(honk_images, honk_image)
  --       timer.performWithDelay(self.mpb * 3 / 4, function()

  --         display.remove(honk_image)
  --       end, 1)
  --     end, 1)
  --   end
  -- end

  -- if self.scene_name == "chapter_2_scene_2" then
  --   self.special_timer = timer.performWithDelay(187, function()
  --     if self.total_performance_time > 4500 and self.total_performance_time < 6000 then
  --       local honk_image = display.newImageRect(self.top_group, "Art/honk.png", 256, 256)
  --         honk_image.x = 100 + math.random(824)
  --         honk_image.y = 192 + 50 + math.random(384 - 100)
  --         timer.performWithDelay(self.mpb * 3 / 4, function()
  --           display.remove(honk_image)
  --       end, 1)
  --     end
  --   end, 0, "special")

  --   self.special_timer = timer.performWithDelay(6750, function()
  --     -- move Girl_13 out and up in advance of switching scenes
  --     for i = 1, #self.script_assets do
  --       asset = self.script_assets[i]
  --       -- print(asset.id)
  --       if asset.id == "Girl_13" and asset.performance ~= nil then
  --         -- print("I found Girl_13")

  --         self.sketch_sprites:poopClouds(asset.performance, 8 + math.random(16))
  --         asset.performance.fixed_x = asset.performance.fixed_x + 2010 -- basically remove it, actually
  --         asset.performance.fixed_y = asset.performance.fixed_y - 58
  --         -- self.sketch_sprites:poopClouds(asset.performance, 4 + math.random(8))
  --       end
  --     end
  --   end, 1, "special")

  --   timer.performWithDelay(12000, function()
  --     local back_row = 1 + self.const_half_layers + 1
  --     local front_row = 2 + self.const_half_layers + 1
  --     self.chapter_2_scoot_counter = 0
  --     if self.scene_name == "chapter_2_scene_2" then
  --       scoot = function()
  --         self.chapter_2_scoot_counter = self.chapter_2_scoot_counter + 1
  --         -- if self.chapter_2_scoot_counter % 4 == 1 then
  --         --   self.performanceAssetGroup[back_row].x = self.performanceAssetGroup[back_row].x - 1024
  --         --   self.performanceAssetGroup[front_row].x = self.performanceAssetGroup[front_row].x + 1024
  --         -- end
  --         local back_and_forth = 128
  --         if self.chapter_2_scoot_counter % 2 == 1 then
  --           back_and_forth = -1 * back_and_forth
  --         end

  --         current_x = self.performanceAssetGroup[back_row].x
  --         animation.to(self.performanceAssetGroup[back_row], {x=current_x + back_and_forth}, {time=750 / 4 * 0.7, easing=easing.outExp})

  --         -- scoot left
  --         timer.performWithDelay(750 * 3 / 4, function()
  --           current_x = self.performanceAssetGroup[front_row].x
  --           animation.to(self.performanceAssetGroup[front_row], {x=current_x - 256}, {time=750 / 4 * 0.7, easing=easing.outExp})
  --           current_x = self.performanceAssetGroup[back_row].x
  --           animation.to(self.performanceAssetGroup[back_row], {x=current_x - back_and_forth}, {time=750 / 4 * 0.7, easing=easing.outExp})
  --         end, 1)

  --         -- print("honking")
  --         local honk_image = display.newImageRect(self.top_group, "Art/honk.png", 256, 256)
  --         honk_image.x = 100 + math.random(824)
  --         honk_image.y = 192 + 50 + math.random(384 - 100)
  --         timer.performWithDelay(self.mpb * 3 / 4, function()
  --           display.remove(honk_image)
  --         end, 1)
  --       end

  --       scoot()
  --       self.special_timer = timer.performWithDelay(1500, function()
  --         scoot()
  --       end, 0, "special")
  --     end
  --   end, 1, "special")
  -- end

  -- local marker_1 = 2250 - 375
  -- local marker_2 = 4500
  -- local shop_time = 375
  -- zoom = function()
  --   if self.scene_name == "chapter_2_scene_3" and self.mode == "performing" then
  --     -- print(self.total_performance_time)
  --     local focus_layer = 0 + self.const_half_layers + 1
  --     if self.total_performance_time < marker_1 
  --       or (self.total_performance_time > marker_1 + shop_time and self.total_performance_time < marker_2) 
  --       or self.total_performance_time > marker_2 + shop_time and self.total_performance_time < 6000 then

  --       self.performanceAssetGroup[focus_layer].isVisible = true
  --       for i = 1, self.const_num_layers do
  --         -- print("in here " .. i)
  --         if i ~= focus_layer then
  --           self.performanceAssetGroup[i].x = self.performanceAssetGroup[i].x - 7
  --           if self.performanceAssetGroup[i].x < -1024 then
  --             self.performanceAssetGroup[i].x = -1024
  --           end
  --         end
  --       end
  --     else
  --       self.performanceAssetGroup[focus_layer].isVisible = false
  --       if self.total_performance_time >= 6000 then
  --         for i = 1, self.const_num_layers do
  --           self.performanceAssetGroup[i].x = 0
  --         end
  --       end
  --       self.performanceAssetGroup.x = 0
  --       self.performanceAssetGroup.y = 0
  --     end
  --   end
  -- end
  -- self.special_timer = timer.performWithDelay(33, function()
  --   zoom()
  -- end, 0, "special")

  -- if self.scene_name == "chapter_2_scene_4" then
  --   -- self.performanceAssetGroup.y = 0
  --   animation.to(self.performanceAssetGroup, {y = 256}, {time = 375 * 16, easing = easing.inOutSine})
  --   self.special_timer = timer.performWithDelay(9000, function()
  --     -- self.performanceAssetGroup.y = 0
  --   end, 1, "special")
  -- end
end

function scene:setupLoading()
  local items = self:computeNextLoad()
  local load_items = items[1]
  local unload_items = items[2]
  print("Got " .. #load_items .. " to load for next scene.")
  -- for i = 1, #load_items do
  --   -- print("Gotta load " .. load_items[i])
  -- end
  print("Got " .. #unload_items .. " to unload for next scene.")
  -- for i = 1, #unload_items do
  --   -- print("Gotta unload " .. unload_items[i])
  -- end
  self.loader:backgroundLoad(
    self.sprite,
    self.picture_info,
    load_items,
    unload_items,
    300,
    function(percent) end,
    function() print("Finished loading items in the background!") end)
end

function scene:computeNextLoad()
  local background_load_items = {}

  local cycles = 0
  local keep_loading = (self.next_scene ~= nil and self.next_scene ~= "end")
  local current_scene_name = self.next_scene
  while keep_loading do
    local load_scene = self.chapter_flow[current_scene_name]
    if load_scene.word ~= nil then
      background_load_items[load_scene.word] = 1
    end
    if load_scene.performance ~= nil then
      background_load_items[load_scene.performance.name] = 1
    end

    if load_scene.script ~= nil then
      for asset_name, asset_value in pairs(load_scene.script) do
        background_load_items[asset_value.name] = 1
      end
    end

    -- keep going until we've checked a scripted scene.
    cycles = cycles + 1
    keep_loading = load_scene.type ~= "scripted" and load_scene.next ~= nil and load_scene.next ~= current_scene_name and cycles < 4
    current_scene_name = load_scene.next
  end

  local clean_load_items = {}
  for picture, info in pairs(self.picture_info) do
    if background_load_items[picture] == 1 and self.picture_info[picture] ~= nil and self.sprite[picture] == nil then
      table.insert(clean_load_items, picture)
    end
  end
  background_load_items = clean_load_items

  local background_unload_items = {}
  local safe_list = {}
  -- add everything in the performance to the safe list
  for i = 1, self.const_num_layers do
    for j = 1, self.performanceAssetGroup[i].numChildren do
      local asset = self.performanceAssetGroup[i][j]
      safe_list[asset.name] = 1
    end
  end
  -- add everything from the future to the safe list
  cycles = 0
  keep_loading = (self.next_scene ~= nil)
  current_scene_name = self.scene_name
  while keep_loading do
    local load_scene = self.chapter_flow[current_scene_name]
    if load_scene.word ~= nil then
      safe_list[load_scene.word] = 1
    end

    if load_scene.performance ~= nil then
      safe_list[load_scene.performance.name] = 1
    end

    if load_scene.script ~= nil then
      for asset_name, asset_value in pairs(load_scene.script) do
        safe_list[asset_value.name] = 1
      end
    end

    -- keep going until we've checked everything
    cycles = cycles + 1
    keep_loading = load_scene.next ~= nil and load_scene.next ~= current_scene_name and cycles < 4
    current_scene_name = load_scene.next
  end

  -- now we have a safe list. unload anything in sprites that isn't on the safe_list.
  for sprite_name, sprite_value in pairs(self.sprite) do
    if (safe_list[sprite_name] == nil and self.picture_info[sprite_name].always_load ~= true) then
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
    local star_sprite = display.newSprite(self.top_group, self.sprite[picture], {frames=self.picture_info[picture].frames})
    star_sprite.id = picture .. "_" .. 0
    star_sprite.x = center_x
    star_sprite.y = center_y
    star_sprite.fixed_y = star_sprite.y
    star_sprite.fixed_x = star_sprite.x
    star_sprite.info = self.picture_info[picture]
    star_sprite.intro = "static"
    star_sprite:setFrame(self.picture_info[picture]["sprite_count"])
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


return scene
