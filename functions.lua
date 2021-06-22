-- general helper functions

local awful = require("awful")
local json = require("lain.util.dkjson")
local naughty = require("naughty")
local inspect = require("inspect").inspect
local terminal = require("globals").terminal

local function floating_terminal(...)
  if select('#', ...) == 0 then
    -- default if no argument was given
    return floating_terminal(awful.util.shell)
  end
  local path = os.getenv('PATH')
  path = path .. ':' .. os.getenv('HOME') .. '/.config/awesome/bin'
  local cmd = {'env', 'PATH='..path, terminal, '-e', ...}
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

local function var_dump(data, title)
  local data = type(data) == "string" and data or inspect(data)
  naughty.notify({title=title or "Debug", text=data, timeout=-1})
end

local function password(key, callback)
  awful.spawn.easy_async({"pass", "show", "--",  key},
    function(stdout, stderr, exitreason, exitcode)
      local index = string.find(stdout, '\n')
      if index ~= nil then
	callback(string.sub(stdout, 1, index - 1))
      end
    end)
end

local function api_update(self, url, callback)
  if self.token == nil then
    return password(self.key, function(token)
      self.token = token
      api_update(self, url, callback)
    end)
  end
  local cmd = { "curl", url, "--header",
    "Authorization: token " ..  self.token }
  awful.spawn.easy_async(cmd, function(stdout, stderr, exitreason, exitcode)
    self.cache = json.decode(stdout)
    callback(self.cache)
  end)
end

local function api(options)
  if options.token == nil and options.key == nil then
    error("You need to provide a token or a key from the password store")
  end
  local api = { key = options.key, token = options.token }
  return setmetatable(api, { __call = api_update })
end

return {
  api = api,
  join = join,
  run_in_central_terminal = floating_terminal,
  var_dump = var_dump,
}
