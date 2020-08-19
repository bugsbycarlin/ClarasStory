
sketch_sprites = {}
sketch_sprites.__index = sketch_sprites

function sketch_sprites:create()

  local object = {}
  setmetatable(object, sketch_sprites)

  object.sprite_list = {}

  function object:add(sprite)
    table.insert(self.sprite_list, sprite)
  end

  function object:update()
    for i = 1, #self.sprite_list do
      sprite = self.sprite_list[i]
      if sprite.finished ~= true then
        if sprite.frame < sprite.info.sprite_count then
          sprite:setFrame(sprite.frame + 1)
        else
          sprite.finished = true
        end
      end
    end
  end

  return object
end

return sketch_sprites