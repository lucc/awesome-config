-- mouse bindings for awesome, by luc {{{1
-- vim: foldmethod=marker

local awful = require("awful")
local mymainmenu = require("menu")

-- Mouse bindings {{{1
local rootbuttons = awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
)

-- client mouse bindings {{{1
local clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- return client and root buttons {{{1
return { client = clientbuttons, root = rootbuttons }
