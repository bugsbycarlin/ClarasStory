
local composer = require("composer")
local json = require("json")
local lfs = require("lfs")

local sketch_sprites_class = require("Source.sketch_sprites")

local scene = composer.newScene()

local sketch_sprites

local asset_info = require("Source.assets")
local sprite = {}
for asset, info in pairs(asset_info) do
  file_name = info["file_name"]
  sheet = info["sheet"]
  sprite[asset] = graphics.newImageSheet("Art/" .. file_name, sheet)
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

  local sceneGroup = self.view
  local phase = event.phase

  sketch_sprites = sketch_sprites_class:create()

  if (phase == "will") then
    -- Code here runs when the scene is still off screen (but is about to come on screen)
    
  elseif (phase == "did") then
    -- Code here runs when the scene is entirely on screen

    local base_path = system.pathForFile(nil, system.ResourceDirectory)
    -- print(base_path)
    -- local path = system.pathForFile("Pages", system.ResourceDirectory)
    -- print(path)

    display.setDefault("background", 1, 1, 1)

    -- local video = native.newVideo( display.contentCenterX, display.contentCenterY, 720 , 720 )
    -- video:load( "VideoTest/Apple.mp4")
    -- video:play()

    local background = display.newImageRect(sceneGroup, "Art/mountains.png", 2560 * 1.4, 1440 * 1.4)
    background.x = display.contentCenterX
    background.y = display.contentCenterY
    background.alpha = 0.6

    clara_letters = {"C", "L", "A", "R", "A", "S"}
    for i = 1, #clara_letters do
      timer.performWithDelay(2000 + i * 800 + 500, function()
        local asset = clara_letters[i]
        local letter_sprite = display.newSprite(sceneGroup, sprite[asset], {frames=asset_info[asset].frames})

        letter_sprite.x = display.contentCenterX - 1050 + 300 * i
        letter_sprite.y = display.contentCenterY - 500
        letter_sprite.info = asset_info[asset]
        letter_sprite.finished = false
        -- letter_sprite:setFrame(0)
        sketch_sprites:add(letter_sprite)
      end, 1)
    end

    story_letters = {"S", "T", "O", "R", "Y"}
    for i = 1, #story_letters do
      timer.performWithDelay(2000 + i * 800 + 900, function()
        local asset = story_letters[i]
        local letter_sprite = display.newSprite(sceneGroup, sprite[asset], {frames=asset_info[asset].frames})

        letter_sprite.x = display.contentCenterX - 900 + 300 * i
        letter_sprite.y = display.contentCenterY - 300
        letter_sprite.info = asset_info[asset]
        letter_sprite.finished = false
        -- letter_sprite:setFrame(0)
        sketch_sprites:add(letter_sprite)
      end, 1)
    end

    -- timer.performWithDelay(9000, function()
    --   local asset = "Apple"

    --   local apple_sprite = display.newSprite(sceneGroup, sprite[asset], {frames=asset_info[asset].frames})

    --   frames = asset_info[asset].sheet.frames
    --   apple_sprite.x = display.contentCenterX
    --   apple_sprite.y = display.contentCenterY + 200
    --   apple_sprite.info = asset_info[asset]
    --   apple_sprite:setFrame(0)
    --   apple_sprite.finished = false

    --   sketch_sprites:add(apple_sprite)
    -- end, 1)

    -- timer.performWithDelay(8500, function()
    --   local asset = "Earth"

    --   local earth_sprite = display.newSprite(sceneGroup, sprite[asset], {frames=asset_info[asset].frames})

    --   frames = asset_info[asset].sheet.frames
    --   earth_sprite.x = display.contentCenterX
    --   earth_sprite.y = display.contentCenterY + 200
    --   earth_sprite.info = asset_info[asset]
    --   earth_sprite:setFrame(0)
    --   earth_sprite.finished = false

    --   sketch_sprites:add(earth_sprite)
    -- end, 1)

      timer.performWithDelay(8500, function()
      local asset = "Tower"

      local bird_sprite = display.newSprite(sceneGroup, sprite[asset], {frames=asset_info[asset].frames})

      frames = asset_info[asset].sheet.frames
      bird_sprite.x = display.contentCenterX
      bird_sprite.y = display.contentCenterY + 200
      bird_sprite.info = asset_info[asset]
      bird_sprite:setFrame(0)
      bird_sprite.finished = false

      sketch_sprites:add(bird_sprite)
    end, 1)

    timer.performWithDelay(35, function() 
      sketch_sprites:update()
    end, 0)

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
