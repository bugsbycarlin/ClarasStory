
local picture_info = {}

-- letters
-- picture_info["A"] = {
--   file_name = "Letter_A_Sketch.png",
--   file_size = 4096,
--   sprite_size = 400,
--   sprite_count = 17,
-- }
-- picture_info["B"] = {
--   file_name = "Letter_B_Sketch.png",
--   file_size = 4096,
--   sprite_size = 400,
--   sprite_count = 17,
-- }
-- picture_info["C"] = {
--   file_name = "Letter_C_Sketch.png",
--   file_size = 4096,
--   sprite_size = 400,
--   sprite_count = 11,
-- }
-- picture_info["D"] = {
--   file_name = "Letter_D_Sketch.png",
--   file_size = 4096,
--   sprite_size = 400,
--   sprite_count = 10,
-- }
-- picture_info["E"] = {
--   file_name = "Letter_E_Sketch.png",
--   file_size = 4096,
--   sprite_size = 400,
--   sprite_count = 21,
-- }
-- picture_info["F"] = {
--   file_name = "Letter_F_Sketch.png",
--   file_size = 4096,
--   sprite_size = 400,
--   sprite_count = 16,
-- }
-- picture_info["L"] = {
--   file_name = "Letter_L_Sketch.png",
--   file_size = 4096,
--   sprite_size = 400,
--   sprite_count = 14,
-- }
-- picture_info["O"] = {
--   file_name = "Letter_O_Sketch.png",
--   file_size = 4096,
--   sprite_size = 400,
--   sprite_count = 32,
-- }
-- picture_info["R"] = {
--   file_name = "Letter_R_Sketch.png",
--   file_size = 4096,
--   sprite_size = 400,
--   sprite_count = 22,
-- }
-- picture_info["S"] = {
--   file_name = "Letter_S_Sketch.png",
--   file_size = 4096,
--   sprite_size = 400,
--   sprite_count = 32,
-- }
-- picture_info["T"] = {
--   file_name = "Letter_T_Sketch.png",
--   file_size = 4096,
--   sprite_size = 400,
--   sprite_count = 12,
-- }
-- picture_info["Y"] = {
--   file_name = "Letter_Y_Sketch.png",
--   file_size = 4096,
--   sprite_size = 400,
--   sprite_count = 25,
-- }



-- objects
-- picture_info["Apple"] = {
--   file_name = "Apple_Sketch.png",
--   file_size = 7200,
--   sprite_size = 720,
--   sprite_count = 47,
-- }

picture_info["Earth"] = {
  file_name = "Earth_Sketch.png",
  file_size = 4096,
  sprite_size = 400,
  sprite_count = 58,
}

picture_info["Bird"] = {
  file_name = "Bird_Sketch.png",
  file_size = 4096,
  sprite_size = 400,
  sprite_count = 52,
}

picture_info["Sweater"] = {
  file_name = "Sweater_Sketch.png",
  file_size = 4096,
  sprite_size = 400,
  sprite_count = 33,
}

picture_info["Tower"] = {
  file_name = "Tower_Sketch.png",
  file_size = 4096,
  sprite_size = 400,
  sprite_count = 30,
}

picture_info["City"] = {
  file_name = "City_Sketch.png",
  file_size = 7200,
  sprite_size = 720,
  sprite_count = 24,
}

picture_info["Seaside"] = {
  file_name = "Seaside_Sketch.png",
  file_size = 7200,
  sprite_size = 720,
  sprite_count = 11,
}

picture_info["Girl"] = {
  file_name = "Girl_Sketch.png",
  file_size = 7200,
  sprite_size = 720,
  sprite_count = 28,
}

picture_info["Green_Star"] = {
  file_name = "Green_Star_Sketch.png",
  file_size = 2048,
  sprite_size = 200,
  sprite_count = 15,
}

picture_info["Yellow_Star"] = {
  file_name = "Yellow_Star_Sketch.png",
  file_size = 2048,
  sprite_size = 200,
  sprite_count = 15,
}

picture_info["Blue_Star"] = {
  file_name = "Blue_Star_Sketch.png",
  file_size = 2048,
  sprite_size = 200,
  sprite_count = 15,
}

picture_info["Red_Star"] = {
  file_name = "Red_Star_Sketch.png",
  file_size = 2048,
  sprite_size = 200,
  sprite_count = 15,
}

picture_info["Orange_Star"] = {
  file_name = "Orange_Star_Sketch.png",
  file_size = 2048,
  sprite_size = 200,
  sprite_count = 15,
}

picture_info["Purple_Star"] = {
  file_name = "Purple_Star_Sketch.png",
  file_size = 2048,
  sprite_size = 200,
  sprite_count = 15,
}

picture_info["Pink_Star"] = {
  file_name = "Pink_Star_Sketch.png",
  file_size = 2048,
  sprite_size = 200,
  sprite_count = 15,
}



for picture, info in pairs(picture_info) do
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

-- function picture_info:getFrame(name, number)

-- end

-- function picture_info:getLastFrame(name)
--   return self:getFrame(name, picture_info[])
-- end

return picture_info