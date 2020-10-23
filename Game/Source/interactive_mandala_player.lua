
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

    if player.script_assets ~= nil and player.script_assets ~= "" then

      player:updatePerformance()

      player.update_timer = timer.performWithDelay(35, function() 
        player:updatePerformance()
      end, 0)
    end

    player:createMandala()

    Runtime:addEventListener("touch", function(event) player:handleMandalaMouse(event) end)
  end

  player.createMandala = function()
    player.mandala_size = 600
    player.mandala_x = display.contentCenterX - 100
    player.mandala_y = display.contentCenterY
    player.mandala_radius = 7

    player.mandala_texture = memoryBitmap.newTexture(
    {
        width = player.mandala_size,
        height = player.mandala_size,
    })
    mandala = player.mandala_texture
 
    local bitmap = display.newImageRect(player.sceneGroup, mandala.filename, mandala.baseDir, player.mandala_size, player.mandala_size )
    bitmap.x = player.mandala_x
    bitmap.y = player.mandala_y

    -- -- Loop through all pixels and set green channel to 1
    for y = 1,mandala.height do
        for x = 1,mandala.width do
            mandala:setPixel(x, y, 0, 1, 0, 0.5 )
        end
    end
     
    -- Set a pixel color in the bitmap
    mandala:setPixel( 10, 10, 1, 0, 0, 1 )  -- Set pixel at (10,10) to be red
    -- mandala:setPixel( 10, 10, {1,0,0,1} )  -- Same using table syntax for RGB+A color
     
    -- Get a pixel color from the bitmap
    print( mandala:getPixel( 10, 10 ) )  --> 1 0 0 1
     
    -- Submit texture to be updated
    mandala:invalidate()

    test_asset = {
      squish_scale= 1,
      intro= "static",
      type= "picture",
      disappear_time= -1,
      squish_period= 1718,
      id= "test_asset_1",
      fixed_y= 382.5,
      x_scale= 1,
      start_time= 187.5,
      y= 382.5,
      y_scale= 1,
      name= "Bird",
      x= 365,
      disappear_method= "",
      depth= 0,
      fixed_x= 365,
      squish_tilt= 0
    }

    player:perform(test_asset)
  end

  player.updateMandala = function(self, x_mouse, y_mouse)
    texture = player.mandala_texture
    local origin = player.mandala_size / 2

    local root_angle = math.atan2(y_mouse, x_mouse)
    print("X,Y are " .. x_mouse .. "," .. y_mouse)
    print("Root angle is " .. root_angle)
    local distance = math.sqrt(x_mouse*x_mouse + y_mouse*y_mouse)

    for i = 0, 4 do
      rotated_angle = (root_angle + i * (2 * math.pi / 5) + 4 * math.pi) % (2 * math.pi)
      rotated_x = distance * math.cos(rotated_angle)
      rotated_y = distance * math.sin(rotated_angle)

      for y = rotated_y - 10,rotated_y + 10 do
        for x = rotated_x - 10,rotated_x + 10 do
          if math.sqrt((x - rotated_x)*(x - rotated_x) + (y - rotated_y)*(y - rotated_y)) <= player.mandala_radius then
            if math.sqrt((x)*(x) + (y)*(y)) <= origin then
              texture:setPixel(x + origin, y + origin, 0, 0, 0, 1)
            end
          end
        end
      end
    end
    texture:invalidate()
  end


  player.edit_mode_asset_start_x = 0
  player.edit_mode_asset_start_y = 0
  player.handleMandalaMouse = function(self, event)
    print("In mandala mouse, mode " .. player.mode)
    print(event.x .. "," .. event.y .. "," .. event.xStart .. "," .. event.yStart)

    if player.mode == "mandala" then

      if event.phase == "began" or event.phase == "moved" or event.phase == "ended" then
        -- calculate relative to center of picture
        player:updateMandala(event.x - player.mandala_x, event.y - player.mandala_y)
      end
    end
  end


  player.finishMandalaScene = function()
    --timer.cancel(player.measure_timer)

    -- tex:releaseSelf()

    print("DONE WITH MANDALA")

    audio.stop()

    player:nextScene()
  end
end

return interactive_mandala_player