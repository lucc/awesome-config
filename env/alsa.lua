local run = require("awful").spawn

return {
  mute = function() run('amixer set Master toggle') end,
  inc = function() run('amixer set Master playback 1%+') end,
  dec = function() run('amixer set Master playback 1%-') end,
}
