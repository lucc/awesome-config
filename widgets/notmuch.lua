-- An awesome widget to display information about new and unread mail from
-- notmuch.

local awful = require("awful")
local json = require("json")
local pango = require("pango")
local vicious = require("vicious")
local wibox = require("wibox")

local symbols = require("symbols")
local run_in_centeral_terminal = require("functions").run_in_centeral_terminal

local query = 'query:inbox_notification'

local function format_summary (summary)
  local str = pango.markup('b', pango.color('green', 'Summary of new mail:'))
  --local keys = {'date_relative', 'authors', 'subject', 'tags'}
  for _, entry in pairs(summary) do
    str = str..'\n'..pango.color('blue', entry['authors'])..': '..
      pango.color('red', entry['subject'])
  end
  return str
end

local function worker (_, warg)
  local query = warg
  os.execute('notmuch new')
  local count = tonumber(io.popen('notmuch count -- '..query):read('*all'))
  if count == 0 then
    return { count = 0, summary = {} }
  else
    return {
      count = count,
      summary = json.decode(
        io.popen(
	  'notmuch search --format=json --sort=newest-first -- '..
	  query
	):read('*all')) }
  end
end

local function formatter (widget, args)
  if args.count == 0 then
    widget.tooltip:set_text("")
    return ""
  end
  widget.tooltip:set_text(format_summary(args.summary))
  return pango.color('red', pango.font('Awesome', string.rep(symbols.envolope2, args.count))) .. ' '
end

-- Define the widget that will hold the info about new mail (summary in
-- tooltip)
local widget = wibox.widget.textbox()
widget.tooltip = awful.tooltip({objects = {widget}})

widget.update = function (self)
  self:set_markup(formatter(self, worker('', query)))
end

widget:buttons(awful.util.table.join(
  awful.button({ }, 1, function ()
    os.execute("notmuch new")
    run_in_centeral_terminal("alot")
  end)))

vicious.register(widget, worker, formatter, 97, query)

return widget
