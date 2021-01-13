
local animation = require("plugin.animation")

interactive_spelling_player = {}
interactive_spelling_player.__index = interactive_spelling_player

local small_word_gap = 150
local large_word_gap = 130

function interactive_spelling_player:augment(player)

  player.startInteractiveSpelling = function()
    player.mode = "spelling_intro"

    local info = player.info
    local word = player.info.word

    player.sketch_sprites.picture_info = player.picture_info
    player.sketch_sprites.sprite_info = player.sprite
    player.sketch_sprites.top_group = player.top_group

    player.current_letter_number = 1

    player.music_loop = audio.loadStream("Sound/chapter_" .. player.chapter_number .. "_interactive_loop.wav")
    audio.play(player.music_loop, {loops=-1})

    player.start_performance_time = system.getTimer()
    player.stored_performance_time = 0
    player.total_performance_time = 0
    player.current_time = system.getTimer()
    player.measures = 1
    player.interactive_measures = 0
    player.beats = 1
    player.interactive_beats = 0

    player.beat_timer = timer.performWithDelay(1, function() 
      player:beatTimerCheck()
    end, 0)

    if player.script_assets ~= nil and player.script_assets ~= "" then

      player:updatePerformance()

      player.update_timer = timer.performWithDelay(35, function() 
        player:updatePerformance()
      end, 0)
    end

    local sound = audio.loadSound("Sound/chapter_" .. player.chapter_number .. "/" .. string.lower(info.word) .. "_intro.wav")
    audio.play(sound)

    player.mode = "spelling_interactive"
    player.interactive_measures = 1
    player.interactive_beats = 1

    

    player:addBook()

    -- this comes after book pages have turned or book has appeared
    timer.performWithDelay(200, function()
      player:addSpellingPerformance()
    end, 1)

    player.button_making_timers = {}
    player.button_backings = {}
    player.button_letters = {}
    player.buttons = {}

    local gap = small_word_gap
    if string.len(info.word) >= 6 then
      gap = large_word_gap
    end

    for i = 1, string.len(info.word) do
      table.insert(player.button_making_timers, timer.performWithDelay(i * player.mpb * 0.5, function()

        local picture = string.upper(info.word):sub(i,i)

        local button = display.newGroup()
        player.top_group:insert(button)

        local button_backing = display.newSprite(player.top_group, player.sprite["Wooden_Block"], {frames=player.picture_info["Wooden_Block"].frames})
        button_backing.id = "button_backing_" .. i
        button_backing.x = display.contentCenterX + gap * (i - string.len(info.word)/2 - 0.5)
        -- button_backing.y = display.contentCenterY + 250
        button_backing.y = display.contentHeight - 80
        button_backing.fixed_y = button_backing.y
        button_backing.fixed_x = button_backing.x
        button_backing.info = player.picture_info["Wooden_Block"]
        button_backing.intro = "static"
        button_backing:setFrame(1)
        button_backing.state = "static"
        button_backing.start_time = system.getTimer()
        button_backing.x_scale = 1
        button_backing.y_scale = 1
        button_backing.xScale = button_backing.x_scale
        button_backing.yScale = button_backing.y_scale
        button_backing.disappear_time = -1
        button_backing.squish_scale = 1
        button_backing.squish_tilt = 0
        button_backing.squish_period = player.mpb
        player.sketch_sprites:add(button_backing)
        table.insert(player.button_backings, button_backing)

        local button_letter = display.newSprite(player.top_group, player.sprite[picture], {frames=player.picture_info[picture].frames})
        button_letter.id = picture .. "_" .. i
        button_letter.x = display.contentCenterX + gap * (i - string.len(info.word)/2 - 0.5)
        -- button_letter.y = display.contentCenterY + 250
        button_letter.y = display.contentHeight - 80
        button_letter.fixed_y = button_letter.y
        button_letter.fixed_x = button_letter.x
        button_letter.info = player.picture_info[picture]
        button_letter.intro = "static"
        button_letter:setFrame(player.picture_info[picture]["sprite_count"])
        button_letter.state = "static"
        button_letter.start_time = system.getTimer()
        button_letter.x_scale = 0.75
        button_letter.y_scale = 0.75
        button_letter.xScale = button_letter.x_scale
        button_letter.yScale = button_letter.y_scale
        button_letter.disappear_time = -1
        button_letter.squish_scale = 1
        button_letter.squish_tilt = 0
        button_letter.squish_period = player.mpb
        player.sketch_sprites:add(button_letter)
        table.insert(player.button_letters, button_letter)

        local this_letter = i

        function poopStars(x, y, val)
          player:poopStars(x, y, val)
        end

        local button_event = function(event)
          if player.mode == "spelling_interactive" then
            if player.current_letter_number >= 1 and player.current_letter_number <= string.len(info.word) and this_letter == player.current_letter_number then

              local letter_sound = audio.loadSound("Sound/chapter_" .. player.chapter_number .. "/" .. string.lower(info.word) .. "_" .. player.current_letter_number .. ".wav")
              audio.play(letter_sound)

              poopStars(button_backing.x, button_backing.y, 3 + math.random(3))

              player.current_letter_number = player.current_letter_number + 1
              local c = player.current_letter_number

              player.button_backings[c - 1]:setFrame(1)
              player.button_backings[c - 1].squish_scale = 1
              player.button_backings[c - 1].squish_tilt = 0
              player.button_backings[c - 1].squish_period = player.mpb
              player.button_letters[c - 1].squish_scale = 1
              player.button_letters[c - 1].squish_tilt = 0
              player.button_letters[c - 1].squish_period = player.mpb

              player.button_backings[c - 1].fixed_y = 5000
              current_y = player.button_letters[c - 1].fixed_y
              current_x = player.button_letters[c - 1].fixed_x
              new_x = display.contentCenterX + (gap * 0.75) * ((c-1) - string.len(info.word)/2 - 0.5)
              animation.to(player.button_letters[c - 1], {fixed_y=display.contentHeight - 200, fixed_x=new_x}, {time=player.mpb / 2, easing=easing.outExp})

              if c <= string.len(info.word) then
                player.button_backings[c].squish_scale = 1.02
                player.button_backings[c].squish_tilt = 8
                player.button_backings[c].squish_period = player.mpb
                player.button_letters[c].squish_scale = 1.02
                player.button_letters[c].squish_tilt = 8
                player.button_letters[c].squish_period = player.mpb
              end

              if c > string.len(info.word) then
                timer.performWithDelay(player.mpb * 2, function()
                  -- we're done!
                  player.mode = "spelling_pre_outro"
                end)
              end

              player:setWordColor(player.current_letter_number)
            end
          end
        end
        button_backing:addEventListener("tap", button_event)
        button.event = button_event

        table.insert(player.buttons, button)
      end, 1))
    end
  end

  player.addSpellingPerformance = function()
    local info = player.info
    local word = player.info.word
    local picture = info.word
    local spelling_object_x = display.contentCenterX
    local spelling_object_y = display.contentCenterY - 100

    if info.performance == nil then
      info.performance = {
        intro = "sketch",
        depth = 18,
      }
    end

    local perf = info["performance"]

    if player.sprite[perf.name] == nil then
      player.loader:loadPicture(perf.name)
    end

    if perf.fixed_x ~= nil then
      spelling_object_x = perf.fixed_x
    end
    if perf.fixed_y ~= nil then
      spelling_object_y = perf.fixed_y
    end

    if perf.name == nil then
      perf.name = picture
    end

    player.spelling_object = display.newSprite(player.performanceAssetGroup[perf.depth + player.const_half_layers + 1], player.sprite[perf.name], {frames=player.picture_info[perf.name].frames})
    player.spelling_object.name = perf.name
    player.spelling_object.id = perf.name .. "_" .. 0
    player.spelling_object.info = player.picture_info[perf.name]
    player.spelling_object.intro = perf.intro
    player:setInitialPerformanceState(player.spelling_object, perf.intro, perf.name)
    if perf.x_scale ~= nil then
      player.spelling_object.x_scale = perf.x_scale
    else
      player.spelling_object.x_scale = 1
    end
    if perf.y_scale ~= nil then
      player.spelling_object.y_scale = perf.y_scale
    else
      player.spelling_object.y_scale = 1
    end
    player.spelling_object.xScale = perf.x_scale
    player.spelling_object.yScale = perf.y_scale
    if perf.disappear_method ~= nil then
      player.spelling_object.disappear_method = perf.disappear_method
    else
      player.spelling_object.disappear_method = ""
    end
    if perf.squish_scale ~= nil then
      player.spelling_object.squish_scale = perf.squish_scale
    else
      player.spelling_object.squish_scale = 1.02
    end
    if perf.squish_tilt ~= nil then
      player.spelling_object.squish_tilt = perf.squish_tilt
    else
      player.spelling_object.squish_tilt = 8
    end
    if perf.squish_period ~= nil then
      player.spelling_object.squish_period = perf.squish_period
    else
      player.spelling_object.squish_period = player.mpb
    end
    
    player.spelling_object.x = spelling_object_x
    player.spelling_object.y = spelling_object_y
    player.spelling_object.fixed_x = spelling_object_x
    player.spelling_object.fixed_y = spelling_object_y
    player.spelling_object.disappear_time = -1
    
    player.spelling_object.start_time = system.getTimer()

    touch_giggle = function(event)
      local giggle_sound = audio.loadSound("Sound/giggle.wav")
      audio.play(giggle_sound)
      local new_y = player.spelling_object.fixed_y - 40 + math.random(80)
      local new_x = player.spelling_object.fixed_x - 100 + math.random(200)
      animation.to(player.spelling_object, {fixed_y=new_y, fixed_x=new_x}, {time=player.mpb / 2, easing=easing.outExp})
    end
    if info.touch_giggle ~= false then
      player.spelling_object:addEventListener("tap", touch_giggle)
    end
    player.sketch_sprites:add(player.spelling_object)
  end

  player.clearSpellingMaterial = function()
    display.remove(player.spelling_object)
    for i = 1, string.len(player.info.word) do
      display.remove(player.button_backings[i])
      display.remove(player.button_letters[i])
    end

  end

  player.beatTimerCheck = function()
    player.current_time = system.getTimer()

    if player.current_time - player.start_performance_time > (player.mpb * player.time_sig) * player.measures then
      player:measureActions()
      -- measure action could finish the scene, so check for that before going on
      if player.mode ~= "spelling_finished" then
        player.measures = player.measures + 1
        if player.mode == "spelling_interactive" then
          player.interactive_measures = player.interactive_measures + 1
        end
      end
    end

    if player.mode ~= "spelling_finished" and player.current_time - player.start_performance_time > player.mpb * player.beats then
      player:beatActions()
      player.beats = player.beats + 1
      if player.mode == "spelling_interactive" then
        player.interactive_beats = player.interactive_beats + 1
      end
    end

    if player.mode == "spelling_finished" then
      player:finishSpellingScene()
    end
  end

  player.finishSpellingScene = function()
    timer.cancel(player.beat_timer)
    
    audio.stop()

    for i = 1, #player.button_making_timers do
      timer.cancel(player.button_making_timers[i])
    end

    for i = 1, string.len(player.info.word) do
      if #player.buttons >= i then
        player.buttons[i]:removeEventListener("tap", player.buttons[i].event)
        display.remove(player.buttons[i])
      end
    end
    player.buttons = {}

    player:nextScene()
  end

  player.beatActions = function()

    local info = player.info
    local word = string.lower(player.info.word)

      -- on every other beat during interactives, update the color coding to fit the letter
    if player.mode == "spelling_interactive" then
      player:setWordColor(player.current_letter_number)
    end
  end

  player.measureActions = function()
    local info = player.info
    local word = string.lower(player.info.word)

    if player.mode == "spelling_pre_outro" then
      player.mode = "spelling_outro"

      local phoneme_sounds = audio.loadSound("Sound/chapter_" .. player.chapter_number .. "/" .. word .. "_phonemes.wav")
      audio.play(phoneme_sounds)

      local num_phonemes = string.len(info.word)
      if info.outro_highlights ~= nil then
        num_phonemes = #info.outro_highlights
      end

      local mpb_value = player.mpb
      if player.spelling_outro_mpb ~= nil then
        mpb_value = player.spelling_outro_mpb
      end

      for phoneme_num = 1, num_phonemes do
        timer.performWithDelay((phoneme_num * 2 - 2) * mpb_value, function()
          if info.outro_highlights ~= nil then
            player:setWordColor(info.outro_highlights[phoneme_num], true)
          else
            player:setWordColor(phoneme_num)
          end
        end)
      end

      timer.performWithDelay(2 * num_phonemes * mpb_value, function()
        player:setWordColor("none")
        local final_sound = audio.loadSound("Sound/touch_letter.wav")
        audio.play(final_sound)
        
        player:poopStars(player.spelling_object.fixed_x, player.spelling_object.fixed_y, 10 + math.random(20))

        if player.info.spellingCallback == nil then
          player.spelling_object.state = "sketching"
        else
          player.info:spellingCallback(player)
        end
      end)

      timer.performWithDelay((2 * num_phonemes + 2) * mpb_value, function()
        player:setWordColor("all")

        if player.spelling_object.disappear_method ~= nil and player.spelling_object.disappear_method ~= "" then
          player.spelling_object.disappear_time = 1
        end
      end)
      timer.performWithDelay((2 * num_phonemes + 4) * mpb_value, function()
        player:setWordColor("none")
        if info.word == "Banana" or info.word == "Pear" or info.word == "Apple" or info.word == "Orange" or info.word == "Plum" or info.word == "Lime" then
          local chomp_sound = audio.loadSound("Sound/chomp.wav")
          audio.play(chomp_sound)
        end
      end)
      timer.performWithDelay((2 * num_phonemes + 6) * mpb_value, function()
        player.mode = "spelling_finished"
      end)
    end
  end

  player.setWordColor = function(self, compare_value, is_pattern)
    local info = player.info
    local word = info.word

    if word == nil or #player.button_backings < string.len(word) then
      return
    end

    is_pattern = is_pattern or false

    for i = 1, string.len(word) do
      if i ~= nil and player.button_backings ~= nil and player.button_backings[i] ~= nil and player.button_backings[i]["squish_scale"] ~= nil then
        if is_pattern then
          pattern_value = compare_value:sub(i,i)
          if pattern_value == "-" then
            player.button_backings[i]:setFrame(1)
            player.button_backings[i].squish_scale = 1
            player.button_backings[i].squish_tilt = 0
            player.button_backings[i].squish_period = player.mpb
            player.button_letters[i].squish_scale = 1
            player.button_letters[i].squish_tilt = 0
            player.button_letters[i].squish_period = player.mpb
            player.button_letters[i].alpha = 1
          else
            player.button_backings[i].squish_scale = 1.02
            player.button_backings[i].squish_tilt = 8
            player.button_backings[i].squish_period = player.mpb
            player.button_letters[i].squish_scale = 1.02
            player.button_letters[i].squish_tilt = 8
            player.button_letters[i].squish_period = player.mpb
            if player.button_backings[i].frame == 1 then
              player.button_backings[i]:setFrame(2)
              player.button_letters[i].alpha = 0.5
            else
              player.button_backings[i]:setFrame(1)
              player.button_letters[i].alpha = 1
            end
          end
        elseif compare_value == "none" or (compare_value ~= "all" and i ~= compare_value) then
          player.button_backings[i]:setFrame(1)
          player.button_backings[i].squish_scale = 1
          player.button_backings[i].squish_tilt = 0
          player.button_backings[i].squish_period = player.mpb
          player.button_letters[i].squish_scale = 1
          player.button_letters[i].squish_tilt = 0
          player.button_letters[i].squish_period = player.mpb
          player.button_letters[i].alpha = 1
        else
          player.button_backings[i].squish_scale = 1.02
          player.button_backings[i].squish_tilt = 8
          player.button_backings[i].squish_period = player.mpb
          player.button_letters[i].squish_scale = 1.02
          player.button_letters[i].squish_tilt = 8
          player.button_letters[i].squish_period = player.mpb
          if player.button_backings[i].frame == 1 then
            player.button_backings[i]:setFrame(2)
            player.button_letters[i].alpha = 0.5
          else
            player.button_backings[i]:setFrame(1)
            player.button_letters[i].alpha = 1
          end
          if compare_value == "all" then
            player.button_backings[i]:setFrame(2)
            player.button_letters[i].alpha = 0.5
          elseif compare_value == "none" then
            player.button_backings[i]:setFrame(1)
            player.button_letters[i].alpha = 1
          end
        end
      end
    end
  end

end

return interactive_spelling_player