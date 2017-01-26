local utf8 = require("compat53.utf8") -- luarocks install compat53
local fonts = require("ufy.fonts")

-- Tracing Settings
-- tex.tracingassigns    = 1
-- tex.tracingcommands   = 1
-- tex.tracinggroups     = 1
-- tex.tracingifs        = 1
-- tex.tracinglostchars  = 1
-- tex.tracingmacros     = 1
-- tex.tracingnesting    = 1
tex.tracingonline     = 1
tex.tracingoutput     = 1
tex.tracingpages      = 1
tex.tracingparagraphs = 1
-- tex.tracingrestores   = 1
-- tex.tracingscantokens = 1
tex.tracingstats      = 1

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

-- Build a simple paragraph node from given text. This code does not do any complex shaping etc.
--
-- adapted from: http://tex.stackexchange.com/questions/114568/can-i-create-a-node-list-from-some-text-entirely-within-lua
local function text_to_paragraph(text)
  local current_font = font.current()
  local font_params = font.getfont(current_font).parameters

  local para_head = node.new("local_par")
  para_head.dir = "TRT"

  local last = para_head

  local indent = node.new("hlist",3)
  indent.width = tex.parindent
  indent.dir = "TRT"
  last.next = indent
  last = indent

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

local head = text_to_paragraph("hello world")

-- Break the paragraph into vertically stacked boxes
local vbox = tex.linebreak(head, { hsize = tex.hsize })

tex.box[666] = node.vpack(vbox)
tex.shipout(666)
