-- the bar at the top of the screen {{{1
-- vim: foldmethod=marker

-- required modules {{{1
local awful = require("awful")
local beautiful = require("beautiful")
local vicious = require("vicious")
local wibox = require("wibox")
local tags = require("tags")
local layouts = tags.layouts
tags = tags.tags

-- local helper functions {{{1
local markup = function (tag, text)
  local first = tag
  local index = string.find(tag, ' ')
  if index ~= nil then
    first = string.sub(tag, 1, index - 1)
  end
  return '<' .. tag .. '>' .. text .. '</' .. first .. '>'
end

local color = function (col, text)
  return markup ('span color="' .. col .. '"', text)
end

-- Menu {{{1
-- Create a laucher widget and a main menu
local mymainmenu = require("menu")
local mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Wibox {{{1
-- MPD information {{{2
mpdwidget = wibox.widget.textbox()
function mpd_status_formatter(widget, args)
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
    return color('blue', 'MPD: stopped')
  else
    return ''
  end
  return color(col, artist..'---'..album..'---'..title)
end
vicious.register(mpdwidget, vicious.widgets.mpd, mpd_status_formatter, 101, nil)
-- battery {{{2

-- copied from the vicious readme
--batwidget = awful.widget.progressbar()
--batwidget:set_width(8)
--batwidget:set_height(10)
--batwidget:set_vertical(true)
--batwidget:set_background_color("#494B4F")
--batwidget:set_border_color(nil)
--batwidget:set_color(
--  {
--    type = "linear",
--    from = { 0, 0 },
--    to = { 0, 10 },
--    stops = {
--      { 0, "#AECF96" },
--      { 0.5, "#88A175" },
--      { 1, "#FF5656" }
--    }
--  }
--  )
--vicious.register(batwidget, vicious.widgets.bat, "$2", 61, "BAT0")

textbat=wibox.widget.textbox()
textbat_tooltip = awful.tooltip({ objects = { textbat } })

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
    return color(col, args[3])
  end,
  67, "BAT0")

-- custom mail check widget {{{2
mytextmailcheckwidget = wibox.widget.textbox()
mymailbutton = awful.widget.button()

local envolope_formatter = function (widget, args)
  if args[1] == 0 and args[2] == 0 then return "" end
  local envolope = "\226\156\137" -- ✉
  return markup('big', color('red',    string.rep(envolope, args[1])) ..
		       color('orange', string.rep(envolope, args[2])))
end

local mail_format_function = function (widget, args)
  if args[1] == 0 and args[2] == 0 then return "" end
  local envolope = "<big>\226\156\137</big>" -- ✉
  local s = ""
  if args[1] ~= 0 then
    s = color('red', args[1] .. ' new')
  end
  if args[2] ~= 0 then
    if s ~= "" then s = s .. ", " end
    s = s .. color('orange', args[2] .. " unread")
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
vicious.register(mymailbutton, vicious.widgets.mdir, mail_format_function, 120, mail_paths) -- TODO

-- wifi info box {{{2
mywifitext = wibox.widget.textbox()
vicious.register(mywifitext, vicious.widgets.wifi,
  -- 'ssid: ${ssid}, mode: ${mode}, chan: ${chan}, rate: ${rate}, link: ${link}, linp: ${linp}, sign: ${sign}',
  ' ${ssid} ',
  --' <span color="blue">${ssid}</span> ',
  120, "wlan0")

-- Pacman Widget {{{2
-- copied from http://www.jasonmaur.com/awesome-wm-widgets-configuration/
pacwidget = wibox.widget.textbox()

pacwidget_t = awful.tooltip({ objects = { pacwidget},})

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

                --vicious.widgets.pkg,
                --function(widget,args)
                --    local io = { popen = io.popen }
                --    local s = io.popen("pacman -Qu")
                --    local str = ''

                --    for line in s:lines() do
                --        str = str .. line .. "\n"
                --    end
                --    pacwidget_t:set_text(str)
                --    s:close()
                --    return "UPDATES: " .. args[1]
                --end,
		--function (widget, args)
		--  if args[1] == 0 then
		--    return ""
		--  else
		--    str = ""
		--    for line in io.popen("pacman -Qu"):lines() do
		--      str = str .. line .. "\n"
		--    end
                --    pacwidget_t:set_text(string.sub(str, 1, -2))
		--    return "Updates available!"
		--  end
		--end,
		1800, "Arch")
                -- 1800 means check every 30 minutes

-- custom calendar and clock {{{2
-- Create a textclock widget
mytextclock = awful.widget.textclock()
-- calendar_tooltip = awful.tooltip({objects = {mytextclock}})
-- --calendar_tooltip:set_text('<span font_desc="monospace">' .. io.popen('cal -3') .. '</span>')
-- calendar_tooltip:set_text((function ()
--   local s = ''
--   for line in io.popen('cal -3'):lines() do
--     s = s .. line .. '\n'
--   end
--   return s
--   --return '<span font="monospace">' ..s.. '</span>'
-- end)())

-- Calendar widget to attach to the textclock
cal = require('cal')
cal.register(mytextclock)

-- Create a wibox for each screen and add it {{{2
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({
                                                      theme = { width = 250 }
                                                  })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(mylauncher)
    left_layout:add(mytaglist[s])
    left_layout:add(mypromptbox[s])

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    -- add the custom mailcheck widget
    right_layout:add(mpdwidget)
    right_layout:add(mywifitext)
    right_layout:add(mytextmailcheckwidget)
    right_layout:add(pacwidget)
    right_layout:add(mymailbutton)
    right_layout:add(textbat)
    --right_layout:add(batwidget)
    if s == 1 then right_layout:add(wibox.widget.systray()) end
    right_layout:add(mytextclock)
    right_layout:add(mylayoutbox[s])
    --right_layout:add(powerline_widget)

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)

    mywibox[s]:set_widget(layout)
end

