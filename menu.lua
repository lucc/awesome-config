-- the main menu

local awful = require("awful")
local beautiful = require("beautiful")
local hotkeys_popup = require("awful.hotkeys_popup").widget

local awesomemenu = {
   { "hotkeys", function() return false, hotkeys_popup.show_help end},
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
