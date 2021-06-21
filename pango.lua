-- helper functions to deal with pango markup

local theme = require("beautiful")

local pango = {}

local function markup(tag, text)
  local first = tag
  local index = string.find(tag, ' ')
  if index ~= nil then
    first = string.sub(tag, 1, index - 1)
  end
  return '<' .. tag .. '>' .. text .. '</' .. first .. '>'
end

function pango.escape(text)
  local replacements = {
    ["&"] = "&amp;",
    ["<"] = "&lt;",
    [">"] = "&gt;",
    ["\""] = "&quot;",
    ["'"] = "&apos;",
  }
  return string.gsub(text, "[&<>'\"]", replacements)
end

function pango.color(col, text)
  if theme.colors[col] then
    col = theme.colors[col]
  end
  return markup('span color="' .. col .. '"', text)
end
function pango.font(font, text)
  return markup('span font="' ..font.. '"', text)
end
function pango.mono(text)
  return markup('span font_desc="monospace"', text)
end
function pango.iconic(text)
  return pango.mono(pango.font('DejaVuSansMono Nerd Font 9', text).." ")
end

return setmetatable(pango, { __call = function(_, ...) return markup(...) end })
