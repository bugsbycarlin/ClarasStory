
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
    table.insert(self.sprite_list, sprite)
  end

  function object:update(mode)
    for i = 1, #self.sprite_list do

      sprite = self.sprite_list[i]
      if sprite.state == "sketching" then
        if sprite.frame < sprite.info.sprite_count then
          sprite:setFrame(sprite.frame + 1)
        else
          sprite.state = "static"
          sprite.squish_start = system.getTimer()
        end
      end

      local current_time = system.getTimer()

      if sprite.state == "static" then
        local squish_time = current_time - sprite.squish_start
        -- sprite.xScale = sprite.x_scale * (1 + (sprite.squish_scale - 1) * math.sin(squish_time * 2 * math.pi / sprite.squish_period))
        sprite.yScale = sprite.y_scale * (1 + (sprite.squish_scale - 1) * math.cos(squish_time * 2 * math.pi / sprite.squish_period))
        sprite.y = sprite.fixed_y - sprite.height * (sprite.squish_scale - 1) * math.cos(squish_time * 2 * math.pi / sprite.squish_period)
        sprite.x = sprite.fixed_x - sprite.squish_tilt * math.sin(0.5 * squish_time * 2 * math.pi / sprite.squish_period)
        -- sprite.rotation = sprite.squish_tilt * math.sin(squish_time * 2 * math.pi / sprite.squish_period)
        
      elseif sprite.state == "sketching" then
        sprite.xScale = sprite.x_scale
        sprite.yScale = sprite.y_scale
      end

      if (mode == "performing") then
        if sprite.state ~= "disappearing_expand" and sprite.disappear_method ~= nil and sprite.disappear_method ~= "" and sprite.disappear_time > 0 then
          if current_time - sprite.start_time > sprite.disappear_time then
            if sprite.disappear_method == "expand" then
              sprite.state = "disappearing_expand"
              current_x_scale = sprite.xScale
              current_y_scale = sprite.yScale
              animation.to(sprite, {xScale=current_x_scale * 10, yScale=current_y_scale * 10, alpha = 0}, {time=sprite.squish_period * 0.75, easing=easing.inExpo})
            end
          end
        end

        if sprite.state ~= "disappearing_pop" and sprite.disappear_method ~= nil and sprite.disappear_method ~= "" and sprite.disappear_time > 0 then
          if current_time - sprite.start_time > sprite.disappear_time then
            if sprite.disappear_method == "pop" then
              sprite.state = "disappearing_pop"
              sprite.isVisible = false
              -- current_x_scale = sprite.xScale
              -- current_y_scale = sprite.yScale
              -- animation.to(sprite, {xScale=current_x_scale * 10, yScale=current_y_scale * 10, alpha = 0}, {time=sprite.squish_period * 0.75, easing=easing.inExpo})
            end
          end
        end
      end

    end
  end

  return object
end

return sketch_sprites