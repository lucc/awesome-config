-- helper functions to deal with pango markup

local theme = require("beautiful")

local markup = function (tag, text)
  local first = tag
  local index = string.find(tag, ' ')
  if index ~= nil then
    first = string.sub(tag, 1, index - 1)
  end
  return '<' .. tag .. '>' .. text .. '</' .. first .. '>'
end

local color = function (col, text)
  if theme.colors[col] then
    col = theme.colors[col]
  end
  return markup ('span color="' .. col .. '"', text)
end

return { color = color, markup = markup }
