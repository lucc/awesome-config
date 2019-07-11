-- An awesome widget to display information about new and unread mail from
-- notmuch.

local awful = require("awful")
local naughty = require("naughty")
local spawn = require("awful.spawn")
local shell = spawn.easy_async_with_shell
local json = require("json")
local pango = require("pango")
local wibox = require("wibox")

local symbols = require("symbols")
local terminal = require("functions").run_in_centeral_terminal

local function format_summary (summary)
  local str = pango('b', pango.color('green', 'Summary of new mail:'))
  --local keys = {'date_relative', 'authors', 'subject', 'tags'}
  for _, entry in pairs(summary) do
    local authors = entry['authors']
    if #authors >= 100 then
      authors = string.sub(authors, 1, 99) .. '…'
    end
    str = str..'\n'..pango.color('blue', authors)..':\t'..pango.color(
      'red', entry['subject'])
  end
  return str
end

local function update(container, force)
  local query = container.query or container.default_query
  local script = ''
  if force then
    script = 'notmuch new;'
  end
  script = script ..
    'notmuch count -- ' .. query .. ';' ..
    'notmuch search --format=json --sort=newest-first -- '.. query
  shell(script, function (stdout, stderr, exitreason, exitcode)
    local i, _ = string.find(stdout, '\n', 1, true)
    local count = tonumber(string.sub(stdout, 1, i))
    local summary = ""
    local markup = ""
    if count ~= 0 then
      markup = pango.iconic(symbols.envolope2)
      if count > 1 then
	markup = count .. ' ' .. markup
      end
      markup = pango.color('red',  markup) .. ' '
      summary = string.sub(stdout, i+1)
      summary = json.decode(summary)
      summary = format_summary(summary)
    else
      local notification = naughty.getById(container.last_id)
      naughty.destroy(notification)
    end
    container:set_markup(markup)
    container.tooltip.markup=summary
  end)
end

local function notify(container, query)
  local query = query or container.default_query
  shell('notmuch search '..query..' | cut -f2- -d " "',
    function(stdout, stderr, reason, exit_code)
      if exit_code == 0 and stdout ~= '' then
	local notification = naughty.notify {
	  text = stdout,
	  title = 'New mail',
	  timeout = 0,
	  icon = '/usr/share/icons/Adwaita/256x256/emblems/emblem-mail.png',
	  replaces_id = container.last_id
	}
	container.last_id = notification.id
      end
  end)
end

-- Define the widget that will hold the info about new mail (summary in
-- tooltip) and all related data.
local notmuch = wibox.widget.textbox()
notmuch.tooltip = awful.tooltip({objects = {notmuch}})

-- The default query will be used if no other query is given.
notmuch.default_query =
  [[\(query:inbox_notification or query:listbox_notification\)]]

-- some nice helper functions
notmuch.tui = function() terminal("alot") end
notmuch.tui2 = function() terminal( "purebred") end
notmuch.gui = function()
  spawn.with_line_callback(
    "astroid", {exit = function() notmuch:update() end}
  )
end

notmuch.notify = notify
notmuch.update = update
notmuch.button1 = notmuch.tui2
notmuch.button3 = notmuch.tui
notmuch:buttons(awful.util.table.join(
  awful.button({}, 1, notmuch.button1),
  awful.button({}, 3, notmuch.button3)
))

notmuch:update()

return notmuch
