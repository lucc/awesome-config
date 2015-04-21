-- An awesome widget to display information about mpd status.

local awful = require("awful")
local naughty = require("naughty")
local vicious = require("vicious")
local wibox = require("wibox")

local pango = require("pango")

local widget = wibox.widget.textbox()
widget.get_data = vicious.widgets.mpd
widget.tooltip = awful.tooltip({ objects = { widget } })

widget.format_symbol = function (data)
  local state = data['{state}']
  if state == 'Play' then
    return pango.color('yellow', ' ▶ ') -- alt: "\xE2\x8F\xB5" = "⏵"
  elseif state == 'Pause' then
    return pango.color('yellow', ' \xE2\x8F\xB8 ') -- alt:
  elseif state == 'Stop' then
    return pango.color('blue', ' ◼ ') -- alt: "\xE2\x8F\xB9" = "⏹"
  else
    return pango.color('red', ' MPD: Error! ')
  end
end

widget.format_text = function (data)
  return 'Artist: ' .. data['{Artist}'] .. '\n' ..
         'Album: '  .. data['{Album}']  .. '\n' ..
	 'Title: '  .. data['{Title}']
end

widget.toggle = function () awful.util.spawn("mpc toggle") end
widget.next = function () awful.util.spawn("mpc next") end
widget.previous = function () awful.util.spawn("mpc previous") end

widget.formatter = function (widget, args)
  widget.tooltip:set_text(widget.format_text(args))
  return widget.format_symbol(args)
end

widget.refresh = function (self)
  local data = self.get_data()
  self:set_markup(self.formatter(self, data))
  --naughty.notify({title = 'MPD', text = self.format_text(data)})
end

widget:buttons(awful.util.table.join(
  awful.button({ }, 1, function () widget:refresh() end)))

vicious.register(widget, widget.get_data, widget.formatter, 101, nil)

-- set the default icon size for mpd-notifcation(1)
naughty.config.defaults.icon_size = 64

return widget
