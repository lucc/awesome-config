-- widgets for the bar {{{1
-- vim: foldmethod=marker

-- required modules {{{1
local awful = require("awful")
local wibox = require("wibox")
local vicious = require("vicious")
local pango = require("pango")

local music = require("widgets/mpd")
local mail = require("widgets/notmuch")

-- battery {{{1

-- copied from the vicious readme
local batwidget = awful.widget.progressbar()
batwidget:set_width(8)
batwidget:set_height(10)
batwidget:set_vertical(true)
batwidget:set_background_color("#494B4F")
batwidget:set_border_color(nil)
batwidget:set_color(
  {
    type = "linear",
    from = { 0, 0 },
    to = { 0, 10 },
    stops = {
      { 0, "#AECF96" },
      { 0.5, "#88A175" },
      { 1, "#FF5656" }
    }
  }
  )
--vicious.register(batwidget, vicious.widgets.bat, "$2", 61, "BAT0")

local textbat=wibox.widget.textbox()
local textbat_tooltip = awful.tooltip({ objects = { textbat } })

vicious.register(textbat, vicious.widgets.bat,
  function (widget, args)
    local col = 'red'
    if args[2] > 33 then
      if args[2] > 66 then
	col = 'green'
      else
	col = 'orange'
      end
    end
    --"<span color='green'>power@$2%=$3</span>"
    textbat_tooltip:set_text(
      'Connected: ' .. args[1] .. '\n' ..
      'Level: ' .. args[2] .. '%\n' ..
      'Time: ' .. args[3]
      )
    return pango.color(col, args[3])
  end,
  67, "BAT0")

-- wifi info box {{{1
local mywifitext = wibox.widget.textbox()
vicious.register(mywifitext, vicious.widgets.wifi,
  -- 'ssid: ${ssid}, mode: ${mode}, chan: ${chan}, rate: ${rate},
  -- link: ${link}, linp: ${linp}, sign: ${sign}',
  ' ${ssid} ',
  --' <span color="blue">${ssid}</span> ',
  120, "wlan0")

-- Pacman Widget {{{1
-- copied from http://www.jasonmaur.com/awesome-wm-widgets-configuration/
local pacwidget = wibox.widget.textbox()

local pacwidget_t = awful.tooltip({ objects = { pacwidget},})

vicious.register(pacwidget,
		 function (widget, args)
		   local str = ''
		   local count = 0
		   for line in io.popen('pacman -Qu'):lines() do
		     str = str .. line .. '\n'
		     count = count + 1
		   end
		   if count == 0 then
		     return ''
		   else
		     pacwidget_t:set_text(string.sub(str, 1, -2))
		     return "Updates available! "
		   end
		 end,
		 '$1',
		1800, "Arch")
                -- 1800 means check every 30 minutes

-- custom calendar and clock {{{1
-- Create a textclock widget
local mytextclock = awful.widget.textclock()
-- Calendar widget to attach to the textclock
local cal = require('cal')
cal.register(mytextclock)
-- TODO does not work?

-- return {{{1
return {
  battery = textbat,
  clock = mytextclock,
  mail = mail.widget,
  music = music,
  updates = pacwidget,
  wifi = mywifitext,
  --mailbutton = mail.button,
}
