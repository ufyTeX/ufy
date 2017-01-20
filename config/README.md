# ufy-config

This folder contains a minimal set of configuration files that are essential to run [ufy](https://github.com/deepakjois/ufy):

* `ufy_pre_init.lua` – Lua file passed as an argument to flag `--lua` when invoking LuaTeX. Does some pre-initialization and loads the `ufy` Lua module.
* `ufy.tex` – Format file for ufy
* `ufy.fmt` – ufy’s format file pre-compiled from `ufy.tex`

## Format generation
_You normally don’t need to do this, because ufy LuaRocks module bundles the format file already._

If you have ufy correctly setup, you can generate a .fmt format file from ufy.tex as follows. Make sure this folder is the current working directory.

```
~/.ufy/luatex --ini ufy.tex
```

