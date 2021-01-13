
local composer = require("composer")
local json = require("json")
local lfs = require("lfs")

local scene = composer.newScene()

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

    self.performanceAssetGroup = display.newGroup()
    self.sceneGroup:insert(self.performanceAssetGroup)

    self.sounds = {}
    self.sounds["Scene_1"] = audio.loadStream("Sound/Sound_Tester/Chapter_1_Scene_1_Tight.wav")
    self.sounds["Scene_2"] = audio.loadStream("Sound/Sound_Tester/Chapter_1_Scene_2_Tight.wav")
    self.sounds["Scene_3"] = audio.loadStream("Sound/Sound_Tester/Chapter_1_Scene_3_Tight.wav")
    self.sounds["Scene_4"] = audio.loadStream("Sound/Sound_Tester/Chapter_1_Scene_4_Tight.wav")
    self.sounds["Scene_5"] = audio.loadStream("Sound/Sound_Tester/Chapter_1_Scene_5_Tight.wav")
    self.sounds["Scene_6"] = audio.loadStream("Sound/Sound_Tester/Chapter_1_Scene_6_Tight.wav")
    self.sounds["Scene_7"] = audio.loadStream("Sound/Sound_Tester/Chapter_1_Scene_7_Tight.wav")
    self.sounds["Loop_1"] = audio.loadStream("Sound/Sound_Tester/Chapter_1_Mini_Loop_1.wav")
    self.sounds["Loop_2"] = audio.loadStream("Sound/Sound_Tester/Chapter_1_Mini_Loop_2.wav")

    self.sounds["Apple"] = audio.loadStream("Sound/Sound_Tester/Apple_Beast_Intro.wav")
    self.sounds["Apple"] = audio.loadStream("Sound/Sound_Tester/Apple_Beast_Intro.wav")
    self.sounds["Apple"] = audio.loadStream("Sound/Sound_Tester/Apple_Beast_Intro.wav")
    self.sounds["Apple"] = audio.loadStream("Sound/Sound_Tester/Apple_Beast_Intro.wav")
    self.sounds["Apple"] = audio.loadStream("Sound/Sound_Tester/Apple_Beast_Intro.wav")
    self.sounds["Apple"] = audio.loadStream("Sound/Sound_Tester/Apple_Beast_Intro.wav")

    scene:startPerformance()
  end
end

function scene:startPerformance()
  mode = "performing"

  -- self.current_time = system.getTimer()
  -- start_performance_time = 0
  -- stored_performance_time = 0
  -- total_performance_time = 0
  
  -- start_performance_time = system.getTimer()
  -- self.current_time = system.getTimer()

  local current_item = 1
  local playlist = {"Scene_1", "Loop_1", "Loop_2", "Scene_2", "Loop_1", "Loop_2", "Scene_3", "Loop_1", "Loop_2", "Scene_4", "Loop_1", "Loop_2", "Scene_5"}

  function playNext(item_number)
    print("Testing " .. item_number)
    if item_number <= #playlist then
      print("Playing it.")
      print("Song is " .. playlist[item_number])
      audio.play(self.sounds[playlist[item_number]], {loops = 0, onComplete=function()
        current_item = current_item + 1
        playNext(current_item)
      end})
    end
  end

  playNext(current_item)
  -- audio.play(self.sounds[1], {loops = 0, onComplete=function()
  --   audio.play(self.sounds["Loop"], {loops = 2, onComplete=function()
  --     audio.play(self.sounds[2], {loops = 0, onComplete=function()
  --       audio.play(self.sounds["Loop"], {loops = 2, onComplete=function()
  --         audio.play(self.sounds[3], {loops=0})
  --       end})
  --     end})
  --   end})
  -- end})
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
  -- Runtime:removeEventListener("touch")
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
