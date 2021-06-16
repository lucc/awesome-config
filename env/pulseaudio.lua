local run = require("awful").spawn

return {
  mute = function() run('pactl set-sink-mute 0 toggle') end,
  inc = function() run('pactl set-sink-volume 0 +3%') end,
  dec = function() run('pactl set-sink-volume 0 -3%') end,
}
