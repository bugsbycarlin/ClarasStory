local animation = require("plugin.animation")
local json = require("json")

editor = {}
editor.__index = editor

function editor:augment(player)

  player.startEditor = function()
    print("Switching to editing mode")
    player.last_mode = player.mode
    player.mode = "editing"

    if player.first_edit == false then
      Runtime:addEventListener("touch", function(event) player:handleMouse(event) end)
      player.first_edit = true
    end

    player.editingGroup.isVisible = true
    for i = 1,player.pictureEditingGroup.numChildren do
      player.pictureEditingGroup[i].isVisible = true
    end
    basic_info_text.isVisible = true

    audio.pause()

    player.current_time = system.getTimer()
    player.stored_performance_time = player.stored_performance_time + player.current_time - player.start_performance_time
    player.total_performance_time = player.stored_performance_time
    player:updatePerformance()
    if player.update_timer ~= nil then
      timer.cancel(player.update_timer)
    end
  end


  player.stopEditor = function()
    print("Switching out of editing mode")
    player.mode = player.last_mode
    player.editingGroup.isVisible = false

    for i = 1,player.pictureEditingGroup.numChildren do
      player.pictureEditingGroup[i].isVisible = false
    end
    basic_info_text.isVisible = false
    
    audio.resume()

    player.start_performance_time = system.getTimer()
    player.current_time = system.getTimer()
    player.update_timer = timer.performWithDelay(35, function() 
      player:updatePerformance()
    end, 0)
  end


  player.getSelectedAsset = function()
    if player.selected_element_id ~= nil then
      for i = 1, #player.script_assets do
        if player.script_assets[i].id == player.selected_element_id then
          player.selection_circle.isVisible = true
          player.selection_circle.x = player.script_assets[i].fixed_x
          player.selection_circle.y = player.script_assets[i].fixed_y
          return player.script_assets[i]
        end
      end
    end

    player.selection_circle.isVisible = false
    return nil
  end


  player.updateAssetDisplayList = function(self, script_asset_start, script_asset_end)
    while player.scriptAssetGroup.numChildren > 0 do
      local child = player.scriptAssetGroup[1]
      if child then child:removeSelf() end
    end

    local scriptHeaderText = display.newText(player.scriptAssetGroup, "Script", display.contentWidth - 30, 18, "Fonts/MouseMemoirs.ttf", 20)
    scriptHeaderText:setTextColor(0.3,0.3,1.0)
    scriptHeaderText.anchorX = 1
    local asset_display_count = 1
    for i = 1, #player.script_assets do
      if i >= script_asset_start and i <= script_asset_end then
        local asset = player.script_assets[i]

        local displayText = display.newText(player.scriptAssetGroup, asset.id, display.contentWidth - 30, 18 * (asset_display_count + 1), "Fonts/MouseMemoirs.ttf", 20)
        displayText.anchorX = 1
        displayText:setTextColor(0,0,0)
        if player.selected_element_id ~= nil and player.selected_element_id == asset.id then
          displayText:setTextColor(0.5,0.8,0.5)
        end
        local id = asset.id
        displayText:addEventListener("tap", function()
          player.selected_element_id = id
          player:updateAssetDisplayList(script_asset_start, script_asset_start + 19)
        end)
        asset_display_count = asset_display_count + 1
      end
    end

    local asset = player:getSelectedAsset()
    if asset ~= nil then
      if asset.type == "picture" then
        for i = 1,player.pictureEditingGroup.numChildren do
          player.pictureEditingGroup[i].isVisible = true
        end
        -- self.pictureEditingGroup.isVisible = true
        player.soundEditingGroup.isVisible = false

        if player.pictureEditingGroup.numChildren == 0 then
          player.edit_fields = {}
          edit_fields = player.edit_fields
          labels = {
            "Start Time",
            "x",
            "y",
            "x scale",
            "y scale",
            "Intro",
            "Disappear Time",
            "Disappear Method",
            "Squish Scale",
            "Squish Tilt",
            "Squish Period",
            "Depth"
          }
          for i = 1, #labels do

            local label = display.newText(player.pictureEditingGroup, labels[i], display.contentWidth - 60, display.contentHeight - 50 - (2 + #labels - i) * 20, "Fonts/MouseMemoirs.ttf", 18)
            label:setTextColor(0.0, 0.0, 0.0)
            label.anchorX = 1

            local text_field = native.newTextField(display.contentWidth - 50, display.contentHeight - 50 - (2 + #labels - i) * 20, 40, 18)
            text_field.anchorX = 0
            player.pictureEditingGroup:insert(text_field)
            table.insert(edit_fields, text_field)  
          end
          
          edit_fields[1]:addEventListener("userInput", function(event)
            if event.phase == "editing" then
              asset = player:getSelectedAsset()
              if tonumber(event.text) ~= nil then
                asset.start_time = tonumber(event.text)
              end
            end
          end)

          edit_fields[2]:addEventListener("userInput", function(event)
            if event.phase == "editing" then
              asset = player:getSelectedAsset()
              if tonumber(event.text) ~= nil then
                asset.fixed_x = tonumber(event.text)
                asset.x = asset.fixed_x

                if asset.performance ~= nil then
                  asset.performance.fixed_x = asset.fixed_x
                  asset.performance.x = asset.fixed_x
                  player:getSelectedAsset()
                end
              end
            end
          end)

          edit_fields[3]:addEventListener("userInput", function(event)
            if event.phase == "editing" then
              asset = player:getSelectedAsset()
              if tonumber(event.text) ~= nil then
                asset.fixed_y = tonumber(event.text)
                asset.y = asset.fixed_y

                if asset.performance ~= nil then
                  asset.performance.fixed_y = asset.fixed_y
                  asset.performance.y = asset.fixed_y
                  player:getSelectedAsset()
                end
              end
            end
          end)

          edit_fields[4]:addEventListener("userInput", function(event)
            if event.phase == "editing" then
              asset = player:getSelectedAsset()
              if tonumber(event.text) ~= nil then
                asset.x_scale = tonumber(event.text)

                if asset.performance ~= nil then
                  asset.performance.x_scale = asset.x_scale
                  asset.performance.xScale = asset.x_scale
                end
              end
            end
          end)

          edit_fields[5]:addEventListener("userInput", function(event)
            if event.phase == "editing" then
              asset = player:getSelectedAsset()
              if tonumber(event.text) ~= nil then
                asset.y_scale = tonumber(event.text)

                if asset.performance ~= nil then
                  asset.performance.y_scale = asset.y_scale
                  asset.performance.yScale = asset.y_scale
                end
              end
            end
          end)

          edit_fields[6]:addEventListener("userInput", function(event)
            if event.phase == "editing" then
              asset = player:getSelectedAsset()
              asset.intro = event.text
              if asset.performance ~= nil then
                asset.performance.intro = asset.intro
              end
            end
          end)

          edit_fields[7]:addEventListener("userInput", function(event)
            if event.phase == "editing" then
              asset = player:getSelectedAsset()
              if tonumber(event.text) ~= nil then
                asset.disappear_time = tonumber(event.text)

                -- if asset.performance ~= nil then
                --   asset.performance.disappear_time = asset.disappear_time
                -- end
              end
            end
          end)

          edit_fields[8]:addEventListener("userInput", function(event)
            if event.phase == "editing" then
              asset = player:getSelectedAsset()
              asset.disappear_method = event.text
              -- if asset.performance ~= nil then
              --   asset.performance.disappear_method = asset.disappear_method
              -- end
            end
          end)

          edit_fields[9]:addEventListener("userInput", function(event)
            if event.phase == "editing" then
              asset = player:getSelectedAsset()
              if tonumber(event.text) ~= nil then
                asset.squish_scale = tonumber(event.text)

                if asset.performance ~= nil then
                  asset.performance.squish_scale = asset.squish_scale
                end
              end
            end
          end)

          edit_fields[10]:addEventListener("userInput", function(event)
            if event.phase == "editing" then
              asset = player:getSelectedAsset()
              if tonumber(event.text) ~= nil then
                asset.squish_tilt = tonumber(event.text)

                if asset.performance ~= nil then
                  asset.performance.squish_tilt = asset.squish_tilt
                end
              end
            end
          end)

          edit_fields[11]:addEventListener("userInput", function(event)
            if event.phase == "editing" then
              asset = player:getSelectedAsset()
              if tonumber(event.text) ~= nil then
                asset.squish_period = tonumber(event.text)

                if asset.performance ~= nil then
                  asset.performance.squish_period = asset.squish_period
                end
              end
            end
          end)

          edit_fields[12]:addEventListener("userInput", function(event)
            if event.phase == "editing" then
              asset = player:getSelectedAsset()
              local layer_number = tonumber(event.text)
              if layer_number ~= nil and layer_number >= -1 * player.const_half_layers and layer_number <= player.const_half_layers then
                asset.depth = layer_number
              
                -- move it from one layer to another
                if asset.performance ~= nil then
                  asset.performance.depth = asset.depth
                  display.remove(asset.performance)
                  player.performanceAssetGroup[asset.depth + player.const_half_layers + 1]:insert(asset.performance)
                end
              end
            end
          end)
        end

        edit_fields[1].text = asset.start_time
        edit_fields[2].text = asset.x
        edit_fields[3].text = asset.y
        edit_fields[4].text = asset.x_scale
        edit_fields[5].text = asset.y_scale
        edit_fields[6].text = asset.intro
        edit_fields[7].text = asset.disappear_time
        edit_fields[8].text = asset.disappear_method
        edit_fields[9].text = asset.squish_scale
        edit_fields[10].text = asset.squish_tilt
        edit_fields[11].text = asset.squish_period
        edit_fields[12].text = asset.depth

      elseif asset.type == "sound" then
        for i = 1,player.pictureEditingGroup.numChildren do
          player.pictureEditingGroup[i].isVisible = false
        end
        -- player.pictureEditingGroup.isVisible = false
        player.soundEditingGroup.isVisible = true
      end
    end
  end


  player.updatePictureAssetMenu = function(self, start_number, end_number)
    -- add pictures menu
    local image_count = 0
    local pictureHeaderText = display.newText(player.editingGroup, "Pictures", 30, 18, "Fonts/MouseMemoirs.ttf", 20)
    pictureHeaderText:setTextColor(0.3,0.3,1.0)
    pictureHeaderText.anchorX = 0
    if player.picture_buttons ~= nil then
      for i = 1, #player.picture_buttons do
        display.remove(player.picture_buttons[i])
        -- should remove event listener but meh
      end
    end
    player.picture_buttons = {}
    local alphabetical_pairs = {}
    for picture_name, info in pairs(player.picture_info) do table.insert(alphabetical_pairs, picture_name) end
    table.sort(alphabetical_pairs)
    for i, picture_name in ipairs(alphabetical_pairs) do
      if i >= start_number and i <= end_number then
        if string.len(picture_name) >= 1 then
          local displayText = display.newText(player.editingGroup, picture_name, 30, 18 * (image_count + 2), "Fonts/MouseMemoirs.ttf", 20)
          displayText.anchorX = 0
          displayText:setTextColor(0,0,0)
          image_count = image_count + 1
          displayText:addEventListener("tap", function()
            if player.mode == "editing" then
              player.script_asset_count = player.script_asset_count + 1
              local new_asset = {
                name=picture_name,
                id=picture_name .. "_" .. player.script_asset_count,
                type="picture",
                start_time=player.stored_performance_time,
                x=display.contentCenterX,
                y=display.contentCenterY,
                x_scale=1,
                y_scale=1,
                intro="sketch",
                disappear_time=-1,
                disappear_method="",
                squish_scale=1,
                squish_tilt=0,
                squish_period=1718,
                depth=0,
                performance=nil,
                timer=nil,
              }
              table.insert(player.script_assets, new_asset)

              player.selected_element_id = new_asset.id

              player:updateAssetDisplayList(player.script_asset_start, player.script_asset_start + 19)

              player:perform(new_asset)
            end
          end)
          table.insert(player.picture_buttons, displayText)
        end
      end
    end
  end


  player.updateSoundAssetMenu = function()

  end

  player.edit_mode_asset_start_x = 0
  player.edit_mode_asset_start_y = 0
  player.handleMouse = function(self, event)
    -- print("In mouse, mode " .. player.mode)
    -- print(event.x .. "," .. event.y .. "," .. event.xStart .. "," .. event.yStart)

    if player.mode == "editing" then
      local asset = player:getSelectedAsset()

      if asset ~= nil and asset.type == "picture" and asset.performance ~= nil then
        if event.phase == "began" then
          player.edit_mode_asset_start_x = asset.performance.fixed_x
          player.edit_mode_asset_start_y = asset.performance.fixed_y
          if player.edit_mode_asset_start_x == nil then
            player.edit_mode_asset_start_x = 0
            player.edit_mode_asset_start_y = 0
          end
        elseif event.phase == "moved" or event.phase == "ended" or event.phase == "cancelled" then
          asset.performance.fixed_x = player.edit_mode_asset_start_x + event.x - event.xStart
          asset.performance.fixed_y = player.edit_mode_asset_start_y + event.y - event.yStart
          asset.fixed_x = asset.performance.fixed_x
          asset.fixed_y = asset.performance.fixed_y
          asset.x = asset.fixed_x
          asset.y = asset.fixed_y
          player.edit_fields[2].text = asset.fixed_x
          player.edit_fields[3].text = asset.fixed_y
          player:getSelectedAsset()
        end
      end
    end
  end


  player.handleKeyboard = function(self, event)
    print("in keyboard")
    if event.keyName == "space"  and event.phase == "down" then
      print("switching mode from " .. player.mode)
      if player.mode == "editing" then
        player:stopEditor()
      else
        player:startEditor()
      end
    end

    if player.mode == "editing" then
      if event.isCtrlDown and event.keyName == "r" and event.phase == "down" then
        player:resetEditorToZero()
      end

      if event.isShiftDown and event.keyName == "left" and event.phase == "up" then
        player:shiftEditor(-1000)
      end

      if event.isShiftDown and event.keyName == "right" and event.phase == "up" then
        player:shiftEditor(1000)
      end

      if event.isAltDown and event.keyName == "left" and event.phase == "up" then 
        player.stored_performance_time = math.floor((player.stored_performance_time / (player.mpb/2)) + 0.5) * (player.mpb/2)
        player.stored_performance_time = player.stored_performance_time - player.mpb/2
        player:shiftEditor(0) -- does the rest of the adjustments
      end

      if event.isAltDown and event.keyName == "right" and event.phase == "up" then
        player.stored_performance_time = math.floor((player.stored_performance_time / (player.mpb/2)) + 0.5) * (player.mpb/2)
        player.stored_performance_time = player.stored_performance_time + player.mpb/2
        player:shiftEditor(0) -- does the rest of the adjustments
      end


      if event.isAltDown == false and event.isShiftDown == false and event.keyName == "right" and event.phase == "up" then
        player.performanceAssetGroup.x = player.performanceAssetGroup.x - 100
      end

      if event.isAltDown == false and event.isShiftDown == false and event.keyName == "left" and event.phase == "up" then
        player.performanceAssetGroup.x = player.performanceAssetGroup.x + 100
      end

      if event.isAltDown == false and event.isShiftDown == false and event.keyName == "up" and event.phase == "up" then
        player.performanceAssetGroup.y = player.performanceAssetGroup.y + 100
      end

      if event.isAltDown == false and event.isShiftDown == false and event.keyName == "down" and event.phase == "up" then
        player.performanceAssetGroup.y = player.performanceAssetGroup.y - 100
      end




      if event.isCtrlDown and event.keyName == "d" and event.phase == "up" then
        self:deleteSelectedAsset()
      end

      if event.isCtrlDown and event.keyName == "e" and event.phase == "up" then
        if player.sketch_sprite_timer ~= nil then
          player.sketch_sprite_timer._delay = 500
        end
      end

      if event.isCtrlDown and event.keyName == "p" and event.phase == "up" then
        asset = player:getSelectedAsset()
        if asset ~= nil and asset.type == "picture" and asset.performance == nil then
          player:perform(asset)
        end
      end

      if event.isCtrlDown and event.keyName == "s" and event.phase == "up" then
        player:saveScriptChanges()
      end

    end
  end


  player.resetEditorToZero = function()
    if player.update_timer ~= nil then
      timer.cancel(player.update_timer)
    end

    player.current_time = system.getTimer()
    player.start_performance_time = 0
    player.stored_performance_time = 0
    player.total_performance_time = 0
    
    audio.stop()

    player:clearPerformance()

    player:updatePerformance()
  end


  player.shiftEditor = function(self, time_shift)
    player.stored_performance_time = player.stored_performance_time + time_shift
    player.total_performance_time = player.stored_performance_time
    
    if player.stored_performance_time < 0 then
      player:resetEditorToZero()
    else
      for i = 1, #player.script_assets do
        local asset = player.script_assets[i]
        if asset.type == "picture" then
          if asset.start_time > player.stored_performance_time then
            player.sketch_sprites:remove(asset.id)
            asset.performance = nil
          end
        elseif asset.type == "sound" then
          print("Seeking time " .. player.stored_performance_time .. " in sound file " .. tostring(asset.performance))
          audio.seek(player.stored_performance_time + 50, asset.performance)
        end
      end
      player:updatePerformance()
    end
  end


  player.deleteSelectedAsset = function()
    local asset = player:getSelectedAsset()
    if asset ~= nil then
      if asset.type == "picture" and asset.performance ~= nil then
        asset.performance:removeSelf()
      end
      new_script_assets = {}
      for i = 1, #player.script_assets do
        if player.script_assets[i].id ~= player.selected_element_id then
          table.insert(new_script_assets, player.script_assets[i])
        end
      end
      player.script_assets = new_script_assets
      player.selected_element_id = nil

      player:updateAssetDisplayList(player.script_asset_start, player.script_asset_start + 19)
    end
  end


  player.saveScriptChanges = function()
    local save_file = system.pathForFile("Scenes/" .. player.scene_name .. ".json", system.ResourceDirectory)

    local file = io.open(save_file, "w")
 
    if file then
      file:write(json.encode(player.script_assets))
      io.close(file)
    else
      print("UNABLE TO OPEN SAVE FILE")
    end

    print("Saved to " .. save_file)
  end

  player.initializeEditorPaginationButtons = function()
    local left_picture_page = display.newImageRect(player.editingGroup, "Art/small_arrow.png", 32, 32)
    left_picture_page.x = 100
    left_picture_page.y = 18
    left_picture_page.xScale = -1
    left_picture_page:addEventListener("tap", function()
      player.picture_asset_start = player.picture_asset_start - 20
      if player.picture_asset_start < 1 then
        player.picture_asset_start = 1
      end

      player:updatePictureAssetMenu(player.picture_asset_start, player.picture_asset_start + 19)
    end)

    local right_picture_page = display.newImageRect(player.editingGroup, "Art/small_arrow.png", 32, 32)
    right_picture_page.x = 124
    right_picture_page.y = 18
    right_picture_page:addEventListener("tap", function()
        player.picture_asset_start = player.picture_asset_start + 20

        player:updatePictureAssetMenu(player.picture_asset_start, player.picture_asset_start + 19)
      -- end
    end)


    local left_script_asset_page = display.newImageRect(player.editingGroup, "Art/small_arrow.png", 32, 32)
    left_script_asset_page.x = display.contentWidth - 124
    left_script_asset_page.y = 18
    left_script_asset_page.xScale = -1
    left_script_asset_page:addEventListener("tap", function()
      player.script_asset_start = player.script_asset_start - 20
      if player.script_asset_start < 1 then
        player.script_asset_start = 1
      end

      player:updateAssetDisplayList(player.script_asset_start, player.script_asset_start + 19)
    end)

    local right_script_asset_page = display.newImageRect(player.editingGroup, "Art/small_arrow.png", 32, 32)
    right_script_asset_page.x = display.contentWidth - 100
    right_script_asset_page.y = 18
    right_script_asset_page:addEventListener("tap", function()
        player.script_asset_start = player.script_asset_start + 20

        player:updateAssetDisplayList(player.script_asset_start, player.script_asset_start + 19)
      -- end
    end)
  end

  player.first_edit = false

  Runtime:addEventListener("key", function(event) player:handleKeyboard(event) end)

  player.editingGroup = display.newGroup()
  player.sceneGroup:insert(player.editingGroup)

  player.scriptAssetGroup = display.newGroup()
  player.editingGroup:insert(player.scriptAssetGroup)

  player.pictureEditingGroup = display.newGroup()
  player.editingGroup:insert(player.pictureEditingGroup)

  player.soundEditingGroup = display.newGroup()
  player.editingGroup:insert(player.soundEditingGroup)

  player.selection_circle = display.newImageRect(player.editingGroup, "Art/selection_circle.png", 32, 32)
  player.selection_circle.isVisible = false

  player.editingGroup.isVisible = false

  basic_info_text = display.newText(player.sceneGroup, "Time:0, Objects: 0", display.contentCenterX, 30, "Fonts/MouseMemoirs.ttf", 30)
  basic_info_text:setTextColor(0.0, 0.0, 0.0)
  basic_info_text.isVisible = false

  player.selected_element_id = nil

  player.picture_asset_start = 1
  player.script_asset_start = 1

  player.script_asset_count = 0

  player:updatePictureAssetMenu(player.picture_asset_start, player.picture_asset_start + 19)

  player:initializeEditorPaginationButtons()

  player:updateSoundAssetMenu()

  player:updateAssetDisplayList(player.script_asset_start, player.script_asset_start + 19)
  
end

return editor