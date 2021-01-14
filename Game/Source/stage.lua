
local composer = require("composer")
local animation = require("plugin.animation")

local sprite_class = require("Source.sprite")

stage = {}
stage.__index = stage

--
-- This is the definition for the stage. The stage manages sprites throughout the chapter
-- and across different parts. It allows them to be created, updated, and destroyed,
-- and placed on any of a series of layers. It also allows the layers to be moved or
-- emptied at any time.
--

const_num_layers = 50

function stage:create()

  local object = {}
  setmetatable(object, stage)

  function object:initialize()
    self.sprite_cache = composer.getVariable("sprite_cache")
    self.sprite_info = composer.getVariable("sprite_info")
    self.chapter = composer.getVariable("chapter")
    self.loader = composer.getVariable("loader")
    self.view = composer.getVariable("view")

    self.stageGroup = display.newGroup()
    self.view:insert(self.stageGroup)

    for i = 1, const_num_layers do
      local layer = display.newGroup()
      self.stageGroup:insert(layer)
    end

    self.sprite_list = {}
    self.id_table = {}
  end

  function object:perform(script_element)
    --
    -- Turn a script element into a sprite on the stage.
    --
    sprite = sprite_class:create(script_element)
    self.stageGroup[script_element.depth]:insert(sprite)

    table.insert(self.sprite_list, sprite)
    self.id_table[sprite.id] = sprite

    if sprite.start_effect == "poof" then
      -- utterly bizarre:
      -- makeClouds makes a call to this perform method,
      -- which somehow prevents the return statement from
      -- this original method from ever being fired.
      -- maybe something weird to do with function tables.
      -- anyway, a hack is to just return the sprite
      -- from makeClouds and then return that result here.
      return self:makeClouds(sprite, 10 + math.random(20))
    else
      return sprite
    end
  end

  function object:resetStage()
    --
    -- Temoves all performance elements and reset the stage and layer positions
    --

    -- remove all assets
    for i = 1, #self.sprite_list do
      display.remove(self.sprite_list[i])
    end
    self.id_table = {}
    self.sprite_list = {}

    -- reset the layer positions
    for i = 1, const_num_layers do
      self:translateLayer(i, 0, nil, {"y", "=", 0})
      self:translateLayer(i, 0, nil, {"x", "=", 0})
    end

    -- reset stage position
    self:translateLayer(-1, 0, nil, {"y", "=", 0})
    self:translateLayer(-1, 0, nil, {"x", "=", 0})
  end

  function object:update()
    --
    -- Update the stage, updating each sprite and removing defunct sprites
    --
    local current_time = self.chapter:getTime()
    for i = 1, #self.sprite_list do
      self.sprite_list[i]:update(current_time)
    end

    new_sprite_list = {}
    for i = 1, #self.sprite_list do
      if self.sprite_list[i].state ~= "inactive" and self.sprite_list[i].isVisible == true and self.sprite_list[i].alpha > 0 then
        table.insert(new_sprite_list, self.sprite_list[i])
      else
        self.id_table[self.sprite_list[i]] = nil
        display.remove(self.sprite_list[i])
      end
    end
    self.sprite_list = new_sprite_list

  end

  function object:has(id)
    --
    -- Checks if the stage has an item with this id
    --
    return self.id_table[id] ~= nil
  end

  function object:get(id)
    --
    -- Try to return a sprite matching this id
    --
    if self:has(id) then
      return self.id_table[id]
    else
      return nil
    end
  end

  function object:translateLayer(layer, delay, easing, instruction)
    --
    -- Translates the entire stage, or a sub layer, with optional animation delay
    -- layer: -1 is the whole stage, N >= 1 is layer N
    -- delay: animation delay. 0 is no animation.
    -- easing: easing function for animation
    -- instruction: {coordinate, operand, number}, eg {"x", "+", "50"} or {"y", "=", "600"}
    --
    

    -- choose the stage as the target of translation by default,
    -- but if a layer is specified, choose that
    local translation_target = self.stageGroup
    if layer >= 1 and layer <= const_num_layers then
      translation_target = self.stageGroup[layer]
    end

    -- compute the target value based on 
    local target_value = instruction[3]
    if instruction[2] == "+" then
      target_value = translation_target[instruction[1]] + instruction[3]
    elseif instruction[2] == "-" then
      target_value = translation_target[instruction[1]] - instruction[3]
    end

    -- if there is no delay, assign immediately
    if delay == 0 then
      translation_target[instruction[1]] = target_value
    else
      -- if there is a delay, set an animation. unfortunately, I don't know
      -- how to make this a general assignment, so it has to be either x or y.
      if instruction[1] == "x" then
        animation.to(translation_target, {x = target_value}, {time = delay, easing = easing, tag="game"})
      elseif instruction[1] == "y" then
        animation.to(translation_target, {y = target_value}, {time = delay, easing = easing, tag="game"})
      end
    end
  end


  --
  --
  -- Effects
  --
  --
  function object:makeHonk(x, y, duration)
    --
    -- Make a speech bubble that says "HONK"
    --
    local current_time = self.chapter:getTime()
    element = {
      picture = "Honk",
      id = "Honk_" .. math.random(50000),
      x = x,
      y = y,
      depth = const_num_layers - 3,
      start_time = current_time,
      end_time = current_time + duration,
      end_effect = "pop",
    }

    local honk_sprite = self:perform(element)
  end

  function object:makeClouds(target_sprite, num_clouds)
    --
    -- Make some poofs of clouds that quickly disappear
    --
    local width = math.abs(target_sprite.width * target_sprite.xScale)
    local height = math.abs(target_sprite.height * target_sprite.yScale)
    local current_time = self.chapter:getTime()
    for i = 1, num_clouds do
      element = {
        picture = "Cloud",
        id = "Cloud_" .. math.random(5) .. 1000 + i,
        x = target_sprite.x - width / 2 + math.random(width),
        y = target_sprite.y - height / 2 + math.random(height),
        xScale = 0.5,
        yScale = 0.5,
        depth = target_sprite.depth,
        start_time = current_time,
        end_time = current_time,
        end_effect = "fade",
        squish_period = target_sprite.squish_period,
      }

      local cloud_sprite = self:perform(element)

      animation.to(cloud_sprite,
        {x = cloud_sprite.x - 40 + math.random(80), y = cloud_sprite.y - 40 + math.random(80)},
        {time=target_sprite.squish_period * 0.75, easing=easing.outExp, tag="game"}
      )
    end
    return target_sprite
  end

  object:initialize()
  return object
end

return stage