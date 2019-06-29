local async = require("awful.spawn").easy_async
local awful = require("awful")
local gears = require("gears")
local pango = require("pango")
local symbols = require("symbols")
local wibox = require("wibox")

-- originally copied from
-- http://www.jasonmaur.com/awesome-wm-widgets-configuration/

local pacman = wibox.widget.textbox()
pacman.tooltip = awful.tooltip({objects={pacman}})

local function set(icon, tooltip)
  pacman.tooltip:set_markup(tooltip)
  pacman:set_markup(pango.iconic(icon))
end

local function update()
  async({'pacman', '--query', 'linux'},
    function(stdout)
      local installed = string.sub(stdout, 7, -2):gsub('-', '.')
      async({'uname', '-r'},
	function(stdout2)
	  local running = string.sub(stdout2, 1, installed:len()):gsub('-', '.')
	  if installed == running then
	    async({'pacman', '--query', '--upgrades'},
	      function(text, _, _, code)
		local icon = ''
		if code == 0 then
		  icon = pango.color('green', symbols.update2)
		end
		set(icon, text)
		pacman.should_reboot = false
	    end)
	  else
	    set(
	      pango.color('red', symbols.reboot),
	      pango('b', 'You should reboot')..'\n'..
	      pango.color('green', 'installed kernel:\t')..installed..'\n'..
	      pango.color('red', 'running kernel:\t')..running)
	    pacman.should_reboot = true
	  end
      end)
  end)
end

local function ask(title, text)
  async({'zenity', '--question', '--title', title, '--text', text},
	function(_, _, _, code) if code == 0 then async({'reboot'}) end end)
end

pacman:buttons(awful.util.table.join(
    awful.button({}, 1, function()
      if pacman.should_reboot then
	ask('Reboot now?', 'Do you want to reboot now?', pacman.reboot)
      else
	async({'term', '-e', 'zsh -c paci'})
      end
    end
)))

gears.timer{
  timeout = 30 * 60,
  autostart = true,
  callback = function() update() end,
}

-- initialize the widget
update()

return pacman
