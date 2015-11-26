-- An awesome widget to display information about new and unread mail from
-- notmuch.

local pango = require("pango")
local vicious = require("vicious")
local wibox = require("wibox")

local query = 'tag:inbox AND tag:unread AND NOT tag:spam'

local function notmuch_count (query)
  return tonumber(io.popen('notmuch count -- '..query):read('*all'))
end

local function worker (format, warg)
  return notmuch_count(warg)
end

local function formatter (widget, args)
  if args == 0 then
    return ""
  end
  local envolope = "\226\156\137" -- ✉
  return pango.markup('big', pango.color('red', string.rep(envolope, args)))
end

local widget = wibox.widget.textbox()

vicious.register(widget, worker, formatter, 97, query)

return {widget = widget}
