-- general helper functions

local awful = require("awful")

local function run_in_centeral_terminal (prog)
  awful.util.spawn('term -n center -e ' .. prog)
end

return {
  run_in_centeral_terminal = run_in_centeral_terminal
}
