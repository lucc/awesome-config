-- widgets for the bar {{{1
-- vim: foldmethod=marker

-- required modules {{{1
local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local vicious = require("vicious")
local naughty = require("naughty")
local pango = require("pango")
local async = require("awful.spawn").easy_async

local music = require("widgets/mpd")
local mail = require("widgets/notmuch")
local taskwarriror = require("widgets/taskwarrior")

local symbols = require("symbols")
-- battery {{{1

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
    textbat_tooltip:set_text(string.format(
      'Connected: %s\nLevel: %s%%\nTime: %s\nRate: %sW', args[1], args[2], args[3], args[5]))
    if args[1] == '-' and (percent < 10 or
	args[3] == '00:00' or args[3] == '00:01' or args[3] == '00:02' or
	args[3] == '00:03' or args[3] == '00:04' or args[3] == '00:05') then
      naughty.notify({ preset = naughty.config.presets.critical,
		       title="Battery low!",
		       text='Only '..args[3]..' remaining!'})
    end
    return pango.color(col, pango.font('Awesome 18', icon)) .. ' '
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
    return pango.color(color, pango.font('Awesome 18', symbols.wifi)) .. ' '
  end,
  --'ssid: ${ssid}, mode: ${mode}, chan: ${chan}, rate: ${rate}, link: ${link}, linp: ${linp}, sign: ${sign}',
  120,
  "wlp3s0" --"wlan0"
  )

-- Pacman Widget {{{1
-- copied from http://www.jasonmaur.com/awesome-wm-widgets-configuration/
local updates = {}
updates.widget = wibox.widget.textbox()
updates.tooltip = awful.tooltip({objects={updates.widget}})
updates.update = function (container)
  async({'pacman', '--query', '--upgrades'},
    function (stdout, stderr, reason, code)
      container.tooltip:set_text(stdout)
      container.widget:set_markup('Updates available! ')
    end)
end
updates.timer = gears.timer{
  timeout = 30 * 60,
  callback = function() updates:update() end,
}

-- Warning about reboot after kernel update
local kernel_warning = wibox.widget.textbox()
local kernel_warning_t = awful.tooltip({ objects = { updates.widget },})
kernel_warning.refresh = function (widget, args)
  local installed = string.sub(io.popen('pacman -Q linux'):read(), 7)
  local running = string.sub(io.popen('uname -r'):read(), 1, string.len(installed))
  if running == installed then
    return ''
  else
    kernel_warning_t:set_text("Kernel update installed, you should rebot!")
    return pango.color('red', '!')
  end
end
--vicious.register(kernel_warning, kernel_warning.refresh, '$1', 3*3600, nil)


-- custom calendar and clock {{{1
-- Create a textclock widget
local mytextclock = wibox.widget.textclock(" %a %b %d, %H:%M:%S " , 1)
-- Calendar widget to attach to the textclock
local cal = require('cal')
cal.register(mytextclock)


-- spacing between widgets {{{1
local space = wibox.widget.textbox()
space:set_text(" ")

-- return {{{1
return {
  battery = baticon,
  clock = mytextclock,
  mail = mail,
  music = music,
  updates = updates,
  wifi = mywifitext,
  --mailbutton = mail.button,
  space = space,
  kernel_warning = kernel_warning,
  taskwarriror = taskwarriror,
}
