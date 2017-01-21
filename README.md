# ufy

_WARNING: This is pre-release code, and very much a work in progress. Lots of functionality is missing and existing functionality may have serious bugs_.

_ufy_ is wrapper around the [LuaTeX](http://www.luatex.org/) typesetting engine. It exposes the core Lua API of LuaTeX in a clean and minimal way.

* No need for an elaborate TeX installation like TeX Live, MikTeX etc. The only dependencies are – [Lua], [LuaRocks] and the [LuaTeX binary] for your platform.
* No need to know the TeX macro language, which is a bit dated and can be very confusing for modern programmers. Write your typesetting code in pure Lua on top of the API that LuaTeX exposes (refer to the [LuaTeX user manual][manual]).
* No need to deal with legacy TeX based font related formats like .tfm, .pfb, .map etc. You can directly load TTF/OTF files.
* Use or write LuaRocks modules for reusable and distributable code. For example, one could use [luaharfbuzz] and [luabidi] to shape text in non-latin scripts like Arabic or Devanagari before sending it to TeX for typesetting.

[Lua]:https://www.lua.org
[LuaRocks]:https://luarocks.org/
[luaharfbuzz]:https://github.com/deepakjois/luaharfbuzz
[luabidi]:https://github.com/deepakjois/luabidi
[manual]:http://www.luatex.org/svn/trunk/manual/luatex.pdf

## Drawbacks
Using the LuaTeX API gives access to the low-level internals of the TeX engine, leaving the client to provide most of the higher level functionality. TeX distributions come bundled with macro files, fonts etc. that enable typesetting complex documents without doing a lot of additional work. With ufy, one will need to write Lua code to replicate all that functionality, or use a LuaRocks module that provides it.

The idea with _ufy_ is to let people contribute modules in Lua as rocks, and reuse them.

## Running

### Install Lua 5.2 and LuaRocks in a sandboxed environment
It is highly recommended that you install Lua 5.2 and LuaRocks in a sandboxed environment on your machine. [Hererocks] makes it dead simple to do, on all platforms.

```
wget https://raw.githubusercontent.com/mpeterv/hererocks/latest/hererocks.py

hererocks lua52 -l5.2 -rlatest
source lua52/bin/activate
```

### Download standalone LuaTeX binary
Download the [LuaTeX binary] for your platform and copy it to `$HOME/.ufy/` (`%USERPROFILE%/.ufy` on Windows):

[LuaTeX binary]:http://www.luatex.org/download.html

```
wget -O $HOME/.ufy/luatex http://minimals.contextgarden.net/current/bin/luatex/osx-intel/bin/luatex
chmod +x $HOME/.ufy/luatex
```

### Checkout and run ufy

This install _ufy_ and make an executable binary available on PATH. If you encounter any problems, make sure you follow the instructions above to install and activate Lua in a sandbox.

```
git clone https://github.com/deepakjois/ufy
cd ufy
luarocks make
```

Run an example file that generates a PDF:

```
$ cd examples

$ ufy hello.lua
…
…<snip>…
…
Output written on hello.pdf (1 page, 17251 bytes).
Transcript written on hello.log.
```
