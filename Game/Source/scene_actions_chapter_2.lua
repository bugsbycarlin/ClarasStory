local animation = require("plugin.animation")

scene_actions_chapter_2 = {}
scene_actions_chapter_2.__index = scene_actions_chapter_2

function scene_actions_chapter_2:augment(player)

  player.sceneActions = {}

  player.sceneActions["chapter_2_scene_1"] = function()

    player.performanceAssetGroup.y = 1024
    animation.to(player.performanceAssetGroup, {y = 0}, {time = 375 * 16, easing = easing.inOutQuart})

    local back_row = 1 + player.const_half_layers + 1
    local front_row = 2 + player.const_half_layers + 1

    local super_back_row = -5 + player.const_half_layers + 1
    local super_front_row = -4 + player.const_half_layers + 1
    player.chapter_2_scoot_counter = 0
    scoot = function()
      print("SCOOT")
      player.chapter_2_scoot_counter = player.chapter_2_scoot_counter + 1
      if player.chapter_2_scoot_counter % 4 == 1 then
        player.performanceAssetGroup[back_row].x = player.performanceAssetGroup[back_row].x - 1024
        player.performanceAssetGroup[front_row].x = player.performanceAssetGroup[front_row].x + 1024
        player.performanceAssetGroup[super_back_row].x = player.performanceAssetGroup[super_back_row].x - 1024
        -- player.performanceAssetGroup[super_front_row].x = player.performanceAssetGroup[super_front_row].x + 1024
      end
      current_x = player.performanceAssetGroup[back_row].x
      current_super = player.performanceAssetGroup[super_back_row].x
      animation.to(player.performanceAssetGroup[back_row], {x=current_x + 256}, {time=750 / 4 * 0.7, easing=easing.outExp})
      animation.to(player.performanceAssetGroup[super_back_row], {x=current_super + 256}, {time=750 / 4 * 0.7, easing=easing.outExp})

      -- scoot left
      timer.performWithDelay(750 * 3 / 4, function()
        current_x = player.performanceAssetGroup[front_row].x
        animation.to(player.performanceAssetGroup[front_row], {x=current_x - 256}, {time=750 / 4 * 0.7, easing=easing.outExp})
        current_super = player.performanceAssetGroup[super_front_row].x
        -- animation.to(player.performanceAssetGroup[super_front_row], {x=current_super - 256}, {time=750 / 4 * 0.7, easing=easing.outExp})
      end, 1)

      if math.random(10) >= 6 then
        -- print("honking")
        local honk_image = display.newImageRect(player.top_group, "Art/honk.png", 256, 256)
        honk_image.x = 100 + math.random(824)
        honk_image.y = 192 + 50 + math.random(384 - 100)
        timer.performWithDelay(player.mpb * 3 / 4, function()
          display.remove(honk_image)
        end, 1)
      end
    end

    scoot()
    player.special_timer = timer.performWithDelay(1500, function()
      scoot()
    end, 0, "special")


    -- honks!
    honk_images = {}
    --22500
    -- fix this so skipping cancels it
    for i = 1,8 do
      timer.performWithDelay(22500 - (375/2) + (player.mpb / 2) * i, function()
        -- print("MAKING A HONK")
        local honk_image = display.newImageRect(player.top_group, "Art/honk.png", 256, 256)
        honk_image.x = 100 + 100 * i
        honk_image.y = 192 + 50 + math.random(384 - 100)
        table.insert(honk_images, honk_image)
        timer.performWithDelay(player.mpb * 3 / 4, function()

          display.remove(honk_image)
        end, 1)
      end, 1)
    end
  end

  player.sceneActions["chapter_2_scene_2"] = function()
    player.special_timer = timer.performWithDelay(187, function()
      if player.total_performance_time > 4500 and player.total_performance_time < 6000 then
        local honk_image = display.newImageRect(player.top_group, "Art/honk.png", 256, 256)
          honk_image.x = 100 + math.random(824)
          honk_image.y = 192 + 50 + math.random(384 - 100)
          timer.performWithDelay(player.mpb * 3 / 4, function()
            display.remove(honk_image)
        end, 1)
      end
    end, 0, "special")

    player.special_timer = timer.performWithDelay(6750, function()
      -- move Girl_13 out and up in advance of switching scenes
      for i = 1, #player.script_assets do
        asset = player.script_assets[i]
        -- print(asset.id)
        if asset.id == "Girl_13" and asset.performance ~= nil then
          -- print("I found Girl_13")

          player.sketch_sprites:poopClouds(asset.performance, 8 + math.random(16))
          asset.performance.fixed_x = asset.performance.fixed_x + 2010 -- basically remove it, actually
          asset.performance.fixed_y = asset.performance.fixed_y - 58
          -- player.sketch_sprites:poopClouds(asset.performance, 4 + math.random(8))
        end
      end
    end, 1, "special")

    timer.performWithDelay(12000, function()
      local back_row = 1 + player.const_half_layers + 1
      local front_row = 2 + player.const_half_layers + 1
      player.chapter_2_scoot_counter = 0
      if player.scene_name == "chapter_2_scene_2" then
        scoot = function()
          player.chapter_2_scoot_counter = player.chapter_2_scoot_counter + 1
          -- if player.chapter_2_scoot_counter % 4 == 1 then
          --   player.performanceAssetGroup[back_row].x = player.performanceAssetGroup[back_row].x - 1024
          --   player.performanceAssetGroup[front_row].x = player.performanceAssetGroup[front_row].x + 1024
          -- end
          local back_and_forth = 128
          if player.chapter_2_scoot_counter % 2 == 1 then
            back_and_forth = -1 * back_and_forth
          end

          current_x = player.performanceAssetGroup[back_row].x
          animation.to(player.performanceAssetGroup[back_row], {x=current_x + back_and_forth}, {time=750 / 4 * 0.7, easing=easing.outExp})

          -- scoot left
          timer.performWithDelay(750 * 3 / 4, function()
            current_x = player.performanceAssetGroup[front_row].x
            animation.to(player.performanceAssetGroup[front_row], {x=current_x - 256}, {time=750 / 4 * 0.7, easing=easing.outExp})
            current_x = player.performanceAssetGroup[back_row].x
            animation.to(player.performanceAssetGroup[back_row], {x=current_x - back_and_forth}, {time=750 / 4 * 0.7, easing=easing.outExp})
          end, 1)

          -- print("honking")
          local honk_image = display.newImageRect(player.top_group, "Art/honk.png", 256, 256)
          honk_image.x = 100 + math.random(824)
          honk_image.y = 192 + 50 + math.random(384 - 100)
          timer.performWithDelay(player.mpb * 3 / 4, function()
            display.remove(honk_image)
          end, 1)
        end

        scoot()
        player.special_timer = timer.performWithDelay(1500, function()
          scoot()
        end, 0, "special")
      end
    end, 1, "special")
  end

  player.sceneActions["chapter_2_scene_3"] = function()
    local marker_1 = 2250 - 375
    local marker_2 = 4500
    local shop_time = 375
    zoom = function()
      if player.mode == "performing" then
        -- print(player.total_performance_time)
        local focus_layer = 0 + player.const_half_layers + 1
        if player.total_performance_time < marker_1 
          or (player.total_performance_time > marker_1 + shop_time and player.total_performance_time < marker_2) 
          or player.total_performance_time > marker_2 + shop_time and player.total_performance_time < 6000 then

          player.performanceAssetGroup[focus_layer].isVisible = true
          for i = 1, player.const_num_layers do
            -- print("in here " .. i)
            if i ~= focus_layer then
              player.performanceAssetGroup[i].x = player.performanceAssetGroup[i].x - 7
              if player.performanceAssetGroup[i].x < -1024 then
                player.performanceAssetGroup[i].x = -1024
              end
            end
          end
        else
          player.performanceAssetGroup[focus_layer].isVisible = false
          if player.total_performance_time >= 6000 then
            for i = 1, player.const_num_layers do
              player.performanceAssetGroup[i].x = 0
            end
          end
          player.performanceAssetGroup.x = 0
          player.performanceAssetGroup.y = 0
        end
      end
    end

    player.special_timer = timer.performWithDelay(33, function()
      zoom()
    end, 0, "special")
  end

  player.sceneActions["chapter_2_scene_4"] = function()
    player.performanceAssetGroup.y = 0
    animation.to(player.performanceAssetGroup, {y = 256}, {time = 375 * 16, easing = easing.inOutSine})
    player.special_timer = timer.performWithDelay(9000, function()
      player.performanceAssetGroup.y = 0
    end, 1, "special")
  end

  player.sceneActions["chapter_2_scene_5"] = function()
    player.special_timer = timer.performWithDelay(6900, function()
      local boat

      boat = player.sketch_sprites:get("Little_White_Boat_Shadow_1")
      if boat ~= nil then
        x = boat.fixed_x
        animation.to(boat, {fixed_x = x + 40}, {time = 30000})

        boat = player.sketch_sprites:get("Little_White_Boat_Shadow_2")
        x = boat.fixed_x
        animation.to(boat, {fixed_x = x + 50}, {time = 30000})

        boat = player.sketch_sprites:get("Little_White_Boat_Shadow_3")
        x = boat.fixed_x
        animation.to(boat, {fixed_x = x - 40}, {time = 30000})

        boat = player.sketch_sprites:get("Little_White_Boat_Shadow_4")
        x = boat.fixed_x
        animation.to(boat, {fixed_x = x + 60}, {time = 30000})
      end
    end, 1, "special")
  end

end

return scene_actions_chapter_2