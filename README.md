# ufy

_WARNING: This is pre-release code, and very much a work in progress. Lots of functionality is missing and existing functionality may have serious bugs_.

_ufy_ is wrapper around the [LuaTeX](http://www.luatex.org/) typesetting engine. It exposes the core Lua API of LuaTeX in a clean and minimal way. This API can be used to perform typesetting tasks using Lua code, and generate PDF files.

### Benefits of using _ufy_
* No need for an elaborate TeX installation like TeX Live, MikTeX etc. The only dependencies are – [Lua], [LuaRocks] and the [LuaTeX binary] for your platform.
* No need to know the TeX macro language, which is a bit dated and can be very confusing for modern programmers. Write your typesetting code in pure Lua on top of the API that LuaTeX exposes (refer to the [LuaTeX user manual][manual]).
* No need to deal with legacy TeX based font formats like .tfm, .pfb, .map files etc. You can directly load TTF/OTF files.
* Use or write LuaRocks modules for reusable and distributable code. For example, one could use [luaharfbuzz] and [luabidi] to reorder and shape text (see [example][bidi-example]) in non-latin scripts like Arabic or Devanagari before using the TeX engine for typesetting.

[bidi-example]:https://github.com/deepakjois/ufy/blob/master/examples/bidi.lua
[Lua]:https://www.lua.org
[LuaRocks]:https://luarocks.org/
[luaharfbuzz]:https://github.com/deepakjois/luaharfbuzz
[luabidi]:https://github.com/deepakjois/luabidi
[manual]:http://www.luatex.org/svn/trunk/manual/luatex.pdf

### Drawbacks of using _ufy_
Using the LuaTeX API gives access to low-level internals of the TeX engine. The client has to provide the higher level functionality. TeX distributions like MacTeX and MikTeX come bundled with macro files, fonts etc. that enable typesetting of complex documents without a lot of additional work. With _ufy_, one wll need to write Lua code to replicate all that functionality, or use a LuaRocks module that already provides it.

## Running

### Install Lua 5.2 and LuaRocks in a sandboxed environment
It is highly recommended that you install Lua 5.2 and LuaRocks in a sandboxed environment on your machine. [Hererocks] makes it dead simple to do, on all platforms.

[Hererocks]:https://github.com/mpeterv/hererocks

```
wget https://raw.githubusercontent.com/mpeterv/hererocks/latest/hererocks.py
hererocks lua52 -l5.2 -rlatest
source lua52/bin/activate
eval $(luarocks path)
```

### Checkout and setup ufy

Install _ufy_ and make an executable binary available on PATH. If you encounter any problems, make sure you have followed the instructions above to install and activate Lua in a sandbox first.

```
git clone https://github.com/deepakjois/ufy
cd ufy
luarocks make
ufy --setup
```

Running `ufy --setup` as shown above will download the [LuaTeX binary] for your platform and copy it to `$HOME/.ufy/` (`%USERPROFILE%/.ufy` on Windows).

WARNING: _`ufy --setup` currently does not work for Windows, because the binaries are not available for download anywhere. You will have to compile and install your own copy of the LuaTeX binary into `%USERPROFILE%\.ufy`_

[LuaTeX binary]:http://www.luatex.org/download.html

### Run ufy

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

## References

* [TeX by Topic](http://texdoc.net/texmf-dist/doc/plain/texbytopic/TeXbyTopic.pdf) (PDF) – Understand the internals of TeX.
* [LuaTeX Reference](http://www.luatex.org/svn/trunk/manual/luatex.pdf) (PDF) – The definitive reference to the Lua API provided by LuaTeX.
