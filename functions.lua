-- general helper functions

local with_shell = require("awful.spawn").with_shell

local function run_in_centeral_terminal (prog)
  with_shell('env PATH=$PATH:$HOME/.config/awesome/bin term -n center -e ' .. prog)
end

return {
  run_in_centeral_terminal = run_in_centeral_terminal
}
