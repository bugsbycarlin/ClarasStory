
local composer = require("composer")
local animation = require("plugin.animation")
local memoryBitmap = require("plugin.memoryBitmap")

local sound_info = require("Source.sound_info")
local scripted_part_template = require("Source.scripted_part")


mandala_part = {}
mandala_part.__index = mandala_part

--
-- This is the definition for a mandala part. It handles the part specific functions
-- of a mandala part, including updating the stage per the script, and drawing the mandala.
--

function mandala_part:create()

  local object = scripted_part_template:create()


  function object:initialize()
    self.chapter = composer.getVariable("chapter")
    self.current_chapter = composer.getVariable("current_chapter")
    self.stage = composer.getVariable("stage")
    self.part_structure = self.chapter.current_part_structure
    self.script = self.part_structure.script
    self.view = composer.getVariable("view")
    self.additional_actions = self.part_structure.additional_actions ~= nil and self.part_structure.additional_actions or {}

    self.last_update_time = 0

    self.mandala_pixels_painted = 0
    self.mandala_target_pixels_painted = 0

    self.end_button = nil

    self:createMandala()

    self.music_loop = audio.loadStream("Sound/chapter_2_interactive_loop.wav")
    audio.play(self.music_loop, {loops=-1})

    -- if chapter is 2, play the little intro
    if self.current_chapter == "2" then
      local sound = audio.loadSound("Sound/chapter_2/mandala_intro.mp3")
      audio.play(sound)
    end

    self.mandalaTouchEventWrapper = function(event)
      self:mandalaTouchEvent(event)
    end
    Runtime:addEventListener("touch", self.mandalaTouchEventWrapper)
  end


  function object:createMandala()
    self.mandala_size = 650
    self.mandala_x = 512 - 64
    self.mandala_y = 340 + 96
    self.mandala_radius = 8
    self.mandala_degree = 3

    self.mandala_r = 0
    self.mandala_g = 0
    self.mandala_b = 0

    self.mandala_target_pixels_painted = (self.mandala_size / 2) * (self.mandala_size / 2) * 1.5

    self.mandala_texture = memoryBitmap.newTexture(
    {
        width = self.mandala_size,
        height = self.mandala_size,
    })
    mandala = self.mandala_texture
 
    self.mandala_performance = display.newImageRect(self.view, mandala.filename, mandala.baseDir, self.mandala_size, self.mandala_size)
    self.mandala_performance.x = self.mandala_x
    self.mandala_performance.y = self.mandala_y

    for y = 1,mandala.height do
      for x = 1,mandala.width do
        mandala:setPixel(x, y, 0, 0, 0, 0)
      end
    end
     
    -- Submit texture to be updated
    mandala:invalidate()
  end


  function object:initializeColorSelection()
    self.mandala_selection = self.stage:get("Letter_Box_1")

    local plus_button = display.newImageRect(self.view, "Art/Nav/plus_button.png", 48, 48)
    plus_button.x = display.contentWidth - 240
    plus_button.y = display.contentHeight - 25
    plus_button:setFillColor(0.5,0.5,0.5)

    local light_button = display.newImageRect(self.view, "Art/Nav/light_button.png", 48, 48)
    light_button.x = display.contentWidth - 290
    light_button.y = display.contentHeight - 25
    light_button:setFillColor(0,0,0)

    local minus_button = display.newImageRect(self.view, "Art/Nav/minus_button.png", 48, 48)
    minus_button.x = display.contentWidth - 340
    minus_button.y = display.contentHeight - 25
    minus_button:setFillColor(0.5,0.5,0.5)

    local color_definitions = {
      {"Red_Paint_8", 215, 36, 36},
      {"Orange_Paint_5", 255, 165, 33},
      {"Yellow_Paint_9", 255, 227, 33},
      {"Green_Paint_4", 43, 183, 25},
      {"Blue_Paint_2", 32, 105, 243},
      {"Purple_Paint_7", 143, 36, 215},
      {"Pink_Paint_6", 255, 133, 185},
      {"Brown_Paint_8", 128, 83, 17},
      {"Black_Paint_3", 0, 0 ,0},
    }
    for i = 1, #color_definitions do
      local color = color_definitions[i]
      local paint = self.stage:get(color[1])
      paint:addEventListener("tap", function(event) 
        self.mandala_r = color[2]/255
        self.mandala_g = color[3]/255
        self.mandala_b = color[4]/255
        local x = paint.x
        local y = paint.y
        animation.to(self.mandala_selection, {x = x, y = y}, {time=250, easing=easing.inOutExpo})
        light_button:setFillColor(self.mandala_r, self.mandala_g, self.mandala_b)
      end)
    end

    plus_button:addEventListener("tap", function(event)
      if self.mandala_r == 0 then
        self.mandala_r = 0.2
        self.mandala_g = 0.2
        self.mandala_b = 0.2
      else
        self.mandala_r = self.mandala_r * 1.1
        self.mandala_g = self.mandala_g * 1.1
        self.mandala_b = self.mandala_b * 1.1
      end
      light_button:setFillColor(self.mandala_r, self.mandala_g, self.mandala_b)
    end)

    minus_button:addEventListener("tap", function(event)
      self.mandala_r = self.mandala_r * 0.9
      self.mandala_g = self.mandala_g * 0.9
      self.mandala_b = self.mandala_b * 0.9
      if self.mandala_r < 0.1 then
        self.mandala_r = 0
      end
      if self.mandala_g < 0.1 then
        self.mandala_g = 0
      end
      if self.mandala_b < 0.1 then
        self.mandala_b = 0
      end
      light_button:setFillColor(self.mandala_r, self.mandala_g, self.mandala_b)
    end)   
  end

  object.mandala_last_x = 0
  object.mandala_last_y = 0
  function object:mandalaTouchEvent(event)
    if event.phase == "moved" or event.phase == "ended" then
      self:updateMandala(event.x - self.mandala_x, event.y - self.mandala_y, self.mandala_last_x - self.mandala_x, self.mandala_last_y - self.mandala_y)
    end
    self.mandala_last_x = event.x
    self.mandala_last_y = event.y
  end


  function object:updateMandala(x_start, y_start, x_end, y_end)
    texture = self.mandala_texture
    local origin = self.mandala_size / 2

    local start_angle = math.atan2(y_start, x_start)
    local start_distance = math.sqrt(x_start*x_start + y_start*y_start)
    local end_angle = math.atan2(y_end, x_end)
    local end_distance = math.sqrt(x_end*x_end + y_end*y_end)
    local block_size = 2

    for i = 0, self.mandala_degree - 1 do
      local r_start_angle = (start_angle + i * (2 * math.pi / self.mandala_degree) + 4 * math.pi) % (2 * math.pi)
      local x0 = start_distance * math.cos(r_start_angle)
      local y0 = start_distance * math.sin(r_start_angle)
      local r_end_angle = (end_angle + i * (2 * math.pi / self.mandala_degree) + 4 * math.pi) % (2 * math.pi)
      local x1 = end_distance * math.cos(r_end_angle)
      local y1 = end_distance * math.sin(r_end_angle)

      local distance = math.ceil(math.sqrt((x1-x0)*(x1-x0) + (y1-y0)*(y1-y0)))

      for j = 0, distance do
        x_j = j/distance * x1 + (distance - j)/distance * x0
        y_j = j/distance * y1 + (distance - j)/distance * y0
        for n = -block_size, block_size do
          for m = -block_size, block_size do
            if math.sqrt((x_j + n)*(x_j + n) + (y_j + m)*(y_j + m)) <= origin then
              if math.abs(m) == math.abs(n) and math.abs(n) == block_size then
                self:plot(x_j + n, y_j + m, 0.2)
              else
                self:plot(x_j + n, y_j + m, 1)
              end
            end
          end
        end
      end
    end

    texture:invalidate()

    if self.mandala_pixels_painted >= self.mandala_target_pixels_painted and self.end_button == nil then
      self.end_button = display.newImageRect(self.view, "Art/Thumb_2.png", 128, 128)
      self.end_button.x = display.contentWidth - 80
      self.end_button.y = 220
      self.end_button:addEventListener("tap", function(event)
        self:nextScene()
      end)
    end
  end


  function object:plot(x, y, alpha)
    local origin = self.mandala_size / 2
    if alpha == 1 then
      texture:setPixel(x + origin, y + origin, self.mandala_r, self.mandala_g, self.mandala_b, 1)
      self.mandala_pixels_painted = self.mandala_pixels_painted + 1
    else
      local r,g,b,a = texture:getPixel(x + origin, y + origin)
      if r ~= nil then
        texture:setPixel(x + origin, y + origin, r * (1-alpha) + self.mandala_r * alpha, g * (1-alpha) + self.mandala_g * alpha, b * (1-alpha) + self.mandala_b * alpha, a * (1-alpha) + 1 * alpha)
      end
    end
  end


  object.parentUpdate = object.update
  function object:update()
    self:parentUpdate()

    if self.mandala_selection == nil then
      self:initializeColorSelection()
    end
  end


  function object:skipToEnd()
    self:cleanup()
  end

  function object:nextScene()
    self:cleanup()
    self.chapter:gotoNextPart()
  end


  function object:cleanup()
    Runtime:removeEventListener("touch", self.mandalaTouchEventWrapper)

    display.remove(self.mandala_performance)
    display.remove(self.end_button)

    audio.stop()
  end


  return object
end

return mandala_part