-- theme and color set up

local beautiful = require("beautiful") -- Theme handling library
local getdir = require("awful").util.getdir
local gears = require("gears")

beautiful.init(gears.filesystem.get_xdg_config_home() .. "awesome/themes/awesome-solarized/dark/theme.lua")
beautiful.border_width = 1

-- Wallpaper {{{1
if beautiful.wallpaper then
    for s = 1, screen.count() do
        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
end
