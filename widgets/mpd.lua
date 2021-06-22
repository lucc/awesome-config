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

local mpd = lain.widget.mpd {
  music_dir = '/media/nas/audio',
  settings = function()
    widget:set_markup(format_symbol(mpd_now.state))
  end,
}

function mpd.toggle()   awful.spawn("mpc toggle") mpd.update() end
function mpd.next()     awful.spawn("mpc next")   mpd.update() end
function mpd.previous() awful.spawn("mpc prev")   mpd.update() end
function mpd.stop()     awful.spawn('mpc stop')   mpd.update() end
function mpd.tui2() run_in_central_terminal('ncmpcpp') end
function mpd.gui() awful.spawn('cantata') end

mpd.widget:buttons(awful.util.table.join(
  awful.button({ }, 1, mpd.toggle),
  awful.button({ }, 2, mpd.tui),
  awful.button({ }, 3, mpd.next)
  ))
mpd.widget:connect_signal("mouse::enter", mpd.update)

-- set the default icon size for mpd-notifcation(1)
naughty.config.defaults.icon_size = 64

return mpd
