
local asset_info = {}

-- letters
asset_info["A"] = {
  file_name = "Letter_A_Sketch.png",
  file_size = 4096,
  sprite_size = 400,
  sprite_count = 17,
}
asset_info["B"] = {
  file_name = "Letter_B_Sketch.png",
  file_size = 4096,
  sprite_size = 400,
  sprite_count = 17,
}
asset_info["C"] = {
  file_name = "Letter_C_Sketch.png",
  file_size = 4096,
  sprite_size = 400,
  sprite_count = 11,
}
asset_info["D"] = {
  file_name = "Letter_D_Sketch.png",
  file_size = 4096,
  sprite_size = 400,
  sprite_count = 10,
}
asset_info["E"] = {
  file_name = "Letter_E_Sketch.png",
  file_size = 4096,
  sprite_size = 400,
  sprite_count = 21,
}
asset_info["F"] = {
  file_name = "Letter_F_Sketch.png",
  file_size = 4096,
  sprite_size = 400,
  sprite_count = 16,
}
asset_info["L"] = {
  file_name = "Letter_L_Sketch.png",
  file_size = 4096,
  sprite_size = 400,
  sprite_count = 14,
}
asset_info["O"] = {
  file_name = "Letter_O_Sketch.png",
  file_size = 4096,
  sprite_size = 400,
  sprite_count = 32,
}
asset_info["R"] = {
  file_name = "Letter_R_Sketch.png",
  file_size = 4096,
  sprite_size = 400,
  sprite_count = 22,
}
asset_info["S"] = {
  file_name = "Letter_S_Sketch.png",
  file_size = 4096,
  sprite_size = 400,
  sprite_count = 32,
}
asset_info["T"] = {
  file_name = "Letter_T_Sketch.png",
  file_size = 4096,
  sprite_size = 400,
  sprite_count = 12,
}
asset_info["Y"] = {
  file_name = "Letter_Y_Sketch.png",
  file_size = 4096,
  sprite_size = 400,
  sprite_count = 25,
}

asset_info["Apple"] = {
  file_name = "Apple_Sketch.png",
  file_size = 7200,
  sprite_size = 720,
  sprite_count = 47,
}

asset_info["Earth"] = {
  file_name = "Earth_Sketch.png",
  file_size = 4096,
  sprite_size = 400,
  sprite_count = 58,
}

asset_info["Bird"] = {
  file_name = "Bird_Sketch.png",
  file_size = 7200,
  sprite_size = 720,
  sprite_count = 52,
}

asset_info["Tower"] = {
  file_name = "Tower_Sketch.png",
  file_size = 7200,
  sprite_size = 720,
  sprite_count = 30,
}

asset_info["City"] = {
  file_name = "City_Sketch.png",
  file_size = 7200,
  sprite_size = 720,
  sprite_count = 24,
}


for asset, info in pairs(asset_info) do
  file_name = info["file_name"]
  sprite_size = info["sprite_size"]
  info.frames = {}
  info.sheet = {
    sheetContentWidth = info["file_size"],
    sheetContentHeight = info["file_size"],
    frames = {}
  }
  -- dang
  for i = 1, info["sprite_count"] do
    info["sheet"].frames[i] = {
      x = sprite_size * ((i - 1) % 10),
      y = sprite_size * (math.floor((i-1) / 10)),
      width = sprite_size,
      height = sprite_size,
    }
    table.insert(info.frames, i)
  end
end

-- function asset_info:getFrame(name, number)

-- end

-- function asset_info:getLastFrame(name)
--   return self:getFrame(name, asset_info[])
-- end

return asset_info