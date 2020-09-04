
local composer = require("composer")
local json = require("json")
local lfs = require("lfs")

local picture_info = require("Source.pictures")
local sound_info = require("Source.sounds")

local scene = composer.newScene()

local sprite = {}

local script_assets = {}

local current_time = 0
local start_performance_time = 0
local stored_performance_time = 0
local total_performance_time = 0

local update_timer = nil

local load_start_time = 0

local selected_element_id = nil

local mode = nil

function updateTime()
  current_time = system.getTimer()

  if mode == "performing" then
    total_performance_time = stored_performance_time + (current_time - start_performance_time)
  end
end

function scene:nextScene()
  timer.cancel(self.sketch_sprite_timer)
  if self.info["cleanup"] == nil or self.info["cleanup"] ~= false then
    self.sketch_sprites:immediatelyRemoveAll()
  end
  mode = nil
  self.chapter:gotoScene(self.next_scene, nil)
  -- composer.gotoScene("Source.interactive_spelling_player", nil)
end

function scene:perform(asset)
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
  self.sketch_sprites.sprite_list = {}

  for i = 1, #script_assets do
    asset = script_assets[i]
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

  if mode == "performing" then
    for i = 1, #script_assets do
      asset = script_assets[i]
      if asset.performance == nil and last_update_time <= asset.start_time and total_performance_time >= asset.start_time then
        print("Performing " .. asset.id)
        self:perform(asset)
      end
    end
  end
end

-- function scene:fullReset()

-- end


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

    self.sketch_sprite_timer = timer.performWithDelay(35, function() 
      self.sketch_sprites:update(mode, total_performance_time)
    end, 0)

    self.info = composer.getVariable("settings")
    self.chapter = composer.getVariable("chapter")
    self.next_scene = composer.getVariable("next_scene")

    -- Runtime:addEventListener("key", function(event) self:handleKeyboard(event) end)
    -- Runtime:addEventListener("touch", function(event) self:handleMouse(event) end)

    sprite = composer.getVariable("sprite")
    script_assets = composer.getVariable("script_assets")

    scene:startPerformance()
  end
end

function scene:startPerformance()
  mode = "performing"

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
  -- Runtime:removeEventListener("touch")
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
