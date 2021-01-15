
local composer = require("composer")
local utilities = require("Source.utilities")

setup_chapter_1 = {}
setup_chapter_1.__index = setup_chapter_1

--
-- This is the definition for chapter 1 setup. Here the pre-built chapter_structure
-- of chapter 1 is defined. This is called right at the start of the whole game, by game_setup.
--

function setup_chapter_1:setup(chapter_structure)
  chapter_structure.first_part = "chapter_1_part_X"

  chapter_structure.bpm = 110
  chapter_structure.mpb = 545.4545454545
  chapter_structure.spelling_outro_mpb = 545.4545454545 / 2
  chapter_structure.time_sig = 4

  chapter_structure.flow = {}

  local flow = chapter_structure.flow
  chapter_structure.flow["chapter_1_part_X"] = {
    name="chapter_1_part_X",
    next=nil,
    type="scripted",
    cleanup=false,
    script=loadPartScript("chapter_1_part_X"),
    music="chapter_1_part_1",
  }

  -- local flow = chapter_structure.flow
  -- chapter_structure.flow["chapter_1_part_4"] = {
  --   name="chapter_1_part_4",
  --   next="chapter_2_interactive_choice_vehicle",
  --   type="scripted",
  --   cleanup=false,
  --   script=loadPartScript("chapter_1_part_4"),
  --   music="chapter_1_part_4",
  -- }


end

return setup_chapter_1