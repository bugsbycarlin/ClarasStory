
local composer = require("composer")
local game_setup = require("Source.game_setup")

display.setStatusBar(display.HiddenStatusBar)

math.randomseed(os.time())

print("pre setup")
game_setup:setup()
print("post setup")

composer.gotoScene("Source.chapter_select")
