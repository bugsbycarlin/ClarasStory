
local composer = require("composer")

game_setup = {}
game_setup.__index = game_setup

--
-- This is the definition for game setup. Game setup initializes universal
-- structures, including sprite info, the sprite cache table, the master
-- list of chapters, and the pre-built structures for each chapter.
--

function game_setup:setup()

  sprite_info = require("Source.sprite_info")
  composer.setVariable("sprite_info", sprite_info)

  sprite_cache = {}
  composer.setVariable("sprite_cache", sprite_cache)

  chapters = {"1", "2", "mandala"}
  composer.setVariable("chapters", chapters)

  chapter_structures = {}
  composer.setVariable("chapter_structures", chapter_structures)

  for i = 1, #chapters do
    chapter_structures[chapters[i]] = {}

    local chapter_source = require("Source.setup_chapter_" .. tostring(chapters[i]))
    chapter_source:setup(chapter_structures[chapters[i]])
  end
end

return game_setup