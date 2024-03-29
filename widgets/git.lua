-- Watch some local  git repositories for changed or untraced files to report
-- them in a widget.
local spawn = require("awful.spawn").easy_async
local gears = require("gears")

local naughty = require("naughty")

local pango = require("pango")
local symbols = require("symbols")
local texticon = require("widgets/texticon")

local dirty = pango.iconic(pango.color("yellow", symbols.git1))
local err = pango.iconic(pango.color("red", symbols.alert2))

local function count_lines(text)
  return select(2, text:gsub("\n", ""))
end

-- Create a closure to use in spawn() and save output to a destination table.
local function save_output(destination, filter)
  return function(stdout, stderr, exitreason, exitcode)
    destination.ok = exitreason == "exit" and exitcode == 0
    if destination.ok then
      destination.data = (filter and filter(stdout)) or stdout
    else
      destination.data = pango.escape(stderr)
    end
  end
end

local function update(self)
  for path, data in pairs(self.paths) do
    local function git(args, destination, filter)
      spawn({"git", "-C", path, table.unpack(args)},
	save_output(destination, filter))
    end
    if data.untracked then
      git({"ls-files", "--others", "--exclude-standard"}, data.untracked,
	count_lines)
    end
    git({"branch", "--show-current"}, data.branch,
      function(stdout) return stdout:gsub("%s+", "") end)
    git({"branch"}, data.branch_count, count_lines)
    git({"diff", "--stat"}, data.changed)
    if data.commits then
      git({"rev-list", "--right-only", "--count", "@{upstream}...HEAD"},
	data.commits, tonumber)
    end
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
    if data.commits then
      if data.commits.ok and data.commits.data > 0 then
	table.insert(parts, pango.color("yellow", data.commits.data ..
					" unpused commits"))
      elseif not data.commits.ok then
	table.insert(parts, pango.color("red", data.commits.data))
      end
    end
    if data.branch_count then
      if data.branch_count.ok and data.branch_count.data > 1 then
	table.insert(parts, pango.color("yellow", data.branch_count.data .. " branches"))
      elseif not data.branch_count.ok then
	table.insert(parts, pango.color("red", data.branch_count.data))
      end
    end
    if #parts > 0 then
      table.insert(parts, 1, pango.color("blue", path) .. " @ " ..
			     pango.color("green", data.branch.data))
      table.insert(parts, "")
      text = text .. "\n" .. table.concat(parts, "\n")
    end
    data.parts = parts
    data.formatted = table.concat(parts, "\n")
  end
  text = text:sub(2)
  self.tooltip.markup = pango.mono(text)
end

-- Register some paths to watch in the widget
local function register(self, ...)
  for i = 1, select('#', ...) do
    local item = select(i, ...)
    if item.untracked == nil then item.untracked = {} end
    if item.changed == nil then item.changed = {} end
    if item.branch == nil then item.branch = {} end
    if item.commits == nil then item.commits = {} end
    if item.branch_count == nil then item.branch_count = {} end
    self.paths[item.path] = item
  end
end

local git = texticon()

-- the paths to watch
git.paths = {}
git.register = register
git.update = update
git.update_icon = update_icon
git.update_tooltip = update_tooltip

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
