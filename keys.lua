-- key bindings for awesome, by luc {{{1
-- vim: foldmethod=marker

-- required modules {{{1
local awful = require("awful")
local vicious = require("vicious")
local keydoc = require("keydoc")
local mymainmenu = require("menu")
local tags = require("tags")
local layouts = tags.layouts
tags = tags.tags
local widgets = require("widgets")
local menubar = require("menubar")

-- global key bindings {{{1
local globalkeys = awful.util.table.join(
    keydoc.group('Tag movement'), -- {{{2
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
	      'switch to last used tag'),

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

    -- Layout manipulation {{{2
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end, 'swap with next client'),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end, 'swap with previous client'),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end, 'focus next monitor'),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end, 'focus previous monitor'),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto, 'jump to urgent client'),
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

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end, 'TODO'),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end, 'TODO'),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end, 'TODO'),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end, 'TODO'),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end, 'TODO'),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end, 'TODO'),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end, 'next layout'),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end, 'previous layout'),

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
      widgets.music.toggle()
      widgets.music:refresh()
    end),
    awful.key({ }, "XF86AudioNext", function ()
      widgets.music.next()
      widgets.music:refresh()
    end),
    awful.key({ }, "XF86AudioPrev", function ()
      widgets.music.previous()
      widgets.music:refresh()
    end),
    --awful.key({modkey}, "XF86MonBrightnessDown", function () awful.util.spawn(terminal .. " -e man awesome") end),
    awful.key({modkey}, "XF86MonBrightnessDown", keydoc.display),
    --awful.key({modkey}, "F1", function () awful.util.spawn(terminal .. " -e man awesome") end),
    awful.key({modkey}, "F1", keydoc.display, 'display this help'),
    awful.key({ }, "XF86LaunchB", function ()
      awful.tag.viewonly(tags[mouse.screen][9])
      awful.util.spawn(terminal .. " -e htop")
      --awful.util.spawn(terminal .. " -e nload wlan0")
      --awful.util.spawn(terminal .. " -e ping luc42.lima-city.de")
    end),
    awful.key({modkey}, "XF86Eject", function () awful.util.spawn('slock') end)
)

-- Bind all key numbers to tags. {{{2
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

-- client keys {{{1
local clientkeys = awful.util.table.join(
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

-- return global and client keys {{{1
return { global = globalkeys, client = clientkeys }
