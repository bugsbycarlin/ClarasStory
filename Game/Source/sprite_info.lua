
--
-- This is a huge sheet of sprite info, to be used bo the loader, the stage, and the sprite
-- class to make sprites according to my own formulae.
--

local sprite_info = {}

-- letters
sprite_info["A"] = {
  file_name = "A.png",
  sprite_size = 200,
  always_load = true,
}
sprite_info["B"] = {
  file_name = "B.png",
  sprite_size = 200,
  always_load = true,
}
sprite_info["C"] = {
  file_name = "C.png",
  sprite_size = 200,
  always_load = true,
}
sprite_info["D"] = {
  file_name = "D.png",
  sprite_size = 200,
  always_load = true,
}
sprite_info["E"] = {
  file_name = "E.png",
  sprite_size = 200,
  always_load = true,
}
sprite_info["F"] = {
  file_name = "F.png",
  sprite_size = 200,
  always_load = true,
}
sprite_info["G"] = {
  file_name = "G.png",
  sprite_size = 200,
  always_load = true,
}
sprite_info["H"] = {
  file_name = "H.png",
  sprite_size = 200,
  always_load = true,
}
sprite_info["I"] = {
  file_name = "I.png",
  sprite_size = 200,
  always_load = true,
}
sprite_info["J"] = {
  file_name = "J.png",
  sprite_size = 200,
  always_load = true,
}
sprite_info["K"] = {
  file_name = "K.png",
  sprite_size = 200,
  always_load = true,
}
sprite_info["L"] = {
  file_name = "L.png",
  sprite_size = 200,
  always_load = true,
}
sprite_info["M"] = {
  file_name = "M.png",
  sprite_size = 200,
  always_load = true,
}
sprite_info["N"] = {
  file_name = "N.png",
  sprite_size = 200,
  always_load = true,
}
sprite_info["O"] = {
  file_name = "O.png",
  sprite_size = 200,
  always_load = true,
}
sprite_info["P"] = {
  file_name = "P.png",
  sprite_size = 200,
  always_load = true,
}
sprite_info["Q"] = {
  file_name = "Q.png",
  sprite_size = 200,
  always_load = true,
}
sprite_info["R"] = {
  file_name = "R.png",
  sprite_size = 200,
  always_load = true,
}
sprite_info["S"] = {
  file_name = "S.png",
  sprite_size = 200,
  always_load = true,
}
sprite_info["T"] = {
  file_name = "T.png",
  sprite_size = 200,
  always_load = true,
}
sprite_info["U"] = {
  file_name = "U.png",
  sprite_size = 200,
  always_load = true,
}
sprite_info["V"] = {
  file_name = "V.png",
  sprite_size = 200,
  always_load = true,
}
sprite_info["W"] = {
  file_name = "W.png",
  sprite_size = 200,
  always_load = true,
}
sprite_info["X"] = {
  file_name = "X.png",
  sprite_size = 200,
  always_load = true,
}
sprite_info["Y"] = {
  file_name = "Y.png",
  sprite_size = 200,
  always_load = true,
}
sprite_info["Z"] = {
  file_name = "Z.png",
  sprite_size = 200,
  always_load = true,
}


-- UI
sprite_info["Letter_Box"] = {
  file_name = "Letter_Box.png",
  row_length = 2,
  sprite_size = 200,
  sprite_count = 2,
  always_load = true,
}

sprite_info["Letter_Box_Small"] = {
  file_name = "Letter_Box_Small.png",
  sprite_size = 100,
}

sprite_info["Wooden_Block"] = {
  file_name = "Wooden_Block.png",
  sprite_size = 120,
  always_load = true,
}

sprite_info["Book_Background"] = {
  file_name = "Book_Background.png",
  sprite_size = 1024,
  sprite_height = 768,
  always_load = true,
}

sprite_info["Book_Large"] = {
  file_name = "Book_Large.png",
  sprite_size = 2048,
  always_load = true,
}

sprite_info["Spiral_Notebook"] = {
  file_name = "Spiral_Notebook.png",
  row_length = 4,
  sprite_size = 1024,
  sprite_height = 1024,
  sprite_count = 8,
  animations = {
    flip = {
      2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8,
      1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
      1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
      1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    },
  },
}

sprite_info["Sepia_Filter"] = {
  file_name = "sepia_filter.png",
  sprite_size = 1024,
  sprite_height = 1024,
}


-- Stars

sprite_info["Green_Star"] = {
  file_name = "Green_Star_Sketch.png",
  row_length = 5,
  sprite_size = 200,
  sprite_count = 15,
  always_load = true,
  animations = {
    sketch = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15},
  },
}

sprite_info["Yellow_Star"] = {
  file_name = "Yellow_Star_Sketch.png",
  row_length = 5,
  sprite_size = 200,
  sprite_count = 15,
  always_load = true,
  animations = {
    sketch = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15},
  },
}

sprite_info["Blue_Star"] = {
  file_name = "Blue_Star_Sketch.png",
  row_length = 5,
  sprite_size = 200,
  sprite_count = 15,
  always_load = true,
  animations = {
    sketch = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15},
  },
}

sprite_info["Red_Star"] = {
  file_name = "Red_Star_Sketch.png",
  row_length = 5,
  sprite_size = 200,
  sprite_count = 15,
  always_load = true,
  animations = {
    sketch = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15},
  },
}

sprite_info["Orange_Star"] = {
  file_name = "Orange_Star_Sketch.png",
  row_length = 5,
  sprite_size = 200,
  sprite_count = 15,
  always_load = true,
  animations = {
    sketch = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15},
  },
}

sprite_info["Purple_Star"] = {
  file_name = "Purple_Star_Sketch.png",
  row_length = 5,
  sprite_size = 200,
  sprite_count = 15,
  always_load = true,
  animations = {
    sketch = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15},
  },
}

sprite_info["Pink_Star"] = {
  file_name = "Pink_Star_Sketch.png",
  row_length = 5,
  sprite_size = 200,
  sprite_count = 15,
  always_load = true,
  animations = {
    sketch = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15},
  },
}

-- things to see and spell
sprite_info["Apple"] = {
  file_name = "Apple_Sketch.png",
  row_length = 5,
  sprite_size = 400,
  sprite_count = 25,
  animations = {
    sketch = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25},
  },
  always_load = true,
}

sprite_info["Earth"] = {
  file_name = "Earth_Sketch.png",
  row_length = 10,
  sprite_size = 400,
  sprite_count = 58,
  animations = {
    sketch = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15,
      16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30,
      31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45,
      46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58},
  },
}

sprite_info["Sun"] = {
  file_name = "Sun.png",
  row_length = 2,
  sprite_size = 400,
  sprite_count = 2,
  animations = {
    animation = {1, 1, 2, 2,},
  },
}

sprite_info["Bird"] = {
  file_name = "Bird_Sketch.png",
  row_length = 5,
  sprite_size = 400,
  sprite_count = 25,
  animations = {
    sketch = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25},
  },
}

sprite_info["Little_Boat"] = {
  file_name = "Little_Boat_Sketch.png",
  row_length = 5,
  sprite_size = 200,
  sprite_count = 25,
  animations = {
    sketch = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25},
  },
}

sprite_info["Little_Wave"] = {
  file_name = "Little_Wave.png",
  sprite_size = 200,
}

sprite_info["Blue_Sky"] = {
  file_name = "Blue_Sky.png",
  sprite_size = 200,
}

sprite_info["Orange_Sky"] = {
  file_name = "Orange_Sky.png",
  sprite_size = 200,
}

sprite_info["Sweater"] = {
  file_name = "Sweater_Sketch.png",
  row_length = 5,
  sprite_size = 400,
  sprite_count = 25,
  animations = {
    sketch = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25},
  },
}

sprite_info["Tower"] = {
  file_name = "Tower_Sketch.png",
  row_length = 5,
  sprite_size = 400,
  sprite_count = 25,
  animations = {
    sketch = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25},
  },
}

sprite_info["Girl_Shadow"] = {
  file_name = "Girl_Shadow_Sketch.png",
  row_length = 5,
  sprite_size = 400,
  sprite_count = 19,
  outline_frame = 8,
}

sprite_info["Black_and_White_Town"] = {
  file_name = "Black_and_White_Town.png",
  sprite_size = 400,
  sprite_height = 256,
}

sprite_info["Seaside_Road"] = {
  file_name = "Seaside_Road.png",
  sprite_size = 1024,
}

sprite_info["Seagull"] = {
  file_name = "Seagull.png",
  sprite_size = 200,
}

sprite_info["Beach"] = {
  file_name = "Beach.png",
  sprite_size = 1024,
  sprite_height = 768,
}

sprite_info["Window"] = {
  file_name = "Window_Sketch.png",
  row_length = 5,
  sprite_size = 400,
  sprite_height = 600,
  sprite_count = 12,
  animations = {
    sketch = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12},
  },
}

sprite_info["Brown_Square"] = {
  file_name = "Brown_Square.png",
  sprite_size = 128,
}

sprite_info["White_Square"] = {
  file_name = "White_Square.png",
  sprite_size = 128,
}

sprite_info["Couch"] = {
  file_name = "Couch.png",
  sprite_size = 800,
}

sprite_info["Hill"] = {
  file_name = "Hill.png",
  sprite_size = 1024,
}

sprite_info["Mountain"] = {
  file_name = "Mountain.png",
  sprite_size = 1024,
}


sprite_info["Mom"] = {
  file_name = "Mom_Sketch.png",
  row_length = 5,
  sprite_size = 400,
  sprite_count = 25,
  animations = {
    sketch = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25},
  },
}

sprite_info["Home"] = {
  file_name = "Home_Sketch.png",
  row_length = 5,
  sprite_size = 400,
  sprite_count = 25,
  animations = {
    sketch = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25},
  },
}

sprite_info["Phone"] = {
  file_name = "Phone_Sketch.png",
  row_length = 5,
  sprite_size = 400,
  sprite_count = 22,
  animations = {
    sketch = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22},
  },
}

sprite_info["Wand"] = {
  file_name = "Wand_Sketch.png",
  row_length = 5,
  sprite_size = 400,
  sprite_count = 25,
  animations = {
    sketch = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25},
  },
}

sprite_info["Teddy"] = {
  file_name = "Teddy_Sketch.png",
  row_length = 5,
  sprite_size = 400,
  sprite_count = 25,
  animations = {
    sketch = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25},
  },
}

sprite_info["Snack"] = {
  file_name = "Snack_Sketch.png",
  row_length = 5,
  sprite_size = 400,
  sprite_count = 25,
  animations = {
    sketch = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25},
  },
}

sprite_info["Orange"] = {
  file_name = "Orange_Sketch.png",
  row_length = 5,
  sprite_size = 400,
  sprite_count = 21,
  always_load = true,
  animations = {
    sketch = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21},
  },
}

sprite_info["Banana"] = {
  file_name = "Banana_Sketch.png",
  row_length = 5,
  sprite_size = 400,
  sprite_count = 20,
  always_load = true,
  animations = {
    sketch = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20},
  },
}

sprite_info["Plum"] = {
  file_name = "Plum_Sketch.png",
  row_length = 5,
  sprite_size = 400,
  sprite_count = 24,
  always_load = true,
  animations = {
    sketch = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24},
  },
}

sprite_info["Spotlight"] = {
  file_name = "Spotlight.png",
  sprite_size = 1024,
  sprite_height = 768,
}

sprite_info["Farm"] = {
  file_name = "Farm_Single.png",
  sprite_size = 1024,
  sprite_height = 768,
}

sprite_info["River"] = {
  file_name = "River_Single.png",
  sprite_size = 1024,
  sprite_height = 768,
}

sprite_info["Fruit_Beast"] = {
  file_name = "Fruit_Beast_Sketch.png",
  row_length = 6,
  sprite_size = 320,
  sprite_count = 34,
  animations = {
    static = {16},
    sketch = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16},
    animating = {17, 17, 18, 18, 19, 19, 20, 20, 21, 21, 22, 22,
      23, 23, 24, 24, 25, 25, 26, 26, 27, 27, 28, 28, 29, 29,
      30, 30, 31, 31, 32, 32, 33, 33, 34, 34}
  },
}

sprite_info["Food_Beast"] = {
  file_name = "Food_Beast_Dance.png",
  row_length = 4,
  sprite_size = 425,
  sprite_height = 729,
  sprite_count = 19,
  animations = {
    animating = {
      1, 2, 3, 4, 5, 6, 6, 6, 6, 6,
      6, 6, 6, 6, 6, 6, 6, 7, 8, 9,
      10, 1, 1, 1, 1, 1, 1, 1, 1, 1,
      1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
      1, 1, 1, 1, 1, 11, 12, 13, 14, 15,
      15, 15, 15, 15, 15, 15, 15, 15, 15, 15,
      15, 15, 16, 17, 18, 19, 1, 1, 1, 1,
      1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
      1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    },
  },
}

sprite_info["Bridge"] = {
  file_name = "Bridge_Sketch.png",
  row_length = 4,
  sprite_size = 512,
  sprite_height = 400,
  sprite_count = 12,
  animations = {
    sketch = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12},
  },
}

sprite_info["Speech_Bubble"] = {
  file_name = "Speech_Bubble.png",
  sprite_size = 400,
}

sprite_info["Pig"] = {
  file_name = "Pig_Sketch.png",
  row_length = 5,
  sprite_size = 400,
  sprite_count = 23,
  animations = {
    sketch = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23},
  },
}

sprite_info["Cow"] = {
  file_name = "Cow_Sketch.png",
  row_length = 5,
  sprite_size = 400,
  sprite_count = 25,
  animations = {
    sketch = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25},
  },
}

sprite_info["Coin"] = {
  file_name = "Coin_Sketch.png",
  row_length = 4,
  sprite_size = 256,
  sprite_count = 16,
  animations = {
    sketch = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16},
  },
}

sprite_info["Pear"] = {
  file_name = "Pear_Sketch.png",
  row_length = 4,
  sprite_size = 256,
  sprite_count = 14,
  always_load = true,
  animations = {
    sketch = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14},
  },
}

sprite_info["Lime"] = {
  file_name = "Lime_Sketch.png",
  row_length = 4,
  sprite_size = 256,
  sprite_count = 15,
  always_load = true,
  animations = {
    sketch = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15},
  },
}

sprite_info["Tent"] = {
  file_name = "Tent_Sketch.png",
  row_length = 2,
  sprite_size = 512,
  sprite_count = 4,
  animations = {
    sketch = {1, 2, 3, 4},
  },
}

sprite_info["Farmer"] = {
  file_name = "Farmer_Sketch.png",
  row_length = 8,
  sprite_size = 256,
  sprite_height = 400,
  sprite_count = 32,
  animations = {
    sketch = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12},
    animating = {17, 17, 18, 18, 19, 19, 20, 20, 21, 21, 22, 22,
      23, 23, 24, 24, 25, 25, 26, 26, 27, 27, 28, 28, 29, 29,
      30, 30, 31, 31, 32, 32},
  },
}


sprite_info["Backpack"] = {
  file_name = "Backpack_Sketch.png",
  row_length = 5,
  sprite_size = 400,
  sprite_count = 25,
  animations = {
    sketch = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25},
  },
}


sprite_info["Dad"] = {
  file_name = "Dad_Sketch.png",
  row_length = 5,
  sprite_size = 400,
  sprite_count = 25,
  animations = {
    sketch = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25},
  },
}


sprite_info["Girl"] = {
  file_name = "Girl_Sketch.png",
  row_length = 5,
  sprite_size = 400,
  sprite_count = 25,
  animations = {
    sketch = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25},
  },
}

sprite_info["Car_Red"] = {
  file_name = "Car_Red_Small.png",
  sprite_size = 256,
}

sprite_info["Car_Green"] = {
  file_name = "Car_Green_Small.png",
  sprite_size = 256,
}

sprite_info["Car_Blue"] = {
  file_name = "Car_Blue_Small.png",
  sprite_size = 256,
}

sprite_info["Car_Pink"] = {
  file_name = "Car_Pink_Small.png",
  sprite_size = 256,
}

sprite_info["Car_Purple"] = {
  file_name = "Car_Purple_Small.png",
  sprite_size = 256,
}

sprite_info["Car_Yellow"] = {
  file_name = "Car_Yellow_Small.png",
  sprite_size = 256,
}

sprite_info["Car_Orange"] = {
  file_name = "Car_Orange_Small.png",
  sprite_size = 256,
}

sprite_info["Car_Gray"] = {
  file_name = "Car_Gray_Small.png",
  sprite_size = 256,
}


sprite_info["Truck_Red"] = {
  file_name = "Truck_Red_Small.png",
  sprite_size = 256,
}

sprite_info["Truck_Green"] = {
  file_name = "Truck_Green_Small.png",
  sprite_size = 256,
}

sprite_info["Truck_Blue"] = {
  file_name = "Truck_Blue_Small.png",
  sprite_size = 256,
}

sprite_info["Truck_Pink"] = {
  file_name = "Truck_Pink_Small.png",
  sprite_size = 256,
}

sprite_info["Truck_Purple"] = {
  file_name = "Truck_Purple_Small.png",
  sprite_size = 256,
}

sprite_info["Truck_Yellow"] = {
  file_name = "Truck_Yellow_Small.png",
  sprite_size = 256,
}

sprite_info["Truck_Orange"] = {
  file_name = "Truck_Orange_Small.png",
  sprite_size = 256,
}

sprite_info["Truck_Gray"] = {
  file_name = "Truck_Gray_Small.png",
  sprite_size = 256,
}

sprite_info["Bus_Blue"] = {
  file_name = "Bus_Blue_Small.png",
  sprite_size = 256,
}

sprite_info["Bus_Yellow"] = {
  file_name = "Bus_Yellow_Small.png",
  sprite_size = 256,
}

sprite_info["Bus_Orange"] = {
  file_name = "Bus_Orange_Small.png",
  sprite_size = 256,
}

sprite_info["Bus_Gray"] = {
  file_name = "Bus_Gray_Small.png",
  sprite_size = 256,
}

sprite_info["Taxi"] = {
  file_name = "Taxi_Small.png",
  sprite_size = 256,
}

sprite_info["Bike_Red"] = {
  file_name = "Bike_Red_Small.png",
  row_length = 2,
  sprite_size = 256,
  sprite_count = 2,
  animations = {
    animating = {
      1, 1, 2, 2,
    },
  },
}

sprite_info["Bike_Green"] = {
  file_name = "Bike_Green_Small.png",
  row_length = 2,
  sprite_size = 256,
  sprite_count = 2,
  animations = {
    animating = {1, 1, 2, 2,},
  },
}

sprite_info["Bike_Blue"] = {
  file_name = "Bike_Blue_Small.png",
  row_length = 2,
  sprite_size = 256,
  sprite_count = 2,
  animations = {
    animating = {1, 1, 2, 2,},
  },
}

sprite_info["Bike_Pink"] = {
  file_name = "Bike_Pink_Small.png",
  row_length = 2,
  sprite_size = 256,
  sprite_count = 2,
  animations = {
    animating = {1, 1, 2, 2,},
  },
}

sprite_info["Bike_Purple"] = {
  file_name = "Bike_Purple_Small.png",
  row_length = 2,
  sprite_size = 256,
  sprite_count = 2,
  animations = {
    animating = {1, 1, 2, 2,},
  },
}

sprite_info["Bike_Yellow"] = {
  file_name = "Bike_Yellow_Small.png",
  row_length = 2,
  sprite_size = 256,
  sprite_count = 2,
  animations = {
    animating = {1, 1, 2, 2,},
  },
}

sprite_info["Bike_Orange"] = {
  file_name = "Bike_Orange_Small.png",
  row_length = 2,
  sprite_size = 256,
  sprite_count = 2,
  animations = {
    animating = {1, 1, 2, 2,},
  },
}

sprite_info["Bike_Gray"] = {
  file_name = "Bike_Gray_Small.png",
  row_length = 2,
  sprite_size = 256,
  sprite_count = 2,
  animations = {
    animating = {1, 1, 2, 2,},
  },
}

sprite_info["Bike_Girl"] = {
  file_name = "Bike_Girl.png",
  sprite_size = 256,
}

sprite_info["City_Block"] = {
  file_name = "City_Block.png",
  sprite_size = 1024,
  sprite_height = 768,
}

sprite_info["City_Block_with_Mural"] = {
  file_name = "City_Block_with_Mural.png",
  sprite_size = 1024,
  sprite_height = 1024,
}

sprite_info["City_Block_with_Mural_zoom"] = {
  file_name = "City_Block_with_Mural_zoom.png",
  sprite_size = 1024,
  sprite_height = 768,
}

sprite_info["Brick_Lines_Overlay"] = {
  file_name = "Brick_Lines_Overlay.png",
  sprite_size = 1024,
  sprite_height = 768,
}

sprite_info["Restaurant_Tables"] = {
  file_name = "Restaurant_Tables.png",
  sprite_size = 1024,
  sprite_height = 173,
}

sprite_info["City_Block_Wider"] = {
  file_name = "City_Block_Wider.png",
  sprite_size = 2048,
  sprite_height = 768,
}

sprite_info["City_Stack_1"] = {
  file_name = "City_Stack_1.png",
  sprite_size = 1024,
  sprite_height = 1292,
}

sprite_info["City_Stack_2"] = {
  file_name = "City_Stack_2.png",
  sprite_size = 1024,
  sprite_height = 872,
}

sprite_info["City_Stack_3"] = {
  file_name = "City_Stack_3.png",
  sprite_size = 1024,
  sprite_height = 901,
}

sprite_info["Palm"] = {
  file_name = "Palm.png",
  sprite_size = 256,
  sprite_height = 512,
}

sprite_info["Perimeter"] = {
  file_name = "Perimeter.png",
  sprite_size = 128,
}

sprite_info["Honk"] = {
  file_name = "Honk.png",
  sprite_size = 256,
}

sprite_info["Cloud"] = {
  file_name = "Cloud.png",
  sprite_size = 256,
}

sprite_info["Horizontal_Dash"] = {
  file_name = "Horizontal_Dash.png",
  sprite_size = 128,
}

sprite_info["Vertical_Dash"] = {
  file_name = "Vertical_Dash.png",
  sprite_size = 128,
}

sprite_info["Blue_Paint"] = {
  file_name = "Blue_Paint.png",
  sprite_size = 128,
}

sprite_info["Red_Paint"] = {
  file_name = "Red_Paint.png",
  sprite_size = 128,
}

sprite_info["Yellow_Paint"] = {
  file_name = "Yellow_Paint.png",
  sprite_size = 128,
}

sprite_info["Orange_Paint"] = {
  file_name = "Orange_Paint.png",
  sprite_size = 128,
}

sprite_info["Purple_Paint"] = {
  file_name = "Purple_Paint.png",
  sprite_size = 128,
}

sprite_info["Green_Paint"] = {
  file_name = "Green_Paint.png",
  sprite_size = 128,
}

sprite_info["Pink_Paint"] = {
  file_name = "Pink_Paint.png",
  sprite_size = 128,
}

sprite_info["Gray_Paint"] = {
  file_name = "Gray_Paint.png",
  sprite_size = 128,
}

sprite_info["Brown_Paint"] = {
  file_name = "Brown_Paint.png",
  sprite_size = 128,
}

sprite_info["Black_Paint"] = {
  file_name = "Black_Paint.png",
  sprite_size = 128,
}

sprite_info["White_Paint"] = {
  file_name = "White_Paint.png",
  sprite_size = 128,
}

sprite_info["Treetop"] = {
  file_name = "Treetop.png",
  sprite_size = 1024,
  sprite_height = 768,
}

sprite_info["Large_Palm"] = {
  file_name = "Large_Palm.png",
  sprite_size = 425,
  sprite_height = 768,
}

sprite_info["Girl_Climbing"] = {
  file_name = "Girl_Climbing.png",
  sprite_size = 256,
}

sprite_info["Girl_Treetop"] = {
  file_name = "Girl_Treetop.png",
  sprite_size = 256,
}

sprite_info["Attention"] = {
  file_name = "Attention.png",
  sprite_size = 256,
}

sprite_info["Bakery"] = {
  file_name = "Bakery.png",
  sprite_size = 1024,
  sprite_height = 768,
}

sprite_info["Teapot"] = {
  file_name = "Teapot.png",
  sprite_size = 196,
  sprite_height = 135,
}

sprite_info["Chandelier"] = {
  file_name = "Chandelier.png",
  sprite_size = 268,
  sprite_height = 207,
}

sprite_info["Bouncy_Bread_1"] = {
  file_name = "Bouncy_Bread_1.png",
  sprite_size = 254,
  sprite_height = 113,
}

sprite_info["Bouncy_Bread_2"] = {
  file_name = "Bouncy_Bread_2.png",
  sprite_size = 294,
  sprite_height = 76,
}

sprite_info["Hi"] = {
  file_name = "Hi.png",
  sprite_size = 148,
  sprite_height = 109,
}


sprite_info["Mini_Brown_Rabbit"] = {
  file_name = "Mini_Brown_Rabbit.png",
  sprite_size = 128,
}

sprite_info["Mini_Gray_Rabbit"] = {
  file_name = "Mini_Gray_Rabbit.png",
  sprite_size = 128,
}

sprite_info["Mini_Brown_Bear"] = {
  file_name = "Mini_Brown_Bear.png",
  sprite_size = 128,
}

sprite_info["Mini_Gray_Bear"] = {
  file_name = "Mini_Gray_Bear.png",
  sprite_size = 128,
}

sprite_info["Mini_Pig"] = {
  file_name = "Mini_Pig.png",
  sprite_size = 128,
}

sprite_info["Mini_Human"] = {
  file_name = "Mini_Human.png",
  sprite_size = 128,
}

sprite_info["Mural"] = {
  file_name = "Mural_Sketch.png",
  row_length = 5,
  sprite_size = 800,
  sprite_height = 400,
  sprite_count = 17,
  animations = {
    static = {17},
    sketch = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17},
  },
}

sprite_info["Sign_Pie"] = {
  file_name = "Sign_Pie.png",
  sprite_size = 84,
  sprite_height = 48,
}

sprite_info["Sign_Peace"] = {
  file_name = "Sign_Peace.png",
  sprite_size = 185,
  sprite_height = 48,
}

sprite_info["Mural_Red"] = {
  file_name = "Mural_Red.png",
  sprite_size = 800,
  sprite_height = 400,
  sprite_count = 5,
  animations = {
    brush = {1},
    static = {5},
    animating = {1, 2, 3, 4, 5},
  },
}

sprite_info["Mural_Blue"] = {
  file_name = "Mural_Blue.png",
  sprite_size = 800,
  sprite_height = 400,
  sprite_count = 5,
  animations = {
    brush = {1},
    static = {5},
    animating = {1, 2, 3, 4, 5},
  },
}

sprite_info["Mural_Purple"] = {
  file_name = "Mural_Purple.png",
  sprite_size = 800,
  sprite_height = 400,
  sprite_count = 5,
  animations = {
    brush = {1},
    static = {5},
    animating = {1, 2, 3, 4, 5},
  },
}

sprite_info["Mural_Orange"] = {
  file_name = "Mural_Orange.png",
  sprite_size = 800,
  sprite_height = 400,
  sprite_count = 5,
  animations = {
    brush = {1},
    static = {5},
    animating = {1, 2, 3, 4, 5},
  },
}

sprite_info["Mural_Green"] = {
  file_name = "Mural_Green.png",
  sprite_size = 800,
  sprite_height = 400,
  sprite_count = 5,
  animations = {
    brush = {1},
    static = {5},
    animating = {1, 2, 3, 4, 5},
  },
}

sprite_info["Mural_Brown"] = {
  file_name = "Mural_Brown.png",
  sprite_size = 800,
  sprite_height = 400,
  sprite_count = 5,
  animations = {
    brush = {1},
    static = {5},
    animating = {1, 2, 3, 4, 5},
  },
}


sprite_info["Mural_Yellow"] = {
  file_name = "Mural_Yellow.png",
  sprite_size = 800,
  sprite_height = 400,
  sprite_count = 5,
  animations = {
    brush = {1},
    static = {5},
    animating = {1, 2, 3, 4, 5},
  },
}

sprite_info["Mural_Black"] = {
  file_name = "Mural_Black.png",
  sprite_size = 800,
  sprite_height = 400,
  sprite_count = 5,
  animations = {
    brush = {1},
    static = {5},
    animating = {1, 2, 3, 4, 5},
  },
}

sprite_info["Mural_White"] = {
  file_name = "Mural_White.png",
  sprite_size = 800,
  sprite_height = 400,
  sprite_count = 5,
  animations = {
    brush = {1},
    static = {5},
    animating = {1, 2, 3, 4, 5},
  },
}

sprite_info["Georges"] = {
  file_name = "Georges.png",
  sprite_size = 400,
  sprite_height = 500,
}

sprite_info["Georges_Laughing"] = {
  file_name = "Georges_Laughing.png",
  sprite_size = 400,
  sprite_height = 500,
}

sprite_info["Girl_Facing_Forward"] = {
  file_name = "Girl_Facing_Forward.png",
  sprite_size = 300,
  sprite_height = 400,
}

sprite_info["Georges_Excuse"] = {
  file_name = "Georges_Excuse.png",
  sprite_size = 400,
}

sprite_info["Clara_v2"] = {
  file_name = "Clara_v2.png",
  sprite_size = 512,
}

-- sprite_info["Paint_Beast"] = {
--   file_name = "Paint_Beast.png",
--   sprite_size = 768,
--   sprite_height = 1024,
-- }

sprite_info["Paint_Beast"] = {
  file_name = "Paint_Beast_Dance.png",
  row_length = 10,
  sprite_size = 409,
  sprite_height = 866,
  sprite_count = 19,
  animations = {
    animating = {
      1, 2, 3, 4, 5, 6, 6, 6, 6, 6,
      6, 6, 6, 6, 6, 6, 6, 7, 8, 9,
      10, 1, 1, 1, 1, 1, 1, 1, 1, 1,
      1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
      1, 1, 1, 1, 1, 11, 12, 13, 14, 15,
      15, 15, 15, 15, 15, 15, 15, 15, 15, 15,
      15, 15, 16, 17, 18, 19, 1, 1, 1, 1,
      1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
      1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    },
  },
}

sprite_info["Clara_Dance"] = {
  file_name = "Clara_Dance.png",
  row_length = 8,
  sprite_size = 405,
  sprite_height = 531,
  sprite_count = 23,
  animations = {
    animating = {
      11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10
    },
  },
}

sprite_info["Small_Mural"] = {
  file_name = "Small_Mural.png",
  sprite_size = 200,
  sprite_height = 100,
}

sprite_info["Agreement_1"] = {
  file_name = "Agreement_1.png",
  sprite_size = 256,
}

sprite_info["Agreement_2"] = {
  file_name = "Agreement_2.png",
  sprite_size = 256,
}

sprite_info["Agreement_3"] = {
  file_name = "Agreement_3.png",
  sprite_size = 256,
}

sprite_info["Restaurant_View"] = {
  file_name = "Restaurant_View.png",
  sprite_size = 1024,
  sprite_height = 768,
}

sprite_info["Little_White_Boat_Shadow"] = {
  file_name = "Little_White_Boat_Shadow.png",
  sprite_size = 48,
}

sprite_info["Little_Black_Boat_Shadow"] = {
  file_name = "Little_Black_Boat_Shadow.png",
  sprite_size = 48,
}

sprite_info["Thumb_1"] = {
  file_name = "Thumb_1.png",
  sprite_size = 128,
}

sprite_info["Thumb_2"] = {
  file_name = "Thumb_2.png",
  sprite_size = 128,
}

sprite_info["Donut"] = {
  file_name = "Donut.png",
  sprite_size = 256,
}

sprite_info["Kebab"] = {
  file_name = "Kebab.png",
  sprite_size = 256,
}

sprite_info["Mixer"] = {
  file_name = "Mixer.png",
  sprite_size = 400,
}

sprite_info["Mandala_Background"] = {
  file_name = "Mandala_Background.png",
  sprite_size = 650,
}


for name, info in pairs(sprite_info) do

  -- augmentations to info
  if info["row_length"] == nil then
    info["row_length"] = 1
  end
  if info["sprite_height"] == nil then
    info["sprite_height"] = info["sprite_size"]
  end
  if info["sprite_count"] == nil then
    info["sprite_count"] = 1
  end
  if info["animations"] == nil then
    info["animations"] = {
      static = {1},
    }
  end
  info.frames = {}

  -- if static is missing from animations, either make it the last
  -- frame of sketch, or frame 1.
  if info.animations["static"] == nil then
    if info.animations["sketch"] == nil then
      info.animations["static"] = {1}
    else
      info.animations["static"] = {info.animations["sketch"][#info.animations["sketch"]]}
    end
  end

  info.sheet = {
    sheetContentWidth = info.row_length * info.sprite_size,
    sheetContentHeight = math.ceil(info.sprite_count / info.row_length) * info.sprite_height,
    frames = {}
  }

  for i = 1, info.sprite_count do
    info.sheet.frames[i] = {
      x = info.sprite_size * ((i - 1) % info.row_length),
      y = info.sprite_height * (math.floor((i-1) / info.row_length)),
      width = info.sprite_size,
      height = info.sprite_height,
    }
    table.insert(info.frames, i)
  end
end


return sprite_info