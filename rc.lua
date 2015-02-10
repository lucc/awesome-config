-- awesome config file by luc {{{1
-- vim: foldmethod=marker

-- Standard awesome library {{{1
local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")

-- manually added
--package.path = package.path .. ';/usr/lib/python3.4/site-packages/powerline/bindings/awesome/?.lua'
--require('powerline')
require("globals")

-- Error handling {{{1
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end

-- Variable definitions {{{1
-- Themes define colours, icons, font and wallpapers.
beautiful.init("/usr/share/awesome/themes/default/theme.lua")
--beautiful.init("/usr/share/awesome/themes/sky/theme.lua")
--beautiful.init("/usr/share/awesome/themes/zenburn/theme.lua")

-- Table of layouts to cover with awful.layout.inc, order matters.
local layouts =
{
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier
}

-- Wallpaper {{{1
if beautiful.wallpaper then
    for s = 1, screen.count() do
        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
end

-- Tags {{{1
-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, screen.count() do
  -- Each screen has its own tag table.
  tags[s] = awful.tag(
    { 1, 2, 3, 4, 5, 6, 7, 8, 9 },
    -- some alternatives from http://awesome.naquadah.org/wiki/Symbolic_tag_names
    --{ "➊", "➋", "➌", "➍", "➎", "➏", "➐", "➑", "➒" },
    --{ "♨", "⌨", "⚡", "✉", "☕", "❁", "☃", "☭", "⚢" },
    --{ "☠", "⌥", "✇", "⌤", "⍜", "✣", "⌨", "⌘", "☕" },
    s,
    layouts[8]
  )
end

-- Menu {{{1
-- Create a laucher widget and a main menu
mymainmenu = require("menu")
mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it

-- Wibox {{{1
require('bar')

-- key and mouse bindings {{{1
keys = require('keys')
root.keys(keys.global)
buttons = require('mouse')
root.buttons(buttons.root)

-- Rules {{{1
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = keys.client,
                     buttons = buttons.client } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "gimp" },
      properties = { floating = true } },
    -- Set Firefox to always map on tags number 1 of screen 1.
    { rule = { class = "Firefox" },
      properties = { tag = tags[1][1] } },
    -- Set Gvim to always map on tags number 2 of screen 1.
    { rule = { class = "Gvim" },
      properties = { tag = tags[1][2] } },
}

-- Signals {{{1
require("signals")
