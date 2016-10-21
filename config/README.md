# ufy-config

This folder contains a minimal set of configuration files that are essential to run [ufy](https://github.com/deepakjois/ufy):

* `ufy_pre_init.lua` – Lua file passed as an argument to flag `--lua` when invoking LuaTeX. Does some pre-initialization and loads the `ufy` Lua module.
* `ufy.tex` – Format file for ufy
* `ufy.fmt` – ufy’s format file pre-compiled from `ufy.tex`
* `cmr10.tfm` – TFM metrics file for Computer Modern Roman 10pt font (used during format generation)
* `cmr10.pfb` – Font file for Computer Modern Roman 10pt in Adobe Type 1 format
* `pdftex.map` - A that contains a single line mapping the name `cmr10` to the corresponding file `cmr10.pfb`. Used by LuaTeX while generating PDF output

## Format generation
_You normally don’t need to do this, because ufy LuaRocks module bundles the format file already._

If you have ufy correctly setup, you can generate a .fmt format file from ufy.tex as follows. Make sure this folder is the current working directory.

```
~/.ufy/luatex --lua=ufy_pre_init.lua --ini ufy.tex
```

