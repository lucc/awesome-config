-- key bindings for awesome, by luc {{{1
-- vim: foldmethod=marker

-- required modules {{{1
local awful = require("awful")
local mymainmenu = require("menu")
local widgets = require("widgets")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup").widget

local term = require("functions").run_in_centeral_terminal

-- other environment
local modkey, terminal, client, awesome = modkey, terminal, client, awesome

-- global key bindings {{{1
local globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "F1",      hotkeys_popup.show_help,
              {description="show help", group="awesome"}),
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext,
              {description = "view next", group = "tag"}),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
              {description = "go back", group = "tag"}),
    awful.key({                   }, "XF86Back",   awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
    awful.key({                   }, "XF86Forward",  awful.tag.viewnext,
              {description = "view next", group = "tag"}),
    awful.key({ modkey,           }, "F2", function() term("task-window.sh") end,
	      {description = "show current tasks (taskwarrior)", group = "utils"}),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
        end,
        {description = "focus next by index", group = "client"}
    ),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
        end,
        {description = "focus previous by index", group = "client"}
    ),
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end,
              {description = "show main menu", group = "awesome"}),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
              {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
              {description = "swap with previous client by index", group = "client"}),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
              {description = "focus the next screen", group = "screen"}),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
              {description = "focus the previous screen", group = "screen"}),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "go back", group = "client"}),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey, "Shift"   }, "Return", function () awful.spawn(terminal..' -b') end,
              {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey, "Control" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit,
              {description = "quit awesome", group = "awesome"}),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)          end,
              {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)          end,
              {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
              {description = "increase the number of master clients", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
              {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
              {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
              {description = "decrease the number of columns", group = "layout"}),
    awful.key({ modkey,           }, "space", function () awful.layout.inc( 1)                end,
              {description = "select next", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
              {description = "select previous", group = "layout"}),

    awful.key({ modkey, "Control" }, "n",
              function ()
                  local c = awful.client.restore()
                  -- Focus restored client
                  if c then
                      client.focus = c
                      c:raise()
                  end
              end,
              {description = "restore minimized", group = "client"}),

    -- Prompt
    awful.key({ modkey },            "r",     function () awful.screen.focused().mypromptbox:run() end,
              {description = "run prompt", group = "launcher"}),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run {
                    prompt       = "Run Lua code: ",
                    textbox      = awful.screen.focused().mypromptbox.widget,
                    exe_callback = awful.util.eval,
                    history_path = awful.util.get_cache_dir() .. "/history_eval"
                  }
              end,
              {description = "lua execute prompt", group = "awesome"}),
    -- Menubar
    awful.key({ modkey }, "p", menubar.show,
              {description = "show the menubar", group = "launcher"}),
    -- some more keys
    awful.key({ }, "XF86Launch1", function () os.execute('slock') end,
	      {description = "lock the screen", group = "screen" }),
    awful.key({ }, "XF86AudioMute",
	      function () os.execute('pactl set-sink-mute 0 toggle') end,
	      {description = "mute", group = "audio" }),
	      --awful.util.spawn("amixer set Master toggle")
    awful.key({ }, "XF86AudioRaiseVolume",
	      function () os.execute('pactl set-sink-volume 0 +3%') end,
	      {description = "increase volume", group = "audio" }),
	      --awful.util.spawn("amixer set Master playback 1%+")
    awful.key({ }, "XF86AudioLowerVolume",
	      function () os.execute('pactl set-sink-volume 0 -3%') end,
	      {description = "decrease volume", group = "audio" }),
	      --awful.util.spawn("amixer set Master playback 1%-")
    awful.key({ }, "XF86AudioPlay",
	      function () widgets.music.toggle(); widgets.music:refresh() end,
	      {description = "play/pause mpd", group = "audio" }),
    awful.key({ }, "XF86AudioStop",
	      function () widgets.music.stop(); widgets.music:refresh() end,
	      {description = "stop mpd", group = "audio" }),
    awful.key({ }, "XF86AudioNext",
	      function () widgets.music.next(); widgets.music:refresh() end,
	      {description = "next song", group = "audio" }),
    awful.key({ }, "XF86AudioPrev",
	      function () widgets.music.previous(); widgets.music:refresh() end,
	      {description = "prev song", group = "audio" }),
    awful.key({ modkey }, "XF86AudioPlay", widgets.music.tui,
              {description = "open the TUI", group = "audio" }),
    awful.key({ }, "XF86Display", function () os.execute('auto-xrandr') end,
	      {description = "reset monitor settings", group = "screen" }),
    awful.key({ }, "XF86Mail", widgets.mail.gui,
	      {description = "start mail client", group = "launcher" }),
    awful.key({ }, "Menu",
	      function () awful.screen.focused().mypromptbox:run() end,
              {description = "run prompt", group = "launcher"}),
    --awful.key({modkey}, "c", function () run_in_centeral_terminal('bc') end, 'open calculator'),
    awful.key({ modkey }, "d",
	      function ()
		  awful.prompt.run {
		    prompt       = 'Look up ',
		    textbox      = awful.screen.focused().mypromptbox.widget,
                    exe_callback = function (string) awful.util.spawn('dict-pager.sh '..string:gsub("'", "\\'")) end,
                    history_path = awful.util.get_cache_dir() .. "/history_dict_lookup"
		  }
	      end,
	      {description = "prompt for a text to look up in a dictionary", group = "launcher"}),

        awful.key({ modkey, "Shift" }, "Left",
                  function ()
                      if client.focus then
			  local old_index = awful.screen.focused().selected_tags[1].index
			  local new_index = (old_index - 2) % 9 + 1
                          local tag = client.focus.screen.tags[new_index]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to previous tag", group = "tag"}),
        awful.key({ modkey, "Shift" }, "Right",
                  function ()
                      if client.focus then
			  local old_index = awful.screen.focused().selected_tags[1].index
			  local new_index = old_index % 9 + 1
                          local tag = client.focus.screen.tags[new_index]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to next tag", group = "tag"})
)

-- Bind all key numbers to tags. {{{2
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = awful.util.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  {description = "view tag #"..i, group = "tag"}),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "toggle tag #" .. i, group = "tag"}),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag #"..i, group = "tag"}),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

-- client keys {{{1
local clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end,
              {description = "close", group = "client"}),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
              {description = "toggle floating", group = "client"}),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
              {description = "move to master", group = "client"}),
    awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
              {description = "move to screen", group = "client"}),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
              {description = "toggle keep on top", group = "client"}),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end ,
        {description = "minimize", group = "client"}),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "maximize", group = "client"})
)

-- return global and client keys {{{1
return { global = globalkeys, client = clientkeys }
