-- the main menu

local awful = require("awful")
local beautiful = require("beautiful")

local awesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}
local keyboardmenu = {
  { "german", "sh -c 'setxkbmap de && xmodmap ~/.config/xinit/Xmodmap'" },
  { "german neo", "setxkbmap de neo" },
}
local mainmenu = awful.menu({
  items = {
    { "awesome", awesomemenu, beautiful.awesome_icon },
    { "open terminal", terminal },
    { "switch keyboard layout", keyboardmenu }
  }
})

return mainmenu
