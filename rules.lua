
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
                     --buttons = buttons.client,
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

    -- Set Firefox to always map on the tag named "2" on screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { screen = 1, tag = "2" } },

    -- Set the browser to always map on tags number 1 of screen 1.
    { rule = { class = "Firefox", instance = "Navigator" },
      properties = { tag = '1' } },
    { rule = { class = "qutebrowser" }, properties = { tag = '1' } },

    { rule = { class = "URxvt", instance = "calculator" },
      properties = { floating = true, ontop = true } },

    { rule = { instance = "center" },
      properties = { floating = true },
      callback = function(c)
	local screen = screen[mouse.screen].geometry
	local x = screen.width / 8
	local y = screen.height / 8
	local width = screen.width * 3 / 4
	local height = screen.height * 3 / 4
	c:geometry({x = x, y = y, width = width, height = height})
      end },

    -- put the prolog help in maximized mode
    { rule = { instance = "SWI-Prolog help", class = "Pui manual" },
      properties = { maximized = true } },
}
