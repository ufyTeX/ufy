-- Page settings
tex.pagewidth = "210mm"
tex.pageheight = "297mm"
tex.hsize = "210mm"

-- Set the paragraph indentation
tex.parindent = "20pt"

-- PDF Related settings
pdf.setpkresolution(600)
pdf.setminorversion(5)

-- Load Merriweather font, which is bundled with ufy
local fontid = ufy.fonts.load_font(string.format("%s/fonts/%s", ufy.config_dir(), "Merriweather-Light.ttf"), 10)
font.current(fontid)

-- Convert text to nodes
local f = io.open("lorem.txt", "rb")
local text = f:read("*all")
f:close()
local head = ufy.text_to_paragraph(text)

-- Break the paragraph into vertically stacked boxes
local vbox = tex.linebreak(head, { hsize = tex.hsize })

tex.box[666] = node.vpack(vbox)
tex.shipout(666)
