-- awesome config file by luc {{{1
-- vim: foldmethod=marker

-- Standard awesome library {{{1
require("awful.autofocus")
local naughty = require("naughty") -- Notification library
local menubar = require("menubar")
menubar.utils = require("menubar.utils")

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

-- custom stuff {{{1
require("theme")
require("globals")
--
-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
require("bar") -- bar at the top of the screen

-- key and mouse bindings
local keys = require("keys")
root.keys(keys.global)
local buttons = require("mouse")
root.buttons(buttons.root)

require("rules")
require("signals")
