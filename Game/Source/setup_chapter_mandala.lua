
local composer = require("composer")
local utilities = require("Source.utilities")

setup_chapter_mandala = {}
setup_chapter_mandala.__index = setup_chapter_mandala

--
-- This is the definition for mandala chapter setup. Here the pre-built chapter_structure
-- of the little mandala chapter is defined. This is called right at the start of the whole game, by game_setup.
--

function setup_chapter_mandala:setup(chapter_structure)
  chapter_structure.first_part = "chapter_2_mandala"

  local mpb = 375
  chapter_structure.bpm = 160
  chapter_structure.mpb = 375
  chapter_structure.spelling_outro_mpb = 375
  chapter_structure.time_sig = 4

  chapter_structure.flow = {}
  chapter_structure.flow["chapter_2_mandala"] = {
    name="chapter_2_mandala",
    next=nil,
    prev=nil,
    type="mandala",
    script=loadPartScript("chapter_2_mandala"),
  }
end

return setup_chapter_mandala