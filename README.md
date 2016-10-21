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

### Setup a minimal ufy configuaration
```
mkdir $HOME/.ufy
git clone https://github.com/deepakjois/ufy-config $HOME/.ufy/ufy-config
```

### Download standalone LuaTeX binary
Download the [LuaTeX binary](http://www.luatex.org/download.html) for your platform and copy it so `$HOME/.ufy/`:

```
wget -O $HOME/.ufy/luatex http://minimals.contextgarden.net/current/bin/luatex/osx-intel/bin/luatex
chmod +x $HOME/.ufy/luatex
```

### Checkout and run ufy

After checking out the source, we install the dependencies from LuaRocks. Since ufy is not in LuaRocks yet, we set a custom LUA_PATH to point to our source directory. This will not be needed later.

```
git clone https://github.com/deepakjois/ufy
cd ufy
luarocks install --only-deps ufy-scm-1.rockspec
eval $(luarocks path)
export LUA_PATH=`pwd`/src/?/init.lua;$LUA_PATH
```

Run an example file to check if it generates the PDF:

```
cd examples
../bin/ufy hello.lua
```

This should generate a PDF file `hello.pdf` in the same folder.



