-- Watch some local  git repositories for changed or untraced files to report
-- them in a widget.
local awful = require("awful")
local shell = require("awful.spawn").easy_async_with_shell
local spawn = require("awful.spawn").easy_async
local gears = require("gears")
local wibox = require("wibox")

local naughty = require("naughty")

local pango = require("pango")
local symbols = require("symbols")

local dirty = pango.iconic(pango.color("yellow", symbols.git1))
local err = pango.iconic(pango.color("red", symbols.alert2))

local function update(self)
  for path, data in pairs(self.paths) do
    spawn({"git", "-C", path, "ls-files", "--others", "--exclude-standard"},
      function(stdout, stderr, exitreason, exitcode)
	data.untracked_ok = exitreason == "exit" and exitcode == 0
	data.untracked = select(2, stdout:gsub("\n", ""))
	if not data.untracked_ok or not data.changed_ok then
	  self:set_markup(err)
	elseif data.untracked == "" and data.changed == "" then
	  self:set_markup(dirty)
	else
	  self:set_markup("")
	end
      end)
    spawn({"git", "-C", path, "diff", "--stat"},
      function(stdout, stderr, exitreason, exitcode)
	data.changed_ok = exitreason == "exit" and exitcode == 0
	data.changed = stdout
      end)
    spawn({"sleep", "2"}, function() self:update_icon() end)
  end
end

local function update_icon(self)
  local text = ""
  for path, data in pairs(self.paths) do
    if not data.untracked_ok or not data.changed_ok then
      self:set_markup(err)
      return
    elseif data.untracked ~= 0 or data.changed ~= "" then
      text = dirty
    end
  end
  self:set_markup(text)
end

local function update_tooltip(self)
  local text = ""
  for path, data in pairs(self.paths) do
    if (data.changed ~= nil and data.changed ~= "") or
       (data.untracked ~= nil and data.untracked ~= 0) then
      text = text .. "\n" .. pango.color("blue", path)
      if data.changed ~= nil then
	text = text .. "\n" .. data.changed
      end
      if data.untracked ~= nil and data.untracked ~= 0 then
	text = text .. " " .. pango.color("yellow", data.untracked .. " untracked files")
      end
      text = text .. "\n"
    end
  end
  text = text:sub(2)
  self.tooltip.markup = string.format('<span font_desc="monospace">%s</span>', text)
end

-- Register some paths to watch in the widget
local function register(self, ...)
  for i = 1, select('#', ...) do
    self.paths[select(i, ...).path] = select(i, ...)
  end
end

local git = wibox.widget.textbox()
git.tooltip = awful.tooltip({objects = {git}})

-- the paths to watch
git.paths = {}
git.register = register
git.update = update
git.update_icon = update_icon
git.update_tooltip = update_tooltip

git:register(
  {path = "/home/luc/.config/pass"},
  {path = "/home/luc/.config/zsh"},
  {path = "/home/luc/.config/nvim"},
  {path = "/home/luc/.config/awesome"},
  {path = "/home/luc/.config"},
  {path = "/home/luc/uni/master"},
  {path = "/home/luc/uni/master/ulang"},
  {path = "/home/luc/src/sys"}
)

gears.timer{
  timeout = 500,
  autostart = true,
  callback = function() git:update_data() end,
}
git:connect_signal("mouse::enter", function()
  git:update_icon()
  git:update_tooltip()
end)

return git
