-- An awesome widget to display information about new and unread mail from
-- notmuch.

local awful = require("awful")
local json = require("json")
local pango = require("pango")
local vicious = require("vicious")
local wibox = require("wibox")
local naughty = require('naughty')

local function display(title, text)
  naughty.notify({text = text, title=title ,timeout=0})
end

local query = 'tag:inbox AND tag:unread AND NOT tag:spam'
query = io.popen('notmuch config get private.inbox_query'):read('*all'):sub(1, -2)
query = 'tag:unread and ( ' .. query .. ' )'
query = query:gsub([=[['"$()\<>{}*?#!&`]]=], '\\%0')

local function notmuch_count (query)
  return tonumber(io.popen('notmuch count -- '..query):read('*all'))
end

local function notmuch_summary (query)
  return json.decode(io.popen(
    'notmuch search --format=json --sort=newest-first -- '..
    query):read('*all'))
end

local function format_summary (summary)
  local str = pango.markup('b', pango.color('green',
					       'Summary of new mail:'))
  --local keys = {'date_relative', 'authors', 'subject', 'tags'}
  for _, entry in pairs(summary) do
    str = str..'\n'..pango.color('blue', entry['authors'])..': '..
      pango.color('red', entry['subject'])
  end
  return str
end

local function worker (_, warg)
  os.execute('notmuch new')
  local count = notmuch_count(warg)
  if count == 0 then
    return { count = 0, summary = {} }
  else
    return { count = count, summary = notmuch_summary(warg) }
  end
end

local function formatter (widget, args)
  if args.count == 0 then
    widget.tooltip:set_text("")
    return ""
  end
  widget.tooltip:set_text(format_summary(args.summary))
  local envolope = "\226\156\137" -- ✉
  return pango.markup('big', pango.color('red', string.rep(envolope, args.count)))
end

local function update(widget)
  widget:set_markup(formatter(widget, worker('', query)))
end

local widget = wibox.widget.textbox()
widget.tooltip = awful.tooltip({objects = {widget}})
widget.update = update

vicious.register(widget, worker, formatter, 97, query)

return {widget = widget}
