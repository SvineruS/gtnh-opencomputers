local graphics = {}


local shapeAlpha = 0.5
local textAlpha = 0.5

function RGB(hex)
    local r = ((hex >> 16) & 0xFF) / 255.0
    local g = ((hex >> 8) & 0xFF) / 255.0
    local b = ((hex) & 0xFF) / 255.0
    return r, g, b
end


function graphics.quad(glasses, v1, v2, v3, v4, color)
  local quad = glasses.addQuad()
  quad.setVertex(1, v1[1], v1[2])
  quad.setVertex(2, v2[1], v2[2])
  quad.setVertex(3, v3[1], v3[2])
  quad.setVertex(4, v4[1], v4[2])
  quad.setColor(RGB(color))
  quad.setAlpha(shapeAlpha)
  return quad
end

function graphics.text(glasses, string, v1, scale, color)
  local text = glasses.addTextLabel()
  text.setText(string)
  text.setPosition(v1[1], v1[2])
  text.setScale(scale/3 or 1)
  text.setColor(RGB(color))
  text.setAlpha(textAlpha)
  return text
end





graphics.colors = {
    red = 0xFF0000,
    orange = 0xFFA500,
    yellow = 0xFFFF00,
    green = 0x008000,
    blue = 0x0000FF,
    indigo = 0x4B0082,
    violet = 0x800080,

    maroon = 0x800000,
    golden = 0xDAA520,
    lime = 0x00FF00,
    olive = 0x556B2F,
    cyan = 0x00FFFF,
    magenta = 0xFF00FF,

    black = 0x000000,
    white = 0xFFFFFF,
    gray = 0x3C5B72,
    lightGray = 0xA9A9A9,
    darkGray = 0x181828,

    electricBlue = 0x00A6FF,
    dodgerBlue = 0x1E90FF,
    steelBlue = 0x4682B4,
    midnightBlue = 0x191970,
    darkBlue = 0x000080,

    darkSlateGreen = 0x2F4F4F,
    darkSlateBlue = 0x303850
}
graphics.RGB = RGB

return graphics
