
local composer = require("composer")
local scene = composer.newScene()

scene.initialized = false

--
-- This is the definition for the chapter select scene. This scene shows available
-- chapters and allows the player to select one, then goes to the loading screen scene.
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
      -- If this is the first time the scene is loaded, set up the table of contents
      if self.initialized == false then
        self.initialized = true

        self.chapters = composer.getVariable("chapters", chapters)

        self:setupTableOfContents()
      end
    end    
end



function scene:setupTableOfContents()
  --
  -- This function builds the table of contents layout and adds click events to each chapter
  --
  self.tableOfContentsGroup = display.newGroup()
  self.view:insert(self.tableOfContentsGroup)

  -- Make the background
  self.tableOfContentsBackground = display.newImageRect(self.tableOfContentsGroup, "Art/table_of_contents_background.png", 1024, 768)
  self.tableOfContentsBackground.x = display.contentCenterX
  self.tableOfContentsBackground.y = display.contentCenterY

  -- For each chapter (not necessarily integer), load an image, and add an event listener
  for i = 1, #self.chapters do
    local chapter_button = display.newImageRect(self.tableOfContentsGroup, "Art/chapter_" .. self.chapters[i] .. "_button.png", 108, 127)
    chapter_button.x = display.contentCenterX + (i - 3) * 180
    chapter_button.y = 222
    chapter_button:addEventListener("tap", function(event)
      composer.setVariable("current_chapter", self.chapters[i])
      self:gotoLoadingScreen(self.chapters[i])
    end)
  end

end


function scene:gotoLoadingScreen()
  --
  -- This function switches to the loading screen scene
  --
  composer.gotoScene("Source.loading_screen")
end


function scene:destroy(event)
  --
  -- Destroy things before removing scene's view
  --
end

scene:addEventListener("show", scene)
scene:addEventListener("destroy", scene)
 
return scene