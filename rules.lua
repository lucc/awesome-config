
local awful = require("awful")
awful.rules = require("awful.rules")
local beautiful = require("beautiful")
local clientbuttons = require("mouse").client
local clientkeys = require("keys").client

-- Rules {{{1
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen
     }
    },

    -- Floating clients.
    { rule_any = {
        instance = {
          "DTA",  -- Firefox addon DownThemAll.
          "copyq",  -- Includes session name in class.
        },
        class = {
	  "Arandr",
	  "gimp",
	  "Gpick",
	  "Kruler",
	  "MessageWin",  -- kalarm.
	  "mpv",
	  "pinentry",
	  "Pinentry",
	  "Sxiv",
	  "veromix",
	  "Wpa_gui",
          "xtightvncviewer"},

        name = {
          "Event Tester",  -- xev.
        },
        role = {
          "AlarmWindow",  -- Thunderbird's calendar.
          "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
      }, properties = { floating = true }},

    -- Set the browser to always map on tags number 1 of screen 1.
    { rule = { class = "qutebrowser" },
      properties = { tag = '1' } },

}
