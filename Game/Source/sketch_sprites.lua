
local animation = require("plugin.animation")

sketch_sprites = {}
sketch_sprites.__index = sketch_sprites

max_squish_scale = 1.25
max_squish_rotation = 30

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
          if sprite.frame < sprite.info.animation_start or sprite.frame > sprite.info.animation_end then
            sprite:setFrame(sprite.info.animation_start)
          else
            if sprite.frame >= sprite.info.animation_end then
              sprite:setFrame(sprite.info.animation_start)
            else
              sprite:setFrame(sprite.frame + 1)
            end
          end
        end
      end

      if sprite.state == "sketching" then
        if sprite.frame < sprite.info.sprite_count then
          sprite:setFrame(sprite.frame + 1)
        else
          if sprite.info["animation_end"] ~= nil then
            print("setting " .. sprite.info.file_name .. " to animation")
            --sprite_count = info["animation_end"]
            sprite.state = "animating"
            sprite.animation_count = 0
          else
            print("setting " .. sprite.info.file_name .. " to static")
            sprite.state = "static"
          end
        end
      end

      if sprite.state == "outline_sketching" then
        if sprite.frame < sprite.info.outline_frame then
          sprite:setFrame(sprite.frame + 1)
        else
          if sprite.info["animation_end"] ~= nil then
            print("setting " .. sprite.info.file_name .. " to animation")
            --sprite_count = info["animation_end"]
            sprite.state = "animating"
            sprite.animation_count = 0
          else
            print("setting " .. sprite.info.file_name .. " to static")
            sprite.state = "static"
          end
        end
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

      if (mode == "performing") then
        if not string.find(sprite.state, "disappearing") and sprite.disappear_method ~= nil and sprite.disappear_method ~= "" and sprite.disappear_time > 0 then
          if total_performance_time > sprite.disappear_time then
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
        end

        if not string.find(sprite.state, "disappearing") and sprite.disappear_method ~= nil and sprite.disappear_method ~= "" and sprite.disappear_time > 0 then
          if total_performance_time > sprite.disappear_time then
            if sprite.disappear_method == "fade" then
              sprite.state = "disappearing_fade"
              animation.to(sprite, {alpha = 0}, {time=sprite.squish_period * 0.75, easing=easing.outSine})
            end
          end
        end

        if not string.find(sprite.state, "disappearing") and sprite.disappear_method ~= nil and sprite.disappear_method ~= "" and sprite.disappear_time > 0 then
          if total_performance_time > sprite.disappear_time then
            if sprite.disappear_method == "leap_left" then
              sprite.state = "disappearing_leap_left"
              local current_x = sprite.x
              local current_y = sprite.y
              animation.to(sprite, {x=current_x - sprite.info["sprite_size"], y=current_y - sprite.info["sprite_size"] / 4, alpha = 0}, {time=sprite.squish_period / 2, easing=easing.outCubic})
            end
          end
        end

        if not string.find(sprite.state, "disappearing") and sprite.disappear_method ~= nil and sprite.disappear_method ~= "" and sprite.disappear_time > 0 then
          if total_performance_time > sprite.disappear_time then
            if sprite.disappear_method == "leap_right" then
              sprite.state = "disappearing_leap_right"
              local current_x = sprite.x
              local current_y = sprite.y
              animation.to(sprite, {x=current_x + sprite.info["sprite_size"], y=current_y - sprite.info["sprite_size"] / 4, alpha = 0}, {time=sprite.squish_period / 2, easing=easing.outCubic})
            end
          end
        end

        if not string.find(sprite.state, "disappearing") and sprite.disappear_method ~= nil and sprite.disappear_method ~= "" and sprite.disappear_time > 0 then
          if total_performance_time > sprite.disappear_time then
            if sprite.disappear_method == "bounce_left" then
              sprite.state = "disappearing_bounce_left"
              local current_x = sprite.x
              local current_y = sprite.y
              animation.to(sprite, {x=current_x - sprite.info["sprite_size"], y=current_y - sprite.info["sprite_size"] / 4, alpha = 0}, {time=sprite.squish_period / 2, easing=easing.inOutBack})
            end
          end
        end

        if not string.find(sprite.state, "disappearing") and sprite.disappear_method ~= nil and sprite.disappear_method ~= "" and sprite.disappear_time > 0 then
          if total_performance_time > sprite.disappear_time then
            if sprite.disappear_method == "bounce_right" then
              sprite.state = "disappearing_bounce_right"
              local current_x = sprite.x
              local current_y = sprite.y
              animation.to(sprite, {x=current_x + sprite.info["sprite_size"], y=current_y - sprite.info["sprite_size"] / 4, alpha = 0}, {time=sprite.squish_period / 2, easing=easing.inOutBack})
            end
          end
        end

        if not string.find(sprite.state, "disappearing") and sprite.disappear_method ~= nil and sprite.disappear_method ~= "" and sprite.disappear_time > 0 then
          if total_performance_time > sprite.disappear_time then
            if sprite.disappear_method == "pop" then
              sprite.state = "disappearing_pop"
              sprite.isVisible = false
            end
          end
        end

        if not string.find(sprite.state, "disappearing") and sprite.disappear_method ~= nil and sprite.disappear_method ~= "" and sprite.disappear_time > 0 then
          if total_performance_time > sprite.disappear_time then
            if sprite.disappear_method == "rewind" then
              sprite.state = "disappearing_rewind"
            end
          end
        end
      end
    end
  end

  return object
end

return sketch_sprites