-- theme and color set up

local beautiful = require("beautiful") -- Theme handling library
local getdir = require("awful").util.getdir
local gears = require("gears")

local theme = os.getenv("theme") or "solarized"
local tone = os.getenv("tone") or "dark"

-- Themes define colours, icons, font and wallpapers.
if theme == "solarized" then
  beautiful.init(getdir("config") .. "/themes/awesome-solarized/" .. tone .. "/theme.lua")
  beautiful.border_width = 1
  --beautiful.border_normal = beautiful.colors.base01
elseif theme == "zenburn" then
  beautiful.init("/usr/share/awesome/themes/zenburn/theme.lua")
else
  --beautiful.init("/usr/share/awesome/themes/sky/theme.lua")
  beautiful.init("/usr/share/awesome/themes/default/theme.lua")
end

-- Wallpaper {{{1
if beautiful.wallpaper then
    for s = 1, screen.count() do
        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
end

--package.path = package.path .. ';/usr/lib/python3.4/site-packages/powerline/bindings/awesome/?.lua'
--require('powerline')
