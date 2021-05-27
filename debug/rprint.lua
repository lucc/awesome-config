local function format(arg)
  local t = type(arg)
  if t == "string" then
    return string.format("%q", arg)
  elseif t == "table" then
    local ret = "{"
    for k, v in pairs(arg) do
      ret = ret .. tostring(k) .. " = " .. format(v) .. ",\n"
    end
    ret = ret .. "}"
    return ret
  else
    return tostring(arg)
  end
end

return function (arg) print(format(arg)) end
