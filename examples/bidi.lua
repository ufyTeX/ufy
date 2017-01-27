local bidi = require("bidi")          -- luarocks install luabidi
local utf8 = require("compat53.utf8") -- luarocks install compat53
local fonts = require("ufy.fonts")
local harfbuzz = require("harfbuzz")  -- luarocks install luaharfbuzz

dofile("plain.lua")

-- local dbgtex = require("debugtex")

-- A4 Paper Size w/ 1in margins on left and top
tex.pagewidth = "210mm"
tex.pageheight = "297mm"
tex.hoffset = tex.sp("1in")
tex.voffset = tex.sp("1in")

-- PDF Related settings
pdf.setpkresolution(600)
pdf.setminorversion(5)

-- Load Amiri font, which should be present in the same directory.
local amiri_fontid = fonts.load_font("amiri-regular.ttf", "10pt")
font.current(amiri_fontid)
local amiri = font.getfont(amiri_fontid)

local function upem_to_sp(v,font)
  return math.floor(v / font.units_per_em * font.size)
end

-- Create a paragraph node from text after reordering and shaping.
--
-- Assumes Arabic RTL text, for simplicity.
local function text_to_shaped_bidi_paragraph(text)

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
  local face = harfbuzz.Face.new(amiri.filename)
  local hb_font = harfbuzz.Font.new(face)

  buf:set_cluster_level(harfbuzz.Buffer.HB_BUFFER_CLUSTER_LEVEL_CHARACTERS)
  buf:add_codepoints(reordered)
  buf:reverse()
  harfbuzz.shape(hb_font, buf, { direction = "RTL" })
  buf:reverse()

  local font_params = amiri.parameters

  -- Create nodelist
  local glyphs = buf:get_glyph_infos_and_positions()

  for _, v in ipairs(glyphs) do
    local n,k -- Node and (optional) Kerning
    local char = amiri.backmap[v.codepoint]
    if codepoints[#codepoints - v.cluster] == 0x20 then
      -- Create spaceskip glue
      n = node.new("glue", 13)
      node.setglue(n, font_params.space, font_params.space_shrink, font_params.space_stretch)
      last.next = n
    else
      -- Create glyph node
      n = node.new("glyph", 1)
      n.font = amiri_fontid
      n.char = char
      n.subtype = 1

      -- Set offsets from Harfbuzz data
      n.yoffset = upem_to_sp(v.y_offset, amiri)
      n.xoffset = upem_to_sp(v.x_offset, amiri)
      n.xoffset = n.xoffset * -1 -- Because of RTL text

      -- Adjust kerning if Harfbuzz’s x_advance does not match glyph width
      local x_advance = upem_to_sp(v.x_advance, amiri)
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
-- dbgtex.show_nodes(head, true)

-- Break the paragraph into vertically stacked boxes
local vbox = tex.linebreak(head, { hsize = tex.hsize, pardir = "TRT" })
-- dbgtex.show_nodes(vbox, true)

tex.box[666] = node.vpack(vbox)
tex.shipout(666)

