
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
    -- This function removes all performance elements and resets the stage and layer positions
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
    -- This function checks if the stage has an item with this id
    --
    return self.id_table[id] ~= nil
  end

  function object:find(id)
    if self:has(id) then
      return self.id_table[id]
    else
      return nil
    end
  end

  function object:translateLayer(layer, delay, easing, value)
    --
    -- This function translates the entire state, or a sub layer, with optional animation
    -- layer: -1 is the whole stage, N > 0 is layer N
    -- delay: animation delay. 0 is no animation.
    -- easing: easing function for animation
    --
    local translation_target = self.stageGroup

    if layer >= 1 and layer <= const_num_layers then
      translation_target = self.stageGroup[layer]
    end

    local target_value = value[3]
    if value[2] == "+" then
      target_value = translation_target[value[1]] + value[3]
    elseif value[2] == "-" then
      target_value = translation_target[value[1]] - value[3]
    end

    if delay == 0 then
      translation_target[value[1]] = target_value
      -- if x ~= nil then
      --   translation_target.x = x
      -- end
      -- if y ~= nil then
      --   translation_target.y = y
      -- end
    else
      -- if value[2] == "=" then
      --   translation_target[value[1]] = value[3]
      -- elseif value[2] == "+" then
      --   translation_target[value[1]] = translation_target[value[1]] + value[3]
      -- elseif value[2] == "-" then
      --   translation_target[value[1]] = translation_target[value[1]] - value[3]
      -- end

      if value[1] == "x" then
        animation.to(translation_target, {x = target_value}, {time = delay, easing = easing, tag="finish_if_skipped"})
      elseif value[1] == "y" then
        animation.to(translation_target, {y = target_value}, {time = delay, easing = easing, tag="finish_if_skipped"})
      end
      -- if x ~= nil then
      --    animation.to(translation_target, {x = x}, {time = delay, easing = easing, tag="finish_if_skipped"})
      -- end
      -- if y ~= nil then
      --   animation.to(translation_target, {y = y}, {time = delay, easing = easing, tag="finish_if_skipped"})
      -- end
    end
  end

  function object:makeHonk(x, y, duration)
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