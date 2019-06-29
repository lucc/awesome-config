local lain = require("lain")
local wibox = require("wibox")

local weather = lain.widget.weather {
  city_id = 2867714,  -- Munich
  showpopup = "off",  -- do not attach to popup to this widget directly
  settings = function ()
    local units = math.floor(weather_now["main"]["temp"])
    widget:set_markup(units .. '°C ')
  end
}
local weather_container = wibox.widget {
  weather.icon,
  weather,
  layout = wibox.layout.align.horizontal
}
weather.attach(weather_container)

return weather_container
