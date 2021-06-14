-- general helper functions

local awful = require("awful")

local function floating_terminal(...)
  if select('#', ...) == 0 then
    -- default if no argument was given
    return floating_terminal(awful.util.shell)
  end
  local path = os.getenv('PATH')
  path = path .. ':' .. os.getenv('HOME') .. '/.config/awesome/bin'
  local cmd = {'env', 'PATH='..path, 'term', '-e', ...}
  local prop = {
    floating = true,
    callback = function(c)
      local screen = mouse.screen.geometry
      local x = screen.width / 8
      local y = screen.height / 8
      local width = screen.width * 3 / 4
      local height = screen.height * 3 / 4
      c:geometry({x = x, y = y, width = width, height = height})
      c:jump_to()
    end
  }
  awful.spawn(cmd, prop)
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
  join = join,
  run_in_central_terminal = floating_terminal,
}
