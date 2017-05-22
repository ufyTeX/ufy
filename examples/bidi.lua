local fonts = require("ufy.fonts")
local ufylayout = require("ufylayout") -- luarocks install ufylayout

local textutils = dofile("textutils.lua")
dofile("plain.lua")

-- A4 Paper Size w/ 1in margins on left and top
tex.pagewidth = "210mm"
tex.pageheight = "297mm"
tex.hoffset = tex.sp("1in")
tex.voffset = tex.sp("1in")

-- PDF Related settings
pdf.setpkresolution(600)
pdf.setminorversion(5)

-- Create a paragraph node from text after reordering and shaping.
--
-- Assumes Arabic RTL text, for simplicity.
local function text_to_shaped_bidi_paragraph(text)
  -- Load Amiri font, which should be present in the same directory.
  local amiri_fontid = fonts.load_font("amiri-regular.ttf", "10pt")

  -- Set the Harfbuzz flag on the font
  local f = font.getfont(amiri_fontid)
  f.harfbuzz = true

  -- Set the current font to Amiri
  font.current(amiri_fontid)

  local head = textutils.text_to_paragraph(text, "TRT")

  local para_head = ufylayout.layout_nodes(head)

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

