
local composer = require("composer")
local utilities = require("Source.utilities")

local animation = require("plugin.animation")

setup_chapter_2 = {}
setup_chapter_2.__index = setup_chapter_2

--
-- This is the definition for chapter 2 setup. Here the pre-built chapter_structure
-- of chapter 2 is defined. This is called right at the start of the whole game, by game_setup.
--

function setup_chapter_2:setup(chapter_structure)
  chapter_structure.first_part = "chapter_2_part_1"

  chapter_structure.bpm = 160
  chapter_structure.mpb = 375
  chapter_structure.spelling_outro_mpb = 375
  chapter_structure.time_sig = 4

  chapter_structure.flow = {}

  setChoiceObject = function(script_name, choice_id, choice_value)
    script_element_list = chapter_structure.flow[script_name].script
    for i = 1, #script_element_list do
      script_element = script_element_list[i]
      if script_element.id == choice_id then
        script_element.choice_value = choice_value
      end
    end
  end

  local flow = chapter_structure.flow
  chapter_structure.flow["chapter_2_part_1"] = {
    name="chapter_2_part_1",
    -- next="chapter_2_interactive_choice_vehicle",
    next="chapter_2_part_2",
    type="scripted",
    cleanup=true,
    script=loadPartScript("chapter_2_part_1"),
    music="chapter_2_scene_1",
    additional_actions = {
      {
        start_time= 0,
        label="pan from city top",
        action=function(part)
          part.stage:translateLayer(-1, 0, 0, {"y", "=", 1024})
          part.stage:translateLayer(-1, 375 * 16, easing.inOutQuart, {"y", "=", 0})
        end
      },
    }
  }

  for i = 0, 24 do
    right_scoot_action = {
      start_time= 1500 * i,
      label="scoot right",
      action=function(part)
        -- right scooting rows are 21 and 15
        if i % 4 == 0 then
          part.stage:translateLayer(21, 0, 0, {"x", "-", 1024})
          part.stage:translateLayer(15, 0, 0, {"x", "-", 1024})
        end
        part.stage:translateLayer(21, 750 / 4 * 0.7, easing.outExp, {"x", "+", 256})
        part.stage:translateLayer(15, 750 / 4 * 0.7, easing.outExp, {"x", "+", 256})

        if math.random(10) >= 6 then
          part.stage:makeHonk(100 + math.random(824), 192 + 50 + math.random(384 - 100), chapter_structure.mpb * 3/4)
        end
      end
    }
    table.insert(chapter_structure.flow["chapter_2_part_1"].additional_actions, right_scoot_action)
    left_scoot_action = {
      start_time= 1500 * i + 750 * 3/4,
      label="scoot left",
      action=function(part)
        -- left scooting rows are 22 and 16
        if i % 4 == 0 then
          part.stage:translateLayer(22, 0, 0, {"x", "+", 1024})
          part.stage:translateLayer(16, 0, 0, {"x", "+", 1024})
        end
        part.stage:translateLayer(22, 750 / 4 * 0.7, easing.outExp, {"x", "-", 256})
        part.stage:translateLayer(16, 750 / 4 * 0.7, easing.outExp, {"x", "-", 256})

        if math.random(10) >= 6 then
          part.stage:makeHonk(100 + math.random(824), 192 + 50 + math.random(384 - 100), chapter_structure.mpb * 3/4)
        end
      end
    }
    table.insert(chapter_structure.flow["chapter_2_part_1"].additional_actions, left_scoot_action)
  end

  for i = 1,8 do
    staccato_honk_action = {
      start_time= 22500 - (375/2) + (chapter_structure.mpb / 2) * i,
      label="honk",
      action=function(part)
        part.stage:makeHonk(900 - 100 * i, 192 + 50 + math.random(384 - 100), chapter_structure.mpb * 3/4)
      end
    }
    table.insert(chapter_structure.flow["chapter_2_part_1"].additional_actions, staccato_honk_action)
  end


  chapter_structure.flow["chapter_2_interactive_choice_vehicle"] = {
    name="chapter_2_interactive_choice_vehicle",
    next=nil,
    type="interactive_choice",
    intro="vehicle_choice",
    cleanup=false,
    choiceCallback = function(something, choice_element, player)

      for i = 1, #player.script do
        other_element = player.script[i]
        if other_element.performance ~= nil and other_element.performance.id ~= choice_element.id then
          animation.to(other_element.performance, {alpha=0}, {time=player.mpb * 0.75, easing=easing.outExp})
        end
      end

      animation.to(choice_element.performance, {fixed_x = display.contentCenterX, fixed_y = display.contentCenterY - 100}, {time=player.mpb, easing=easing.outExp})

      player:poopStars(choice_element.performance.fixed_x, choice_element.performance.fixed_y, 3 + math.random(3))

      local choice_value = choice_element.name

      if string.find(choice_value, "Car") then 
        player.next_part = "chapter_2_interactive_car"
      elseif string.find(choice_value, "Truck") then
        player.next_part = "chapter_2_interactive_truck"
      elseif string.find(choice_value, "Bus") then
        player.next_part = "chapter_2_interactive_bus"
      elseif string.find(choice_value, "Taxi") then
        player.next_part = "chapter_2_interactive_taxi"
        setChoiceObject("chapter_2_part_2", "Vehicle_Choice_1", "Taxi")
      end

      timer.performWithDelay(player.mpb, function() 
        player.mode = "choice_outro"
      end)
    end,
    script=loadPartScript("chapter_2_interactive_choice_vehicle"),
  }

  chapter_structure.flow["chapter_2_interactive_taxi"] = {
    name="chapter_2_interactive_taxi",
    next="chapter_2_part_2",
    type="interactive_spelling",
    word="Taxi",
    script=nil,
    performance = {
      squish_scale = 1.02,
      intro = "static",
      y_scale = 1,
      name = "Taxi",
      disappear_method = "poof",
      x_scale = 1,
      squish_tilt = 8,
      depth = 18,
    },
  }

  chapter_structure.flow["chapter_2_interactive_bus"] = {
    name="chapter_2_interactive_bus",
    next="chapter_2_interactive_choice_bus_color",
    type="interactive_spelling",
    cleanup=false,
    word="Bus",
    script=nil,
    performance = {
      squish_scale = 1.02,
      intro = "static",
      y_scale = 1,
      name = "Bus_Blue",
      disappear_method = "poof",
      x_scale = 1,
      squish_tilt = 8,
      depth = 18,
    },
  }
  chapter_structure.flow["chapter_2_interactive_choice_bus_color"] = {
    name="chapter_2_interactive_choice_bus_color",
    next="chapter_2_part_2",
    type="interactive_choice",
    intro="bus_color_choice",
    choiceCallback = function(something, choice_element, player)

      color = string.gsub(choice_element.name, "_Paint", "")

      for i = 1, #player.script do
        script_element = player.script[i]
        if script_element.performance ~= nil and string.find(script_element.name, "Paint") then
          script_element.performance.isVisible = false
        elseif script_element.performance ~= nil and string.find(script_element.name, "Bus") then
          display.remove(script_element.performance)
          script_element.performance = nil
          script_element.name = "Bus_" .. color
          script_element.intro = "poof"
          player:perform(script_element)
        end
      end

      setChoiceObject("chapter_2_part_2", "Vehicle_Choice_1", "Bus_" .. color)

      for i = 1, #chapter_structure.flow["chapter_2_part_2"].script do
        script_element = chapter_structure.flow["chapter_2_part_2"].script[i]

        if script_element.id == "Clara_v2_13" then
          script_element.fixed_x = script_element.fixed_x - 10
          script_element.x = script_element.x - 10
          script_element.fixed_y = script_element.fixed_y - 13
          script_element.y = script_element.y - 13
        end
      end

      timer.performWithDelay(player.mpb, function() 
        player.mode = "choice_outro"
      end)
    end,
    script=loadPartScript("chapter_2_interactive_choice_bus_color"),
  }

  chapter_structure.flow["chapter_2_interactive_car"] = {
    name="chapter_2_interactive_car",
    next="chapter_2_interactive_choice_car_color",
    type="interactive_spelling",
    word="Car",
    cleanup=false,
    script=nil,
    performance = {
      squish_scale = 1.02,
      intro = "static",
      y_scale = 1,
      name = "Car_Green",
      disappear_method = "poof",
      x_scale = 1,
      squish_tilt = 8,
      depth = 18,
    },
  }
  chapter_structure.flow["chapter_2_interactive_choice_car_color"] = {
    name="chapter_2_interactive_choice_car_color",
    next="chapter_2_part_2",
    type="interactive_choice",
    intro="car_color_choice",
    choiceCallback = function(something, choice_element, player)

      color = string.gsub(choice_element.name, "_Paint", "")

      for i = 1, #player.script do
        script_element = player.script[i]
        if script_element.performance ~= nil and string.find(script_element.name, "Paint") then
          script_element.performance.isVisible = false
        elseif script_element.performance ~= nil and string.find(script_element.name, "Car") then
          display.remove(script_element.performance)
          script_element.performance = nil
          script_element.name = "Car_" .. color
          script_element.intro = "poof"
          player:perform(script_element)
        end
      end

      setChoiceObject("chapter_2_part_2", "Vehicle_Choice_1", "Car_" .. color)

      timer.performWithDelay(player.mpb, function() 
        player.mode = "choice_outro"
      end)
    end,
    script=loadPartScript("chapter_2_interactive_choice_car_color"),
  }

  chapter_structure.flow["chapter_2_interactive_truck"] = {
    name="chapter_2_interactive_truck",
    next="chapter_2_interactive_choice_truck_color",
    type="interactive_spelling",
    word="Truck",
    cleanup=false,
    outro_highlights = {"t----", "-r---", "--u--", "---ck"},
    script=nil,
    performance = {
      squish_scale = 1.02,
      intro = "static",
      y_scale = 1,
      name = "Truck_Red",
      disappear_method = "poof",
      x_scale = 1,
      squish_tilt = 8,
      depth = 18,
    },
  }
  chapter_structure.flow["chapter_2_interactive_choice_truck_color"] = {
    name="chapter_2_interactive_choice_truck_color",
    next="chapter_2_part_2",
    type="interactive_choice",
    intro="truck_color_choice",
    choiceCallback = function(something, choice_element, player)

      color = string.gsub(choice_element.name, "_Paint", "")

      for i = 1, #player.script do
        script_element = player.script[i]
        if script_element.performance ~= nil and string.find(script_element.name, "Paint") then
          script_element.performance.isVisible = false
        elseif script_element.performance ~= nil and string.find(script_element.name, "Truck") then
          display.remove(script_element.performance)
          script_element.performance = nil
          script_element.name = "Truck_" .. color
          script_element.intro = "poof"
          player:perform(script_element)
        end
      end

      setChoiceObject("chapter_2_part_2", "Vehicle_Choice_1", "Truck_" .. color)

      for i = 1, #chapter_structure.flow["chapter_2_part_2"].script do
        script_element = chapter_structure.flow["chapter_2_part_2"].script[i]

        if script_element.id == "Clara_v2_13" then
          script_element.fixed_x = script_element.fixed_x + 30
          script_element.x = script_element.x + 30
        end
      end

      timer.performWithDelay(player.mpb, function() 
        player.mode = "choice_outro"
      end)
    end,
    script=loadPartScript("chapter_2_interactive_choice_truck_color"),
  }

  chapter_structure.flow["chapter_2_part_2"] = {
    name="chapter_2_part_2",
    -- next="chapter_2_interactive_bike",
    next="chapter_2_part_3",
    type="scripted",
    cleanup=false,
    script=loadPartScript("chapter_2_part_2"),
    music="chapter_2_scene_2",
    additional_actions = {},
  }

  for i = 1, 8 do
    more_honks = {
      start_time= 4500 + 187 * i,
      label="mo hanks",
      action=function(part)
        part.stage:makeHonk(100 + math.random(824), 192 + 50 + math.random(384 - 100), chapter_structure.mpb * 3/4)
      end
    }
    table.insert(chapter_structure.flow["chapter_2_part_2"].additional_actions, more_honks)
  end

  for i = 8, 24 do
    right_scoot_action = {
      start_time= 1500 * i,
      label="scoot right",
      action=function(part)
        cha_cha_modifier = 1
        if i % 2 == 0 then
          cha_cha_modifier = -1
        end
        part.stage:translateLayer(21, 750 / 4 * 0.7, easing.outExp, {"x", "+", cha_cha_modifier * 128})

        if math.random(10) >= 6 then
          part.stage:makeHonk(100 + math.random(824), 192 + 50 + math.random(384 - 100), chapter_structure.mpb * 3/4)
        end
      end
    }
    table.insert(chapter_structure.flow["chapter_2_part_2"].additional_actions, right_scoot_action)
    left_scoot_action = {
      start_time= 1500 * i + 750 * 3/4,
      label="scoot left",
      action=function(part)
        cha_cha_modifier = 1
        if i % 2 == 0 then
          cha_cha_modifier = -1
        end
        part.stage:translateLayer(21, 750 / 4 * 0.7, easing.outExp, {"x", "-", cha_cha_modifier * 128})
        -- if i % 4 == 2 then
        --   part.stage:translateLayer(22, 0, 0, {"x", "+", 1024})
        -- end
        part.stage:translateLayer(22, 750 / 4 * 0.7, easing.outExp, {"x", "-", 256})

        if math.random(10) >= 6 then
          part.stage:makeHonk(100 + math.random(824), 192 + 50 + math.random(384 - 100), chapter_structure.mpb * 3/4)
        end
      end
    }
    table.insert(chapter_structure.flow["chapter_2_part_2"].additional_actions, left_scoot_action)
  end


  chapter_structure.flow["chapter_2_interactive_bike"] = {
    name="chapter_2_interactive_bike",
    next="chapter_2_interactive_choice_bike_color",
    type="interactive_spelling",
    word="Bike",
    outro_highlights = {"b---", "-i--", "--ke"},
    script=nil,
    cleanup=false,
    performance = {
      squish_scale = 1.02,
      intro = "poof",
      y_scale = 1,
      name = "Bike_Purple",
      disappear_method = "poof",
      x_scale = 1,
      squish_tilt = 8,
      depth = 18,
    },
  }
  chapter_structure.flow["chapter_2_interactive_choice_bike_color"] = {
    name="chapter_2_interactive_choice_bike_color",
    next="chapter_2_part_3",
    type="interactive_choice",
    intro="bike_color_choice",
    choiceCallback = function(something, choice_element, player)

      color = string.gsub(choice_element.name, "_Paint", "")

      for i = 1, #player.script do
        script_element = player.script[i]
        if script_element.performance ~= nil and string.find(script_element.name, "Paint") then
          script_element.performance.isVisible = false
        elseif script_element.performance ~= nil and string.find(script_element.name, "Bike") then
          display.remove(script_element.performance)
          script_element.performance = nil
          script_element.name = "Bike_" .. color
          script_element.intro = "poof"
          player:perform(script_element)
        end
      end

      setChoiceObject("chapter_2_part_3", "Bike_Choice_1", "Bike_" .. color)
      setChoiceObject("chapter_2_part_4", "Bike_Choice_1", "Bike_" .. color)

      timer.performWithDelay(player.mpb, function() 
        player.mode = "choice_outro"
      end)
    end,
    script=loadPartScript("chapter_2_interactive_choice_bike_color"),
  }


  chapter_structure.flow["chapter_2_part_3"] = {
    name="chapter_2_part_3",
    next="chapter_2_part_4",
    type="scripted",
    script=loadPartScript("chapter_2_part_3"),
    cleanup=true,
    music="chapter_2_scene_3",
    additional_actions = {
      {
        start_time= 0,
        label="gradual stage move left to right",
        action=function(part)
          part.stage:translateLayer(-1, 1875, easing.linear, {"x", "-", 390})
          part.stage:translateLayer(20, 1875, easing.linear, {"x", "+", 390})
        end
      },
      {
        start_time=2250,
        label="gradual stage move left to right",
        action=function(part)
          part.stage:translateLayer(-1, 2250, easing.linear, {"x", "-", 512})
          part.stage:translateLayer(20, 2250, easing.linear, {"x", "+", 512})
        end
      },
      {
        start_time=6000,
        label="gradual stage move left to right",
        action=function(part)
          part.stage:translateLayer(-1, 0, nil, {"x", "=", 0})
          part.stage:translateLayer(20, 0, nil, {"x", "=", 0})
        end
      },
    }
  }

  chapter_structure.flow["chapter_2_part_4"] = {
    name="chapter_2_part_4",
    -- next="chapter_2_interactive_choice_mural_color",
    next="chapter_2_part_5",
    type="scripted",
    script=loadPartScript("chapter_2_part_4"),
    music="chapter_2_scene_4",
    cleanup=true,
    additional_actions = {
      {
        start_time=0,
        label="move the stage down",
        action=function(part)
          part.stage:translateLayer(-1, 375 * 16, easing.inOutSine, {"y", "=", 256})
        end
      },
      {
        start_time=9000,
        label="move the stage back",
        action=function(part)
          part.stage:translateLayer(-1, 0, nil, {"y", "=", 0})
        end
      },
    }
  }

  paint_depths = {
    Mural_White=4,
    Mural_Black=3,
    Mural_Yellow=2,
    Mural_Orange=1,
    Mural_Purple=-1,
    Mural_Brown=-2,
    Mural_Red=-3,
    Mural_Blue=-4,
    Mural_Green=-5,
  }
  chapter_structure.flow["chapter_2_interactive_choice_mural_color"] = {
    name="chapter_2_interactive_choice_mural_color",
    next="chapter_2_interactive_spell_color",
    type="interactive_choice",
    intro="mural_color_choice",
    choiceCallback = function(something, choice_element, player)

      color = string.gsub(choice_element.name, "_Paint", "")

      mural_paint_name = "Mural_" .. color

      mural_paint_script_element = {
        intro = "outline_sketching",
        type = "picture",
        id = mural_paint_name .. "_1",
        y = 331.75,
        fixed_y = 331.75,
        x_scale = 1,
        start_time = 0,
        name = mural_paint_name,
        y_scale = 1,
        disappear_method = "pop",
        depth = paint_depths[mural_paint_name],
        x = 471.5,
        fixed_x = 471.5,
        squish_tilt = 0,
        squish_scale = 1,
        squish_period = 1700,
        disappear_time = -1,
      }
      -- player:perform(mural_paint_script_element)

      -- doctor the mural color script to remove the current color choice
      new_script = {}
      for i = 1, #player.script do
        script_element = player.script[i]

        -- remove all script_elements, because we're not doing cleanup
        if script_element.performance ~= nil then
          display.remove(script_element.performance)
          script_element.performance.isVisible = false
          script_element.performance = nil
        end

        if choice_element.name == script_element.name then
          -- skip this one
        else
          table.insert(new_script, script_element)
        end
      end
      chapter_structure.flow["chapter_2_interactive_choice_mural_color"].script = new_script

      chapter_structure.flow["chapter_2_interactive_spell_color"].word = color
      chapter_structure.flow["chapter_2_interactive_spell_color"].performance = mural_paint_script_element
      if color == "Red" then
        chapter_structure.flow["chapter_2_interactive_spell_color"].outro_highlights = nil
      elseif color == "Blue" then
        chapter_structure.flow["chapter_2_interactive_spell_color"].outro_highlights = {"b---", "-l--", "--ue"}
      elseif color == "Green" then
        chapter_structure.flow["chapter_2_interactive_spell_color"].outro_highlights = {"g----", "-r---", "--ee-", "----n"}
      elseif color == "Yellow" then
        chapter_structure.flow["chapter_2_interactive_spell_color"].outro_highlights = {"y-----", "-e----", "--ll--", "----ow"}
      elseif color == "Orange" then
        chapter_structure.flow["chapter_2_interactive_spell_color"].outro_highlights = {"o-----", "-r----", "--a---", "---n--", "----ge"}
      elseif color == "Purple" then
        chapter_structure.flow["chapter_2_interactive_spell_color"].outro_highlights = {"p-----", "-u----", "--r---", "---p--", "----le"}
      elseif color == "Brown" then
        chapter_structure.flow["chapter_2_interactive_spell_color"].outro_highlights = {"b----", "-r---", "--ow-", "----n"}
      elseif color == "Black" then
        chapter_structure.flow["chapter_2_interactive_spell_color"].outro_highlights = {"b----", "-l---", "--a--", "---ck"}
      elseif color == "White" then
        chapter_structure.flow["chapter_2_interactive_spell_color"].outro_highlights = {"wh---", "--i--", "---te"}
      end


      if #new_script == 0 then
        chapter_structure.flow["chapter_2_interactive_spell_color"].next = "chapter_2_part_5"
        chapter_structure.flow["chapter_2_interactive_spell_color"].cleanup = true
        -- maybe remove and re-add the paint beast here so he's in sync with the food beast.
        -- clara too.
      end

      player.mode = "choice_outro"
    end,
    script=loadPartScript("chapter_2_interactive_choice_mural_color"),
    cleanup=false,
  }
  chapter_structure.flow["chapter_2_interactive_spell_color"] = {
    name="chapter_2_interactive_spell_color",
    next="chapter_2_interactive_choice_mural_color",
    type="interactive_spelling",
    word="Red",
    touch_giggle=false,
    random_order=false,
    random_letters=false,
    intro_letter_beats = {0, 0.5, 1, 1.5},
    outro_sounds = {"ruh", "eh", "duh"},
    script=nil,
    cleanup=false,
    spellingCallback = function(something, player)
      chapter_structure.flow["chapter_2_interactive_spell_color"].performance.intro = "splash"
      player:perform(chapter_structure.flow["chapter_2_interactive_spell_color"].performance)
    end,
  }

  chapter_structure.flow["chapter_2_part_5"] = {
    name="chapter_2_part_5",
    next=nil,
    type="scripted",
    script=loadPartScript("chapter_2_part_5"),
    music="chapter_2_scene_5",
    additional_actions = {
      {
        start_time=6900,
        label="move the little boats",
        action=function(part)
          boat = part.stage:get("Little_White_Boat_Shadow_1")
          if boat ~= nil then
            x = boat.x
            animation.to(boat, {x = x + 40}, {time = 30000, tag="game"})
          end

          boat = part.stage:get("Little_White_Boat_Shadow_2")
          if boat ~= nil then
            x = boat.x
            animation.to(boat, {x = x + 50}, {time = 30000, tag="game"})
          end

          boat = part.stage:get("Little_White_Boat_Shadow_3")
          if boat ~= nil then
            x = boat.x
            animation.to(boat, {x = x - 40}, {time = 30000, tag="game"})
          end

          boat = part.stage:get("Little_White_Boat_Shadow_4")
          if boat ~= nil then
            x = boat.x
            animation.to(boat, {x = x + 60}, {time = 30000, tag="game"})
          end
        end
      },
    }
  }

  chapter_structure.flow["chapter_2_interactive_mandala"] = {
    name="chapter_2_interactive_mandala",
    next=nil,
    type="interactive_mandala",
    script=loadPartScript("chapter_2_interactive_mandala"),
  }
end

return setup_chapter_2