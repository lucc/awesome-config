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

-- Create a closure to use in spawn() and save output to a destination table.
local function save_output(destination, filter)
  return function(stdout, stderr, exitreason, exitcode)
    destination.ok = exitreason == "exit" and exitcode == 0
    if destination.ok then
      destination.data = (filter and filter(stdout)) or stdout
    else
      destination.data = stderr
    end
  end
end

local function update(self)
  for path, data in pairs(self.paths) do
    if data.untracked then
      spawn({"git", "-C", path, "ls-files", "--others", "--exclude-standard"},
	save_output(data.untracked, function (stdout)
	  return select(2, stdout:gsub("\n", ""))
	end))
    end
    spawn({"git", "-C", path, "branch", "--show-current"},
      save_output(data.branch, function(stdout)
	return stdout:gsub("%s+", "")
      end))
    spawn({"git", "-C", path, "diff", "--stat"}, save_output(data.changed))
    spawn({"sleep", "2"}, function() self:update_icon() end)
  end
end

local function update_icon(self)
  local text = ""
  for path, data in pairs(self.paths) do
    if (data.untracked and not data.untracked.ok)
    or (data.changed and not data.changed.ok) then
      self:set_markup(err)
      return
    elseif (data.untracked and data.untracked.data ~= 0)
	or (data.changed and data.changed.data ~= "") then
      text = dirty
    end
  end
  self:set_markup(text)
end

local function update_tooltip(self)
  local paths = {}
  for path, _ in pairs(self.paths) do table.insert(paths, path) end
  table.sort(paths)
  local text = ""
  for _, path in ipairs(paths) do
    local data = self.paths[path]
    local parts = {}
    if data.changed then
      if data.changed.ok and data.changed.data ~= "" then
	table.insert(parts, data.changed.data:sub(1,-2))
      elseif not data.changed.ok then
	table.insert(parts, pango.color("red", data.changed.data))
      end
    end
    if data.untracked then
      if data.untracked.ok and data.untracked.data > 0 then
	table.insert(parts, pango.color("yellow", data.untracked.data ..
					" untracked files"))
      elseif not data.untracked.ok then
	table.insert(parts, pango.color("red", data.untracked.data))
      end
    end
    if #parts > 0 then
      table.insert(parts, 1, pango.color("blue", path) .. " @ " .. pango.color("green", data.branch.data))
      table.insert(parts, "")
      text = text .. "\n" .. table.concat(parts, "\n")
    end
    data.parts = parts
    data.formatted = table.concat(parts, "\n")
  end
  text = text:sub(2)
  self.tooltip.markup = string.format('<span font_desc="monospace">%s</span>',
				      text)
end

-- Register some paths to watch in the widget
local function register(self, ...)
  for i = 1, select('#', ...) do
    local item = select(i, ...)
    if item.untracked == nil then item.untracked = {} end
    if item.changed == nil then item.changed = {} end
    if item.branch == nil then item.branch = {} end
    self.paths[item.path] = item
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
  {path = "/etc/nixos"},
  {path = "/home/luc/.config", untracked = false},
  {path = "/home/luc/.config/awesome"},
  {path = "/home/luc/.config/nvim"},
  {path = "/home/luc/.config/pass"},
  {path = "/home/luc/.config/zsh"},
  {path = "/home/luc/src/khard"},
  {path = "/home/luc/src/nvimpager"},
  {path = "/home/luc/src/sys"},
  {path = "/home/luc/uni/master"},
  {path = "/home/luc/uni/master/ulang"}
)

gears.timer{
  timeout = 500,
  autostart = true,
  callback = function() git:update() end,
}
git:connect_signal("mouse::enter", function()
  git:update_icon()
  git:update_tooltip()
end)

return git
