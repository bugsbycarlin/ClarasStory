
local animation = require("plugin.animation")
local composer = require("composer")
local json = require("json")
local lfs = require("lfs")

local picture_info = require("Source.pictures")
local sound_info = require("Source.sounds")

local sketch_sprites_class = require("Source.sketch_sprites")
local loader = require("Source.loader")

local scene = composer.newScene()

local sprite = {}

local mode = "loading"

local current_time = 0
local start_performance_time = 0
local stored_performance_time = 0
local total_performance_time = 0

local update_timer = nil

local load_start_time = 0

local title_text = nil
local credit_text = nil
local loading_text = nil

local memory_estimate = 0

local current_scene = nil

function scene:loadSceneScript(scene_name)
  local scene_file = system.pathForFile("Scenes/" .. scene_name .. ".json", system.ResourceDirectory)
  local file = io.open(scene_file, "r")
  local script_assets = {}
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

  return script_assets
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

  if (phase == "will") then
    -- Code here runs when the scene is still off screen (but is about to come on screen)
    
  elseif (phase == "did") then
    -- Code here runs when the scene is entirely on screen

    if self.initialized == false then
      self.initialized = true

      self.tableOfContentsGroup = display.newGroup()
      self.sceneGroup:insert(self.tableOfContentsGroup)

      self.performanceAssetGroup = display.newGroup()
      self.sceneGroup:insert(self.performanceAssetGroup)
      self.performanceAssetGroup.isVisible = false

      composer.removeHidden()

      display.setDefault("background", 1, 1, 1)

      composer.setVariable("chapter", self)

      -- self.title_text = {}
      -- self.credits_text = {}

      -- self.title_text[1] = "Chapter 1 - Getting Started"
      -- self.credits_text[1] = "Programming, Story, Art, Music\nMattsby"

      -- self.title_text[2] = "Chapter 2 - Town"
      -- self.credits_text[2] = "Programming, Story, Art, Music\nMattsby"

      self:setupTableOfContents()
    end

    self:displayTableOfContents()
  end
end

function scene:setupTableOfContents()
  self.tableOfContentsBackground = display.newImageRect(self.tableOfContentsGroup, "Art/table_of_contents_background.png", 1024, 768)
  self.tableOfContentsBackground.x = display.contentCenterX
  self.tableOfContentsBackground.y = display.contentCenterY

  chapter_values = {1, 2, "mandala"} --"free_play"

  for i = 1, 3 do
    local chapter_button = display.newImageRect(self.tableOfContentsGroup, "Art/chapter_" .. chapter_values[i] .. "_button.png", 108, 127)
    chapter_button.x = display.contentCenterX + (i - 3) * 180
    chapter_button.y = 222
    chapter_button:addEventListener("tap", function(event)
      self:gotoChapter(chapter_values[i])
    end)
  end
    -- self.skip_scene_button.alpha = 0.3
    -- self.skip_scene_button.last_skip = system.getTimer() - 1
    -- self.skip_scene_button:addEventListener("tap", function(event)
    --   if (system.getTimer() - self.skip_scene_button.last_skip > 1) then
end

function scene:displayTableOfContents()
  print("SHOWING TOC")
  self.tableOfContentsGroup.isVisible = true
  self.performanceAssetGroup.isVisible = false
end

function scene:gotoChapter(chapter_value)
  self.tableOfContentsGroup.isVisible = false
  self.performanceAssetGroup.isVisible = true

  self.chapter_number = chapter_value

  composer.setVariable("chapter_number", self.chapter_number)

  self.flow = {}

  self.sketch_sprites = sketch_sprites_class:create()
  self.loader = loader:create()

  composer.setVariable("sketch_sprites", self.sketch_sprites)

  self:setupDisplay()
  self:setupSceneStructure()

  composer.setVariable("chapter_flow", self.flow)

  -- when loading finishes, it will call self:startChapter()
  self:setupLoading()

  intro_sound = audio.loadSound("Sound/chapter_intro.wav")
  audio.play(intro_sound)
end

function scene:setupDisplay()
  while self.performanceAssetGroup.numChildren > 0 do
    local child = self.performanceAssetGroup[1]
    if child then child:removeSelf() end
  end

  background = display.newImageRect(self.performanceAssetGroup, "Art/chapter_" .. self.chapter_number .. "_loading_background.png", 1024, 768)
  background.x = display.contentCenterX
  background.y = display.contentCenterY

  -- if self.chapter_number == 1 or self.chapter_number == 2 then
  --   title_text = display.newText(self.performanceAssetGroup, self.title_text[self.chapter_number], display.contentCenterX, display.contentCenterY - 250, "Fonts/MouseMemoirs.ttf", 80)
  --   title_text:setTextColor(0.0, 0.0, 0.0)

  --   credits_text = display.newText({
  --   	parent = self.performanceAssetGroup,
  --       text = self.credits_text[self.chapter_number],
  --       x = display.contentCenterX,
  --       y = display.contentCenterY + 40,
  --       width = 400,
  --       height = 200,
  --       font = "Fonts/MouseMemoirs.ttf",
  --       fontSize = 40,
  --       align = "center"
  --   })
  --   credits_text:setTextColor(0.0, 0.0, 0.0)
  -- end

  loading_text = display.newText(self.performanceAssetGroup, "", display.contentCenterX, display.contentCenterY + 250, "Fonts/BebasNeue.ttf", 30)
  loading_text:setTextColor(0.0, 0.0, 0.0)
end

function scene:setupLoading()

  -- just pre-load the stuff from scene 1. other stuff will be loaded in the background as we go along.
  load_items = {}
  local scene = self.flow[self.first_scene]
  if scene.word ~= nil then
    load_items[scene.word] = 1
  end

  if scene.script ~= nil then
    for asset_name, asset_value in pairs(scene.script) do
      load_items[asset_value.name] = 1
    end
  end

  -- gotta add standard stuff like letters and stars; these are always loads
  partialLoadObjects = {}
  for picture, info in pairs(picture_info) do
    if load_items[picture] == 1 or info.always_load == true then
      table.insert(partialLoadObjects, picture)
    end
  end

  function updateLoadDisplay(percent)
    loading_text.text = "Spelling " .. percent .. "%"
  end

  self.loader:backgroundLoad(
    sprite,
    picture_info,
    partialLoadObjects,
    nil,
    0,
    function(percent) updateLoadDisplay(percent) end,
    function() self:startChapter() end)
end

function scene:setupSceneStructure()
  if self.chapter_number == 1 then
    scene:chapter_1_Structure()
  elseif self.chapter_number == 2 then
    scene:chapter_2_Structure()
  elseif self.chapter_number == "mandala" then
    scene:chapter_mandala_Structure()
  end
end

function scene:chapter_mandala_Structure()
  self.first_scene = "chapter_2_interactive_mandala"

  local mpb = 375
  composer.setVariable("bpm", 160)
  composer.setVariable("mpb", mpb)
  composer.setVariable("spelling_outro_mpb", mpb)
  composer.setVariable("time_sig", 4)

  self.flow = {}

  self.flow["chapter_2_interactive_mandala"] = {
    name="chapter_2_interactive_mandala",
    next=nil,
    type="interactive_mandala",
    script=self:loadSceneScript("chapter_2_interactive_mandala"),
  }
end

function scene:chapter_2_Structure()
  self.first_scene = "chapter_2_scene_1"
  -- self.first_scene = "chapter_2_interactive_mandala"

  local mpb = 375
  composer.setVariable("bpm", 160)
  composer.setVariable("mpb", mpb)
  composer.setVariable("spelling_outro_mpb", mpb)
  composer.setVariable("time_sig", 4)

  setChoiceObject = function(script_name, choice_id, choice_value)
    asset_list = self.flow[script_name].script
    for i = 1, #asset_list do
      asset = asset_list[i]
      if asset.id == choice_id then
        asset.choice_value = choice_value
      end
    end
  end

  self.flow = {}
  local flow = self.flow
  self.flow["chapter_2_scene_1"] = {
    name="chapter_2_scene_1",
    next="chapter_2_interactive_choice_vehicle",
    type="scripted",
    cleanup=false,
    script=self:loadSceneScript("chapter_2_scene_1"),
  }
  self.flow["chapter_2_interactive_choice_vehicle"] = {
    name="chapter_2_interactive_choice_vehicle",
    next=nil,
    type="interactive_choice",
    intro="vehicle_choice",
    cleanup=false,
    choiceCallback = function(something, choice_asset, player)

      for i = 1, #player.script_assets do
        other_asset = player.script_assets[i]
        if other_asset.performance ~= nil and other_asset.performance.id ~= choice_asset.id then
          animation.to(other_asset.performance, {alpha=0}, {time=player.mpb * 0.75, easing=easing.outExp})
        end
      end

      animation.to(choice_asset.performance, {fixed_x = display.contentCenterX, fixed_y = display.contentCenterY - 100}, {time=player.mpb, easing=easing.outExp})

      player:poopStars(choice_asset.performance.fixed_x, choice_asset.performance.fixed_y, 3 + math.random(3))

      local choice_value = choice_asset.name

      if string.find(choice_value, "Car") then 
        player.next_scene = "chapter_2_interactive_car"
      elseif string.find(choice_value, "Truck") then
        player.next_scene = "chapter_2_interactive_truck"
      elseif string.find(choice_value, "Bus") then
        player.next_scene = "chapter_2_interactive_bus"
      elseif string.find(choice_value, "Taxi") then
        player.next_scene = "chapter_2_interactive_taxi"
        setChoiceObject("chapter_2_scene_2", "Vehicle_Choice_1", "Taxi")
      end

      timer.performWithDelay(player.mpb, function() 
        player.mode = "choice_outro"
      end)
    end,
    script=self:loadSceneScript("chapter_2_interactive_choice_vehicle"),
  }

  self.flow["chapter_2_interactive_taxi"] = {
    name="chapter_2_interactive_taxi",
    next="chapter_2_scene_2",
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

  self.flow["chapter_2_interactive_bus"] = {
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
  self.flow["chapter_2_interactive_choice_bus_color"] = {
    name="chapter_2_interactive_choice_bus_color",
    next="chapter_2_scene_2",
    type="interactive_choice",
    intro="bus_color_choice",
    choiceCallback = function(something, choice_asset, player)

      color = string.gsub(choice_asset.name, "_Paint", "")

      for i = 1, #player.script_assets do
        asset = player.script_assets[i]
        if asset.performance ~= nil and string.find(asset.name, "Paint") then
          asset.performance.isVisible = false
        elseif asset.performance ~= nil and string.find(asset.name, "Bus") then
          display.remove(asset.performance)
          asset.performance = nil
          asset.name = "Bus_" .. color
          asset.intro = "poof"
          player:perform(asset)
        end
      end

      setChoiceObject("chapter_2_scene_2", "Vehicle_Choice_1", "Bus_" .. color)

      for i = 1, #self.flow["chapter_2_scene_2"].script do
        asset = self.flow["chapter_2_scene_2"].script[i]

        if asset.id == "Clara_v2_13" then
          asset.fixed_x = asset.fixed_x - 10
          asset.x = asset.x - 10
          asset.fixed_y = asset.fixed_y - 13
          asset.y = asset.y - 13
        end
      end

      timer.performWithDelay(player.mpb, function() 
        player.mode = "choice_outro"
      end)
    end,
    script=self:loadSceneScript("chapter_2_interactive_choice_bus_color"),
  }

  self.flow["chapter_2_interactive_car"] = {
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
  self.flow["chapter_2_interactive_choice_car_color"] = {
    name="chapter_2_interactive_choice_car_color",
    next="chapter_2_scene_2",
    type="interactive_choice",
    intro="car_color_choice",
    choiceCallback = function(something, choice_asset, player)

      color = string.gsub(choice_asset.name, "_Paint", "")

      for i = 1, #player.script_assets do
        asset = player.script_assets[i]
        if asset.performance ~= nil and string.find(asset.name, "Paint") then
          asset.performance.isVisible = false
        elseif asset.performance ~= nil and string.find(asset.name, "Car") then
          display.remove(asset.performance)
          asset.performance = nil
          asset.name = "Car_" .. color
          asset.intro = "poof"
          player:perform(asset)
        end
      end

      setChoiceObject("chapter_2_scene_2", "Vehicle_Choice_1", "Car_" .. color)

      timer.performWithDelay(player.mpb, function() 
        player.mode = "choice_outro"
      end)
    end,
    script=self:loadSceneScript("chapter_2_interactive_choice_car_color"),
  }

  self.flow["chapter_2_interactive_truck"] = {
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
  self.flow["chapter_2_interactive_choice_truck_color"] = {
    name="chapter_2_interactive_choice_truck_color",
    next="chapter_2_scene_2",
    type="interactive_choice",
    intro="truck_color_choice",
    choiceCallback = function(something, choice_asset, player)

      color = string.gsub(choice_asset.name, "_Paint", "")

      for i = 1, #player.script_assets do
        asset = player.script_assets[i]
        if asset.performance ~= nil and string.find(asset.name, "Paint") then
          asset.performance.isVisible = false
        elseif asset.performance ~= nil and string.find(asset.name, "Truck") then
          display.remove(asset.performance)
          asset.performance = nil
          asset.name = "Truck_" .. color
          asset.intro = "poof"
          player:perform(asset)
        end
      end

      setChoiceObject("chapter_2_scene_2", "Vehicle_Choice_1", "Truck_" .. color)

      for i = 1, #self.flow["chapter_2_scene_2"].script do
        asset = self.flow["chapter_2_scene_2"].script[i]

        if asset.id == "Clara_v2_13" then
          asset.fixed_x = asset.fixed_x + 30
          asset.x = asset.x + 30
        end
      end

      timer.performWithDelay(player.mpb, function() 
        player.mode = "choice_outro"
      end)
    end,
    script=self:loadSceneScript("chapter_2_interactive_choice_truck_color"),
  }

  self.flow["chapter_2_scene_2"] = {
    name="chapter_2_scene_2",
    next="chapter_2_interactive_bike",
    type="scripted",
    cleanup=false,
    script=self:loadSceneScript("chapter_2_scene_2"),
  }


  self.flow["chapter_2_interactive_bike"] = {
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
  self.flow["chapter_2_interactive_choice_bike_color"] = {
    name="chapter_2_interactive_choice_bike_color",
    next="chapter_2_scene_3",
    type="interactive_choice",
    intro="bike_color_choice",
    choiceCallback = function(something, choice_asset, player)

      color = string.gsub(choice_asset.name, "_Paint", "")

      for i = 1, #player.script_assets do
        asset = player.script_assets[i]
        if asset.performance ~= nil and string.find(asset.name, "Paint") then
          asset.performance.isVisible = false
        elseif asset.performance ~= nil and string.find(asset.name, "Bike") then
          display.remove(asset.performance)
          asset.performance = nil
          asset.name = "Bike_" .. color
          asset.intro = "poof"
          player:perform(asset)
        end
      end

      setChoiceObject("chapter_2_scene_3", "Bike_Choice_1", "Bike_" .. color)
      setChoiceObject("chapter_2_scene_4", "Bike_Choice_1", "Bike_" .. color)

      timer.performWithDelay(player.mpb, function() 
        player.mode = "choice_outro"
      end)
    end,
    script=self:loadSceneScript("chapter_2_interactive_choice_bike_color"),
  }


  self.flow["chapter_2_scene_3"] = {
    name="chapter_2_scene_3",
    next="chapter_2_scene_4",
    type="scripted",
    script=self:loadSceneScript("chapter_2_scene_3"),
  }

  self.flow["chapter_2_scene_4"] = {
    name="chapter_2_scene_4",
    next="chapter_2_interactive_choice_mural_color",
    type="scripted",
    script=self:loadSceneScript("chapter_2_scene_4"),
    cleanup=false,
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
  self.flow["chapter_2_interactive_choice_mural_color"] = {
    name="chapter_2_interactive_choice_mural_color",
    next="chapter_2_interactive_spell_color",
    type="interactive_choice",
    intro="mural_color_choice",
    choiceCallback = function(something, choice_asset, player)

      color = string.gsub(choice_asset.name, "_Paint", "")

      mural_paint_name = "Mural_" .. color

      mural_paint_asset = {
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
      -- player:perform(mural_paint_asset)

      -- doctor the mural color script to remove the current color choice
      new_assets = {}
      for i = 1, #player.script_assets do
        asset = player.script_assets[i]

        -- remove all assets, because we're not doing cleanup
        if asset.performance ~= nil then
          display.remove(asset.performance)
          asset.performance.isVisible = false
          asset.performance = nil
        end

        if choice_asset.name == asset.name then
          -- skip this one
        else
          table.insert(new_assets, asset)
        end
      end
      self.flow["chapter_2_interactive_choice_mural_color"].script = new_assets

      self.flow["chapter_2_interactive_spell_color"].word = color
      self.flow["chapter_2_interactive_spell_color"].performance = mural_paint_asset
      if color == "Red" then
        self.flow["chapter_2_interactive_spell_color"].outro_highlights = nil
      elseif color == "Blue" then
        self.flow["chapter_2_interactive_spell_color"].outro_highlights = {"b---", "-l--", "--ue"}
      elseif color == "Green" then
        self.flow["chapter_2_interactive_spell_color"].outro_highlights = {"g----", "-r---", "--ee-", "----n"}
      elseif color == "Yellow" then
        self.flow["chapter_2_interactive_spell_color"].outro_highlights = {"y-----", "-e----", "--ll--", "----ow"}
      elseif color == "Orange" then
        self.flow["chapter_2_interactive_spell_color"].outro_highlights = {"o-----", "-r----", "--a---", "---n--", "----ge"}
      elseif color == "Purple" then
        self.flow["chapter_2_interactive_spell_color"].outro_highlights = {"p-----", "-u----", "--r---", "---p--", "----le"}
      elseif color == "Brown" then
        self.flow["chapter_2_interactive_spell_color"].outro_highlights = {"b----", "-r---", "--ow-", "----n"}
      elseif color == "Black" then
        self.flow["chapter_2_interactive_spell_color"].outro_highlights = {"b----", "-l---", "--a--", "---ck"}
      elseif color == "White" then
        self.flow["chapter_2_interactive_spell_color"].outro_highlights = {"wh---", "--i--", "---te"}
      end


      if #new_assets == 0 then
        self.flow["chapter_2_interactive_spell_color"].next = "chapter_2_scene_5"
        self.flow["chapter_2_interactive_spell_color"].cleanup = true
        -- maybe remove and re-add the paint beast here so he's in sync with the food beast.
        -- clara too.
      end

      player.mode = "choice_outro"
    end,
    script=self:loadSceneScript("chapter_2_interactive_choice_mural_color"),
    cleanup=false,
  }
  self.flow["chapter_2_interactive_spell_color"] = {
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
      self.flow["chapter_2_interactive_spell_color"].performance.intro = "splash"
      player:perform(self.flow["chapter_2_interactive_spell_color"].performance)
    end,
  }

  self.flow["chapter_2_scene_5"] = {
    name="chapter_2_scene_5",
    next="chapter_2_interactive_mandala",
    type="scripted",
    script=self:loadSceneScript("chapter_2_scene_5"),
  }

  self.flow["chapter_2_interactive_mandala"] = {
    name="chapter_2_interactive_mandala",
    next=nil,
    type="interactive_mandala",
    script=self:loadSceneScript("chapter_2_interactive_mandala"),
  }

end

function scene:chapter_1_Structure()
  -- self.first_scene = "chapter_1_scene_1"
  self.first_scene = "chapter_1_interactive_girl"

  composer.setVariable("bpm", 110)
  composer.setVariable("mpb", 545.4545454545)
  composer.setVariable("spelling_outro_mpb", 545.4545454545 / 2)
  composer.setVariable("time_sig", 4)

  self.flow = {}
  self.flow["chapter_1_scene_1"] = {
    name="chapter_1_scene_1",
    next="chapter_1_interactive_girl",
    type="scripted",
    cleanup=false,
    script_file="chapter_1_scene_1.json",
    script=self:loadSceneScript("chapter_1_scene_1"),
    duration=28363.636,
  }
  self.flow["chapter_1_interactive_girl"] = {
    name="chapter_1_interactive_girl",
    next="chapter_1_interactive_bird",
    type="interactive_spelling",
    word="Girl",
    performance = {
      name = "Girl",
      fixed_x = 542,
      fixed_y = 375,
      intro = "outline_sketching",
      depth = 18,
    },
    script=nil,
  }
  self.flow["chapter_1_interactive_bird"] = {
    name="chapter_1_interactive_bird",
    next="chapter_1_scene_2",
    type="interactive_spelling",
    word="Bird",
    performance = {
      name = "Bird",
      intro = "outline_sketching",
      depth = 18,
    },
    script=nil,
  }
  self.flow["chapter_1_scene_2"] = {
    name="chapter_1_scene_2",
    next="chapter_1_interactive_mom",
    type="scripted",
    script=self:loadSceneScript("chapter_1_scene_2"),
    duration=0,
    cleanup=false,
  }
  self.flow["chapter_1_interactive_mom"] = {
    name="chapter_1_interactive_mom",
    next="chapter_1_interactive_dad",
    type="interactive_spelling",
    word="Mom",
    performance = {
      name = "Mom",
      fixed_x = 299.75,
      fixed_y = 533.25,
      intro = "outline_sketching",
      depth = 18,
    },
    script=self:loadSceneScript("chapter_1_mom_interactive"),
    cleanup=false,
    -- here it might be fun to use a stage spotlight
  }
  self.flow["chapter_1_interactive_dad"] = {
    name="chapter_1_interactive_dad",
    next="chapter_1_scene_3",
    type="interactive_spelling",
    word="Dad",
    performance = {
      name = "Dad",
      fixed_x = 473,
      fixed_y = 523.5,
      intro = "outline_sketching",
      depth = 19,
    },
    script=self:loadSceneScript("chapter_1_dad_interactive"),
    -- here it might be fun to use a stage spotlight
  }
  self.flow["chapter_1_scene_3"] = {
    name="chapter_1_scene_3",
    next="chapter_1_interactive_wand",
    type="scripted",
    script_file="chapter_1_scene_3.json",
    script=self:loadSceneScript("chapter_1_scene_3"),
    duration=0,
  }
  self.flow["chapter_1_interactive_wand"] = {
    name="chapter_1_interactive_wand",
    next="chapter_1_scene_4",
    type="interactive_spelling",
    word="Wand",
    performance = {
      name = "Wand",
      intro = "outline_sketching",
      depth = 18,
    },
    script=nil,
    -- here it might be fun to use a stage spotlight
  }
  self.flow["chapter_1_scene_4"] = {
    name="chapter_1_scene_4",
    next="chapter_1_interactive_pig",
    type="scripted",
    script_file="chapter_1_scene_4.json",
    script=self:loadSceneScript("chapter_1_scene_4"),
    duration=0,
    cleanup=false,
  }
  self.flow["chapter_1_interactive_pig"] = {
    name="chapter_1_interactive_pig",
    next="chapter_1_interactive_cow",
    type="interactive_spelling",
    word="Pig",
    performance = {
      name = "Pig",
      fixed_x = 398,
      fixed_y = 400,
      intro = "sketch",
      depth = 18,
    },
    script=nil,
    cleanup=false,
    -- here it might be fun to use a stage spotlight
  }
  self.flow["chapter_1_interactive_cow"] = {
    name="chapter_1_interactive_cow",
    next="chapter_1_scene_5",
    type="interactive_spelling",
    word="Cow",
    performance = {
      name = "Cow",
      fixed_x = 686,
      fixed_y = 410,
      intro = "sketch",
      depth = 18,
    },
    script=nil,
  }
  self.flow["chapter_1_scene_5"] = {
    name="chapter_1_scene_5",
    next="chapter_1_interactive_coin",
    type="scripted",
    script_file="chapter_1_scene_5.json",
    script=self:loadSceneScript("chapter_1_scene_5"),
    duration=0,
  }
  self.flow["chapter_1_interactive_coin"] = {
    name="chapter_1_interactive_coin",
    next="chapter_1_scene_6",
    type="interactive_spelling",
    word="Coin",
    outro_highlights = {"c---", "-oi-", "---n"},
    script=nil,
  }
  self.flow["chapter_1_scene_6"] = {
    name="chapter_1_scene_6",
    next=nil,
    type="scripted",
    script_file="chapter_1_scene_6.json",
    script=self:loadSceneScript("chapter_1_scene_6"),
    duration=0,
    cleanup=false,
  }


  self.flow["chapter_1_beast_apple"] = {
    name="chapter_1_beast_apple",
    next="chapter_1_interactive_apple",
    type="scripted",
    script=self:loadSceneScript("chapter_1_beast_apple"),
    cleanup=false,
    duration=0,
  }
  self.flow["chapter_1_interactive_apple"] = {
    name="chapter_1_interactive_apple",
    next=nil,
    type="interactive_spelling",
    word="Apple",
    outro_highlights = {"a----", "-pp--", "---le"},
    cleanup=false,
  }
  self.flow["chapter_1_beast_banana"] = {
    name="chapter_1_beast_banana",
    next="chapter_1_interactive_banana",
    type="scripted",
    cleanup=false,
    script=self:loadSceneScript("chapter_1_beast_banana"),
    duration=0,
  }
  self.flow["chapter_1_interactive_banana"] = {
    name="chapter_1_interactive_banana",
    next=nil,
    type="interactive_spelling",
    word="Banana",
    cleanup=false,
  }
  self.flow["chapter_1_beast_lime"] = {
    name="chapter_1_beast_lime",
    next="chapter_1_interactive_lime",
    type="scripted",
    cleanup=false,
    script=self:loadSceneScript("chapter_1_beast_lime"),
    duration=0,
  }
  self.flow["chapter_1_interactive_lime"] = {
    name="chapter_1_interactive_lime",
    next=nil,
    type="interactive_spelling",
    word="Lime",
    outro_highlights = {"l---", "-i--", "--me"},
    cleanup=false,
  }
  self.flow["chapter_1_beast_orange"] = {
    name="chapter_1_beast_orange",
    next="chapter_1_interactive_orange",
    type="scripted",
    script=self:loadSceneScript("chapter_1_beast_orange"),
    cleanup=false,
    duration=0,
  }
  self.flow["chapter_1_interactive_orange"] = {
    name="chapter_1_interactive_orange",
    next=nil,
    type="interactive_spelling",
    word="Orange",
    outro_highlights = {"o-----", "-r----", "--a---", "---n--", "----ge"},
    cleanup=false,
  }
  self.flow["chapter_1_beast_pear"] = {
    name="chapter_1_beast_pear",
    next="chapter_1_interactive_pear",
    type="scripted",
    cleanup=false,
    script=self:loadSceneScript("chapter_1_beast_pear"),
    duration=0,
  }
  self.flow["chapter_1_interactive_pear"] = {
    name="chapter_1_interactive_pear",
    next=nil,
    type="interactive_spelling",
    word="Pear",
    outro_highlights = {"p---", "-ea-", "--r"},
    cleanup=false,
  }
  self.flow["chapter_1_beast_plum"] = {
    name="chapter_1_beast_plum",
    next="chapter_1_interactive_plum",
    type="scripted",
    cleanup=false,
    script=self:loadSceneScript("chapter_1_beast_plum"),
    duration=0,
  }
  self.flow["chapter_1_interactive_plum"] = {
    name="chapter_1_interactive_plum",
    next=nil,
    type="interactive_spelling",
    word="Plum",
    cleanup=false,
  }
  self.flow["chapter_1_scene_7"] = {
    name="chapter_1_scene_7",
    next=nil,
    type="scripted",
    script=self:loadSceneScript("chapter_1_scene_7"),
    duration=0,
  }

  -- make a random chain of fruits for the fruit beast before moving to Scene 7
  fruits = {
    "apple",
    "banana",
    "lime",
    "orange",
    "pear",
    "plum",
  }
  for i = #fruits, 2, -1 do
    local j = math.random(i)
    fruits[i], fruits[j] = fruits[j], fruits[i]
  end


  self.flow["chapter_1_scene_6"].next = "chapter_1_beast_" .. fruits[1]
  self.flow["chapter_1_interactive_" .. fruits[1]].next = "chapter_1_beast_" .. fruits[2]
  self.flow["chapter_1_interactive_" .. fruits[2]].next = "chapter_1_beast_" .. fruits[3]
  self.flow["chapter_1_interactive_" .. fruits[3]].next = "chapter_1_scene_7"
  self.flow["chapter_1_interactive_" .. fruits[3]].cleanup = true

  -- chomp_asset = {
  --   name="Chomp",
  --   id="Chomp_555",
  --   type="sound",
  --   start_time=0,
  --   timer=nil,
  --   performance=nil,
  --   x=display.contentCenterX,
  --   y=display.contentCenterY
  -- }
  -- table.insert(self.flow["chapter_1_beast_" .. fruits[2]].script, chomp_asset)
  -- table.insert(self.flow["chapter_1_beast_" .. fruits[3]].script, chomp_asset)
  -- table.insert(self.flow["chapter_1_scene_7"].script, chomp_asset)
end



function scene:startChapter()
  -- remove loading text
  loading_text:removeSelf()

  composer.setVariable("sprite", sprite)

  -- self:displayTableOfContents()

  self:gotoScene(self.first_scene, {effect = "fade", time = 500})
end

function scene:gotoScene(new_scene_name, fade_options)
  if new_scene_name ~= "end" and self.flow[new_scene_name] ~= nil then
    
    new_scene = self.flow[new_scene_name]
    composer.setVariable("scene_name", new_scene.name)
    composer.setVariable("settings", new_scene)
    
    if new_scene.script ~= nil then
      composer.setVariable("script_assets", new_scene.script)
    else
      composer.setVariable("script_assets", "")
    end
    
    if new_scene.next ~= nil then
      composer.setVariable("next_scene", new_scene.next)
    else
      composer.setVariable("next_scene", "end")
    end

    composer.gotoScene("Source.scripted_player", fade_options)
  else
    composer.gotoScene("Source.temporary_end", fade_options)
  end
end

-- function scene:finish()
--   -- unload many things!
--   self:displayTableOfContents()
--   composer.gotoScene("Source.chapter")
--   --composer.gotoScene("Source.temporary_end")
-- end

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
  -- Runtime:removeEventListener("key")
  Runtime:removeEventListener("touch")    

end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)
-- -----------------------------------------------------------------------------------

scene.initialized = false

return scene
