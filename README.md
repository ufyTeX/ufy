# ufy

_WARNING: This is pre-release code, and very much a work in progress. Lots of functionality is missing and existing functionality may have serious bugs_.

_ufy_ is wrapper around the [LuaTeX](http://www.luatex.org/) typesetting engine. It exposes the core Lua-based API of LuaTeX in a clean and minimal way. This API could be used to perform typesetting using only Lua, without needing to use the TeX macro language.

### Benefits of using _ufy_
* You don’t need to know the TeX macro language, which can be very confusing for modern-day programmers. Write your typesetting code in pure Lua (refer to the [LuaTeX user manual][manual]).
* You don’t need an elaborate TeX installation like TeX Live, MikTeX etc. to get up and running. The only dependencies are – [Lua], [LuaRocks] and the [LuaTeX binary] for your platform.
* You don’t need to deal with legacy TeX based font formats like .tfm, .pfb, .map files etc. Basic loading of TTF/OTF files is supported by the `ufy.fonts` module.
* Use or write LuaRocks modules for reusable and distributable code. For example, one could use [luaharfbuzz] and [luabidi] to reorder and shape text (see [example][bidi-example]) in non-latin scripts like Arabic before using the TeX engine for typesetting.

[bidi-example]:https://github.com/deepakjois/ufy/blob/master/examples/bidi.lua
[Lua]:https://www.lua.org
[LuaRocks]:https://luarocks.org/
[luaharfbuzz]:https://github.com/deepakjois/luaharfbuzz
[luabidi]:https://github.com/deepakjois/luabidi
[manual]:http://www.luatex.org/svn/trunk/manual/luatex.pdf

### Drawbacks of using _ufy_
Using the LuaTeX API gives access to low-level internals of the TeX engine. The client has to still provide the higher level functionality. TeX distributions like MacTeX and MikTeX come bundled with macro packages like LaTeX, fonts and other artefacts that do a lot of the heavy lifting in typesetting complex documents.

With _ufy_, you are pretty much on your own at the moment. _ufy_ invokes the LuaTeX binary with the `--ini` flag, so that is the environment you get dropped into when ufy starts. You could extend the capabilities of _ufy_ by writing and sharing LuaRocks modules for more complex typesetting tasks.

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

WARNING: _`ufy --setup` currently does not work for Windows, because the binaries are not available for download anywhere. You will have to compile and install your own copy of the LuaTeX binary into `%USERPROFILE%\.ufy`_

Running `ufy --setup` as shown above will download the [LuaTeX binary] for your platform and copy it to `$HOME/.ufy/` (`%USERPROFILE%/.ufy` on Windows).

[LuaTeX binary]:http://www.luatex.org/download.html

### Run ufy

Run an example file that generates a PDF:

```
$ cd examples

$ ufy hello.lua
Checking if luatex is present…

/home/deepak/.ufy/luatex --shell-escape --lua=/home/deepak/lua52/lib/luarocks/rocks/ufy/scm-1/config/ufy_pre_init.lua --jobname=bidi --ini '\catcode`\{=1' '\catcode`\}=2' '\directlua{ufy.init()}' '\directlua{dofile("bidi.lua")}' '\end'

This is LuaTeX, Version 1.0.0 (TeX Live 2017/dev)  (INITEX)
 system commands enabled.
…
…<snip>…
…
Output written on hello.pdf (1 page, 17251 bytes).
Transcript written on hello.log.
```

## References

* [TeX by Topic](http://texdoc.net/texmf-dist/doc/plain/texbytopic/TeXbyTopic.pdf) (PDF) – Understand the internals of TeX.
* [LuaTeX Reference](http://www.luatex.org/svn/trunk/manual/luatex.pdf) (PDF) – The definitive reference to the Lua API provided by LuaTeX.
* [Tex without TeX](http://wiki.luatex.org/index.php/TeX_without_TeX) – The information on this page may be a bit outdated, but it is a good reference to understand the basic concepts behind using LuaTeX without the TeX macro language.

## Credits
* [SILE](https://github.com/simoncozens/sile) – which originally sparked the idea.
* [speedata Publisher](https://github.com/speedata/publisher) which already does this, but not in a general-purpose way.
* People on [TeX.SX](http://tex.stackexchange.com/) and [LuaTeX mailing list](https://tug.org/mailman/listinfo/luatex) for all their assistance.
