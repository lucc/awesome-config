-- An awesome widget to display information about mpd status.

local awful = require("awful")
local naughty = require("naughty")
local lain = require("lain")

local pango = require("pango")
local symbols = require("symbols")
local run_in_central_terminal = require("functions").run_in_central_terminal

local function format_symbol (state)
  local color = 'yellow'
  local icon
  if state == 'play' then
    icon = symbols.play2
  elseif state == 'pause' then
    icon = symbols.pause2
  elseif state == 'stop' then
    color = 'blue'
    icon = symbols.stop2
  else
    color = 'red'
    icon = 'MPD: Error!'
  end
  return pango.color(color, pango.iconic(icon)) .. ' '
end

local widget = lain.widget.mpd {
  music_dir = '/media/nas/audio',
  settings = function ()
    widget:set_markup(format_symbol(mpd_now.state))
  end,
}

widget.toggle = function () awful.spawn("mpc toggle"); widget.update() end
widget.next = function () awful.spawn("mpc next"); widget.update() end
widget.previous = function () awful.spawn("mpc prev"); widget.update() end
widget.stop = function () awful.spawn('mpc stop'); widget.update() end
widget.tui = function () run_in_central_terminal('ncmpcpp') end
widget.gui = function () awful.spawn('cantata') end

widget.widget:buttons(awful.util.table.join(
  awful.button({ }, 1, widget.toggle),
  awful.button({ }, 2, widget.tui),
  awful.button({ }, 3, widget.next)
  ))
widget.widget:connect_signal("mouse::enter", widget.update)

-- set the default icon size for mpd-notifcation(1)
naughty.config.defaults.icon_size = 64

return widget
