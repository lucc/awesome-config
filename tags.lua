
local awful = require("awful")

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

-- Define a tag table which hold all screen tags.
local tags = {}
for s = 1, screen.count() do
  -- Each screen has its own tag table.
  tags[s] = awful.tag(
    { 1, 2, 3, 4, 5, 6, 7, 8, 9 },
    -- some alternatives from http://awesome.naquadah.org/wiki/Symbolic_tag_names
    --{ "➊", "➋", "➌", "➍", "➎", "➏", "➐", "➑", "➒" },
    --{ "♨", "⌨", "⚡", "✉", "☕", "❁", "☃", "☭", "⚢" },
    --{ "☠", "⌥", "✇", "⌤", "⍜", "✣", "⌨", "⌘", "☕" },
    s,
    layouts[2]
  )
end
return { tags = tags, layouts = layouts }
