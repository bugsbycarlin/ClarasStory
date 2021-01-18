
local json = require("json")

editor = {}
editor.__index = editor

--
-- This function adds editor mode functionality to the chapter by way of augmentation
--

function editor:augment(player)


  player.startEditor = function()
    --
    -- Start the editor
    --
    print("Switching to editing mode")

    player:pause()

    player.editor_mode = true

    player.editor_group.isVisible = true

    player:recreateEditorStageList(player.editor_stage_list_start, player.editor_stage_list_start + 19)

    player:updateEditorInfoText()
  end


  player.stopEditor = function()
    --
    -- Stop the editor
    --
    print("Switching out of editing mode")

    player.editor_mode = false

    player.editor_group.isVisible = false

    player:resume()
  end


  player.updateEditorInfoText = function()
    player.editor_info_text.text = "Time: " .. math.floor(player:getTime()) / 1000.0 .. ", Objects: " .. #player.stage.sprite_list
  end


  player.recreateEditorSpriteList = function(self, start_number, end_number)
    --
    --  Create and recreate the sprite list for the editor
    --

    -- if there's already an editor, destroy it.
    if player.sprite_list_group ~= nil then
      display.remove(player.sprite_list_group)
    end
    player.sprite_list_group = display.newGroup()
    player.editor_group:insert(player.sprite_list_group)

    local sprite_count = 0

    local sprite_list_header_text = display.newText(player.sprite_list_group, "Pictures", 30, 18, "Fonts/Arial Black.ttf", 20)
    sprite_list_header_text:setTextColor(0.3,0.3,1.0)
    sprite_list_header_text.anchorX = 0

    local alphabetical_pairs = {}
    for sprite_name, info in pairs(player.sprite_info) do table.insert(alphabetical_pairs, sprite_name) end
    table.sort(alphabetical_pairs)

    for i, sprite_name in ipairs(alphabetical_pairs) do
      if i >= start_number and i <= end_number then
        if string.len(sprite_name) >= 1 then
          local sprite_text_button = display.newText(player.sprite_list_group, sprite_name, 30, 3 + 18 * (sprite_count + 2), "Fonts/Arial Black.ttf", 20)
          sprite_text_button.anchorX = 0
          sprite_text_button:setTextColor(0,0,0)
          sprite_count = sprite_count + 1
          sprite_text_button:addEventListener("tap", function()
            if player.editor_mode == true then
              element = {
                picture = sprite_name,
                id = sprite_name .. "_" .. math.random(50000),
                x = display.contentCenterX - player.stage:getX(-1),
                y = display.contentCenterY - player.stage:getY(-1),
                xScale = 1,
                yScale = 1,
                depth = player.stage.const_num_layers,
                start_time = player:getTime(),
                end_time = -1,
                start_effect = "",
                end_effect = "",
                squish_period = 1700,
                squish_tilt = 0,
                squish_scale = 1,
              }
              table.insert(player.current_part_structure.script, element)

              player.stage:perform(element)

              player:updateEditorInfoText()

              player.selected_element_id = element.id

              player:recreateEditorStageList(player.editor_stage_list_start, player.editor_stage_list_start + 19)
            end
          end)
        end
      end
    end

    local sprite_list_box = display.newImageRect(player.sprite_list_group, "Art/Nav/editor_bars.png", 512, 512)
    sprite_list_box.x = 18
    sprite_list_box.y = 211
    -- sprite_list_box.xScale = -1

    local sprite_list_page_left = display.newImageRect(player.sprite_list_group, "Art/small_arrow.png", 32, 32)
    sprite_list_page_left.x = 50
    sprite_list_page_left.y = 410
    sprite_list_page_left.xScale = -1
    sprite_list_page_left:addEventListener("tap", function()
      player.editor_sprite_list_start = player.editor_sprite_list_start - 20
      if player.editor_sprite_list_start < 1 then
        player.editor_sprite_list_start = 1
      end
      player:recreateEditorSpriteList(player.editor_sprite_list_start, player.editor_sprite_list_start + 19)
      player:updateEditorInfoText()
    end)

    local sprite_list_page_right = display.newImageRect(player.sprite_list_group, "Art/small_arrow.png", 32, 32)
    sprite_list_page_right.x = 70
    sprite_list_page_right.y = 410
    sprite_list_page_right:addEventListener("tap", function()
      player.editor_sprite_list_start = player.editor_sprite_list_start + 20
      player:recreateEditorSpriteList(player.editor_sprite_list_start, player.editor_sprite_list_start + 19)
      player:updateEditorInfoText()
    end)
  end


  player.recreateEditorStageList = function(self, start_number, end_number)
    --
    --  Create and recreate the stage list for the editor
    --

    -- if there's already an editor, destroy it.
    if player.stage_list_group ~= nil then
      display.remove(player.stage_list_group)
    end
    player.stage_list_group = display.newGroup()
    player.editor_group:insert(player.stage_list_group)

    print("in recreate function")
    print(#player.stage.sprite_list)

    local sprite_count = 0

    local stage_list_header_text = display.newText(player.stage_list_group, "Stage", display.contentWidth - 30, 18, "Fonts/Arial Black.ttf", 20)
    stage_list_header_text:setTextColor(0.3, 0.3, 1.0)
    stage_list_header_text.anchorX = 1

    for i = 1, #player.stage.sprite_list do
      local sprite = player.stage.sprite_list[i]
      print("in loop")
      print(sprite.id)
      if i >= start_number and i <= end_number then
        print("in make thingy")
        local sprite_text_button = display.newText(player.stage_list_group, sprite.id, display.contentWidth - 30, 18 * (sprite_count + 2), "Fonts/Arial Black.ttf", 20)
        sprite_text_button.anchorX = 1
        sprite_text_button:setTextColor(0, 0, 0)
        if sprite.id == player.selected_element_id then
          sprite_text_button:setTextColor(0.5, 0.8, 0.5)
        end
        sprite_count = sprite_count + 1
        sprite_text_button:addEventListener("tap", function()
          if player.editor_mode == true then
            player.selected_element_id = sprite.id
            player:recreateEditorStageList(player.editor_stage_list_start, player.editor_stage_list_start + 19)
          end
        end)
      end
    end

    local stage_list_box = display.newImageRect(player.stage_list_group, "Art/Nav/editor_bars.png", 512, 512)
    stage_list_box.x = display.contentWidth - 15
    stage_list_box.y = 211
    stage_list_box.xScale = -1

    local stage_list_page_left = display.newImageRect(player.stage_list_group, "Art/small_arrow.png", 32, 32)
    stage_list_page_left.x = display.contentWidth - 70
    stage_list_page_left.y = 410
    stage_list_page_left.xScale = -1
    stage_list_page_left:addEventListener("tap", function()
      player.editor_stage_list_start = player.editor_stage_list_start - 20
      if player.editor_stage_list_start < 1 then
        player.editor_stage_list_start = 1
      end
      player:recreateEditorStageList(player.editor_stage_list_start, player.editor_stage_list_start + 19)
      player:updateEditorInfoText()
    end)

    local stage_list_page_right = display.newImageRect(player.stage_list_group, "Art/small_arrow.png", 32, 32)
    stage_list_page_right.x = display.contentWidth - 50
    stage_list_page_right.y = 410
    stage_list_page_right:addEventListener("tap", function()
      player.editor_stage_list_start = player.editor_stage_list_start + 20
      player:recreateEditorStageList(player.editor_stage_list_start, player.editor_stage_list_start + 19)
      player:updateEditorInfoText()
    end)

    player:recreateSelectedSpriteEditor()
  end


  player.recreateSelectedSpriteEditor = function()
    --
    -- Create and recreate the selected sprite editor
    --
    if player.sprite_editor_group ~= nil then
      display.remove(player.sprite_editor_group)
    end
    player.sprite_editor_group = display.newGroup()
    player.editor_group:insert(player.sprite_editor_group)

    if player.selected_element_id ~= nil then
      stage_sprite = player.stage:get(player.selected_element_id)
      if stage_sprite ~= nil then
        local sprite_editor_header_text = display.newText(player.sprite_editor_group, "Sprite", display.contentWidth - 30, 450, "Fonts/Arial Black.ttf", 16)
        sprite_editor_header_text:setTextColor(0.3,0.3,1.0)
        sprite_editor_header_text.anchorX = 1

        player.sprite_editor_fields = {}

        labels = {
          "id",
          "x",
          "y",
          "xScale",
          "yScale",
          "depth",
          "start_time",
          "end_time",
          "start_effect",
          "end_effect",
          "squish_period",
          "squish_tilt",
          "squish_scale",
          "animation_sequence",
        }

        for i = 1, #labels do
          local label = display.newText(player.sprite_editor_group, labels[i], display.contentWidth - 135, 449 + i * 21, "Fonts/Arial Black.ttf", 12)
          label:setTextColor(0.0, 0.0, 0.0)
          label.anchorX = 1

          local text_field = native.newTextField(display.contentWidth - 30, 450 + i * 21, 100, 16)
          text_field.anchorX = 1
          player.sprite_editor_group:insert(text_field)
          table.insert(player.sprite_editor_fields, text_field)
        end

        player.sprite_editor_fields[1]:addEventListener("userInput", function(event)
          local old_id = stage_sprite.id
          stage_sprite.id = event.text
          player:updateScript(old_id, stage_sprite)
        end)

        player.sprite_editor_fields[2]:addEventListener("userInput", function(event)
          local x = tonumber(event.text)
          if x ~= nil then
            stage_sprite.x = x
          end
          player:updateScript(stage_sprite.id, stage_sprite)
        end)

        player.sprite_editor_fields[3]:addEventListener("userInput", function(event)
          local y = tonumber(event.text)
          if y ~= nil then
            stage_sprite.y = y
          end
          player:updateScript(stage_sprite.id, stage_sprite)
        end)

        player.sprite_editor_fields[4]:addEventListener("userInput", function(event)
          local xScale = tonumber(event.text)
          if xScale ~= nil then
            stage_sprite.xScale = xScale
          end
          player:updateScript(stage_sprite.id, stage_sprite)
        end)

        player.sprite_editor_fields[5]:addEventListener("userInput", function(event)
          local yScale = tonumber(event.text)
          if yScale ~= nil then
            stage_sprite.yScale = yScale
          end
          player:updateScript(stage_sprite.id, stage_sprite)
        end)

        player.sprite_editor_fields[6]:addEventListener("userInput", function(event)
          local depth = tonumber(event.text)
          if depth ~= nil then
            player.stage:relayer(stage_sprite, depth)
          end
          player:updateScript(stage_sprite.id, stage_sprite)
        end)

        player.sprite_editor_fields[7]:addEventListener("userInput", function(event)
          local start_time = tonumber(event.text)
          if start_time ~= nil then
            stage_sprite.start_time = start_time
          end
          player:updateScript(stage_sprite.id, stage_sprite)
        end)

        player.sprite_editor_fields[8]:addEventListener("userInput", function(event)
          local end_time = tonumber(event.text)
          if end_time ~= nil then
            stage_sprite.end_time = end_time
          end
          player:updateScript(stage_sprite.id, stage_sprite)
        end)

        player.sprite_editor_fields[9]:addEventListener("userInput", function(event)
          stage_sprite.start_effect = event.text
          player:updateScript(stage_sprite.id, stage_sprite)
        end)

        player.sprite_editor_fields[10]:addEventListener("userInput", function(event)
          stage_sprite.end_effect = event.text
          player:updateScript(stage_sprite.id, stage_sprite)
        end)

        player.sprite_editor_fields[11]:addEventListener("userInput", function(event)
          local squish_period = tonumber(event.text)
          if squish_period ~= nil then
            stage_sprite.squish_period = squish_period
          end
          player:updateScript(stage_sprite.id, stage_sprite)
        end)

        player.sprite_editor_fields[12]:addEventListener("userInput", function(event)
          local squish_tilt = tonumber(event.text)
          if squish_tilt ~= nil then
            stage_sprite.squish_tilt = squish_tilt
          end
          player:updateScript(stage_sprite.id, stage_sprite)
        end)

        player.sprite_editor_fields[13]:addEventListener("userInput", function(event)
          local squish_scale = tonumber(event.text)
          if squish_scale ~= nil then
            stage_sprite.squish_scale = squish_scale
          end
          player:updateScript(stage_sprite.id, stage_sprite)
        end)

        player.sprite_editor_fields[14]:addEventListener("userInput", function(event)
          if event.text ~= nil then
            stage_sprite.animation_sequence = event.text
            print("text is _" .. event.text .. "_")
            stage_sprite:queueAnimations(stage_sprite.animation_sequence)
            player:updateScript(stage_sprite.id, stage_sprite)
          end
        end)

        player.sprite_editor_fields[1].text = stage_sprite.id
        player.sprite_editor_fields[2].text = stage_sprite.x
        player.sprite_editor_fields[3].text = stage_sprite.y
        player.sprite_editor_fields[4].text = stage_sprite.xScale
        player.sprite_editor_fields[5].text = stage_sprite.yScale
        player.sprite_editor_fields[6].text = stage_sprite.depth
        player.sprite_editor_fields[7].text = stage_sprite.start_time
        player.sprite_editor_fields[8].text = stage_sprite.end_time
        player.sprite_editor_fields[9].text = stage_sprite.start_effect
        player.sprite_editor_fields[10].text = stage_sprite.end_effect
        player.sprite_editor_fields[11].text = stage_sprite.squish_period
        player.sprite_editor_fields[12].text = stage_sprite.squish_tilt
        player.sprite_editor_fields[13].text = stage_sprite.squish_scale
        player.sprite_editor_fields[14].text = stage_sprite.animation_sequence
      end
    end
  end


  player.updateScript = function(self, sprite_id, sprite)
    --
    -- Update the script for sprite with given id (note this may not match the new id)
    --
    if string.len(sprite_id) > 2 then
      for i = 1, #player.current_part_structure.script do
        local element = player.current_part_structure.script[i]

        if element.id == sprite_id then
          -- note in the case of a new id, we matched on the old id and we're writing the new one here
          element.id = sprite.id
          element.x = sprite.x
          element.y = sprite.y
          element.xScale = sprite.xScale
          element.yScale = sprite.yScale
          element.depth = sprite.depth
          element.start_time = sprite.start_time
          element.end_time = sprite.end_time
          element.start_effect = sprite.start_effect
          element.end_effect = sprite.end_effect
          element.squish_period = sprite.squish_period
          element.squish_tilt = sprite.squish_tilt
          element.squish_scale = sprite.squish_scale
          element.animation_sequence = sprite.animation_sequence
          break -- so it doesn't update two things, especially in the case of a weird id match
        end
      end
    end
  end


  player.deleteSelectedSprite = function()
    stage_sprite = player.stage:get(player.selected_element_id)

    if stage_sprite ~= nil then
      player.stage:delete(player.selected_element_id)
      new_script = {}
      for i = 1, #player.current_part_structure.script do
        element = player.current_part_structure.script[i]
        if element.id ~= player.selected_element_id then
          table.insert(new_script, element)
        end
      end
      player.selected_element_id = nil
      player.current_part_structure.script = new_script
      player:recreateEditorStageList(player.editor_stage_list_start, player.editor_stage_list_start + 19)
    end
  end



  player.saveScriptChanges = function()
    print("hulloo")
    print(player.current_part_structure.name)
    local save_file = system.pathForFile("ChapterScripts/" .. player.current_part_structure.name .. ".json", system.ResourceDirectory)

    local file = io.open(save_file, "w")
 
    if file then
      file:write(json.encode(player.current_part_structure.script))
      io.close(file)
    else
      print("UNABLE TO OPEN SAVE FILE")
    end

    print("Saved to " .. save_file)
  end


  player.editor_mouse_start_x = 0
  player.editor_mouse_start_y = 0
  player.editorMouseEvent = function(event)
    --
    -- Handle editor mouse events
    --
    if player.editor_mode == true then
      local stage_sprite = player.stage:get(player.selected_element_id)

      if stage_sprite ~= nil then
        if event.phase == "began" then
          player.editor_mouse_start_x = stage_sprite.x
          player.editor_mouse_start_y = stage_sprite.y
        elseif event.phase == "moved" or event.phase == "ended" or event.phase == "cancelled" then
          print("boom")
          print(player.stage:getX(-1))
          print(player.stage:getY(-1))
          stage_sprite.x = player.editor_mouse_start_x + event.x - event.xStart
          stage_sprite.y = player.editor_mouse_start_y + event.y - event.yStart
          player.sprite_editor_fields[2].text = stage_sprite.x
          player.sprite_editor_fields[3].text = stage_sprite.y
          player:updateScript(stage_sprite.id, stage_sprite)
        end
      end
    end
  end
  Runtime:addEventListener("touch", player.editorMouseEvent)


  player.editorKeyboardEvent = function(event)
    --
    -- Handle editor keyboard
    --
    if event.keyName == "space"  and event.phase == "down" then
      if player.editor_mode == false then
        player:startEditor()
      else
        player:stopEditor()
      end
    end
    if player.editor_mode == true then
      local stage_sprite = player.stage:get(player.selected_element_id)

      if event.isAltDown == false and event.isShiftDown == false and event.phase == "up" then
        if event.keyName == "right" then 
          player.stage:translateLayer(-1, 100, easing.inOutQuart, {"x", "+", 64})
        elseif event.keyName == "left" then
          player.stage:translateLayer(-1, 100, easing.inOutQuart, {"x", "-", 64})
        elseif event.keyName == "up" then
          player.stage:translateLayer(-1, 100, easing.inOutQuart, {"y", "+", 64})
        elseif event.keyName == "down" then
          player.stage:translateLayer(-1, 100, easing.inOutQuart, {"y", "-", 64})
        end
      end

      if event.isCtrlDown and event.keyName == "d" and event.phase == "up" then
        player:deleteSelectedSprite()
      end

      if event.isShiftDown and event.keyName == "left" and event.phase == "up" then
        player.start_time = player.start_time + player.chapter_structure.mpb
        if player:getTime() < 0 then
          player.start_time = player.pause_start - player.pause_time
        end
        player:updateEditorInfoText()
      end

      if event.isShiftDown and event.keyName == "right" and event.phase == "up" then
        player.start_time = player.start_time - player.chapter_structure.mpb
        player:updateEditorInfoText()
      end

      if event.isCtrlDown and event.keyName == "s" and event.phase == "up" then
        player:saveScriptChanges()
      end

    end
  end
  Runtime:addEventListener("key", player.editorKeyboardEvent)


  player.editor_group = display.newGroup()
  player.view:insert(player.editor_group)
  player.editor_group.isVisible = false

  -- player.sprite_editor_group = display.newGroup()
  -- player.editor_group:insert(player.sprite_editor_group)

  player.editor_info_text = display.newText(player.editor_group, "Time: 0, Objects: 0", display.contentCenterX, 30, "Fonts/Arial Black.ttf", 30)
  player.editor_info_text:setTextColor(0,0,0)

  player.editor_selected_element_id = nil

  player.editor_sprite_list_start = 1
  player.editor_stage_list_start = 1

  player:recreateEditorSpriteList(player.editor_sprite_list_start, player.editor_sprite_list_start + 19)

  player.editor_mode = false
end

return editor