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
    local time = args[3]
    local rate = args[5] == 'N/A' and 'N/A' or (args[5]..'W')
    textbat_tooltip:set_text(
      string.format('Connected: %s\nLevel: %s%%\nTime: %s\nRate: %s',
		    args[1], percent, time, rate))
    if args[1] == '-' and (percent < 10 or
	time == '00:00' or time == '00:01' or time == '00:02' or
	time == '00:03' or time == '00:04' or time == '00:05') then
      naughty.notify({ preset = naughty.config.presets.critical,
		       title="Battery low!",
		       text='Only '..time..' remaining!'})
    end
    return pango.color(col, pango.iconic(icon)) .. ' '
  end,
  67, "BAT0")

-- wifi info box {{{1
local mywifitext = wibox.widget.textbox()
local wifi_widget_tooltip = awful.tooltip({ objects = {mywifitext},})
vicious.register(mywifitext, vicious.widgets.wifi,
  function (widget, args)
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
    return pango.color(color, pango.iconic(symbols.wifi)) .. ' '
  end,
  --'ssid: ${ssid}, mode: ${mode}, chan: ${chan}, rate: ${rate}, link: ${link}, linp: ${linp}, sign: ${sign}',
  120,
  "wlp3s0" --"wlan0"
  )

-- Pacman Widget {{{1
-- originally copied from
-- http://www.jasonmaur.com/awesome-wm-widgets-configuration/
local updates = wibox.widget.textbox()
updates.tooltip = awful.tooltip({objects={updates}})
updates.set = function(widget, icon, tooltip)
  widget.tooltip:set_markup(tooltip)
  widget:set_markup(pango.iconic(icon))
end
updates.update = function (widget)
  async({'pacman', '--query', 'linux'},
    function(stdout)
      local installed = string.sub(stdout, 7, -2)
      async({'uname', '-r'},
	function(stdout2)
	  local running = string.sub(stdout2, 1, installed:len())
	  if installed == running then
	    async({'pacman', '--query', '--upgrades'},
	      function(text, _, _, code)
		local icon = ''
		if code == 0 then
		  icon = pango.color('green', symbols.update2)
		end
		widget:set(icon, text)
	    end)
	  else
	    widget:set(
	      pango.color('red', symbols.reboot),
	      pango('b', 'You should reboot')..'\n'..
	      pango.color('green', 'installed kernel:\t')..installed..'\n'..
	      pango.color('red', 'running kernel:\t')..running)
	  end
      end)
  end)
end
updates.timer = gears.timer{
  timeout = 30 * 60,
  autostart = true,
  callback = function() updates:update() end,
}
updates:update()

-- custom calendar and clock {{{1
-- Create a textclock widget
local mytextclock = wibox.widget.textclock(" %a %b %d, %H:%M:%S " , 1)
-- Calendar widget to attach to the textclock
local cal = require('cal')
cal.register(mytextclock)


-- systemd failed units
local systemd = wibox.widget.textbox()
systemd.tooltip = awful.tooltip({ objects = { systemd } })
systemd.update = function(widget)
  async({"systemctl", "list-units",
         "--state=failed", "--plain", "--no-legend"},
    function (stdout, stderr, reason, code)
      local msg = ''
      local icon = ''
      if stdout ~= "" then
	icon = pango.color('red', pango.iconic(symbols.alert2))
	for line in string.gmatch(stdout, '[^\n]+') do
	  msg = msg .. '\n' .. string.gsub(line, '^([^ ]+)%.[^. ]+ .*', '%1')
	end
	msg = string.sub(msg, 2)
      end
      widget:set_markup(icon)
      widget.tooltip:set_text(msg)
    end)
end
gears.timer{
  timeout = 100,
  autostart = true,
  callback = function() systemd:update() end
}
systemd:update()

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
  taskwarriror = taskwarriror,
  systemd = systemd,
}
