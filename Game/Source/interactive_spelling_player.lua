
local animation = require("plugin.animation")

interactive_spelling_player = {}
interactive_spelling_player.__index = interactive_spelling_player

local small_word_gap = 180
local large_word_gap = 160

function interactive_spelling_player:augment(player)

  player.startInteractiveSpelling = function()
    player.mode = "intro"

    local info = player.info
    local word = player.info.word

    player.sketch_sprites.picture_info = player.picture_info
    player.sketch_sprites.sprite_info = player.sprite
    player.sketch_sprites.top_group = player.performanceAssetGroup[9]

    player.current_letter_number = 1

    player.music_loop = audio.loadStream("Sound/Chapter_1_Interactive_Loop.wav")
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

    local sound = audio.loadSound("Sound/Chapter_1/" .. info.word .. "_Intro.wav")
    audio.play(sound)
    --, {onComplete = function()
    --   player.mode = "interactive"
    --   player.interactive_measures = 1
    --   player.interactive_beats = 1

    --   player:setWordColor(player.current_letter_number)
    -- end})
    player.mode = "interactive"
    player.interactive_measures = 1
    player.interactive_beats = 1

    local picture = info.word

    local spelling_object_x = display.contentCenterX
    local spelling_object_y = display.contentCenterY - 100
    if info["object_x"] ~= nil then
      spelling_object_x = info["object_x"]
    end
    if info["object_y"] ~= nil then
      spelling_object_y = info["object_y"]
    end

    player.spelling_object = display.newSprite(player.performanceAssetGroup, player.sprite[picture], {frames=player.picture_info[picture].frames})
    player.spelling_object.id = picture .. "_" .. 0
    player.spelling_object.x = spelling_object_x
    player.spelling_object.y = spelling_object_y
    player.spelling_object.fixed_y = player.spelling_object.y
    player.spelling_object.fixed_x = player.spelling_object.x
    player.spelling_object.info = player.picture_info[picture]
    player.spelling_object.intro = "sketch"
    player.spelling_object:setFrame(1)
    player.spelling_object.state = "outline_sketching"
    player.spelling_object.start_time = system.getTimer()
    player.spelling_object.x_scale = 1
    player.spelling_object.y_scale = 1
    player.spelling_object.xScale = player.spelling_object.x_scale
    player.spelling_object.yScale = player.spelling_object.y_scale
    player.spelling_object.disappear_time = -1
    player.spelling_object.squish_scale = 1.02
    player.spelling_object.squish_tilt = 8
    player.spelling_object.squish_period = player.mpb
    touch_giggle = function(event)
      local giggle_sound = audio.loadSound("Sound/giggle.wav")
      audio.play(giggle_sound)
      local new_y = player.spelling_object.fixed_y - 40 + math.random(80)
      local new_x = player.spelling_object.fixed_x - 100 + math.random(200)
      animation.to(player.spelling_object, {fixed_y=new_y, fixed_x=new_x}, {time=player.mpb / 2, easing=easing.outExp})
    end
    player.spelling_object:addEventListener("tap", touch_giggle)
    player.sketch_sprites:add(player.spelling_object)

    player.button_making_timers = {}
    player.button_backings = {}
    player.button_letters = {}
    player.buttons = {}

    local gap = small_word_gap
    if string.len(info.word) >= 6 then
      gap = large_word_gap
    end

    for i = 1, string.len(info.word) do
      table.insert(player.button_making_timers, timer.performWithDelay(info.intro_letter_beats[i] * player.mpb, function()

        local picture = string.upper(info.word):sub(i,i)

        local button = display.newGroup()
        player.performanceAssetGroup:insert(button)

        local button_backing = display.newSprite(player.performanceAssetGroup, player.sprite["Letter_Box"], {frames=player.picture_info["Letter_Box"].frames})
        button_backing.id = "button_backing_" .. i
        button_backing.x = display.contentCenterX + gap * (i - string.len(info.word)/2 - 0.5)
        button_backing.y = display.contentCenterY + 250
        button_backing.fixed_y = button_backing.y
        button_backing.fixed_x = button_backing.x
        button_backing.info = player.picture_info["Letter_Box"]
        button_backing.intro = "static"
        button_backing:setFrame(1)
        button_backing.state = "static"
        button_backing.start_time = system.getTimer()
        button_backing.x_scale = 0.75
        button_backing.y_scale = 0.75
        button_backing.xScale = button_backing.x_scale
        button_backing.yScale = button_backing.y_scale
        button_backing.disappear_time = -1
        button_backing.squish_scale = 1
        button_backing.squish_tilt = 0
        button_backing.squish_period = player.mpb
        player.sketch_sprites:add(button_backing)
        table.insert(player.button_backings, button_backing)

        local button_letter = display.newSprite(player.performanceAssetGroup, player.sprite[picture], {frames=player.picture_info[picture].frames})
        button_letter.id = picture .. "_" .. i
        button_letter.x = display.contentCenterX + gap * (i - string.len(info.word)/2 - 0.5)
        button_letter.y = display.contentCenterY + 250
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
          if player.mode == "interactive" then
            print("Touching " .. player.current_letter_number)
            if player.current_letter_number >= 1 and player.current_letter_number <= string.len(info.word) and this_letter == player.current_letter_number then
              local sound = audio.loadSound("Sound/Touch_Letter.wav")
              audio.play(sound)
              local sound = audio.loadSound("Sound/Letters_2/" .. picture .. ".wav")
              audio.play(sound)

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
              -- display.remove(player.button_backings[c - 1])
              -- player.button_backings[c - 1].isVisible = false
              player.button_backings[c - 1].fixed_y = 5000
              current_y = player.button_letters[c - 1].fixed_y
              current_x = player.button_letters[c - 1].fixed_x
              new_x = display.contentCenterX + (gap * 0.6) * ((c-1) - string.len(info.word)/2 - 0.5)
              animation.to(player.button_letters[c - 1], {fixed_y=100, fixed_x=new_x}, {time=player.mpb / 2, easing=easing.outExp})

              if c <= string.len(info.word) then
                player.button_backings[c].squish_scale = 1.02
                player.button_backings[c].squish_tilt = 8
                player.button_backings[c].squish_period = player.mpb
                player.button_letters[c].squish_scale = 1.02
                player.button_letters[c].squish_tilt = 8
                player.button_letters[c].squish_period = player.mpb
              end

              if c > string.len(info.word) then
                -- we're done!
                player.mode = "pre_outro"
                player.spelling_object.state = "sketching"
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

  player.clearSpellingMaterial = function()
    print("I am removing spelling material")
    display.remove(player.spelling_object)
    for i = 1, string.len(player.info.word) do
      display.remove(player.button_backings[i])
      display.remove(player.button_letters[i])
    end

  end

  player.beatTimerCheck = function()
    player.current_time = system.getTimer()
    if player.current_time - player.start_performance_time > (player.mpb * player.info.time_sig) * player.measures then
      player:measureActions()
      -- measure action could finish the scene, so check for that before going on
      if player.mode ~= "finished" then
        player.measures = player.measures + 1
        if player.mode == "interactive" then
          player.interactive_measures = player.interactive_measures + 1
        end
      end
    end

    if player.mode ~= "finished" and player.current_time - player.start_performance_time > player.mpb * player.beats then
      player:beatActions()
      player.beats = player.beats + 1
      if player.mode == "interactive" then
        player.interactive_beats = player.interactive_beats + 1
      end
    end

    if player.mode == "finished" then
      player:finishSpellingScene()
    end
  end

  player.finishSpellingScene = function()
    print("Canceling the beat timer")
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
    -- print("on interactive beat " .. player.interactive_beats)

    local info = player.info
    local word = string.lower(player.info.word)

      -- on every other beat during interactives, update the color coding to fit the letter
    if player.mode == "interactive" then
      player:setWordColor(player.current_letter_number)
    end

    -- on interactives, on the 3rd out of every 8 beats, tell the player to press a button.
    -- the sound is delayed by one beat (to capture the pre-beat sound), so this will actually
    -- land right on the measure mark.
    -- if player.mode == "interactive" and player.interactive_beats % 8 == 3 then
    --   if player.current_letter_number >= 1 and player.current_letter_number <= string.len(word) then
    --     current_letter = word:sub(player.current_letter_number, player.current_letter_number)
    --     randomizer = math.random(4)
    --     local sound = audio.loadSound("Sound/Interactive_Letters_".. info.bpm .. "/" .. current_letter .. "_" .. randomizer .. ".wav")
    --     audio.play(sound)
    --   end
    -- end
  end

  player.measureActions = function()
    -- print("on measure")

    local info = player.info
    local word = string.lower(player.info.word)

    if player.mode == "pre_outro" then
      player.mode = "outro"

      -- play the outro sound
      -- local sound = audio.loadSound("Sound/Chapter_1/" .. info.word .. "_Outro.wav")
      -- audio.play(sound, {onComplete = function()
      --   player.mode = "post_outro"
      -- end})

      -- load up some letter timing for show
      for letter_num = 1, string.len(info.word) do
        timer.performWithDelay(letter_num * player.mpb, function()
          player:setWordColor(letter_num)

          letter = string.upper(info.word):sub(letter_num,letter_num)

          local sound = audio.loadSound("Sound/Letters_2/" .. letter .. ".wav", {channel = 5})
          audio.play(sound)
        end)
      end
      for letter_num = 1, string.len(info.word) do
        timer.performWithDelay((string.len(info.word) + letter_num + 1) * player.mpb, function()
          player:setWordColor(letter_num)

          local sound = audio.loadSound("Sound/Letters_2/" .. info.outro_sounds[letter_num] .. ".wav", {channel = 5})

          audio.play(sound)
        end)
      end
      timer.performWithDelay((2 * string.len(info.word) + 3) * player.mpb, function()
        local final_sound = audio.loadSound("Sound/Touch_Letter.wav")
        audio.play(final_sound)
        player:setWordColor("all")
      end)
      timer.performWithDelay((2 * string.len(info.word) + 4) * player.mpb, function()
        player:setWordColor("none")
        player.mode = "post_outro"
        if info.word == "Banana" or info.word == "Pear" or info.word == "Apple" or info.word == "Orange" or info.word == "Plum" or info.word == "Lime" then
          local chomp_sound = audio.loadSound("Sound/chomp.wav")
          audio.play(chomp_sound)
        end
      end)
      -- timer.performWithDelay((2 * string.len(info.word) + 5) * player.mpb, function()
        
      -- end)
    end

    if player.mode == "post_outro" then
      player.mode = "finished"
    end
  end

  player.setWordColor = function(self, compare_value)
    -- print("in set word color")
    -- print(self)
    -- print(player)
    -- print(compare_value)

    local info = player.info
    local word = info.word
    -- print(word)
    -- print(player.button_backings)
    -- print(#player.button_backings)
    if word == nil or #player.button_backings < string.len(word) then
      return
    end
    -- print(player.button_backings[1])
    -- print(player.button_backings[1]["squish_scale"])
    -- print(compare_value)
    for i = 1, string.len(word) do
      if i ~= nil and player.button_backings ~= nil and player.button_backings[i] ~= nil and player.button_backings[i]["squish_scale"] ~= nil then
        if compare_value == "none" or (compare_value ~= "all" and i ~= compare_value) then
          -- print("setting this one flat")
          -- print(i)
          player.button_backings[i]:setFrame(1)
          player.button_backings[i].squish_scale = 1
          player.button_backings[i].squish_tilt = 0
          player.button_backings[i].squish_period = player.mpb
          player.button_letters[i].squish_scale = 1
          player.button_letters[i].squish_tilt = 0
          player.button_letters[i].squish_period = player.mpb
          player.button_letters[i].alpha = 1
        else
          -- print("setting this one fancy")
          -- print(i)
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