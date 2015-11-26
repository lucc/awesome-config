-- An awesome widget to display information about new and unread mail in
-- maildirs.

local awful = require("awful")
local wibox = require("wibox")
local pango = require("pango")
local vicious = require("vicious")

local mytextmailcheckwidget = wibox.widget.textbox()
local mymailbutton = awful.widget.button()

local envolope_formatter = function (widget, args)
  if args[1] == 0 and args[2] == 0 then return "" end
  local envolope = "\226\156\137" -- ✉
  return pango.markup('big',
                      pango.color('red', string.rep(envolope, args[1])) ..
		      pango.color('orange', string.rep(envolope, args[2])))
end

local mail_format_function = function (widget, args)
  if args[1] == 0 and args[2] == 0 then return "" end
  local envolope = "<big>\226\156\137</big>" -- ✉
  local s = ""
  if args[1] ~= 0 then
    s = pango.color('red', args[1] .. ' new')
  end
  if args[2] ~= 0 then
    if s ~= "" then s = s .. ", " end
    s = s .. pango.color('orange', args[2] .. " unread")
  end
  local sum = args[1] + args[2]
  if sum > 0 then
    s = s .. " mail"
    if sum > 1 then s = s .. "s" end
  end
  return envolope .. s
end

-- table with full paths to maildir structures
local mail_paths = {
  "/home/luc/mail/inbox",
  --"/home/luc/mail/gmx",
  --"/home/luc/mail/gmx",
  --"/home/luc/mail/gmx",
  "/home/luc/mail/gmx"
}

vicious.register(mytextmailcheckwidget, vicious.widgets.mdir,
		 envolope_formatter, 120, mail_paths)
vicious.register(mymailbutton, vicious.widgets.mdir, mail_format_function,
		 120, mail_paths) -- TODO

return {widget = mytextmailcheckwidget, button = mymailbutton}
