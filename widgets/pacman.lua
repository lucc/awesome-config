local async = require("awful.spawn").easy_async
local awful = require("awful")
local gears = require("gears")
local naughty = require("naughty")
local pango = require("pango")
local symbols = require("symbols")
local wibox = require("wibox")

-- Pacman Widget {{{1
-- originally copied from
-- http://www.jasonmaur.com/awesome-wm-widgets-configuration/
local updates = wibox.widget.textbox()
updates.tooltip = awful.tooltip({objects={updates}})
updates.set = function(widget, icon, tooltip)
  widget.tooltip:set_markup(tooltip)
  widget:set_markup(pango.iconic(icon))
end
updates.update = function (widget)
  async({'pacman', '--query', 'linux'},
    function(stdout)
      local installed = string.sub(stdout, 7, -2)
      async({'uname', '-r'},
	function(stdout2)
	  local running = string.sub(stdout2, 1, installed:len())
	  local f = function(iter)
	    local ret = ''
	    for x in iter do
	      ret = ret .. '\n|'..x..'|'
	    end
	    return ret
	  end
      naughty.notify({ preset = naughty.config.presets.critical,
		       title="debug",
		       text='installed:' .. f(string.gmatch(installed, '[^.-]+') ) ..
		       '\n'..
		       'running:' ..f(string.gmatch(running, '[^.-]+') ) ..
		       '\n'
		     })
	  if installed == running then
	    async({'pacman', '--query', '--upgrades'},
	      function(text, _, _, code)
		local icon = ''
		if code == 0 then
		  icon = pango.color('green', symbols.update2)
		end
		widget:set(icon, text)
	    end)
	  else
	    widget:set(
	      pango.color('red', symbols.reboot),
	      pango('b', 'You should reboot')..'\n'..
	      pango.color('green', 'installed kernel:\t')..installed..'\n'..
	      pango.color('red', 'running kernel:\t')..running)
	  end
      end)
  end)
end
updates.reboot = function() async({'reboot'}) end
updates.ask = function(title, text, callback)
  async({'zenity', '--question', '--title', title, '--text', text},
	function(_, _, _, code) if code == 0 then callback() end end)
end
updates.timer = gears.timer{
  timeout = 30 * 60,
  autostart = true,
  callback = function() updates:update() end,
}
updates:buttons(awful.util.table.join(
    awful.button({}, 1, function()
      updates.ask('Reboot now?', 'Do you want to reboot now?', updates.reboot)
    end
)))
updates:update()

return updates
