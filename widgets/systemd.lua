-- An awesome widget to display information about failed systemd units.

local async = require("awful.spawn").easy_async_with_shell
local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")

local functions = require("functions")
local join = functions.join
local terminal = functions.run_in_central_terminal
local pango = require("pango")
local symbols = require("symbols")

local systemd = wibox.widget.textbox()
systemd.cache = {}
systemd.tooltip = awful.tooltip({ objects = { systemd } })

function systemd.update(widget)
  local args = "list-units --state=failed --plain --no-legend"
  async("systemctl "..args.."; systemctl --user "..args,
    function (stdout, stderr, reason, _code)
      local msg = ''
      local icon = ''
      widget.cache = {}
      if stdout ~= "" then
	icon = pango.color('red', pango.iconic(symbols.alert2)) .. ' '
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

function systemd.gui()
  terminal("sh", "-c", "systemctl status "..join(systemd.cache, " ").." | less")
end

systemd:buttons(awful.util.table.join(
  awful.button({}, 1, systemd.gui)
))

gears.timer{
  timeout = 100,
  autostart = true,
  callback = function() systemd:update() end
}
systemd:update()

return systemd
