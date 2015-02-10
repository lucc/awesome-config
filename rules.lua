
local awful = require("awful")
awful.rules = require("awful.rules")
local beautiful = require("beautiful")
local buttons = require("mouse")
local keys = require("keys")

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
