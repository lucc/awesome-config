local awful = require("awful")
local pango = require("pango")
local json = require("json")
local shell = require("awful.spawn").easy_async_with_shell
local symbols = require("symbols")
local wibox = require("wibox")

local function update(self)
  local pass = 'pass show www/github.com'
  local sed = [[sed -n '1h;/^user: /{s/^user: //;s/$/:/;G;s/\n//;p;q;}']]
  local url = 'https://api.github.com/notifications'
  shell('curl --user $('..pass..'|'..sed..') '..url,
    function (stdout, stderr, exitreason, exitcode)
      self.notifications = json.decode(stdout)
      if #self.notifications ~= 0 then
	self:set_markup(pango.color('yellow', symbols.gtihub))
	self.tooltip.text = stdout
      else
	self:set_markup()
      end
    end)
end

local github = wibox.widget.textbox()
github.tooltip = awful.tooltip({objects = {github}})
github.update = update

github:update()

return github
