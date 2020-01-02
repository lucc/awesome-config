local awful = require("awful")
local gears = require("gears")
local join = require("functions").join
local json = require("lain.util.dkjson")
local pango = require("pango")
local shell = require("awful.spawn").easy_async_with_shell
local symbols = require("symbols")
local wibox = require("wibox")

local default_url = 'https://github.com/notifications'
local token = nil

local function curl(url, callback)
  if token == nil then
    shell('pass show api/awesomewm@api.github.com',
      function(stdout, stderr, exitreason, exitcode)
	local index = string.find(stdout, '\n')
	if index ~= nil then
	  token = string.sub(stdout, 1, index - 1)
	end
      end)
  end
  shell('curl --header "Authorization: token '..token..'" '..url,
    function(stdout, stderr, exitreason, exitcode)
      callback(json.decode(stdout))
    end)
end

local function update(self)
  curl('https://api.github.com/notifications',
    function(notifications)
      if notifications ~= nil and #notifications ~= 0 then
	self:set_markup(pango.color('yellow', pango.iconic(symbols.gtihub)))
	local lines = {}
	for i, n in pairs(notifications) do
	  lines[i] = n.repository.full_name ..': ' .. n.subject.title
	end
	self.tooltip.text = join(lines, '\n')
	if #notifications == 1 then
	  curl(notifications[1].subject.latest_comment_url,
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
github.open = function() shell('xdg-open ' .. github.url, function() end) end
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
