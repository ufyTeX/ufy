-- Page settings
tex.pagewidth = "210mm"
tex.pageheight = "297mm"
tex.hsize = "210mm"

-- Set the paragraph indentation
tex.parindent = "20pt"

-- Convert text to nodes
local f = io.open("lorem.txt", "rb")
local text = f:read("*all")
f:close()
local head = ufy.text_to_paragraph(text)

-- Break the paragraph into vertically stacked boxes
local vbox = tex.linebreak(head, { hsize = tex.hsize })

-- Write node to ‘current’ list
node.write(vbox)

