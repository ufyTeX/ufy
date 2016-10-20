# ufy

_WARNING: This is pre-release code, and very much a work in progress. Lots of functionality is missing and existing functionality may have serious bugs._

_ufy_ is an API and program to typeset PDF documents using Lua code and the [LuaTeX](http://www.luatex.org/) typesetting engine.

The _ufy_ API is built on top of the API that LuaTeX exposes (refer to the [LuaTeX user manual][manual]). The _ufy_ program uses the Lua interpreter embedded in LuaTeX to execute Lua code, but at the same time allows use of any Lua modules on the system – LuaRocks modules or other Lua modules exposed using LUA_PATH ca.

[manual]:http://www.luatex.org/svn/trunk/manual/luatex.pdf

## Running

These are instructions to fetch and run ufy, while it is still under heavy development. Things will be automated and cleaned up closer to release. See https://github.com/deepakjois/ufy/issues/1

Install [luatexminimal], which is a minimal environment to run LuaTeX.

[luatexminimal]:https://github.com/deepakjois/luatexminimal

```
mkdir $HOME/.ufy
git clone https://github.com/deepakjois/luatexminimal $HOME/.ufy/luatexminimal
```

Download the [LuaTeX binary](http://www.luatex.org/download.html) for your OS and copy it so `$HOME/.ufy/luatexminimal`:

```
wget -O http://minimals.contextgarden.net/current/bin/luatex/osx-intel/bin/luatex
chmod +x $HOME/.ufy/luatexminimal/luatex
```

Now you are ready to checkout and run _ufy_:

```
git clone https://github.com/deepakjois/ufy
cd ufy
luarocks install --only-deps ufy-scm-1.rockspec
eval $(luarocks path)
export LUA_PATH=`pwd/src/?/init.lua;$LUA_PATH`
```

Run an example file to check if generates the PDF:
```
cd examples
../bin/ufy hello.lua
```

This should generate a PDF file `hello.pdf` in the same folder.



