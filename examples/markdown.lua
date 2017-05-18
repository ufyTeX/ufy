local cmark = require "cmark" -- luarocks install cmark
local utf8 = require("compat53.utf8") -- luarocks install compat53
local fonts = require("ufy.fonts")

local f = io.open("md.txt", "rb")
local input = f:read("*all")

local doc = cmark.parse_string(input, cmark.OPT_DEFAULT)

local para_head, last

for cur, entering, node_type in cmark.walk(doc) do
  if entering and node_type == cmark.NODE_DOCUMENT then
    print("start processing document")
    -- load Plain TeX defaults
    dofile("plain.lua")
    -- A4 Paper Size w/ 1in margins on left and top
    tex.pagewidth = "210mm"
    tex.pageheight = "297mm"
    tex.hoffset = tex.sp("1in")
    tex.voffset = tex.sp("1in")

    -- PDF Related settings
    pdf.setpkresolution(600)
    pdf.setminorversion(5)

    -- Load Amiri font, which should be present in the same directory.
    local fontid = fonts.load_font("amiri-regular.ttf", "10pt")
    font.current(fontid)
  elseif not entering and node_type == cmark.NODE_DOCUMENT then
    print("finish processing document")
  elseif entering and node_type == cmark.NODE_PARAGRAPH then
    print("start processing paragraph")
    -- TODO check if vertical list is empty and insert parskip if not.
    para_head = node.new("local_par")
    para_head.dir = "TRT"

    last = para_head

    local indent = node.new("hlist",3)
    indent.width = tex.parindent
    indent.dir = "TRT"
    last.next = indent
    last = indent
  elseif not entering and node_type == cmark.NODE_PARAGRAPH then
    print("finish processing paragraph")
    -- now add the final parts: a penalty and the parfillskip glue
    local penalty = node.new("penalty", 0)
    penalty.penalty = 10000

    local parfillskip = node.new("glue", 14)
    parfillskip.stretch = 2^16
    parfillskip.stretch_order = 2

    last.next = penalty
    penalty.next = parfillskip

    node.slide(para_head)

    -- Break the paragraph into vertically stacked boxes
    local vbox = tex.linebreak(para_head, { hsize = tex.hsize })

    node.write(vbox)

    local skip = node.new("glue", 1)
    print("vbox depth ", vbox.depth)
    print("baseline skip width ", tex.baselineskip.width)
    node.setglue(skip, tex.baselineskip.width)

    node.write(skip)
  elseif entering and node_type == cmark.NODE_TEXT then
    print("process paragraph text")
    local text = cmark.node_get_literal(cur)
    local current_font = font.current()
    local font_params = font.getfont(current_font).parameters
    for _,v in utf8.codes(text) do
      local n
      if v < 32 then
        goto skipchar
      elseif v == 32 then -- FIXME use Unicode properties to identify whitespace
        n = node.new("glue",13)
        node.setglue(n, font_params.space, font_params.space_shrink, font_params.space_stretch)
      else
        n = node.new("glyph", 1)
        n.font = current_font
        n.char = v
        n.lang = tex.language
        n.uchyph = 1
        n.left = tex.lefthyphenmin
        n.right = tex.righthyphenmin
      end
      last.next = n
      last = n
      ::skipchar::
    end
  else
    error("Invalid Document! Only plain paragraphs allowed.")
  end
end
