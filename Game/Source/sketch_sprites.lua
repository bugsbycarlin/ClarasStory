
local animation = require("plugin.animation")

sketch_sprites = {}
sketch_sprites.__index = sketch_sprites

max_squish_scale = 1.25
max_squish_rotation = 30

gravity_constant = 2

function sketch_sprites:create()

  local object = {}
  setmetatable(object, sketch_sprites)

  object.sprite_list = {}

  function object:add(sprite)
    sprite.squish_start = system.getTimer()
    table.insert(self.sprite_list, sprite)
  end

  function object:immediatelyRemoveAll()
    for i = 1, #self.sprite_list do
      sprite = self.sprite_list[i]
      animation.cancel(sprite)
      display.remove(sprite)
    end
    self.sprite_list = {}
  end

  function object:remove(id)
    for i = 1, #self.sprite_list do
      sprite = self.sprite_list[i]
      if sprite.id == id then
        sprite.state = "remove"
        print("Removing " .. sprite.id)
      end
    end
  end

  function object:get(id)
    for i = 1, #self.sprite_list do
      sprite = self.sprite_list[i]
      if sprite.id == id then
        return sprite
      end
    end
    return nil
  end

  function object:setStaticOrAnimating(sprite)
    if sprite.info.animation_end ~= nil or sprite.info.animation_frames ~= nil then
      sprite.state = "animating"
      sprite.animation_count = 0
      sprite.frame_count = 1
    else
      sprite.state = "static"
    end
  end

  function object:update(mode, total_performance_time)
    -- print("Updating; time " .. system.getTimer())
    copy_sprite_list = {}
    for i = 1, #self.sprite_list do
      sprite = self.sprite_list[i]
      if sprite.state ~= "remove" and sprite.isVisible == true and sprite.alpha > 0 then
        table.insert(copy_sprite_list, sprite)
      else
        print("Fully deleting " .. sprite.id)
        animation.cancel(sprite)
        display.remove(sprite)
      end
    end
    self.sprite_list = copy_sprite_list

    for i = 1, #self.sprite_list do

      sprite = self.sprite_list[i]

      if sprite.state == "animating" then
        sprite.animation_count = sprite.animation_count + 1
        if sprite.animation_count % sprite.info.animation_on == 0 then
          if sprite.info.animation_frames ~= nil then
            if sprite.frame_count >= #sprite.info.animation_frames then
              sprite:setFrame(sprite.info.animation_frames[1])
              sprite.frame_count = 1
            else
              sprite.frame_count = sprite.frame_count + 1
              sprite:setFrame(sprite.info.animation_frames[sprite.frame_count])
            end
          elseif sprite.info.animation_end ~= nil then
            if sprite.frame < sprite.info.animation_start or sprite.frame >= sprite.info.animation_end then
              sprite:setFrame(sprite.info.animation_start)
            else
              sprite:setFrame(sprite.frame + 1)
            end
          end
        end
      end

      if sprite.state == "splash" then
        if sprite.frame < sprite.info.sprite_count then
          sprite.animation_count = sprite.animation_count + 1
          if (sprite.frame ~= 1 and sprite.animation_count % 3 == 0) or (sprite.frame == 1 and sprite.animation_count % 30 == 0) then
            if sprite.frame == 1 then
              local splash = audio.loadSound("Sound/splash.wav")
              audio.play(splash)
            end
            sprite:setFrame(sprite.frame + 1)

          end
        else
          self:setStaticOrAnimating(sprite)
        end
      end

      if sprite.state == "sketching" then
        if sprite.frame < sprite.info.sprite_count then
          sprite:setFrame(sprite.frame + 1)
        else
          self:setStaticOrAnimating(sprite)
        end
      end

      if sprite.state == "poof" then
        self:setStaticOrAnimating(sprite)
        self:poopClouds(sprite, 10 + math.random(20))
      end

      if sprite.state == "outline_sketching" then
        if sprite.info.outline_frame ~= nil and sprite.frame < sprite.info.outline_frame then
          sprite:setFrame(sprite.frame + 1)
        else
          self:setStaticOrAnimating(sprite)
        end
      end

      if sprite.state == "fade_in" then
        if sprite.alpha < 1.0 then
          sprite.alpha = sprite.alpha + 0.16
          if sprite.alpha >= 1.0 then
            sprite.alpha = 1.0
            self:setStaticOrAnimating(sprite)
          end
        end
      end

      if sprite.state == "rise" then
        local height = sprite.info.sprite_size
        if sprite.info["sprite_height"] ~= nil then
          height = sprite.info["sprite_height"]
        end
        current_y = sprite.fixed_y
        animation.to(sprite, {fixed_y=current_y - height, y=current_y - height}, {time=sprite.squish_period, easing=easing.inOutQuad})

        self:setStaticOrAnimating(sprite)
      end

      sprite = self.sprite_list[i]
      if sprite.state == "disappearing_rewind" then
        if sprite.frame > 1 then
          sprite:setFrame(sprite.frame - 1)
        else
          sprite.state = "disappearing_pop"
          sprite.isVisible = false
        end
      end

      local current_time = system.getTimer()

      if sprite.state == "static" or sprite.state == "sketching"  or sprite.state == "animating" then
        local squish_time = current_time - sprite.squish_start
        -- sprite.xScale = sprite.x_scale * (1 + (sprite.squish_scale - 1) * math.sin(squish_time * 2 * math.pi / sprite.squish_period))
        sprite.yScale = sprite.y_scale * (1 + (sprite.squish_scale - 1) * math.cos(squish_time * 2 * math.pi / sprite.squish_period))
        sprite.xScale = sprite.x_scale
        sprite.y = sprite.fixed_y - sprite.height * (sprite.squish_scale - 1) * math.cos(squish_time * 2 * math.pi / sprite.squish_period)
        sprite.x = sprite.fixed_x - sprite.squish_tilt * math.sin(0.5 * squish_time * 2 * math.pi / sprite.squish_period)
      end

      if sprite.state == "punch" then
        sprite.x = sprite.fixed_x - 4 + math.random(8)
        sprite.y = sprite.fixed_y - 4 + math.random(8)
        if current_time - sprite.start_time > 150 then
          self:setStaticOrAnimating(sprite)
        end
      end

      if sprite.x_vel ~= nil and sprite.x_vel ~= 0 then
        sprite.x = sprite.x + sprite.x_vel
      end
      if sprite.y_vel ~= nil and sprite.y_vel ~= 0 then
        sprite.y = sprite.y + sprite.y_vel
      end

      if sprite.state == "disappearing_gravity" then
        sprite.x = sprite.x + sprite.x_vel
        sprite.y = sprite.y + sprite.y_vel
        --sprite.x = sprite.fixed_x
        --sprite.y = sprite.fixed_y
        sprite.y_vel = sprite.y_vel + gravity_constant
        if sprite.y > display.contentHeight + 400 then
          sprite.state = "disappearing_pop"
          sprite.isVisible = false
        end
      end

      if (mode ~= "editing") then

        if total_performance_time > sprite.disappear_time or mode == "outro" then
          if not string.find(sprite.state, "disappearing") and sprite.disappear_method ~= nil and sprite.disappear_method ~= "" and sprite.disappear_time > 0 then
            if sprite.disappear_method == "expand" then
              sprite.state = "disappearing_expand"
              current_x_scale = sprite.xScale
              current_y_scale = sprite.yScale
              if sprite.info["sprite_size"] > 200 then
                animation.to(sprite, {xScale=current_x_scale * 10, yScale=current_y_scale * 10, alpha = 0}, {time=sprite.squish_period * 0.75, easing=easing.inSine})
              else
                animation.to(sprite, {xScale=current_x_scale * 30, yScale=current_y_scale * 30, alpha = 0}, {time=sprite.squish_period * 0.75, easing=easing.inSine})
              end
            end
          end

          if not string.find(sprite.state, "disappearing") and sprite.disappear_method ~= nil and sprite.disappear_method ~= "" and sprite.disappear_time > 0 then
            if sprite.disappear_method == "fade" then
              sprite.state = "disappearing_fade"
              animation.to(sprite, {alpha = 0}, {time=sprite.squish_period * 0.75, easing=easing.outSine})
            end
          end

          if not string.find(sprite.state, "disappearing") and sprite.disappear_method ~= nil and sprite.disappear_method ~= "" and sprite.disappear_time > 0 then
            if sprite.disappear_method == "poof" then
              sprite.state = "disappearing_poof"
              sprite.isVisible = false
              self:poopClouds(sprite, 10 + math.random(20))
            end
          end

          if not string.find(sprite.state, "disappearing") and sprite.disappear_method ~= nil and sprite.disappear_method ~= "" and sprite.disappear_time > 0 then
            if sprite.disappear_method == "leap_left" then
              sprite.state = "disappearing_leap_left"
              local current_x = sprite.x
              local current_y = sprite.y
              animation.to(sprite, {x=current_x - sprite.info["sprite_size"], y=current_y - sprite.info["sprite_size"] / 4, alpha = 0}, {time=sprite.squish_period / 2, easing=easing.outCubic})
            end
          end

          if not string.find(sprite.state, "disappearing") and sprite.disappear_method ~= nil and sprite.disappear_method ~= "" and sprite.disappear_time > 0 then
            if sprite.disappear_method == "leap_right" then
              sprite.state = "disappearing_leap_right"
              local current_x = sprite.x
              local current_y = sprite.y
              animation.to(sprite, {x=current_x + sprite.info["sprite_size"], y=current_y - sprite.info["sprite_size"] / 4, alpha = 0}, {time=sprite.squish_period / 2, easing=easing.outCubic})
            end
          end

          if not string.find(sprite.state, "disappearing") and sprite.disappear_method ~= nil and sprite.disappear_method ~= "" and sprite.disappear_time > 0 then
            if sprite.disappear_method == "bounce_left" then
              sprite.state = "disappearing_bounce_left"
              local current_x = sprite.x
              local current_y = sprite.y
              animation.to(sprite, {x=current_x - sprite.info["sprite_size"], y=current_y - sprite.info["sprite_size"] / 4, alpha = 0}, {time=sprite.squish_period / 2, easing=easing.inOutBack})
            end
          end

          if not string.find(sprite.state, "disappearing") and sprite.disappear_method ~= nil and sprite.disappear_method ~= "" and sprite.disappear_time > 0 then
            if sprite.disappear_method == "bounce_right" then
              sprite.state = "disappearing_bounce_right"
              local current_x = sprite.x
              local current_y = sprite.y
              animation.to(sprite, {x=current_x + sprite.info["sprite_size"], y=current_y - sprite.info["sprite_size"] / 4, alpha = 0}, {time=sprite.squish_period / 2, easing=easing.inOutBack})
            end
          end

          if not string.find(sprite.state, "disappearing") and sprite.disappear_method ~= nil and sprite.disappear_method ~= "" and sprite.disappear_time > 0 then
            if sprite.disappear_method == "pop" then
              sprite.state = "disappearing_pop"
              sprite.isVisible = false
            end
          end

          if not string.find(sprite.state, "disappearing") and sprite.disappear_method ~= nil and sprite.disappear_method ~= "" and sprite.disappear_time > 0 then
            if sprite.disappear_method == "rewind" then
              sprite.state = "disappearing_rewind"
            end
          end

          if not string.find(sprite.state, "disappearing") and sprite.disappear_method ~= nil and sprite.disappear_method ~= "" and sprite.disappear_time > 0 then
            if sprite.disappear_method == "gravity" then
              sprite.state = "disappearing_gravity"
            end
          end

          if not string.find(sprite.state, "disappearing") and sprite.disappear_method ~= nil and sprite.disappear_method ~= "" and sprite.disappear_time > 0 then
            if sprite.disappear_method == "fruit" then
              self:poopFruits(sprite, 100, 150, 10 + math.random(20))
              sprite.state = "disappearing_pop"
              sprite.isVisible = false
            end
          end
        end
      end
    end
  end

  function object:poopFruits(current_sprite, range_x, range_y, num_fruits)
    local info = current_sprite.info
    local fruits = {"Apple", "Banana", "Lime", "Orange", "Pear", "Plum"}
    for i = 1, num_fruits do
      local picture = fruits[math.random(#fruits)]
      local fruit_sprite = display.newSprite(self.top_group, self.sprite[picture], {frames=self.picture_info[picture].frames})
      fruit_sprite.id = picture .. "_" .. 0
      fruit_sprite.x = current_sprite.fixed_x - range_x + math.random(2 * range_x)
      fruit_sprite.y = current_sprite.fixed_y - range_y + math.random(2 * range_y)
      fruit_sprite.fixed_y = fruit_sprite.y
      fruit_sprite.fixed_x = fruit_sprite.x
      fruit_sprite.info = self.picture_info[picture]
      fruit_sprite.intro = "static"
      fruit_sprite:setFrame(self.picture_info[picture]["sprite_count"])
      fruit_sprite.state = "disappearing_gravity"
      fruit_sprite.start_time = system.getTimer()
      fruit_sprite.x_scale = 0.25
      fruit_sprite.y_scale = 0.25
      fruit_sprite.xScale = fruit_sprite.x_scale
      fruit_sprite.yScale = fruit_sprite.y_scale
      fruit_sprite.disappear_time = -1
      fruit_sprite.squish_scale = 1
      fruit_sprite.squish_tilt = 0
      fruit_sprite.squish_period = info.mpb
      fruit_sprite.x_vel = -20 + math.random(40)
      fruit_sprite.y_vel = -1 * (4 + math.random(6))
      self:add(fruit_sprite)
    end
  end

  function object:poopClouds(current_sprite, num_clouds)
    local info = current_sprite.info
    print("Width of this sprite is " .. current_sprite.width * current_sprite.xScale)
    local width = current_sprite.width * current_sprite.xScale
    local height = current_sprite.height * current_sprite.yScale
    for i = 1, num_clouds do
      local cloud_sprite = display.newImageRect(self.top_group, "Art/Cloud.png", 256, 256)
      cloud_sprite.id = "Cloud_" .. math.random(5) .. 1000 + i
      cloud_sprite.x = current_sprite.fixed_x - width / 2 + math.random(width)
      cloud_sprite.y = current_sprite.fixed_y - height / 2 + math.random(height)
      cloud_sprite.fixed_y = cloud_sprite.y
      cloud_sprite.fixed_x = cloud_sprite.x
      cloud_sprite.info = self.picture_info["Cloud"]
      cloud_sprite.intro = "static"
      cloud_sprite.state = "disappearing_fade"
      cloud_sprite.start_time = system.getTimer()
      cloud_sprite.x_scale = 0.5
      cloud_sprite.y_scale = 0.5
      cloud_sprite.xScale = cloud_sprite.x_scale
      cloud_sprite.yScale = cloud_sprite.y_scale
      cloud_sprite.disappear_time = -1
      cloud_sprite.squish_scale = 1
      cloud_sprite.squish_tilt = 0
      cloud_sprite.squish_period = 0

      animation.to(cloud_sprite, {x = cloud_sprite.x - 40 + math.random(80), y = cloud_sprite.y - 40 + math.random(80), alpha = 0}, {time=sprite.squish_period * 0.75, easing=easing.outExp})
      self:add(cloud_sprite)
    end
  end

  return object
end

return sketch_sprites