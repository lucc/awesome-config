-- widgets for the bar

-- required modules
local awful = require("awful")
local wibox = require("wibox")
local vicious = require("vicious")
local naughty = require("naughty")
local pango = require("pango")

local github = require("widgets/github")
local git = require("widgets/git")
local mail = require("widgets/notmuch")
local music = require("widgets/mpd")
local systemd = require("widgets/systemd")
local tasks = require("widgets/taskwarrior")
local updates = require("widgets/pacman")
local weather = require("widgets/weather")

local symbols = require("symbols")

-- battery
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
  67, "BAT1")

-- wifi info box
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
  120,
  "wlp1s0"
  )

-- filesystem info
local disk = wibox.widget.textbox()
disk.tooltip = awful.tooltip{objects = {disk}}
vicious.register(disk, vicious.widgets.fs,
  function (widget, args)
    local interesting_filesystems = {"/", "/home"}
    local percent = 100
    for i, fs in pairs(interesting_filesystems) do
      local p = args["{"..fs.." avail_p}"]
      if p ~= nil and p < percent then percent = p end
    end
    local color = ""
    if percent < 1 then color = "red"
    elseif percent < 2 then color = "yellow"
    elseif percent < 5 then color = "green"
    end
    if color ~= "" then
      local tooltip = "Free disk space"
      for i, fs in pairs(interesting_filesystems) do
	local p = args["{"..fs.." avail_p}"]
	if p ~= nil then
	  tooltip = tooltip .. "\n" .. fs .. "\t"
	  ..  args["{"..fs.." avail_gb}"] .. "GB free (" .. p .. "%)"
	end
      end
      widget.tooltip:set_markup(tooltip)
      return pango.color(color, pango.iconic(symbols.disk2))
    end
    return ""
  end, 307)

-- custom calendar and clock
-- Create a textclock widget
local mytextclock = wibox.widget.textclock(" %a %b %d, %H:%M:%S " , 1)
-- Calendar widget to attach to the textclock
local cal = require('cal')
cal.register(mytextclock)

-- spacing between widgets
local space = wibox.widget.textbox()
space:set_text(" ")

-- return {{{1
return {
  battery = baticon,
  clock = mytextclock,
  disk = disk,
  github = github,
  git = git,
  mail = mail,
  music = music,
  space = space,
  systemd = systemd,
  tasks = tasks,
  updates = updates,
  weather = weather,
  wifi = mywifitext,
}
