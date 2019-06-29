-- general helper functions

local with_shell = require("awful.spawn").with_shell

local function run_in_centeral_terminal (prog)
  with_shell('env PATH=$PATH:$HOME/.config/awesome/bin term -n center -e ' .. prog)
end

local function join(array, glue)
  local result = ''
  if #array > 0 then
    result = array[1]
    for i = 2, #array do
      result = result .. glue .. array[i]
    end
  end
  return result
end


return {
  run_in_centeral_terminal = run_in_centeral_terminal,
  join = join
}
