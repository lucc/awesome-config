-- An awesome widget to display information about new and unread mail from
-- notmuch.

local awful = require("awful")
local easy_async_with_shell = require("awful.spawn").easy_async_with_shell
local json = require("json")
local pango = require("pango")
--local vicious = require("vicious")
local wibox = require("wibox")

local symbols = require("symbols")
local run_in_centeral_terminal = require("functions").run_in_centeral_terminal

local function format_summary (summary)
  local str = pango.markup('b', pango.color('green', 'Summary of new mail:'))
  --local keys = {'date_relative', 'authors', 'subject', 'tags'}
  for _, entry in pairs(summary) do
    str = str..'\n'..pango.color('blue', entry['authors'])..':\t'..
      pango.color('red', entry['subject'])
  end
  return str
end

-- Define the contrainer that will hold the widget and all related data.
local notmuch = {}
-- Define the widget that will hold the info about new mail (summary in
-- tooltip)
notmuch.widget = wibox.widget.textbox()
notmuch.widget.tooltip = awful.tooltip({objects = {notmuch.widget}})

-- The default query will be used if no other query is given.
notmuch.default_query = [[\(query:inbox_notification or query:listbox_notification\)]]

notmuch.update = function(container, force)
  local query = container.query or container.default_query
  local script = ''
  if force then
    script = 'notmuch new;'
  end
  script = script .. 'notmuch count -- ' .. query .. ';'
  script = script .. 'notmuch search --format=json --sort=newest-first -- '.. query
  easy_async_with_shell(script, function (stdout, stderr, exitreason, exitcode)
    local i, j = string.find(stdout, '\n', 1, true)
    local count = tonumber(string.sub(stdout, 1, i))
    local summary = ""
    local markup = ""
    if count ~= 0 then
      markup = symbols.envolope2
      if count > 1 then
	markup = count .. ' ' .. markup
      end
      markup = pango.color('red', pango.font('Awesome', markup)) .. ' '
      summary = string.sub(stdout, i+1)
      summary = json.decode(summary)
      summary = format_summary(summary)
    end
    container.widget:set_markup(markup)
    container.widget.tooltip.markup=summary
  end)
end

notmuch.button1 = function () run_in_centeral_terminal("alot") end
notmuch.widget:buttons(awful.util.table.join(awful.button({}, 1, notmuch.button1)))

notmuch:update()

return notmuch
