local awful = require("awful")
local async = awful.spawn.easy_async
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
  async({'pacman', '--query', '--upgrades'},
    function(text, _, _, code)
      if code == 0 then
	set(pango.color('green', symbols.update2), text)
	pacman.should_reboot = false
      else
	awful.spawn.with_line_callback({'needrestart', '-kb'}, {
	    stdout = function(line)
	      if string.find(line, '^NEEDRESTART-KCUR: ') ~= nil then
		pacman.current = string.sub(line, 19)
	      elseif string.find(line, '^NEEDRESTART-KEXP: ') ~= nil then
		pacman.expected = string.sub(line, 19)
	      end
	    end,
	    exit = function()
	      local cur, exp = pacman.current, pacman.expected
	      if cur ~= nil and exp ~= nil and cur ~= exp then
		set(
		  pango.color('red', symbols.reboot),
		  pango('b', 'You should reboot')..'\n'..
		  pango.color('green', 'installed kernel:\t')..exp..'\n'..
		  pango.color('red', 'running kernel:\t')..cur)
		pacman.should_reboot = true
	      else
		set("", "")
	      end
	    end})
      end
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
  timeout = 30 * 60, -- half an hour
  autostart = true,
  callback = update,
  call_now = true,
}

return pacman
