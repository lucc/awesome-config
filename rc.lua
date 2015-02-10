-- awesome config file by luc {{{1
-- vim: foldmethod=marker

-- Standard awesome library {{{1
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
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

-- Wallpaper {{{1
if beautiful.wallpaper then
    for s = 1, screen.count() do
        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
end

-- Tags {{{1
local tags = require("tags")

-- Menu {{{1
-- Create a laucher widget and a main menu
local mymainmenu = require("menu")
mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it

-- bar at the top of the screen {{{1
require('bar')

-- key and mouse bindings {{{1
keys = require('keys')
root.keys(keys.global)
buttons = require('mouse')
root.buttons(buttons.root)

-- Rules {{{1
require("rules")

-- Signals {{{1
require("signals")
