-- widgets for the bar {{{1
-- vim: foldmethod=marker

-- required modules {{{1
local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local vicious = require("vicious")
local naughty = require("naughty")
local pango = require("pango")
local async = require("awful.spawn").easy_async_with_shell

local github = require("widgets/github")
local mail = require("widgets/notmuch")
local music = require("widgets/mpd")
local taskwarriror = require("widgets/taskwarrior")
local updates = require("widgets/pacman")
local weather = require("widgets/weather")

local symbols = require("symbols")
local functions = require("functions")
local terminal = functions.run_in_centeral_terminal
local join = functions.join
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
      local notification = naughty.notify({
	  preset = naughty.config.presets.critical,
	  title="Battery low!",
	  replaces_id = widget.last_id,
	  text='Only '..time..' remaining!'
      })
      widget.last_id = notification.id
    else
      local notification = naughty.getById(widget.last_id)
      naughty.destroy(notification)
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

-- custom calendar and clock {{{1
-- Create a textclock widget
local mytextclock = wibox.widget.textclock(" %a %b %d, %H:%M:%S " , 1)
-- Calendar widget to attach to the textclock
local cal = require('cal')
cal.register(mytextclock)


-- systemd failed units
local systemd = wibox.widget.textbox()
systemd.cache = {}
systemd.tooltip = awful.tooltip({ objects = { systemd } })
systemd.update = function(widget)
  local args = "list-units --state=failed --plain --no-legend"
  async("systemctl "..args.."; systemctl --user "..args,
    function (stdout, stderr, reason, _code)
      local msg = ''
      local icon = ''
      widget.cache = {}
      if stdout ~= "" then
	icon = pango.color('red', pango.iconic(symbols.alert2))
	for line in string.gmatch(stdout, '[^\n]+') do
	  local item = string.gsub(line, '^([^ ]+)%.[^. ]+ .*', '%1')
	  msg = msg .. '\n' .. item
	  table.insert(widget.cache, item)
	end
	msg = string.sub(msg, 2)
      end
      widget:set_markup(icon)
      widget.tooltip:set_text(msg)
    end)
end

systemd:buttons(awful.util.table.join(
  awful.button({}, 1, function ()
    terminal("systemctl " .. join(systemd.cache, " "))
  end)
))

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
  github = github,
  mail = mail,
  music = music,
  space = space,
  systemd = systemd,
  taskwarriror = taskwarriror,
  updates = updates,
  weather = weather,
  wifi = mywifitext,
}
