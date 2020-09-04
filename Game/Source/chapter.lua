

local composer = require("composer")
local json = require("json")
local lfs = require("lfs")

local picture_info = require("Source.pictures")
local sound_info = require("Source.sounds")

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

local flow = nil

-- local scripts = {}

local current_scene = nil

local chapter_1_scene_1_file = system.pathForFile("Scenes/chapter_1_scene_1.json", system.ResourceDirectory)
local chapter_1_scene_2_file = system.pathForFile("Scenes/chapter_1_scene_2.json", system.ResourceDirectory)
local chapter_1_scene_3_file = system.pathForFile("Scenes/chapter_1_scene_3.json", system.ResourceDirectory)
local chapter_1_scene_4_file = system.pathForFile("Scenes/chapter_1_scene_4.json", system.ResourceDirectory)
local chapter_1_scene_5_file = system.pathForFile("Scenes/chapter_1_scene_5.json", system.ResourceDirectory)
local chapter_1_scene_6_file = system.pathForFile("Scenes/chapter_1_scene_6.json", system.ResourceDirectory)

function scene:loadInfo(scene_file)
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

  self.performanceAssetGroup = display.newGroup()
  self.sceneGroup:insert(self.performanceAssetGroup)

  if (phase == "will") then
    -- Code here runs when the scene is still off screen (but is about to come on screen)
    
  elseif (phase == "did") then
    -- Code here runs when the scene is entirely on screen

    display.setDefault("background", 1, 1, 1)

    composer.setVariable("chapter", self)

    self:setupDisplay()
    self:setupLoading()
    self:setupSceneStructure()
    -- when loading finishes, it will call self:startGame()

    intro_sound = audio.loadSound("Sound/Chapter_Intro.wav")
    audio.play(intro_sound)
  end
end

function scene:setupDisplay()
  title_text = display.newText(self.sceneGroup, "Chapter 1 - Getting Started", display.contentCenterX, display.contentCenterY - 250, "Fonts/MouseMemoirs.ttf", 80)
  title_text:setTextColor(0.0, 0.0, 0.0)

  credits_text = display.newText({
  	parent = self.sceneGroup,
      text = "Programming, Story, Art, Music\nMattsby",
      x = display.contentCenterX,
      y = display.contentCenterY + 40,
      width = 400,
      height = 200,
      font = "Fonts/MouseMemoirs.ttf",
      fontSize = 40,
      align = "center"
  })
  credits_text:setTextColor(0.0, 0.0, 0.0)

  loading_text = display.newText(self.sceneGroup, "Bongos", display.contentCenterX, display.contentCenterY + 250, "Fonts/MouseMemoirs.ttf", 40)
  loading_text:setTextColor(0.0, 0.0, 0.0)
end

function scene:setupLoading()
  self.partialLoadNumber = 1
  self.partialLoadObjects = {}
  for picture, info in pairs(picture_info) do
    table.insert(self.partialLoadObjects, picture)
  end

  function updateLoadDisplay()
    local percent = math.floor((self.partialLoadNumber / #self.partialLoadObjects) * 100)
    loading_text.text = "Loading " .. percent .. "%"
  end

  timer.performWithDelay(40, function() 
    load_start_time = system.getTimer()
    self:partialLoad() 
  end)

  Runtime:addEventListener("enterFrame", updateLoadDisplay)

  updateLoadDisplay()
end

function scene:partialLoad()
  picture_name = self.partialLoadObjects[self.partialLoadNumber]
  if string.len(picture_name) >= 1 then
    file_name = picture_info[picture_name]["file_name"]
    sheet = picture_info[picture_name]["sheet"]
    sprite[picture_name] = graphics.newImageSheet("Art/" .. file_name, sheet)
  end
  print("Loaded " .. picture_name)

  self.partialLoadNumber = self.partialLoadNumber + 1
  if self.partialLoadNumber <= #self.partialLoadObjects then
  -- if self.partialLoadNumber < 2 then
    timer.performWithDelay(20, function() self:partialLoad() end)
  else
    loading_text.text = "Loading 100%"
    Runtime:removeEventListener("enterFrame", updateLoadDisplay)
    local load_time_total = system.getTimer() - load_start_time
    print("Load time was " .. load_time_total)
    self:startGame()
  end
end

function scene:setupSceneStructure()

  flow = {}
  flow["Chapter_1_Scene_1"] = {
    name="Chapter_1_Scene_1",
    next="Chapter_1_Interactive_Girl",
    type="scripted",
    script_file="Chapter_1_Scene_1.json",
    script=nil,
    duration=28363.636,
  }
  flow["Chapter_1_Interactive_Girl"] = {
    name="Chapter_1_Interactive_Girl",
    next="Chapter_1_Interactive_Bird",
    type="interactive_spelling",
    word="Girl",
    random_order=false,
    random_letters=false,
    bpm=110,
    mpb=545.4545454545,
    intro_letter_beats = {12, 13, 14, 15},
    outro_letter_beats = {4, 6, 8, 10},
    outro_sound_beats = {12, 14, 16, 18},
    outro_word_beat = 20,
    time_sig=4,
  }
  flow["Chapter_1_Interactive_Bird"] = {
    name="Chapter_1_Interactive_Bird",
    next="Chapter_1_Scene_2",
    type="interactive_spelling",
    word="Bird",
    random_order=false,
    random_letters=false,
    bpm=110,
    mpb=545.4545454545,
    intro_letter_beats = {12, 13, 14, 15},
    outro_letter_beats = {4, 6, 8, 10},
    outro_sound_beats = {12, 14, 16, 18},
    outro_word_beat = 20,
    time_sig=4,
  }
  flow["Chapter_1_Scene_2"] = {
    name="Chapter_1_Scene_2",
    next="Chapter_1_Interactive_Mom",
    type="scripted",
    script_file="Chapter_1_Scene_2.json",
    script=nil,
    duration=0,
  }
  flow["Chapter_1_Interactive_Mom"] = {
    name="Chapter_1_Interactive_Mom",
    next="Chapter_1_Interactive_Dad",
    type="interactive_spelling",
    word="Mom",
    random_order=false,
    random_letters=false,
    bpm=110,
    mpb=545.4545454545,
    intro_letter_beats = {8, 10, 12},
    outro_letter_beats = {4, 6, 8},
    outro_sound_beats = {12, 14, 16},
    outro_word_beat = 18,
    time_sig=4,
    -- here it might be fun to use a stage spotlight
  }
  flow["Chapter_1_Interactive_Dad"] = {
    name="Chapter_1_Interactive_Dad",
    next="Chapter_1_Scene_3",
    type="interactive_spelling",
    word="Dad",
    random_order=false,
    random_letters=false,
    bpm=110,
    mpb=545.4545454545,
    intro_letter_beats = {8, 10, 12},
    outro_letter_beats = {4, 6, 8},
    outro_sound_beats = {12, 14, 16},
    outro_word_beat = 18,
    time_sig=4,
    -- here it might be fun to use a stage spotlight
  }
  flow["Chapter_1_Scene_3"] = {
    name="Chapter_1_Scene_3",
    next="Chapter_1_Interactive_Wand",
    type="scripted",
    script_file="Chapter_1_Scene_3.json",
    script=nil,
    duration=0,
  }
  flow["Chapter_1_Interactive_Wand"] = {
    name="Chapter_1_Interactive_Wand",
    next="Chapter_1_Scene_4",
    type="interactive_spelling",
    word="Wand",
    random_order=false,
    random_letters=false,
    bpm=110,
    mpb=545.4545454545,
    intro_letter_beats = {4, 6, 8, 10},
    outro_letter_beats = {4, 6, 8, 10},
    outro_sound_beats = {12, 14, 16, 18},
    outro_word_beat = 20,
    time_sig=4,
    -- here it might be fun to use a stage spotlight
  }
  flow["Chapter_1_Scene_4"] = {
    name="Chapter_1_Scene_4",
    next="Chapter_1_Interactive_Pig",
    type="scripted",
    script_file="Chapter_1_Scene_4.json",
    script=nil,
    duration=0,
  }
  flow["Chapter_1_Interactive_Pig"] = {
    name="Chapter_1_Interactive_Pig",
    next="Chapter_1_Interactive_Cow",
    type="interactive_spelling",
    word="Pig",
    random_order=false,
    random_letters=false,
    bpm=110,
    mpb=545.4545454545,
    intro_letter_beats = {4, 6, 8},
    outro_letter_beats = {4, 6, 8},
    outro_sound_beats = {12, 14, 16},
    outro_word_beat = 20,
    time_sig=4,
    -- here it might be fun to use a stage spotlight
  }
  flow["Chapter_1_Interactive_Cow"] = {
    name="Chapter_1_Interactive_Cow",
    next=nil,
    type="interactive_spelling",
    word="Cow",
    random_order=false,
    random_letters=false,
    bpm=110,
    mpb=545.4545454545,
    intro_letter_beats = {4, 6, 8},
    outro_letter_beats = {4, 6, 8},
    outro_sound_beats = {12, 14, 16},
    outro_word_beat = 20,
    time_sig=4,
    -- here it might be fun to use a stage spotlight
  }


  flow["Chapter_1_Scene_5"] = {
    name="Chapter_1_Scene_5",
    next="Chapter_1_Interactive_Cow",
    type="scripted",
    script_file="Chapter_1_Scene_5.json",
    script=nil,
    duration=0,
  }
  flow["Chapter_1_Scene_6"] = {
    name="Chapter_1_Scene_6",
    next="Chapter_1_Interactive_Cow",
    type="scripted",
    script_file="Chapter_1_Scene_6.json",
    script=nil,
    duration=0,
  }


  flow.Chapter_1_Scene_1.script = self:loadInfo(chapter_1_scene_1_file)
  flow.Chapter_1_Scene_2.script = self:loadInfo(chapter_1_scene_2_file)
  flow.Chapter_1_Scene_3.script = self:loadInfo(chapter_1_scene_3_file)
  flow.Chapter_1_Scene_4.script = self:loadInfo(chapter_1_scene_4_file)
  flow.Chapter_1_Scene_5.script = self:loadInfo(chapter_1_scene_5_file)
  flow.Chapter_1_Scene_6.script = self:loadInfo(chapter_1_scene_6_file)

end

function scene:startGame()
  -- remove loading text
  loading_text:removeSelf()

  composer.setVariable("sprite", sprite)

  -- self:gotoScene("Chapter_1_Scene_1", {effect = "fade", time = 500})
  self:gotoScene("Chapter_1_Interactive_Dad", {effect = "fade", time = 500})
end

function scene:gotoScene(new_scene_name, fade_options)
  if new_scene_name ~= "end" and flow[new_scene_name] ~= nil then
    print("New scene: " .. new_scene_name)
    new_scene = flow[new_scene_name]
    if new_scene.next ~= nil then
      composer.setVariable("next_scene", new_scene.next)
    else
      composer.setVariable("next_scene", "end")
    end
    print("COMPOSER has set next as " .. tostring(composer.getVariable("next_scene")))
    if new_scene.type == "interactive_spelling" then
      composer.setVariable("interactive_settings", new_scene)
      
      composer.gotoScene("Source.interactive_spelling_player", fade_options)
    elseif new_scene.type == "scripted" then
      composer.setVariable("script_assets", new_scene.script)
      composer.gotoScene("Source.scripted_player", fade_options)
    end
  else
    composer.gotoScene("Source.temporary_end", fade_options)
  end
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
  mui.destroy()
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
