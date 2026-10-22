-- ==================================================
--  KoolDots (2026)
--  Project URL: https://github.com/LinuxBeginnings
--  License: GNU GPLv3
--  SPDX-License-Identifier: GPL-3.0-or-later
-- ==================================================

local function load_wallust_colors(path)
  local colors = {}
  local home = os.getenv("HOME") or ""
  local dynamic_path = home .. "/.config/hypr/config/colors_dynamic.lua"
  local ok_dyn = pcall(dofile, dynamic_path)
  if ok_dyn and DYNAMIC_ACTIVE_1 then
    colors["color12"] = DYNAMIC_ACTIVE_1
    colors["color10"] = DYNAMIC_INACTIVE or "rgba(5f6578ff)"
    colors["color15"] = DYNAMIC_ACTIVE_2 or DYNAMIC_ACTIVE_1
    colors["color0"]  = DYNAMIC_SURFACE or "rgba(0f111aff)"
  end

  local handle = io.open(path, "r")
  if not handle then
    return colors
  end

  for line in handle:lines() do
    local name, hex = line:match("^%s*%$([%w_]+)%s*=%s*rgb%(([0-9A-Fa-f]+)%)")
    if name and hex and hex ~= "" then
      colors[string.lower(name)] = "rgb(" .. string.upper(hex) .. ")"
    end
  end

  handle:close()
  return colors
end

return {
  load_wallust_colors = load_wallust_colors,
}
