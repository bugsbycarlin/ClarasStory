

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
  print(scene_name)
  print(scene_file)
  if file then
    print(file)
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

  self.performanceAssetGroup = display.newGroup()
  self.sceneGroup:insert(self.performanceAssetGroup)

  if (phase == "will") then
    -- Code here runs when the scene is still off screen (but is about to come on screen)
    
  elseif (phase == "did") then
    -- Code here runs when the scene is entirely on screen

    display.setDefault("background", 1, 1, 1)

    composer.setVariable("chapter", self)

    self.chapter = 1

    self.flow = {}

    self.title_text = {}
    self.credits_text = {}

    self.title_text[1] = "Chapter 1 - Getting Started"
    self.credits_text[1] = "Programming, Story, Art, Music\nMattsby"

    self.title_text[2] = "Chapter 2 - Town"
    self.credits_text[2] = "Programming, Story, Art, Music\nMattsby"

    self.sketch_sprites = sketch_sprites_class:create()
    self.loader = loader:create()

    composer.setVariable("sketch_sprites", self.sketch_sprites)

    self:setupDisplay()
    self:setupSceneStructure()

    composer.setVariable("chapter_flow", self.flow)

    -- when loading finishes, it will call self:startGame()
    self:setupLoading()

    intro_sound = audio.loadSound("Sound/Chapter_Intro.wav")
    audio.play(intro_sound)
  end
end

function scene:setupDisplay()
  title_text = display.newText(self.sceneGroup, self.title_text[self.chapter], display.contentCenterX, display.contentCenterY - 250, "Fonts/MouseMemoirs.ttf", 80)
  title_text:setTextColor(0.0, 0.0, 0.0)

  credits_text = display.newText({
  	parent = self.sceneGroup,
      text = self.credits_text[self.chapter],
      x = display.contentCenterX,
      y = display.contentCenterY + 40,
      width = 400,
      height = 200,
      font = "Fonts/MouseMemoirs.ttf",
      fontSize = 40,
      align = "center"
  })
  credits_text:setTextColor(0.0, 0.0, 0.0)

  loading_text = display.newText(self.sceneGroup, "", display.contentCenterX, display.contentCenterY + 250, "Fonts/MouseMemoirs.ttf", 40)
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
    function() self:startGame() end)
end

function scene:setupSceneStructure()
  if self.chapter == 1 then
    scene:chapter_1_Structure()
  elseif self.chapter == 2 then
    scene:chapter_2_Structure()
  end
end

function scene:chapter_2_Structure()
  self.first_scene = "Chapter_2_Scene_1"

  self.flow = {}
  self.flow["Chapter_2_Scene_1"] = {
    name="Chapter_2_Scene_1",
    next=nil,
    type="scripted",
    script=self:loadSceneScript("Chapter_2_Scene_1"),
  }
end

function scene:chapter_1_Structure()
  self.first_scene = "Chapter_1_Scene_1"
  -- self.first_scene = "Chapter_1_Interactive_Girl"

  self.flow = {}
  self.flow["Chapter_1_Scene_1"] = {
    name="Chapter_1_Scene_1",
    next="Chapter_1_Interactive_Girl",
    type="scripted",
    script_file="Chapter_1_Scene_1.json",
    script=self:loadSceneScript("chapter_1_scene_1"),
    duration=28363.636,
  }
  self.flow["Chapter_1_Interactive_Girl"] = {
    name="Chapter_1_Interactive_Girl",
    next="Chapter_1_Interactive_Bird",
    type="interactive_spelling",
    word="Girl",
    random_order=false,
    random_letters=false,
    bpm=110,
    mpb=545.4545454545,
    object_x = 542,
    object_y = 375,
    intro_letter_beats = {0, 0.5, 1, 1.5},
    outro_sounds = {"guh", "ih", "ruh", "luh"},
    -- outro_letter_beats = {1, 2, 3, 4},
    -- outro_sound_beats = {5, 6, 7, 8},
    -- outro_word_beat = 20,
    time_sig=4,
    script=nil,
  }
  self.flow["Chapter_1_Interactive_Bird"] = {
    name="Chapter_1_Interactive_Bird",
    next="Chapter_1_Scene_2",
    type="interactive_spelling",
    word="Bird",
    random_order=false,
    random_letters=false,
    bpm=110,
    mpb=545.4545454545,
    intro_letter_beats = {0, 0.5, 1, 1.5},
    outro_sounds = {"buh", "ih", "ruh", "duh"},
    -- outro_letter_beats = {4, 6, 8, 10},
    -- outro_sound_beats = {12, 14, 16, 18},
    -- outro_word_beat = 20,
    time_sig=4,
    script=nil,
  }
  self.flow["Chapter_1_Scene_2"] = {
    name="Chapter_1_Scene_2",
    next="Chapter_1_Interactive_Mom",
    type="scripted",
    script=self:loadSceneScript("chapter_1_scene_2"),
    duration=0,
    cleanup=false,
  }
  self.flow["Chapter_1_Interactive_Mom"] = {
    name="Chapter_1_Interactive_Mom",
    next="Chapter_1_Interactive_Dad",
    type="interactive_spelling",
    word="Mom",
    random_order=false,
    random_letters=false,
    bpm=110,
    mpb=545.4545454545,
    object_x = 299.75,
    object_y = 533.25,
    intro_letter_beats = {0, 0.5, 1},
    outro_sounds = {"muh", "oah", "muh",},
    -- outro_letter_beats = {4, 6, 8},
    -- outro_sound_beats = {12, 14, 16},
    -- outro_word_beat = 18,
    time_sig=4,
    script=self:loadSceneScript("chapter_1_mom_interactive"),
    cleanup=false,
    -- here it might be fun to use a stage spotlight
  }
  self.flow["Chapter_1_Interactive_Dad"] = {
    name="Chapter_1_Interactive_Dad",
    next="Chapter_1_Scene_3",
    type="interactive_spelling",
    word="Dad",
    random_order=false,
    random_letters=false,
    bpm=110,
    mpb=545.4545454545,
    object_x = 473,
    object_y = 523.5,
    intro_letter_beats = {0, 0.5, 1},
    outro_sounds = {"duh", "ah", "duh",},
    -- outro_letter_beats = {4, 6, 8},
    -- outro_sound_beats = {12, 14, 16},
    -- outro_word_beat = 18,
    time_sig=4,
    script=self:loadSceneScript("chapter_1_dad_interactive"),
    -- here it might be fun to use a stage spotlight
  }
  self.flow["Chapter_1_Scene_3"] = {
    name="Chapter_1_Scene_3",
    next="Chapter_1_Interactive_Wand",
    type="scripted",
    script_file="Chapter_1_Scene_3.json",
    script=self:loadSceneScript("chapter_1_scene_3"),
    duration=0,
  }
  self.flow["Chapter_1_Interactive_Wand"] = {
    name="Chapter_1_Interactive_Wand",
    next="Chapter_1_Scene_4",
    type="interactive_spelling",
    word="Wand",
    random_order=false,
    random_letters=false,
    bpm=110,
    mpb=545.4545454545,
    intro_letter_beats = {0, 0.5, 1, 1.5},
    outro_sounds = {"wuh", "ahh", "nuh", "duh"},
    -- intro_letter_beats = {8, 10, 12, 14},
    -- outro_letter_beats = {4, 6, 8, 10},
    -- outro_sound_beats = {12, 14, 16, 18},
    -- outro_word_beat = 20,
    time_sig=4,
    script=nil,
    -- here it might be fun to use a stage spotlight
  }
  self.flow["Chapter_1_Scene_4"] = {
    name="Chapter_1_Scene_4",
    next="Chapter_1_Interactive_Pig",
    type="scripted",
    script_file="Chapter_1_Scene_4.json",
    script=self:loadSceneScript("chapter_1_scene_4"),
    duration=0,
    cleanup=false,
  }
  self.flow["Chapter_1_Interactive_Pig"] = {
    name="Chapter_1_Interactive_Pig",
    next="Chapter_1_Interactive_Cow",
    type="interactive_spelling",
    word="Pig",
    random_order=false,
    random_letters=false,
    bpm=110,
    mpb=545.4545454545,
    object_x = 398,
    object_y = 400,
    -- intro_letter_beats = {12, 14, 16},
    -- outro_letter_beats = {4, 6, 8},
    -- outro_sound_beats = {12, 14, 16},
    -- outro_word_beat = 18,
    intro_letter_beats = {0, 0.5, 1},
    outro_sounds = {"puh", "ih", "guh"},
    time_sig=4,
    script=nil,
    cleanup=false,
    -- here it might be fun to use a stage spotlight
  }
  self.flow["Chapter_1_Interactive_Cow"] = {
    name="Chapter_1_Interactive_Cow",
    next="Chapter_1_Scene_5",
    type="interactive_spelling",
    word="Cow",
    random_order=false,
    random_letters=false,
    bpm=110,
    mpb=545.4545454545,
    object_x = 686,
    object_y = 410,
    -- intro_letter_beats = {8, 10, 12},
    -- outro_letter_beats = {4, 6, 8},
    -- outro_sound_beats = {12, 14, 16},
    -- outro_word_beat = 18,
    intro_letter_beats = {0, 0.5, 1},
    outro_sounds = {"cuh", "oah", "wuh"},
    time_sig=4,
    script=nil,
    -- here it might be fun to use a stage spotlight
  }
  self.flow["Chapter_1_Scene_5"] = {
    name="Chapter_1_Scene_5",
    next="Chapter_1_Interactive_Coin",
    type="scripted",
    script_file="Chapter_1_Scene_5.json",
    script=self:loadSceneScript("chapter_1_scene_5"),
    duration=0,
  }
  self.flow["Chapter_1_Interactive_Coin"] = {
    name="Chapter_1_Interactive_Coin",
    next="Chapter_1_Scene_6",
    type="interactive_spelling",
    word="Coin",
    random_order=false,
    random_letters=false,
    bpm=110,
    mpb=545.4545454545,
    -- intro_letter_beats = {12, 14, 16, 18},
    -- outro_letter_beats = {4, 6, 8, 10},
    -- outro_sound_beats = {12, 14, 16, 18},
    -- outro_word_beat = 20,
    intro_letter_beats = {0, 0.5, 1, 1.5},
    outro_sounds = {"cuh", "oh", "ih", "nuh"},
    time_sig=4,
    script=nil,
    -- here it might be fun to use a stage spotlight
  }
  self.flow["Chapter_1_Scene_6"] = {
    name="Chapter_1_Scene_6",
    next=nil,
    type="scripted",
    script_file="Chapter_1_Scene_6.json",
    script=self:loadSceneScript("chapter_1_scene_6"),
    duration=0,
    cleanup=false,
  }


  self.flow["Chapter_1_Beast_Apple"] = {
    name="Chapter_1_Beast_Apple",
    next="Chapter_1_Interactive_Apple",
    type="scripted",
    script=self:loadSceneScript("chapter_1_beast_apple"),
    cleanup=false,
    duration=0,
  }
  self.flow["Chapter_1_Interactive_Apple"] = {
    name="Chapter_1_Interactive_Apple",
    next=nil,
    type="interactive_spelling",
    word="Apple",
    random_order=false,
    random_letters=false,
    bpm=110,
    mpb=545.4545454545,
    -- intro_letter_beats = {12, 13, 14, 15, 16},
    -- outro_letter_beats = {4, 6, 8, 10, 12},
    -- outro_sound_beats = {16, 18, 20, 22, 24},
    -- outro_word_beat = 26,
    intro_letter_beats = {0, 0.5, 1, 1.5, 2},
    outro_sounds = {"ah", "puh", "puh", "luh", "eh"},
    time_sig=4,
    cleanup=false,
  }
  self.flow["Chapter_1_Beast_Banana"] = {
    name="Chapter_1_Beast_Banana",
    next="Chapter_1_Interactive_Banana",
    type="scripted",
    cleanup=false,
    script=self:loadSceneScript("chapter_1_beast_banana"),
    duration=0,
  }
  self.flow["Chapter_1_Interactive_Banana"] = {
    name="Chapter_1_Interactive_Banana",
    next=nil,
    type="interactive_spelling",
    word="Banana",
    random_order=false,
    random_letters=false,
    bpm=110,
    mpb=545.4545454545,
    -- intro_letter_beats = {12, 14, 16, 18, 20, 22},
    -- outro_letter_beats = {4, 6, 8, 10, 12, 14},
    -- outro_sound_beats = {16, 18, 20, 22, 24, 26},
    -- outro_word_beat = 28,
    intro_letter_beats = {0, 0.5, 1, 1.5, 2, 2.5},
    outro_sounds = {"buh", "ah", "nuh", "ah", "nuh", "ah"},
    time_sig=4,
    cleanup=false,
  }
  self.flow["Chapter_1_Beast_Lime"] = {
    name="Chapter_1_Beast_Lime",
    next="Chapter_1_Interactive_Lime",
    type="scripted",
    cleanup=false,
    script=self:loadSceneScript("chapter_1_beast_lime"),
    duration=0,
  }
  self.flow["Chapter_1_Interactive_Lime"] = {
    name="Chapter_1_Interactive_Lime",
    next=nil,
    type="interactive_spelling",
    word="Lime",
    random_order=false,
    random_letters=false,
    bpm=110,
    mpb=545.4545454545,
    -- intro_letter_beats = {12, 14, 16, 18},
    -- outro_letter_beats = {4, 6, 8, 10},
    -- outro_sound_beats = {12, 14, 16, 18},
    -- outro_word_beat = 20,
    intro_letter_beats = {0, 0.5, 1, 1.5},
    outro_sounds = {"luh", "I", "muh", "eh"},
    time_sig=4,
    cleanup=false,
  }
  self.flow["Chapter_1_Beast_Orange"] = {
    name="Chapter_1_Beast_Orange",
    next="Chapter_1_Interactive_Orange",
    type="scripted",
    script=self:loadSceneScript("chapter_1_beast_orange"),
    cleanup=false,
    duration=0,
  }
  self.flow["Chapter_1_Interactive_Orange"] = {
    name="Chapter_1_Interactive_Orange",
    next=nil,
    type="interactive_spelling",
    word="Orange",
    random_order=false,
    random_letters=false,
    bpm=110,
    mpb=545.4545454545,
    -- intro_letter_beats = {12, 14, 16, 18, 20, 22},
    -- outro_letter_beats = {4, 6, 8, 10, 12, 14},
    -- outro_sound_beats = {20, 22, 24, 26, 28, 30},
    -- outro_word_beat = 34,
    intro_letter_beats = {0, 0.5, 1, 1.5, 2, 2.5},
    outro_sounds = {"oh", "ruh", "ah", "nuh", "juh", "eh"},
    time_sig=4,
    cleanup=false,
  }
  self.flow["Chapter_1_Beast_Pear"] = {
    name="Chapter_1_Beast_Pear",
    next="Chapter_1_Interactive_Pear",
    type="scripted",
    cleanup=false,
    script=self:loadSceneScript("chapter_1_beast_pear"),
    duration=0,
  }
  self.flow["Chapter_1_Interactive_Pear"] = {
    name="Chapter_1_Interactive_Pear",
    next=nil,
    type="interactive_spelling",
    word="Pear",
    random_order=false,
    random_letters=false,
    bpm=110,
    mpb=545.4545454545,
    -- intro_letter_beats = {12, 14, 16, 18},
    -- outro_letter_beats = {4, 6, 8, 10},
    -- outro_sound_beats = {12, 14, 16, 18},
    -- outro_word_beat = 20,
    intro_letter_beats = {0, 0.5, 1, 1.5},
    outro_sounds = {"puh", "eh", "ah", "ruh"},
    time_sig=4,
    cleanup=false,
  }
  self.flow["Chapter_1_Beast_Plum"] = {
    name="Chapter_1_Beast_Plum",
    next="Chapter_1_Interactive_Plum",
    type="scripted",
    cleanup=false,
    script=self:loadSceneScript("chapter_1_beast_plum"),
    duration=0,
  }
  self.flow["Chapter_1_Interactive_Plum"] = {
    name="Chapter_1_Interactive_Plum",
    next=nil,
    type="interactive_spelling",
    word="Plum",
    random_order=false,
    random_letters=false,
    bpm=110,
    mpb=545.4545454545,
    -- intro_letter_beats = {12, 14, 16, 18},
    -- outro_letter_beats = {4, 6, 8, 10},
    -- outro_sound_beats = {12, 14, 16, 18},
    -- outro_word_beat = 20,
    intro_letter_beats = {0, 0.5, 1, 1.5},
    outro_sounds = {"puh", "luh", "uh", "muh"},
    time_sig=4,
    cleanup=false,
  }
  self.flow["Chapter_1_Scene_7"] = {
    name="Chapter_1_Scene_7",
    next=nil,
    type="scripted",
    script=self:loadSceneScript("chapter_1_scene_7"),
    duration=0,
  }

  -- make a random chain of fruits for the fruit beast before moving to Scene 7
  fruits = {
    "Apple",
    "Banana",
    "Lime",
    "Orange",
    "Pear",
    "Plum",
  }
  for i = #fruits, 2, -1 do
    local j = math.random(i)
    fruits[i], fruits[j] = fruits[j], fruits[i]
  end


  self.flow["Chapter_1_Scene_6"].next = "Chapter_1_Beast_" .. fruits[1]
  self.flow["Chapter_1_Interactive_" .. fruits[1]].next = "Chapter_1_Beast_" .. fruits[2]
  self.flow["Chapter_1_Interactive_" .. fruits[2]].next = "Chapter_1_Beast_" .. fruits[3]
  self.flow["Chapter_1_Interactive_" .. fruits[3]].next = "Chapter_1_Scene_7"
  self.flow["Chapter_1_Interactive_" .. fruits[3]].cleanup = true

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
  -- table.insert(self.flow["Chapter_1_Beast_" .. fruits[2]].script, chomp_asset)
  -- table.insert(self.flow["Chapter_1_Beast_" .. fruits[3]].script, chomp_asset)
  -- table.insert(self.flow["Chapter_1_Scene_7"].script, chomp_asset)
end



function scene:startGame()
  -- remove loading text
  loading_text:removeSelf()

  composer.setVariable("sprite", sprite)

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

-- function scene:setNextScene(new_scene_name)
--   if new_scene_name ~= "end" and self.flow[new_scene_name] ~= nil then
--     print("New scene: " .. new_scene_name)
--     new_scene = self.flow[new_scene_name]
--     composer.setVariable("scene_name", new_scene.name)
--     composer.setVariable("settings", new_scene)
--     if new_scene.script ~= nil then
--       composer.setVariable("script_assets", new_scene.script)
--     else
--       composer.setVariable("script_assets", "")
--     end
--     if new_scene.next ~= nil then
--       composer.setVariable("next_scene", new_scene.next)
--     else
--       composer.setVariable("next_scene", "end")
--     end
--   else
--     composer.gotoScene("Source.temporary_end")
--   end
-- end

function scene:finish()
  composer.gotoScene("Source.temporary_end")
end

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

return scene
