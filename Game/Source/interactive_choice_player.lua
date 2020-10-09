
local animation = require("plugin.animation")

interactive_choice_player = {}
interactive_choice_player.__index = interactive_choice_player

function interactive_choice_player:augment(player)


  player.old_perform = player.perform
  player.perform = function(self, asset)
    player:old_perform(asset)
    if asset.choice == true then
      player.number_of_interactive_choices = player.number_of_interactive_choices + 1
      local pop_sound = audio.loadSound("Sound/pop_" .. ((player.number_of_interactive_choices % 4) + 1) .. ".wav")
      audio.play(pop_sound)
      table.insert(player.interactive_choices, asset)
      asset.performance:addEventListener("tap", function()
        if player.mode == "choice_interactive" then
          local touch_sound = audio.loadSound("Sound/touch_letter.wav")
          audio.play(touch_sound)
          player.interactive_choice = asset

          player.info:choiceCallback(player.interactive_choice, player)
        end
      end)
    end
  end

  player.startInteractiveChoice = function()
    player.mode = "choice_intro"

    local info = player.info

    player.interactive_choices = {}

    player.number_of_interactive_choices = -1

    player.sketch_sprites.picture_info = player.picture_info
    player.sketch_sprites.sprite_info = player.sprite
    player.sketch_sprites.top_group = player.performanceAssetGroup[9]

    player.music_loop = audio.loadStream("Sound/chapter_" .. player.chapter_number .. "_interactive_loop.wav")
    audio.play(player.music_loop, {loops=-1})

    player.start_performance_time = system.getTimer()
    player.stored_performance_time = 0
    player.total_performance_time = 0
    player.current_time = system.getTimer()

    player.measures = 1

    if player.script_assets ~= nil and player.script_assets ~= "" then

      player:updatePerformance()

      player.update_timer = timer.performWithDelay(35, function() 
        player:updatePerformance()
      end, 0)
    end

    local sound = audio.loadSound("Sound/chapter_" .. player.chapter_number .. "/" .. info.intro .. ".wav")
    audio.play(sound)

    player.measure_timer = timer.performWithDelay(1, function() 
      player:measureTimer()
    end, 0)

    last_choice_appears = 0
    for i = 1, #player.script_assets do
      asset = player.script_assets[i]
      if asset.choice == true and asset.start_time > last_choice_appears then
        last_choice_appears = asset.start_time
      end
    end
    timer.performWithDelay(last_choice_appears, function()
      player.mode = "choice_interactive"
      print("Now it's interactive")
    end)
  end

  player.measureTimer = function()
    player.current_time = system.getTimer()
    if player.current_time - player.start_performance_time > (player.mpb * player.time_sig) * player.measures then
      print("Measure " .. player.measures)
      player.measures = player.measures + 1
      if player.mode == "choice_outro" and player.measures % 2 == 1 then
        player:finishChoiceScene()
      end
    end
  end


  player.finishChoiceScene = function()
    timer.cancel(player.measure_timer)

    audio.stop()

    -- player.next_scene = player.info:choiceCallback(player.interactive_choice)

    -- future: maybe should remove the choice object tap events

    player:nextScene()
  end
end

return interactive_choice_player