-- check for afailable updates on nixos
local wibox = require("wibox")
local shell = require("awful.spawn").easy_async_with_shell
local var_dump = require("functions").var_dump
local pango = require("pango")
local symbols = require("symbols")
local texticon = require("widgets/texticon")
local gears = require("gears")

local nixos = texticon()
local system_flake = os.getenv("HOME") .. '/src/nixos'

local function update()
  local script = [[set -e
	  dir=$(mktemp -d)
	  trap 'rm -fr "$dir"' EXIT
	  cd "$dir"
	  git clone --quiet --depth 1 -- file://]] .. system_flake .. [[ .
	  nix flake update 2>&1 | grep -v '^warning: '
	  git diff --quiet]]
  shell(script,
    function(stdout, stderr, exitreason, exitcode)
      if exitreason == "exit" and exitcode == 1 then
	nixos:set_markup(pango.color("blue", pango.iconic(symbols.nixos)) .. " ")
	nixos:set_tooltip(stdout)
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
