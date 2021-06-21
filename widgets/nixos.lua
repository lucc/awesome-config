-- check for afailable updates on nixos
local wibox = require("wibox")
local shell = require("awful.spawn").easy_async_with_shell
local var_dump = require("functions").var_dump
local json = require("lain.util.dkjson")
local pango = require("pango")
local symbols = require("symbols")
local texticon = require("widgets/texticon")
local gears = require("gears")

local nixos = texticon()
local system_flake = os.getenv("HOME") .. '/src/nixos'
local icon = pango.color("blue", pango.iconic(symbols.nixos)) .. " "

local function update()
  local script = [[set -e
	  dir=$(mktemp -d)
	  trap 'rm -fr "$dir"' EXIT
	  cd "$dir"
	  git clone --quiet --depth 1 -- file://]] .. system_flake .. [[ .
	  nix flake metadata --json
	  nix flake update
	  nix flake metadata --json]]
  shell(script,
    function(stdout, stderr, exitreason, exitcode)
      if exitreason == "exit" and exitcode == 0 then
	local before, pos = json.decode(stdout)
	local after = json.decode(stdout, pos)
	before = before.locks.nodes
	before.root = nil
	after = after.locks.nodes
	local lines = {}
	for name, info in pairs(before) do
	  if info.locked.lastModified ~= after[name].locked.lastModified then
	    table.insert(lines, name .. ": \t" ..
	      os.date("%F %T", info.locked.lastModified) .. " -> " ..
	      os.date("%F %T", after[name].locked.lastModified))
	  end
	end
	if #lines > 0 then
	  table.insert(lines, 1, pango("b", "Available Updates"))
	  nixos:set_tooltip(table.concat(lines, "\n"), true)
	  nixos:set_markup(icon)
	else
	  nixos:set_markup("")
	end
      else
	nixos:set_markup("")
      end
    end)
end

gears.timer{
  timeout = 30 * 60, -- half an hour
  autostart = true,
  callback = update,
  call_now = true,
}

return nixos
