local vicious = require("vicious")
-- helper functions for awesome-client {{{1
function update_mpd_widget()
  mpdwidget:set_markup(mpd_status_formatter(nil,vicious.widgets.mpd()))
end
function test() mpdwidget:set_text('hans') end
