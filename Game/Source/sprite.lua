
local composer = require("composer")
local animation = require("plugin.animation")

local stringx = require("pl.stringx")
stringx.import()

sprite = {}
sprite.__index = sprite

--
-- This is the definition for the sprite. The sprite is a wrapper around some picture on the screen.
-- Fundamentally it's a display group (with the standard positional properties) along with
-- a state (that may end up "remove", in which case it is the stage's job to handle removal)
-- and some mechanics associated with state changes, and last but not least, an image,
-- which itself has positional properties that may be changed in accordance with the sprite's state
-- (eg warping the image itself when the sprite is supposed to bounce)
--

function sprite:create(element)

  local object = display.newGroup()

  function object:initialize()
    self.sprite_cache = composer.getVariable("sprite_cache")
    self.sprite_info = composer.getVariable("sprite_info")
    self.parent_stage = composer.getVariable("stage") -- "stage" is a reserved word inside display groups
    self.chapter = composer.getVariable("chapter")
    self.loader = composer.getVariable("loader")

    -- guard against trying to use an unloaded sprite.
    print(element.picture)
    if self.sprite_cache[element.picture] == nil then
      self.loader:loadSprite(element.picture)
    end

    self.image = display.newSprite(self, self.sprite_cache[element.picture], {frames=self.sprite_info[element.picture].frames})
    self.id = element.id
    self.picture = element.picture
    self.info = self.sprite_info[element.picture]
    self.x = element.x
    self.y = element.y
    self.xVel = 0
    self.yVel = 0
    self.xScale = element.xScale ~= nil and element.xScale or 1
    self.yScale = element.yScale ~= nil and element.yScale or 1
    self.start_time = element.start_time ~= nil and element.start_time or 0
    self.start_effect = element.start_effect
    self.end_time = element.end_time ~= nil and element.end_time or -1
    self.end_effect = element.end_effect

    self.squish_period = element.squish_period ~= nil and element.squish_period or 1000
    self.squish_tilt = element.squish_tilt ~= nil and element.squish_tilt or 0
    self.squish_scale = element.squish_scale ~= nil and element.squish_scale or 1
    self.squish_enabled = true

    self.depth = element.depth

    self.width = self.sprite_info[element.picture]["sprite_size"]
    self.height = self.sprite_info[element.picture]["sprite_height"]

    local queue_string = element.animation_queue ~= nil and element.animation_queue or "static"
    local starting_queue = (queue_string):split(",")
    self:queueAnimations(starting_queue)

    self:startEffect()

    self.state = "active"
  end

  function object:getSnapshot()
    --
    -- This function returns a script element corresponding to a snapshot of this sprite,
    -- with timing information stripped out.
    --
    return {
      picture = self.picture,
      id = self.id,
      x = self.x,
      y = self.y,
      xScale = self.xScale,
      yScale = self.yScale,
      depth = self.depth,
      start_time = 0,
      end_time = -1,
      squish_period = self.squish_period,
      squish_tilt = self.squish_tilt,
      squish_scale = self.squish_scale,
      animation_queue = (","):join(self.animation_queue),
    }
  end

  function object:update(current_time)
    -- print(self.id)
    -- print("updating")
    self:animate(current_time)
    self:squishPunch(current_time)
    self:checkEnd(current_time)
  end

  function object:startEffect()
    if self.start_effect == "fade_in" then
      self.image.alpha = 0.01
      animation.to(self.image, {alpha = 1}, {time = 200, easing = easing.linear, tag="game"})
    elseif self.start_effect == "rise" then
      local target = self.y
      self.y = self.y + self.info.sprite_height
      animation.to(self, {y = target}, {time = self.squish_period, easing = easing.inOutQuad, tag="game"})
    -- elseif self.start_effect == "poof" then
    --   self.parent_stage:makeClouds(self, 10 + math.random(20))
    elseif self.start_effect == "punch" then

    end
    return
  end

  function object:nextAnimation()
    if #self.animation_queue > 0 then
      local new_animation = self.animation_queue[1]
      if self.info.animations[new_animation] == nil then
        error("Sprite " .. self.picture .. " does not have animation " .. new_animation)
      end
      self.animation = new_animation
    end

    if #self.animation_queue > 1 then
      new_animation_queue = {}
      for i = 2, #self.animation_queue do
        table.insert(new_animation_queue, self.animation_queue[i])
      end
      self.animation_queue = new_animation_queue
    end

    self.frame_count = 1

    self.image:setFrame(self.info.animations[self.animation][1])
  end

  function object:queueAnimations(animation_queue)
    self.animation_queue = animation_queue
    self:nextAnimation()
  end

  function object:animate(current_time)
    -- print(self.id)
    -- print(self.animation_queue)
    -- print(self.animation)
    self.frame_count = self.frame_count + 1
    -- print(self.picture .. " animation " .. self.animation .. " on frame count " .. self.frame_count)
    if self.frame_count >= #self.info.animations[self.animation] then
      self:nextAnimation()
    else
      self.image:setFrame(self.info.animations[self.animation][self.frame_count])
    end
  end

  function object:squishPunch(current_time)
    if self.start_effect == "punch" and current_time - self.start_time <= 150 then
      self.image.x = -4 + math.random(8)
      self.image.y = -4 + math.random(8)
    elseif self.squish_enabled then
      local squish_time = current_time - self.start_time
      self.image.yScale = (1 + (self.squish_scale - 1) * math.cos(squish_time * 2 * math.pi / self.squish_period))
      self.image.y = -1 * self.height * (self.squish_scale - 1) * math.cos(squish_time * 2 * math.pi / self.squish_period)
      self.image.x = -1 * self.squish_tilt * math.sin(0.5 * squish_time * 2 * math.pi / self.squish_period)
    else
      self.image.x = 0
      self.image.y = 0
    end
  end

  function object:checkEnd(current_time)
    if self.end_time > 0 and current_time > self.end_time then
      if self.state == "active" then
        if self.end_effect == "fade" then
          animation.to(self, {alpha = 0}, {time=self.squish_period * 0.75, easing=easing.outSine, tag="game"})
        elseif self.end_effect == "poof" then
          self.state = "inactive"
          self.isVisible = false
          self.parent_stage:makeClouds(self, 10 + math.random(20))
        else
          self.state = "inactive"
          self.isVisible = false
        end
      end
    end

    if self.isVisible == false or self.alpha < 0.01 then
      self.state = "inactive"
    end
  end

  object:initialize()
  return object
end

return sprite