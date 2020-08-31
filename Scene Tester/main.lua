local composer = require("composer")

display.setStatusBar(display.HiddenStatusBar)

math.randomseed(os.time())

composer.gotoScene("Source.editor")
-- composer.gotoScene("Source.interactive_spelling")
-- composer.gotoScene("Source.chapter")

