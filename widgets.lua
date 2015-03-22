-- widgets for the bar {{{1
-- vim: foldmethod=marker

-- required modules {{{1
local awful = require("awful")
local wibox = require("wibox")
local vicious = require("vicious")
local pango = require("pango")

-- MPD information {{{1
local mpdwidget = wibox.widget.textbox()
local function mpd_status_formatter(widget, args)
  local state = args['{state}']
  local artist = args['{Artist}']
  local album = args['{Album}']
  local title = args['{Title}']
  --args['{}']
  local col = ''
  if state == 'Play' then
    col = 'yellow'
  elseif state == 'Pause' then
    col = 'orange'
  elseif state == 'Stop' then
    return pango.color('blue', 'MPD: stopped')
  else
    return ''
  end
  return pango.color(col, artist..'---'..album..'---'..title)
end
vicious.register(mpdwidget, vicious.widgets.mpd, mpd_status_formatter, 101,
		 nil)
-- add an refresh function to the mpd widgets to update the text and such
mpdwidget.refresh = function (widget)
  widget:set_markup(mpd_status_formatter(nil, vicious.widgets.mpd()))
end
mpdwidget.toggle = function (widget) awful.util.spawn("mpc toggle") end
mpdwidget.next = function (widget) awful.util.spawn("mpc next") end
mpdwidget.previous = function (widget) awful.util.spawn("mpc previous") end


-- battery {{{1

-- copied from the vicious readme
local batwidget = awful.widget.progressbar()
batwidget:set_width(8)
batwidget:set_height(10)
batwidget:set_vertical(true)
batwidget:set_background_color("#494B4F")
batwidget:set_border_color(nil)
batwidget:set_color(
  {
    type = "linear",
    from = { 0, 0 },
    to = { 0, 10 },
    stops = {
      { 0, "#AECF96" },
      { 0.5, "#88A175" },
      { 1, "#FF5656" }
    }
  }
  )
--vicious.register(batwidget, vicious.widgets.bat, "$2", 61, "BAT0")

local textbat=wibox.widget.textbox()
local textbat_tooltip = awful.tooltip({ objects = { textbat } })

vicious.register(textbat, vicious.widgets.bat,
  function (widget, args)
    local col = 'red'
    if args[2] > 33 then
      if args[2] > 66 then
	col = 'green'
      else
	col = 'orange'
      end
    end
    --"<span color='green'>power@$2%=$3</span>"
    textbat_tooltip:set_text(
      'Connected: ' .. args[1] .. '\n' ..
      'Level: ' .. args[2] .. '%\n' ..
      'Time: ' .. args[3]
      )
    return pango.color(col, args[3])
  end,
  67, "BAT0")

-- custom mail check widget {{{1
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

-- wifi info box {{{1
local mywifitext = wibox.widget.textbox()
vicious.register(mywifitext, vicious.widgets.wifi,
  -- 'ssid: ${ssid}, mode: ${mode}, chan: ${chan}, rate: ${rate},
  -- link: ${link}, linp: ${linp}, sign: ${sign}',
  ' ${ssid} ',
  --' <span color="blue">${ssid}</span> ',
  120, "wlan0")

-- Pacman Widget {{{1
-- copied from http://www.jasonmaur.com/awesome-wm-widgets-configuration/
local pacwidget = wibox.widget.textbox()

local pacwidget_t = awful.tooltip({ objects = { pacwidget},})

vicious.register(pacwidget,
		 function (widget, args)
		   local str = ''
		   local count = 0
		   for line in io.popen('pacman -Qu'):lines() do
		     str = str .. line .. '\n'
		     count = count + 1
		   end
		   if count == 0 then
		     return ''
		   else
		     pacwidget_t:set_text(string.sub(str, 1, -2))
		     return "Updates available! "
		   end
		 end,
		 '$1',
		1800, "Arch")
                -- 1800 means check every 30 minutes

-- custom calendar and clock {{{1
-- Create a textclock widget
local mytextclock = awful.widget.textclock()
-- Calendar widget to attach to the textclock
local cal = require('cal')
cal.register(mytextclock)
-- TODO does not work?

-- return {{{1
return {
  battery = textbat,
  clock = mytextclock,
  mail = mytextmailcheckwidget,
  music = mpdwidget,
  updates = pacwidget,
  wifi = mywifitext,
  mailbutton = mymailbutton,
}
