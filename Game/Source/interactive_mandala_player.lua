
local animation = require("plugin.animation")
local memoryBitmap = require("plugin.memoryBitmap")

interactive_mandala_player = {}
interactive_mandala_player.__index = interactive_mandala_player

function interactive_mandala_player:augment(player)


  -- player.old_perform = player.perform
  -- player.perform = function(self, asset)
  --   player:old_perform(asset)
  --   if asset.choice == true then
  --     player.number_of_interactive_choices = player.number_of_interactive_choices + 1
  --     local pop_sound = audio.loadSound("Sound/pop_" .. ((player.number_of_interactive_choices % 4) + 1) .. ".wav")
  --     audio.play(pop_sound)
  --     table.insert(player.interactive_choices, asset)
  --     asset.performance:addEventListener("tap", function()
  --       if player.mode == "choice_interactive" then
  --         local touch_sound = audio.loadSound("Sound/touch_letter.wav")
  --         audio.play(touch_sound)
  --         player.interactive_choice = asset

  --         player.info:choiceCallback(player.interactive_choice, player)
  --       end
  --     end)
  --   end
  -- end

  player.startInteractiveMandala = function()
    player.mode = "mandala"

    local info = player.info

    player.start_performance_time = system.getTimer()
    player.stored_performance_time = 0
    player.total_performance_time = 0
    player.current_time = system.getTimer()

    player.mandala_pixels_painted = 0
    player.mandala_target_pixels_painted = 0

    player.end_button = nil

    if player.script_assets ~= nil and player.script_assets ~= "" then

      player:updatePerformance()

      player.update_timer = timer.performWithDelay(5, function() 
        player:updatePerformance()
        -- print(player.mandala_pixels_painted .. " out of " .. player.mandala_target_pixels_painted)
      end, 0)
    end

    player:createMandala()

    --player.music_loop = audio.loadStream("Sound/chapter_" .. player.chapter_number .. "_interactive_loop.wav")
    -- always use the chapter 2 music for the mandala
    player.music_loop = audio.loadStream("Sound/chapter_2_interactive_loop.wav")
    audio.play(player.music_loop, {loops=-1})

    -- change this based on chapter
    local sound = audio.loadSound("Sound/chapter_" .. player.chapter_number .. "/mandala_intro.mp3")
    audio.play(sound)

    Runtime:addEventListener("touch", function(event) player:handleMandalaMouse(event) end)

    timer.performWithDelay(250, function()
      player.mandala_selection = player.sketch_sprites:get("Letter_Box_1")    

      if player.script_assets ~= nil then
        for i = 1, #player.script_assets do
          asset = player.script_assets[i]
          if string.find(asset.id, "Paint") and string.find(asset.id, "Beast") == nil then
            local id = asset.id
            asset.performance:addEventListener("tap", function(event) 
              new_paint = player.sketch_sprites:get(id)
              animation.to(player.mandala_selection, {fixed_x = new_paint.fixed_x, fixed_y = new_paint.fixed_y}, {time=250, easing=easing.inOutExpo})    
            
              if id == "Blue_Paint_2" then
                player.mandala_r = 32/255
                player.mandala_g = 105/255
                player.mandala_b = 243/255
              elseif id == "Black_Paint_3" then
                player.mandala_r = 0/255
                player.mandala_g = 0/255
                player.mandala_b = 0/255
              elseif id == "Green_Paint_4" then
                player.mandala_r = 43/255
                player.mandala_g = 183/255
                player.mandala_b = 25/255
              elseif id == "Orange_Paint_5" then
                player.mandala_r = 255/255
                player.mandala_g = 165/255
                player.mandala_b = 33/255
              elseif id == "Pink_Paint_6" then
                player.mandala_r = 255/255
                player.mandala_g = 133/255
                player.mandala_b = 185/255
              elseif id == "Purple_Paint_7" then
                player.mandala_r = 143/255
                player.mandala_g = 36/255
                player.mandala_b = 215/255
              elseif id == "Red_Paint_8" then
                player.mandala_r = 215/255
                player.mandala_g = 36/255
                player.mandala_b = 36/255
              elseif id == "Yellow_Paint_9" then
                player.mandala_r = 255/255
                player.mandala_g = 227/255
                player.mandala_b = 33/255
              elseif id == "Brown_Paint_8" then
                player.mandala_r = 128/255
                player.mandala_g = 83/255
                player.mandala_b = 17/255
              end


            end)
          end
        end
      end
    end, 1)
    
  end

  player.createMandala = function()
    player.mandala_size = 650
    player.mandala_x = 512
    player.mandala_y = 340
    player.mandala_radius = 8
    player.mandala_degree = 3

    player.mandala_r = 0
    player.mandala_g = 0
    player.mandala_b = 0

    player.mandala_target_pixels_painted = (player.mandala_size / 2) * (player.mandala_size / 2) * 1.5

    player.mandala_texture = memoryBitmap.newTexture(
    {
        width = player.mandala_size,
        height = player.mandala_size,
    })
    mandala = player.mandala_texture
 
    player.mandala_performance = display.newImageRect(player.sceneGroup, mandala.filename, mandala.baseDir, player.mandala_size, player.mandala_size )
    player.mandala_performance.x = player.mandala_x
    player.mandala_performance.y = player.mandala_y

    for y = 1,mandala.height do
        for x = 1,mandala.width do
            mandala:setPixel(x, y, 0, 0, 0, 0 )
        end
    end
     
    -- Submit texture to be updated
    mandala:invalidate()

  end

  function plot(x, y, alpha)
    local origin = player.mandala_size / 2
    if alpha == 1 then
      texture:setPixel(x + origin, y + origin, player.mandala_r, player.mandala_g, player.mandala_b, 1)
      player.mandala_pixels_painted = player.mandala_pixels_painted + 1
    else
      local r,g,b,a = texture:getPixel(x + origin, y + origin)
      if r ~= nil then
        texture:setPixel(x + origin, y + origin, r * (1-alpha) + player.mandala_r * alpha, g * (1-alpha) + player.mandala_g * alpha, b * (1-alpha) + player.mandala_b * alpha, a * (1-alpha) + 1 * alpha)
      end
    end
  end

  player.updateMandala = function(self, x_start, y_start, x_end, y_end)
    texture = player.mandala_texture
    local origin = player.mandala_size / 2

    local start_angle = math.atan2(y_start, x_start)
    local start_distance = math.sqrt(x_start*x_start + y_start*y_start)
    local end_angle = math.atan2(y_end, x_end)
    local end_distance = math.sqrt(x_end*x_end + y_end*y_end)
    local block_size = 2

    -- vals = {}
    -- local dupcount = 0

    for i = 0, player.mandala_degree - 1 do
      local r_start_angle = (start_angle + i * (2 * math.pi / player.mandala_degree) + 4 * math.pi) % (2 * math.pi)
      local x0 = start_distance * math.cos(r_start_angle)
      local y0 = start_distance * math.sin(r_start_angle)
      local r_end_angle = (end_angle + i * (2 * math.pi / player.mandala_degree) + 4 * math.pi) % (2 * math.pi)
      local x1 = end_distance * math.cos(r_end_angle)
      local y1 = end_distance * math.sin(r_end_angle)

      local distance = math.ceil(math.sqrt((x1-x0)*(x1-x0) + (y1-y0)*(y1-y0)))

      for j = 0, distance do
        x_j = j/distance * x1 + (distance - j)/distance * x0
        y_j = j/distance * y1 + (distance - j)/distance * y0
        for n = -block_size, block_size do
          for m = -block_size, block_size do
            if math.sqrt((x_j + n)*(x_j + n) + (y_j + m)*(y_j + m)) <= origin then
              -- if vals[x_j + n] == nil then
              --   vals[x_j + n] = {}
              -- end
              -- if vals[x_j + n][y_j + m] == nil then
              --   vals[x_j + n][y_j + m] = 0
              -- end
              -- if vals[x_j + n][y_j + m] ~= 0 then
              --   dupcount = dupcount + 1
              -- end
              -- if math.abs(m) == math.abs(n) and math.abs(n) == block_size then
              --   -- plot(x_j + n, y_j + m, 0.2)
              --   if vals[x_j + n][y_j + m] == 0 then
              --     vals[x_j + n][y_j + m] = 1
              --   end
              -- else
              --   -- plot(x_j + n, y_j + m, 1)
              --   vals[x_j + n][y_j + m] = 2
              -- end
              if math.abs(m) == math.abs(n) and math.abs(n) == block_size then
                plot(x_j + n, y_j + m, 0.2)
              else
                plot(x_j + n, y_j + m, 1)
              end
            end
          end
        end
      end
    end

    -- for k1,v1 in pairs(vals) do
    --   for k2,v2 in pairs(v1) do
    --     if v2 == 1 then
    --       plot(k1, k2, 0.2)
    --     elseif v2 == 2 then
    --       plot(k1, k2, 1)
    --     end
    --   end
    -- end

    texture:invalidate()

    if player.mandala_pixels_painted >= player.mandala_target_pixels_painted and player.end_button == nil then
      player.end_button = display.newImageRect(player.sceneGroup, "Art/Thumb_2.png", 128, 128)
      player.end_button.x = display.contentWidth - 100
      player.end_button.y = 100
      player.end_button:addEventListener("tap", function(event)
        player:finishMandalaScene()
      end)
    end
  end

  player.mandala_last_x = 0
  player.mandala_last_y = 0
  player.handleMandalaMouse = function(self, event)

    if player.mode == "mandala" then
      if event.phase == "moved" or event.phase == "ended" then
        player:updateMandala(event.x - player.mandala_x, event.y - player.mandala_y, player.mandala_last_x - player.mandala_x, player.mandala_last_y - player.mandala_y)
      end
      player.mandala_last_x = event.x
      player.mandala_last_y = event.y
    end
  end


  player.finishMandalaScene = function()
    --timer.cancel(player.measure_timer)

    display.remove(player.mandala_performance)
    display.remove(player.end_button)

    -- crashy as hell!
    -- player.mandala_texture:releaseSelf()

    timer.cancel(player.update_timer)

    audio.stop()

    player:nextScene()
  end
end

return interactive_mandala_player