
local awful = require("awful")
local wibox = require("wibox")

local original_set_markup = wibox.widget.textbox.set_markup

local function set_markup(widget, markup)
  --if markup == "" or markup == nil then
  --  widget.forced_width = nil
  --else
  --  widget.forced_width = widget._width
  --end
  original_set_markup(widget, " "..markup.." ")
end

local function texticon(options)
  options = options or {}
  options.tooltip = options.tooltip or true
  options.align = "center"
  options.valign = "center"
  --options.forced_width = options.width or 20
  options.widget = wibox.widget.textbox
  local widget = wibox.widget(options)
  if options.tooltip then
    widget.tooltip = awful.tooltip{ objects = { widget } }
  end
  --widget._width = options.forced_width
  return widget
end

return texticon
