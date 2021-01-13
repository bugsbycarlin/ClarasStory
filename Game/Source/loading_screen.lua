
local composer = require("composer")
local scene = composer.newScene()

local loader = require("Source.loader")


--
-- This is the definition for the loading screen. The loading screen reads
-- the current chapter structure, collects a list of things to load,
-- sends it to the loader, and shows a nice background while waiting.
-- When loading is finished, it goes to the chapter scene.
--

function scene:show(event)
  --
  -- This function runs when the scene has loaded
  --

    -- Remove any other scenes
    composer.removeHidden()

    -- White background
    display.setDefault("background", 1, 1, 1)
 
    if (event.phase == "did") then
      self.chapter_structures = composer.getVariable("chapter_structures")
      self.sprite_cache = composer.getVariable("sprite_cache")
      self.sprite_info = composer.getVariable("sprite_info")
      self.current_chapter = composer.getVariable("current_chapter")

      self.loader = loader:create()
      composer.setVariable("loader", self.loader)

      self:setupLoadingScreenDisplay()
      self:startLoading(self:getLoadItems())
    end    
end


function scene:setupLoadingScreenDisplay()
  --
  -- This function sets up the loading screen display
  --

  self.loadingScreenGroup = display.newGroup()
  self.view:insert(self.loadingScreenGroup)

  self.background = display.newImageRect(self.loadingScreenGroup, "Art/chapter_" .. self.current_chapter .. "_loading_background.png", 1024, 768)
  self.background.x = display.contentCenterX
  self.background.y = display.contentCenterY

  self.loading_text = display.newText(self.loadingScreenGroup, "", display.contentCenterX, display.contentCenterY + 250, "Fonts/BebasNeue.ttf", 30)
  self.loading_text:setTextColor(0.0, 0.0, 0.0)
end

function scene:getLoadItems()
  --
  -- This function gets load items from chapter_structures[chapter]
  --

  -- pre-load the stuff from part 1. other stuff will be loaded in the background as we go along.
  first_part_items = {}
  local first_part = self.chapter_structures[self.current_chapter].first_part
  local first_part_script = self.chapter_structures[self.current_chapter].flow[first_part].script

  print(first_part)
  print(#first_part_script)
  
   if first_part_script ~= nil then
    for element_name, element_value in pairs(first_part_script) do
      first_part_items[element_value.picture] = 1
    end
  end

  if self.chapter_structures[self.current_chapter].flow[first_part].word ~= nil then
    load_items[self.chapter_structures[self.current_chapter].flow[first_part].word] = 1
  end

  load_items = {}

  -- combine the first part stuff with the stuff that's always supposed to load
  for sprite, info in pairs(self.sprite_info) do
    if first_part_items[sprite] == 1 or info.always_load == true then
      table.insert(load_items, sprite)
    end
  end

  return load_items
end


function scene:startLoading(load_items)
  --
  -- This function starts the partial loader and plays the intro tone
  --
  function updateLoadDisplay(percent)
    self.loading_text.text = "Spelling " .. percent .. "%"
  end

  self.loader:backgroundLoad(
    self.sprite_cache,
    self.sprite_info,
    load_items,
    0,
    function(percent) updateLoadDisplay(percent) end,
    function() self:gotoChapter() end)

  intro_sound = audio.loadSound("Sound/chapter_intro.wav")
  audio.play(intro_sound)

end


function scene:gotoChapter()
  --
  -- This function switches to the game scene
  --
  composer.gotoScene("Source.chapter", {effect = "fade", time = 500})
end


function scene:destroy(event)
  --
  -- Destroy things before removing scene's view
  --
end
 
scene:addEventListener("show", scene)
scene:addEventListener("destroy", scene)
 
return scene