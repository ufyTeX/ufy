local bidi = require("bidi")
local utf8 = require("compat53.utf8")
local fonts = require("ufy.fonts")
local harfbuzz = require("harfbuzz")

local dbgtex = require("debugtex")

-- Page settings
tex.pagewidth = "210mm"
tex.pageheight = "297mm"
tex.hsize = "210mm"

-- Set the paragraph indentation
tex.parindent = "20pt"

-- PDF Related settings
pdf.setpkresolution(600)
pdf.setminorversion(5)

-- Load Amiri font, which should be present in the same directory.
local fontid = fonts.load_font("amiri-regular.ttf", 10)
font.current(fontid)

local function upem_to_sp(v,font)
  return math.floor(v / font.units_per_em * font.size)
end

-- Create a paragraph node from text after reordering and shaping.
local function text_to_shaped_bidi_paragraph(text)
  local current_font = font.current()
  local font_params = font.getfont(current_font).parameters

  local para_head = node.new("local_par")
  para_head.dir = "TRT"

  local last = para_head

  local indent = node.new("hlist",3)
  indent.dir = "TRT"
  indent.width = tex.parindent
  last.next = indent
  last = indent

  -- Run the bidi algorithm
  local codepoints = {}
  for _, c in utf8.codes(text) do
    codepoints[#codepoints + 1] = c
  end
  local reordered = bidi.get_visual_reordering(codepoints)

  -- Shape the text
  local buf = harfbuzz.Buffer.new()
  local face = harfbuzz.Face.new(font.getfont(current_font).filename)
  local hb_font = harfbuzz.Font.new(face)

  buf:set_cluster_level(harfbuzz.Buffer.HB_BUFFER_CLUSTER_LEVEL_CHARACTERS)
  buf:add_codepoints(reordered)
  buf:reverse()
  harfbuzz.shape(hb_font, buf, { direction = "RTL" })
  buf:reverse()

  -- Create nodelist
  local glyphs = buf:get_glyph_infos_and_positions()

  for _, v in ipairs(glyphs) do
    local n,k -- Node and (optional) Kerning
    local char = font.getfont(current_font).backmap[v.codepoint]
    print(string.format("char is %02x, at index",char, v.cluster))
    if codepoints[#codepoints - v.cluster] == 0x20 then
      assert(char == 0x20 or char == 0xa0, "Expected char to be 0x20 or 0xa0")
      n = node.new("glue", 13)
      node.setglue(n, font_params.space, font_params.space_shrink, font_params.space_stretch)
      last.next = n
    else
      -- Create glyph node
      n = node.new("glyph", 1)
      n.font = current_font
      n.char = char
      n.subtype = 1

      -- Set offsets from Harfbuzz data
      n.yoffset = upem_to_sp(v.y_offset, font.getfont(current_font))
      n.xoffset = upem_to_sp(v.x_offset, font.getfont(current_font))
      n.xoffset = n.xoffset * -1 -- Because of RTL text

      -- Adjust kerning if Harfbuzz’s x_advance does not match glyph width
      local x_advance = upem_to_sp(v.x_advance, font.getfont(current_font))
      if  math.abs(x_advance - n.width) > 1 then -- needs kerning
        k = node.new("kern")
        k.kern = (x_advance - n.width)
      end

      -- Insert glyph node into new list,
      -- adjusting for direction and kerning.
      if k then
        -- kerning goes before glyph in TRT
          k.next = n
          last.next = k
      else -- no kerning
        last.next = n
      end
    end
    last = node.slide(last)
  end

   -- now add the final parts: a penalty and the parfillskip glue
  local penalty = node.new("penalty", 0)
  penalty.penalty = 10000

  local parfillskip = node.new("glue", 14)
  parfillskip.stretch = 2^16
  parfillskip.stretch_order = 2

  last.next = penalty
  penalty.next = parfillskip

  node.slide(para_head)
  return para_head
end

tex.parindent = "50pt"
-- Load text
local f = io.open("bidi.txt", "rb")
local text = f:read("*all")
f:close()

-- Convert text to nodes
local head = text_to_shaped_bidi_paragraph(text)
dbgtex.show_nodes(head, true)

-- Break the paragraph into vertically stacked boxes
local vbox = tex.linebreak(head, { hsize = tex.hsize, pardir = "TRT" })
dbgtex.show_nodes(vbox, true)

tex.box[666] = node.vpack(vbox)
tex.shipout(666)
