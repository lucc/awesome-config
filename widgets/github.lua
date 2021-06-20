local awful = require("awful")
local gears = require("gears")
local json = require("lain.util.dkjson")
local pango = require("pango")
local spawn = require("awful").spawn
local symbols = require("symbols")
local wibox = require("wibox")
local functions = require("functions")

local default_url = 'https://github.com/notifications'
local api = functions.api({ key = 'api/awesomewm@api.github.com' })

local function update(self)
  api('https://api.github.com/notifications',
    function(notifications)
      if notifications ~= nil and #notifications ~= 0 then
	self:set_markup(pango.color('yellow', pango.iconic(symbols.github)))
	local lines = {}
	for i, n in pairs(notifications) do
	  lines[i] = n.repository.full_name ..': ' .. n.subject.title
	end
	self.tooltip.text = functions.join(lines, '\n')
	if #notifications == 1 then
	  api(notifications[1].subject.latest_comment_url,
	    function(data)
	      if data ~= nil then
		self.url = data.html_url
	      else
		self.url = default_url
	      end
	    end)
	else
	  self.url = default_url
	end
      else
	self:set_markup("")
      end
    end)
end

local github = wibox.widget.textbox()
github.tooltip = awful.tooltip({objects = {github}})
github.update = update
github.open = function() spawn({'xdg-open', github.url}) end
github.button1 = function() github:open() github:update() end

gears.timer{
  timeout = 5 * 60,
  autostart = true,
  callback = function() github:update() end,
}
github:buttons(awful.util.table.join(
  awful.button({}, 1, github.button1)
))

return github
