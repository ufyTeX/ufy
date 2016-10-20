# ufy

_WARNING: This is pre-release code, and very much a work in progress._

_ufy_ is an API and program to typeset PDF documents using Lua code. It is built on top of [LuaTeX](http://www.luatex.org/), and uses the Lua interpreter embedded in it.

## Running

These are instructions to fetch and run ufy, while it is still under heavy development. Things will be automated and cleaned up closer to release.

Install [luatexminimal], which is a minimal environment to run LuaTeX.

```
mkdir $HOME/.ufy
git clone https://github.com/deepakjois/luatexminimal $HOME/.ufy/luatexminimal
```

Download the [LuaTeX binary](http://www.luatex.org/download.html) for your system and copy it so `$HOME/.ufy/luatexminimal`:

```
wget -O http://minimals.contextgarden.net/current/bin/luatex/osx-intel/bin/luatex
chmod +x $HOME/.ufy/luatexminimal/luatex
```

Now you are ready to checkout and run ufy:

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



