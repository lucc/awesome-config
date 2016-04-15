-- widgets for the bar {{{1
-- vim: foldmethod=marker

-- required modules {{{1
local awful = require("awful")
local wibox = require("wibox")
local vicious = require("vicious")
local pango = require("pango")

local music = require("widgets/mpd")
local mail = require("widgets/notmuch")

local symbols = require("symbols")
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
local baticon = wibox.widget.textbox()
local textbat_tooltip = awful.tooltip({ objects = { baticon } })

vicious.register(baticon, vicious.widgets.bat,
  function (widget, args)
    local icon = symbols.battery0
    local col = 'red'
    local percent = args[2]
    if percent > 33 then
      col = 'yellow'
      icon = symbols.battery1
    end
    if percent > 50 then
      icon = symbols.battery2
    end
    if percent > 66 then
      col = 'green'
      icon = symbols.battery3
    end
    if percent > 95 then
      icon = symbols.battery4
    end
    --"<span color='green'>power@$2%=$3</span>"
    textbat_tooltip:set_text(
      'Connected: ' .. args[1] .. '\n' ..
      'Level: ' .. args[2] .. '%\n' ..
      'Time: ' .. args[3]
      )
    return pango.color(col, pango.font('Awesome', icon)) .. ' '
  end,
  67, "BAT0")

-- wifi info box {{{1
local mywifitext = wibox.widget.textbox()
local wifi_widget_tooltip = awful.tooltip({ objects = {mywifitext},})
vicious.register(mywifitext, vicious.widgets.wifi,
  function (widget, args)
  --' <span color="red" font="Awesome 14">'..symbols.wifi..'</span> ${ssid} ',
  --' <span color="blue">${ssid}</span> ',
    local color = 'red'
    local ssid = args['{ssid}']
    local symbol = pango.font('Awesome', symbols.wifi)
    if ssid == 'N/A' then
      wifi_widget_tooltip:set_text('\n Not connected! \n')
    else
      if args['{linp}'] >= 50 then
	color = 'green'
      else
	color = 'yellow'
      end
      wifi_widget_tooltip:set_text(ssid)
    end
    return pango.color(color, pango.font('Awesome', symbols.wifi)) .. ' '
  end,
  --'ssid: ${ssid}, mode: ${mode}, chan: ${chan}, rate: ${rate}, link: ${link}, linp: ${linp}, sign: ${sign}',
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
local mytextclock = awful.widget.textclock(" %a %b %d, %H:%M:%S " , 1)
-- Calendar widget to attach to the textclock
local cal = require('cal')
cal.register(mytextclock)

-- return {{{1
return {
  battery = baticon,
  clock = mytextclock,
  mail = mail.widget,
  music = music,
  updates = pacwidget,
  wifi = mywifitext,
  --mailbutton = mail.button,
}
