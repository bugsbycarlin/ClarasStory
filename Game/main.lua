local composer = require("composer")

display.setStatusBar(display.HiddenStatusBar)

math.randomseed(os.time())

-- audio.setVolume(0)
audio.setVolume(0.4, {channel=5})

composer.gotoScene("Source.editor")
-- composer.gotoScene("Source.chapter")

-- composer.gotoScene("Source.sound_tester")
