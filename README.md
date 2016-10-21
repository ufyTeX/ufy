# ufy

_WARNING: This is pre-release code, and very much a work in progress. Lots of functionality is missing and existing functionality may have serious bugs._

_ufy_ is an API and program to typeset PDF documents using Lua code and the [LuaTeX](http://www.luatex.org/) typesetting engine.

The _ufy_ API is built on top of the API that LuaTeX exposes (refer to the [LuaTeX user manual][manual]). The _ufy_ program uses the Lua interpreter embedded in LuaTeX to execute Lua code, but at the same time allows use of any Lua modules on the system – LuaRocks modules or other Lua modules exposed using LUA_PATH.

[manual]:http://www.luatex.org/svn/trunk/manual/luatex.pdf

Here is a really simple and crude example of typesetting a document with _ufy_:

```lua
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
```

## Running

These are instructions to fetch and run ufy, while it is still under heavy development. Things will be automated and cleaned up closer to release. See https://github.com/deepakjois/ufy/issues/1

### Download standalone LuaTeX binary
Download the [LuaTeX binary](http://www.luatex.org/download.html) for your platform and copy it so `$HOME/.ufy/`:

```
wget -O $HOME/.ufy/luatex http://minimals.contextgarden.net/current/bin/luatex/osx-intel/bin/luatex
chmod +x $HOME/.ufy/luatex
```

### Checkout and run ufy

We install ufy and its dependencies in a local Luarocks tree to keep things clean.

```
git clone https://github.com/deepakjois/ufy
cd ufy
luarocks --local make
eval $(luarocks path --bin)
```

Run an example file to check if it generates the PDF:

```
$ cd examples

$ ufy hello.lua
Checking if luatex is present…
/Users/deepak/.ufy/luatex --shell-escape --lua=/Users/deepak/.luarocks/lib/luarocks/rocks/ufy/scm-1/config/ufy_pre_init.lua \&ufy hello.lua
This is LuaTeX, Version 1.0.0 (TeX Live 2017/dev)
 system commands enabled.
(hello.lua [1{/Users/deepak/.luarocks/lib/luarocks/rocks/ufy/scm-1/config/fonts
/pdftex.map}])</Users/deepak/.luarocks/lib/luarocks/rocks/ufy/scm-1/config/font
s/cmr10.pfb>
Output written on hello.pdf (1 page, 17251 bytes).
Transcript written on hello.log.
```

This should generate a PDF file `hello.pdf` in the same folder.



