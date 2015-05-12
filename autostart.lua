local naughty = require("naughty")
local awful = require("awful")
awful.util = require("awful.util")
local tags = require("tags")
tags = tags.tags
naughty.notify({text = 'do you want a full start?', run = function ()
  awful.util.spawn('firefox')
  awful.util.spawn('gvim')
  awful.tag.viewonly(
    tags[
      mouse.screen
      ][3]
    )
  awful.util.spawn(terminal)
end
})
