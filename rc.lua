-- awesome config file by luc {{{1
-- vim: foldmethod=marker

-- Standard awesome library {{{1
local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")

-- manually added
local vicious = require("vicious")

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

-- Error handling {{{1
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end

-- Variable definitions {{{1
-- Themes define colours, icons, font and wallpapers.
beautiful.init("/usr/share/awesome/themes/default/theme.lua")
--beautiful.init("/usr/share/awesome/themes/sky/theme.lua")
--beautiful.init("/usr/share/awesome/themes/zenburn/theme.lua")

-- This is used later as the default terminal and editor to run.
--awful.util.spawn("urxvtd -q -o -f")
--terminal = "urxvtc"
terminal = "term"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
local layouts =
{
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier
}

-- Wallpaper {{{1
if beautiful.wallpaper then
    for s = 1, screen.count() do
        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
end

-- Tags {{{1
-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag({ 1, 2, 3, 4, 5, 6, 7, 8, 9 }, s, layouts[8])
end

-- Menu {{{1
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it

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
calenda2 = require('calendar2')
calendar2.addCalendarToWidget(mytextclock)
-- TODO does not work?

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

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)

    mywibox[s]:set_widget(layout)
end

-- Mouse bindings {{{1
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))

-- Key bindings {{{1
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Shift"   }, "Return",
      function ()
	awful.tag.viewonly(tags[mouse.screen][9])
	awful.util.spawn(terminal)
      end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end),
    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end),
    -- copied from the FAQ
    -- toggle the visibleity of the bar at the top of the screen
    awful.key({ modkey }, "b", function ()
      mywibox[mouse.screen].visible = not mywibox[mouse.screen].visible
    end),
    -- some media keys on the mac book pro
    --awful.key({ }, "XF86AudioRaiseVolume", function () awful.util.spawn("amixer set Master playback 1%+") end),
    --awful.key({ }, "XF86AudioLowerVolume", function () awful.util.spawn("amixer set Master playback 1%-") end),
    --awful.key({ }, "XF86AudioMute",        function () awful.util.spawn("amixer set Master toggle")       end),
    --awful.key({ }, "XF86KbdBrightnessDown", function () awful.util.spawn("kbdlight down") end),
    --awful.key({ }, "XF86KbdBrightnessUp", function () awful.util.spawn("kbdlight up") end),
    awful.key({ }, "XF86AudioPlay", function ()
      awful.util.spawn("mpc toggle")
      mpdwidget:set_markup(mpd_status_formatter(nil, vicious.widgets.mpd()))
    end),
    awful.key({ }, "XF86AudioNext", function ()
      awful.util.spawn("mpc next")
      mpdwidget:set_markup(mpd_status_formatter(nil, vicious.widgets.mpd()))
    end),
    awful.key({ }, "XF86AudioPrev", function ()
      awful.util.spawn("mpc previous")
      mpdwidget:set_markup(mpd_status_formatter(nil, vicious.widgets.mpd()))
    end),
    awful.key({modkey}, "XF86MonBrightnessDown", function () awful.util.spawn(terminal .. " -e man awesome") end),
    awful.key({modkey}, "F1", function () awful.util.spawn(terminal .. " -e man awesome") end),
    awful.key({ }, "XF86LaunchB", function ()
      awful.tag.viewonly(tags[mouse.screen][9])
      awful.util.spawn(terminal .. " -e htop")
      --awful.util.spawn(terminal .. " -e nload wlan0")
      --awful.util.spawn(terminal .. " -e ping luc42.lima-city.de")
    end),
    awful.key({modkey}, "XF86Eject", function () awful.util.spawn('slock') end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = awful.util.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        local tag = awful.tag.gettags(screen)[i]
                        if tag then
                           awful.tag.viewonly(tag)
                        end
                  end),
        -- Toggle tag.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      local tag = awful.tag.gettags(screen)[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[i]
                          if tag then
                              awful.client.movetotag(tag)
                          end
                     end
                  end),
        -- Toggle tag.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[i]
                          if tag then
                              awful.client.toggletag(tag)
                          end
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)

-- Rules {{{1
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "gimp" },
      properties = { floating = true } },
    -- Set Firefox to always map on tags number 1 of screen 1.
    { rule = { class = "Firefox" },
      properties = { tag = tags[1][1] } },
    -- Set Gvim to always map on tags number 2 of screen 1.
    { rule = { class = "Gvim" },
      properties = { tag = tags[1][2] } },
}

-- Signals {{{1
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end

    local titlebars_enabled = false
    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
        -- buttons for the titlebar
        local buttons = awful.util.table.join(
                awful.button({ }, 1, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.move(c)
                end),
                awful.button({ }, 3, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.resize(c)
                end)
                )

        -- Widgets that are aligned to the left
        local left_layout = wibox.layout.fixed.horizontal()
        left_layout:add(awful.titlebar.widget.iconwidget(c))
        left_layout:buttons(buttons)

        -- Widgets that are aligned to the right
        local right_layout = wibox.layout.fixed.horizontal()
        right_layout:add(awful.titlebar.widget.floatingbutton(c))
        right_layout:add(awful.titlebar.widget.maximizedbutton(c))
        right_layout:add(awful.titlebar.widget.stickybutton(c))
        right_layout:add(awful.titlebar.widget.ontopbutton(c))
        right_layout:add(awful.titlebar.widget.closebutton(c))

        -- The title goes in the middle
        local middle_layout = wibox.layout.flex.horizontal()
        local title = awful.titlebar.widget.titlewidget(c)
        title:set_align("center")
        middle_layout:add(title)
        middle_layout:buttons(buttons)

        -- Now bring it all together
        local layout = wibox.layout.align.horizontal()
        layout:set_left(left_layout)
        layout:set_right(right_layout)
        layout:set_middle(middle_layout)

        awful.titlebar(c):set_widget(layout)
    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

-- helper functions for awesome-client {{{1
function update_mpd_widget()
  mpdwidget:set_markup(mpd_status_formatter(nil,vicious.widgets.mpd()))
end
function test() mpdwidget:set_text('hans') end
