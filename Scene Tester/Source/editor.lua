
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

local mode = "loading"

local current_time = 0
local start_performance_time = 0
local stored_performance_time = 0
local total_performance_time = 0

local update_timer = nil
local time_text = nil

local load_start_time = 0

local selected_element_id = nil

local save_file = system.pathForFile("Scenes/chapter_1_scene_1.json", system.ResourceDirectory)
print(save_file)

function scene:saveInfo(event)
  local file = io.open(save_file, "w")
 
  if file then
    file:write(json.encode(script_assets))
    io.close(file)
  end

  print(save_file)

  return true
end

function scene:loadInfo()
  local file = io.open(save_file, "r")
  print(save_file)
 
  if file then
      local contents = file:read("*a")
      io.close(file)
      script_assets = json.decode(contents)
      script_asset_count = 0
      for k,v in pairs(script_assets) do
        script_asset_count = script_asset_count + 1
      end
  end

  if script_assets == nil or #script_assets == 0 then
    script_assets = {}
  end

  have_loaded = true

  current_time = system.getTimer()
  start_performance_time = 0
  stored_performance_time = 0
  total_performance_time = 0

  self:updateScriptAssetDisplay()
  self:updateEverything()
    
  audio.stop()

  self:clearPerformance()
end

function updateTime()
  current_time = system.getTimer()

  if mode == "performing" then
    total_performance_time = stored_performance_time + (current_time - start_performance_time)
  end
end

function getSelectedAsset()
  if selected_element_id ~= nil then
    for i = 1, #script_assets do
      if script_assets[i].id == selected_element_id then
        return script_assets[i]
      end
    end
  end

  return nil
end

function scene:updateScriptAssetDisplay()
  while self.scriptAssetGroup.numChildren > 0 do
    local child = self.scriptAssetGroup[1]
    if child then child:removeSelf() end
  end

  local scriptHeaderText = display.newText(self.scriptAssetGroup, "Script", display.contentWidth - 30, 18, "Fonts/MouseMemoirs.ttf", 20)
  scriptHeaderText:setTextColor(0.3,0.3,1.0)
  scriptHeaderText.anchorX = 1
  for i = 1, #script_assets do
    local asset = script_assets[i]

    local displayText = display.newText(self.scriptAssetGroup, asset.id, display.contentWidth - 30, 18 * (i + 1), "Fonts/MouseMemoirs.ttf", 20)
    displayText.anchorX = 1
    displayText:setTextColor(0,0,0)
    if selected_element_id ~= nil and selected_element_id == asset.id then
      displayText:setTextColor(0.5,0.8,0.5)
    end
    local id = asset.id
    displayText:addEventListener("tap", function()
      selected_element_id = id
      self:updateScriptAssetDisplay()
    end)
  end

  local asset = getSelectedAsset()
  if asset ~= nil then
    if asset.type == "picture" then
      for i = 1,self.pictureEditingGroup.numChildren do
        self.pictureEditingGroup[i].isVisible = true
      end
      -- self.pictureEditingGroup.isVisible = true
      self.soundEditingGroup.isVisible = false

      if self.pictureEditingGroup.numChildren == 0 then
        labels = {"Start Time", "x", "y", "x scale", "y scale", "Disappear Time", "Disappear Method", "Squish Scale", "Squish Tilt", "Squish Period"}
        edit_fields = {}
        for i = 1, #labels do

          local label = display.newText(self.pictureEditingGroup, labels[i], display.contentWidth - 60, display.contentHeight - (2 + #labels - i) * 20, "Fonts/MouseMemoirs.ttf", 18)
          label:setTextColor(0.0, 0.0, 0.0)
          label.anchorX = 1

          local text_field = native.newTextField(display.contentWidth - 50, display.contentHeight - (2 + #labels - i) * 20, 40, 18)
          text_field.anchorX = 0
          self.pictureEditingGroup:insert(text_field)
          table.insert(edit_fields, text_field)  
        end
        
        edit_fields[1]:addEventListener("userInput", function(event)
          if event.phase == "editing" then
            asset = getSelectedAsset()
            if tonumber(event.text) ~= nil then
              asset.start_time = tonumber(event.text)
            end
          end
        end)

        edit_fields[2]:addEventListener("userInput", function(event)
          if event.phase == "editing" then
            asset = getSelectedAsset()
            if tonumber(event.text) ~= nil then
              asset.x = tonumber(event.text)
            end
            if asset.performance ~= nil then
              asset.performance.x = asset.x
            end
          end
        end)

        edit_fields[3]:addEventListener("userInput", function(event)
          if event.phase == "editing" then
            asset = getSelectedAsset()
            if tonumber(event.text) ~= nil then
              asset.y = tonumber(event.text)
            end
            if asset.performance ~= nil then
              asset.performance.y = asset.y
            end
          end
        end)

        edit_fields[4]:addEventListener("userInput", function(event)
          if event.phase == "editing" then
            asset = getSelectedAsset()
            if tonumber(event.text) ~= nil then
              asset.x_scale = tonumber(event.text)
            end
            if asset.performance ~= nil then
              asset.performance.x_scale = asset.x_scale
              asset.performance.xScale = asset.x_scale
            end
          end
        end)

        edit_fields[5]:addEventListener("userInput", function(event)
          if event.phase == "editing" then
            asset = getSelectedAsset()
            if tonumber(event.text) ~= nil then
              asset.y_scale = tonumber(event.text)
            end
            if asset.performance ~= nil then
              asset.performance.y_scale = asset.y_scale
              asset.performance.yScale = asset.y_scale
            end
          end
        end)

        edit_fields[6]:addEventListener("userInput", function(event)
          if event.phase == "editing" then
            asset = getSelectedAsset()
            if tonumber(event.text) ~= nil then
              asset.disappear_time = tonumber(event.text)
            end
            -- if asset.performance ~= nil then
            --   asset.performance.disappear_time = asset.disappear_time
            -- end
          end
        end)

        edit_fields[7]:addEventListener("userInput", function(event)
          if event.phase == "editing" then
            asset = getSelectedAsset()
            asset.disappear_method = event.text
            -- if asset.performance ~= nil then
            --   asset.performance.disappear_method = asset.disappear_method
            -- end
          end
        end)

        edit_fields[8]:addEventListener("userInput", function(event)
          if event.phase == "editing" then
            asset = getSelectedAsset()
            if tonumber(event.text) ~= nil then
              asset.squish_scale = tonumber(event.text)
            end
            if asset.performance ~= nil then
              asset.performance.squish_scale = asset.squish_scale
            end
          end
        end)

        edit_fields[9]:addEventListener("userInput", function(event)
          if event.phase == "editing" then
            asset = getSelectedAsset()
            if tonumber(event.text) ~= nil then
              asset.squish_tilt = tonumber(event.text)
            end
            if asset.performance ~= nil then
              asset.performance.squish_tilt = asset.squish_tilt
            end
          end
        end)

        edit_fields[10]:addEventListener("userInput", function(event)
          if event.phase == "editing" then
            asset = getSelectedAsset()
            if tonumber(event.text) ~= nil then
              asset.squish_period = tonumber(event.text)
            end
            if asset.performance ~= nil then
              asset.performance.squish_period = asset.squish_period
            end
          end
        end)


      end

      edit_fields[1].text = asset.start_time
      edit_fields[2].text = asset.x
      edit_fields[3].text = asset.y
      edit_fields[4].text = asset.x_scale
      edit_fields[5].text = asset.y_scale
      edit_fields[6].text = asset.disappear_time
      edit_fields[7].text = asset.disappear_method
      edit_fields[8].text = asset.squish_scale
      edit_fields[9].text = asset.squish_tilt
      edit_fields[10].text = asset.squish_period
    elseif asset.type == "sound" then
      for i = 1,self.pictureEditingGroup.numChildren do
        self.pictureEditingGroup[i].isVisible = false
      end
      -- self.pictureEditingGroup.isVisible = false
      self.soundEditingGroup.isVisible = true
    end
  end
end

function scene:perform(asset)
  if asset.type == "sound" then
    asset.performance = audio.loadSound("Sound/" .. sound_info[asset.name].file_name)
    audio.play(asset.performance, 0)
  elseif asset.type == "picture" then
    local picture = asset.name

    asset.performance = display.newSprite(self.performanceAssetGroup, sprite[picture], {frames=picture_info[picture].frames})
    asset.performance.x = asset.x
    asset.performance.y = asset.y
    asset.performance.fixed_y = asset.y
    asset.performance.fixed_x = asset.x
    asset.performance.info = picture_info[picture]
    asset.performance:setFrame(0)
    asset.performance.state = "sketching"
    asset.performance.start_time = system.getTimer()
    asset.performance.x_scale = asset.x_scale
    asset.performance.y_scale = asset.y_scale
    asset.performance.disappear_time = asset.disappear_time
    asset.performance.disappear_method = asset.disappear_method
    asset.performance.squish_scale = asset.squish_scale
    asset.performance.squish_tilt = asset.squish_tilt
    asset.performance.squish_period = asset.squish_period
    sketch_sprites:add(asset.performance)
  end
end

function scene:clearPerformance()
  sketch_sprites.sprite_list = {}

  for i = 1, #script_assets do
    asset = script_assets[i]
    asset.performance = nil
  end

  while self.performanceAssetGroup.numChildren > 0 do
    local child = self.performanceAssetGroup[1]
    if child then child:removeSelf() end
  end
end

function scene:updateEverything()
  updateTime()
  time_text.text = math.floor(total_performance_time) / 1000.0

  if mode == "performing" then
    for i = 1, #script_assets do
      asset = script_assets[i]
      if asset.performance == nil and total_performance_time >= asset.start_time then
        self:perform(asset)
      end
    end
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

  self.performanceAssetGroup = display.newGroup()
  self.sceneGroup:insert(self.performanceAssetGroup)

  self.editingGroup = display.newGroup()
  self.sceneGroup:insert(self.editingGroup)

  self.scriptAssetGroup = display.newGroup()
  self.editingGroup:insert(self.scriptAssetGroup)

  self.pictureEditingGroup = display.newGroup()
  self.editingGroup:insert(self.pictureEditingGroup)

  self.soundEditingGroup = display.newGroup()
  self.editingGroup:insert(self.soundEditingGroup)

  sketch_sprites = sketch_sprites_class:create()

  if (phase == "will") then
    -- Code here runs when the scene is still off screen (but is about to come on screen)
    
  elseif (phase == "did") then
    -- Code here runs when the scene is entirely on screen

    local base_path = system.pathForFile(nil, system.ResourceDirectory)
    -- print(base_path)
    -- local path = system.pathForFile("Pages", system.ResourceDirectory)
    -- print(path)

    display.setDefault("background", 1, 1, 1)

    time_text = display.newText(self.sceneGroup, "0", display.contentCenterX, 30, "Fonts/MouseMemoirs.ttf", 30)
    time_text:setTextColor(0.0, 0.0, 0.0)

    self.partialLoadNumber = 1
    self.partialLoadObjects = {}
    for picture, info in pairs(picture_info) do
      table.insert(self.partialLoadObjects, picture)
    end

    loadingText = display.newText(self.sceneGroup, "Bongos", display.contentCenterX, display.contentCenterY, "Georgia-Bold", 50)
    loadingText:setTextColor(0.0, 0.0, 0.0)

    function updateLoadDisplay()
      local percent = math.floor((self.partialLoadNumber / #self.partialLoadObjects) * 100)
      loadingText.text = "Loading " .. percent .. "%"
    end

    timer.performWithDelay(40, function() 
      load_start_time = system.getTimer()
      self:partialLoad() 
    end)

    Runtime:addEventListener("enterFrame", updateLoadDisplay)

    updateLoadDisplay()

    timer.performWithDelay(35, function() 
      sketch_sprites:update(mode, total_performance_time)
    end, 0)

    Runtime:addEventListener("key", function(event) self:handleKeyboard(event) end)

  end
end

function scene:partialLoad()
  picture_name = self.partialLoadObjects[self.partialLoadNumber]
  if string.len(picture_name) >= 1 then
    file_name = picture_info[picture_name]["file_name"]
    sheet = picture_info[picture_name]["sheet"]
    sprite[picture_name] = graphics.newImageSheet("Art/" .. file_name, sheet)
  end
  print("Loaded " .. picture_name)

  self.partialLoadNumber = self.partialLoadNumber + 1
  if self.partialLoadNumber <= #self.partialLoadObjects then
  -- if self.partialLoadNumber < 2 then
    timer.performWithDelay(20, function() self:partialLoad() end)
  else
    loadingText.text = "Loading 100%"
    Runtime:removeEventListener("enterFrame", updateLoadDisplay)
    local load_time_total = system.getTimer() - load_start_time
    print("Load time was " .. load_time_total)
    self:startEditor()
  end
end

function scene:startEditor()
  -- remove loading text
  loadingText:removeSelf()

  -- add pictures menu
  local image_count = 0
  local pictureHeaderText = display.newText(self.editingGroup, "Pictures", 30, 14, "Fonts/MouseMemoirs.ttf", 16)
  pictureHeaderText:setTextColor(0.3,0.3,1.0)
  pictureHeaderText.anchorX = 0
  for picture_name, info in pairs(picture_info) do
    if string.len(picture_name) >= 1 then
      local displayText = display.newText(self.editingGroup, picture_name, 30, 14 * (image_count + 2), "Fonts/MouseMemoirs.ttf", 16)
      displayText.anchorX = 0
      displayText:setTextColor(0,0,0)
      image_count = image_count + 1
      displayText:addEventListener("tap", function()
        if mode == "editing" then
          script_asset_count = script_asset_count + 1
          new_asset = {
            name=picture_name,
            id=picture_name .. "_" .. script_asset_count,
            type="picture",
            start_time=stored_performance_time,
            x=display.contentCenterX,
            y=display.contentCenterY,
            x_scale=1,
            y_scale=1,
            disappear_time=-1,
            disappear_method="",
            squish_scale=1,
            squish_tilt=0,
            squish_period=1718,
            performance=nil,
            timer=nil,
          }
          table.insert(script_assets, new_asset)

          selected_element_id = new_asset.id

          self:updateScriptAssetDisplay()

          self:perform(new_asset)
        end
      end)
    end

    stored_performance_time = 0
    total_performance_time = 0
    mode = "editing"
  end

  -- add sounds menu
  local sound_count = 0
  sound_names = {}
  for name, info in pairs(sound_info) do
    table.insert(sound_names, name)
  end
  local soundHeaderText = display.newText(self.editingGroup, "Sounds", 30, display.contentHeight - 30 * (#sound_names + 2), "Fonts/MouseMemoirs.ttf", 32)
  soundHeaderText:setTextColor(0.3,0.3,1.0)
  soundHeaderText.anchorX = 0
  for sound_name, info in pairs(sound_info) do
    if string.len(sound_name) > 2 then
      local displayText = display.newText(self.editingGroup, sound_name, 30, display.contentHeight - 30 * (#sound_names + 1), "Fonts/MouseMemoirs.ttf", 32)
      displayText.anchorX = 0
      displayText:setTextColor(0,0,0)
      sound_count = sound_count + 1
      displayText:addEventListener("tap", function()
        if mode == "editing" then
          script_asset_count = script_asset_count + 1
          new_asset = {
            name=sound_name,
            id=sound_name .. "_" .. script_asset_count,
            type="sound",
            start_time=stored_performance_time,
            timer=nil,
            performance=nil,
            x=display.contentCenterX,
            y=display.contentCenterY
          }
          table.insert(script_assets, new_asset)

          selected_element_id = new_asset.id

          self:updateScriptAssetDisplay()
        end
      end)
    end
  end

  Runtime:addEventListener("touch", function(event) self:handleMouse(event) end)

  self:updateScriptAssetDisplay()
end

asset_start_x = 0
asset_start_y = 0
function scene:handleMouse(event)
  if mode == "editing" then
    local asset = getSelectedAsset()

    if asset ~= nil and asset.type == "picture" and asset.performance ~= nil then
      if event.phase == "began" then
        asset_start_x = asset.performance.fixed_x
        asset_start_y = asset.performance.fixed_y
        if asset_start_x == nil then
          asset_start_x = 0
          asset_start_y = 0
        end
      elseif event.phase == "moved" or event.phase == "ended" or event.phase == "cancelled" then
        asset.performance.fixed_x = asset_start_x + event.x - event.xStart
        asset.performance.fixed_y = asset_start_y + event.y - event.yStart
        asset.fixed_x = asset.performance.fixed_x
        asset.fixed_y = asset.performance.fixed_y
        asset.x = asset.fixed_x
        asset.y = asset.fixed_y
      end
    end
  end
end

function scene:handleKeyboard(event)
  if event.keyName == "space" and event.phase == "down" then
    if mode == "editing" then
      mode = "performing"
      self.editingGroup.isVisible = false
      for i = 1,self.pictureEditingGroup.numChildren do
        self.pictureEditingGroup[i].isVisible = false
      end
      audio.resume()
      start_performance_time = system.getTimer()
      current_time = system.getTimer()
      update_timer = timer.performWithDelay(35, function() 
        self:updateEverything()
      end, 0)
    elseif mode == "performing" then
      mode = "editing"
      self.editingGroup.isVisible = true
      for i = 1,self.pictureEditingGroup.numChildren do
        self.pictureEditingGroup[i].isVisible = true
      end
      audio.pause()
      current_time = system.getTimer()
      stored_performance_time = stored_performance_time + current_time - start_performance_time
      total_performance_time = stored_performance_time
      self:updateEverything()
      timer.cancel(update_timer)
    end
  end

  if event.isCtrlDown and event.keyName == "r" and event.phase == "down" then
    mode = "editing"
    self.editingGroup.isVisible = true
    for i = 1,self.pictureEditingGroup.numChildren do
      self.pictureEditingGroup[i].isVisible = true
    end

    if update_timer ~= nil then
      timer.cancel(update_timer)
    end

    current_time = system.getTimer()
    start_performance_time = 0
    stored_performance_time = 0
    total_performance_time = 0
    
    self:updateEverything()
    
    audio.stop()

    self:clearPerformance()
  end

  if event.isCtrlDown and event.keyName == "d" and event.phase == "up" then
    if mode == "editing" then
      asset = getSelectedAsset()
      if asset.type == "picture" and asset.performance ~= nil then
        asset.performance:removeSelf()
      end
       new_script_assets = {}
      for i = 1, #script_assets do
        if script_assets[i].id ~= selected_element_id then
          table.insert(new_script_assets, script_assets[i])
        end
      end
      script_assets = new_script_assets
      selected_element_id = nil

      self:updateScriptAssetDisplay()
    end
  end

  if event.isCtrlDown and event.keyName == "p" and event.phase == "up" then
    if mode == "editing" then
      asset = getSelectedAsset()
      if asset ~= nil and asset.type == "picture" and asset.performance == nil then
        self:perform(asset)
      end
    end
  end

  if event.isCtrlDown and event.keyName == "s" and event.phase == "up" then
    if mode == "editing" then
      self:saveInfo()
    end
  end

  if event.isCtrlDown and event.keyName == "l" and event.phase == "up" then
    if mode == "editing" then
      self:loadInfo()
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
  Runtime:removeEventListener("key")
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
