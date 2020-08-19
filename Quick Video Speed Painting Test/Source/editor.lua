
local composer = require("composer")
local json = require("json")
local lfs = require("lfs")

local scene = composer.newScene()

local const_image_width = 370
local const_image_height = 517

local pictures
local picture_number
local picture_object

local page_number
local configured_pages = {}

local save_file = system.pathForFile("SavedConfig/reader_config.json", system.ResourceDirectory)
print(save_file)

function scene:saveInfo(event)
  local file = io.open(save_file, "w")
 
  if file then
    file:write(json.encode(configured_pages))
    io.close(file)
  end

  print(save_file)

  return true
end

function scene:loadInfo()
  local file = io.open(save_file, "r")
  print(save_file)
 
  if file then
      local contents = file:read("*a")
      io.close(file)
      configured_pages = json.decode(contents)
  end

  if configured_pages == nil or #configured_pages == 0 then
    configured_pages = {}
  end
end

function scene:newPage()
  page_number = page_number + 1
  configured_pages[page_number] = {page=pictures[picture_number]}
  -- table.insert(configured_pages, {page=pictures[picture_number]})
  print("Project is " .. #configured_pages .. " pages")
end

function scene:editKeyboard(event)
  return true

  -- local sceneGroup = self.view
  -- print(event.keyName)
  -- print(event.phase)
  -- if event.phase == "up" then
    
  --   if event.keyName == "down" then
  --     picture_number = picture_number + 1
  --     if picture_number > #pictures then
  --       picture_number = 1
  --     end
  --     print(picture_number)
  --     print(pictures[picture_number])
  --     configured_pages[page_number].page = pictures[picture_number]
  --     picture_object.fill = {type="image", filename="Pages/" .. pictures[picture_number]}
  --   end
    
  --   if event.keyName == "up" then
  --     picture_number = picture_number - 1
  --     if picture_number < 1 then
  --       picture_number = #pictures
  --     end
  --     print(picture_number)
  --     print(pictures[picture_number])
  --     configured_pages[page_number].page = pictures[picture_number]
  --     picture_object.fill = {type="image", filename="Pages/" .. pictures[picture_number]}
  --   end

  --   if event.keyName == "s" then
  --     self:saveInfo()
  --   end

  --   if event.keyName == "n" then
  --     self:newPage()
  --   end
  end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create(event)

  local sceneGroup = self.view
  -- Code here runs when the scene is first created but has not yet appeared on screen

  -- background = display.newImageRect(sceneGroup, "Art/goodgamelab.png", display.contentWidth, display.contentHeight)
  -- background.x = display.contentCenterX
  -- background.y = display.contentCenterY
  -- background.alpha = 0.8

  -- good = display.newEmbossedText(sceneGroup, "GOOD", display.contentCenterX - 106, display.contentCenterY, "Georgia-Bold", 30)
  -- good:setTextColor(0.72, 0.18, 0.18)

  -- game = display.newEmbossedText(sceneGroup, "GAME", display.contentCenterX, display.contentCenterY, "Georgia-Bold", 30)
  -- game:setTextColor(0.9, 0.9, 0.9)

  -- lab = display.newEmbossedText(sceneGroup, "LAB", display.contentCenterX + 93, display.contentCenterY, "Georgia-Bold", 30)
  -- lab:setTextColor(0.18, 0.18, 0.72)

end


-- show()
function scene:show(event)

  local sceneGroup = self.view
  local phase = event.phase

  if (phase == "will") then
    -- Code here runs when the scene is still off screen (but is about to come on screen)
    -- transitionTimer = timer.performWithDelay(4000, gotoTitle, 1)
    -- display.getCurrentStage():setFocus(background)
    -- Runtime:addEventListener("tap", immediateTitle)
  elseif (phase == "did") then
    -- Code here runs when the scene is entirely on screen

    local base_path = system.pathForFile(nil, system.ResourceDirectory)
    -- print(base_path)
    local path = system.pathForFile("Pages", system.ResourceDirectory)
    -- print(path)

    page_number = 1
    
    -- picture_object = display.newRect( sceneGroup, display.contentWidth, display.contentHeight, 2* const_image_width, 2* const_image_height)       
    -- picture_object.x = display.contentCenterX
    -- picture_object.y = display.contentCenterY
    -- pictures = {}
    -- for filename in lfs.dir(path) do
    --   if filename ~= ".." and filename ~= "." then
    --     table.insert(pictures, filename)
    --   end
    -- end
    -- table.sort(pictures)
    -- for k,picture in pairs(pictures) do
    --   print(picture .. "," .. k)
    --   if picture_number == nil then
    --     picture_number = k
    --     print(k)
    --     print(pictures[k])
    --     picture_object.fill = {type="image", filename="Pages/" .. pictures[picture_number]}
    --     configured_pages[page_number] = {page=pictures[picture_number]}
    --   end
    -- end

    display.setDefault("background", 1, 1, 1)

    local video = native.newVideo( display.contentCenterX, display.contentCenterY, 720 , 720 )
    video:load( "Videos/Apple.mp4")
    video:play()

    -- local video2 = native.newVideo( display.contentCenterX + 400, display.contentCenterY, 640, 360 )
    -- video2:load( "VideoTest/Apple.mp4")
    -- video2:play()

    -- local video3 = native.newVideo( display.contentCenterX - 400, display.contentCenterY, 640, 360 )
    -- video3:load( "VideoTest/Apple.mp4")
    -- video3:play()

    Runtime:addEventListener("key", function(event) self:editKeyboard(event) end)
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
  Runtime:removeEventListener("key")

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
