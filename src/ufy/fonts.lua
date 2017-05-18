local fonts = {}

-- Read font metrics. Size is specified in TeX sp units.
function fonts.read_font_metrics(file, size)
  if size < 0 then
    size = size * tex.sp("10pt") / -1000
  end
  -- Load file using fontloader.open
  local f = fontloader.open (file)
  local fonttable = fontloader.to_table(f)
  fontloader.close(f)

  local metrics = {
    name = fonttable.fontname,
    fullname = fonttable.fontname,
    type = "real",
    filename = file,
    psname = fonttable.fontname,
    format = string.match(string.lower(file), "otf$") and "opentype" or string.match(string.lower(file), "ttf$") and "truetype",
    embedding = 'subset',
    size = size,
    designsize = size,
    cidinfo = fonttable.cidinfo,
    units_per_em = fonttable.units_per_em
  }

  -- Scaling for font metrics
  local mag = size / fonttable.units_per_em

  -- Find glyph for 0x20, and get width for spacing glue.
  local space_glyph = fonttable.map.map[0x20]
  local space_glyph_table = fonttable.glyphs[space_glyph]
  local space_glyph_width = space_glyph_table.width * mag

  metrics.parameters = {
    slant = 0,
    space = space_glyph_width,
    space_stretch = 1.5 * space_glyph_width,
    space_shrink = 0.5 * space_glyph_width,
    x_height = fonttable.pfminfo.os2_xheight * mag,
    quad = 1.0 * size,
    extra_space = 0
  }

  -- Save backmap in TeX font, so we can get char code from glyph index
  -- obtainded from Harfbuzz
  metrics.backmap = fonttable.map.backmap

  metrics.characters = { }
  for char, glyph in pairs(fonttable.map.map) do
    local glyph_table = fonttable.glyphs[glyph]
    metrics.characters[char] = {
      index = glyph,
      width = glyph_table.width * mag,
      name = glyph_table.name,
    }
    if glyph_table.boundingbox[4] then
      metrics.characters[char].height = glyph_table.boundingbox[4] * mag
    end
    if glyph_table.boundingbox[2] then
      metrics.characters[char].depth = -glyph_table.boundingbox[2] * mag
    end
  end

  return metrics
end

-- Load font at a given size. Size can be specified as
-- a TeX dimension, for e.g. 12pt
function fonts.load_font(file, size)
  size = tex.sp(size)

  local metrics = fonts.read_font_metrics(file, size)

  return font.define(metrics)
end

return fonts
