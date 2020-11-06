-- helper functions to deal with pango markup

local theme = require("beautiful")

local pango = {}

local markup = function (tag, text)
  local first = tag
  local index = string.find(tag, ' ')
  if index ~= nil then
    first = string.sub(tag, 1, index - 1)
  end
  return '<' .. tag .. '>' .. text .. '</' .. first .. '>'
end

pango.color = function (col, text)
  if theme.colors[col] then
    col = theme.colors[col]
  end
  return markup('span color="' .. col .. '"', text)
end

pango.font = function (font, text)
  return markup('span font="' ..font.. '"', text)
end
pango.iconic = function (text)
  return pango.font('DejaVuSans Nerd Font 18', text)
end

return setmetatable(pango, { __call = function(_, ...) return markup(...) end })
