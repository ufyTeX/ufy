local textutils = dofile("textutils.lua")

-- load Plain TeX defaults
dofile("plain.lua")


local fonts = require("ufy.fonts")

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

-- Read text file
local f = io.open("lorem.txt", "rb")
local content = f:read("*all")
f:close()

local head = textutils.text_to_paragraph(content, "TLT")

-- Break the paragraph into vertically stacked boxes
local vbox = tex.linebreak(head, { hsize = tex.hsize })

node.write(vbox)
