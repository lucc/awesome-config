-- taskwarriror widget for the bar
local awful = require("awful")
local wibox = require("wibox")
local shell = require("awful.spawn").easy_async_with_shell
local gears = require("gears")

local lain = require("lain")

local term = require("functions").run_in_central_terminal

--local taskicon = '/usr/share/awesome/lib/lain/icons/taskwarrior.png'
local taskicon = gears.filesystem.get_xdg_config_home() .. 'awesome/lain/icons/taskwarrior.png' -- nixos
local taskimg = wibox.widget.imagebox(taskicon)
lain.widget.contrib.task.attach(taskimg, {
  show_cmd = 'task '..
	     'rc.report.next.columns='..
		 'id,due.relative,description.truncated_count,urgency ' ..
	     'rc.report.next.labels=ID,Due,Description,Urg '..
	     'rc.gc=off '..
	     'next',
  notification_preset = {
      font = "Monospace 10",
      icon = taskicon,
      timeout = 0,
  },
})

function taskimg.show() term("task-window.sh") end
function taskimg.add()
  shell([[x=$(zenity --entry --title=taskwarrior --text="New task") ]]..
        [[&& [ -n "$x" ] && task add $x]])
end
taskimg:buttons(awful.util.table.join(
  awful.button({}, 1, taskimg.show),
  awful.button({}, 3, taskimg.add)
))

return taskimg
