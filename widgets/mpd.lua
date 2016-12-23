-- An awesome widget to display information about mpd status.

local awful = require("awful")
local naughty = require("naughty")
local vicious = require("vicious")
local wibox = require("wibox")

local pango = require("pango")
local symbols = require("symbols")
local run_in_centeral_terminal = require("functions").run_in_centeral_terminal

local widget = wibox.widget.textbox()
widget.get_data = vicious.widgets.mpd
widget.tooltip = awful.tooltip({ objects = { widget } })

widget.format_symbol = function (data)
  local state = data['{state}']
  local color = 'yellow'
  local icon
  if state == 'Play' then
    icon = symbols.play2
  elseif state == 'Pause' then
    icon = symbols.pause2
  elseif state == 'Stop' then
    color = 'blue'
    icon = symbols.stop2
  else
    color = 'red'
    icon = 'MPD: Error!'
  end
  return pango.color(color, pango.font('Awesome', icon)) .. ' '
end

widget.format_text = function (data)
  return 'Artist: ' .. data['{Artist}'] .. '\n' ..
         'Album: '  .. data['{Album}']  .. '\n' ..
	 'Title: '  .. data['{Title}']
end

widget.toggle = function () awful.util.spawn("mpc toggle") end
widget.next = function () awful.util.spawn("mpc next") end
widget.previous = function () awful.util.spawn("mpc prev") end

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
  awful.button({ }, 1, function () widget:toggle(); widget:refresh() end),
  awful.button({ }, 2, function () run_in_centeral_terminal("ncmpcpp") end),
  awful.button({ }, 3, function () widget:next(); widget:refresh() end)
  ))
widget:connect_signal("mouse::enter", function () widget:refresh() end)

vicious.register(widget, widget.get_data, widget.formatter, 101, nil)

-- set the default icon size for mpd-notifcation(1)
naughty.config.defaults.icon_size = 64

return widget
