
local awful = require("awful")
awful.rules = require("awful.rules")
local beautiful = require("beautiful")
local buttons = require("mouse")
local keys = require("keys")
local tags = require("tags")
local layouts = tags.layouts
tags = tags.tags

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
    { rule = { class = "URxvt", instance = "calculator" },
      properties = { floating = true, ontop = true } },
    { rule = { class = "URxvt", instance = "center" },
      properties = { floating = true, ontop = true },
      callback = function(c)
	local screen = screen[mouse.screen].geometry
	local x = screen.width / 8
	local y = screen.height / 8
	local width = screen.width * 3 / 4
	local height = screen.height * 3 / 4
	c:geometry({x = x, y = y, width = width, height = height})
      end }
}
