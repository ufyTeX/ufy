-- Set the internal TeX parameters to exactly match the values when
-- Plain TeX is loaded.
--
-- Refer to plain.tex: http://ctan.imsc.res.in/macros/plain/base/plain.tex
tex.pretolerance=100
tex.tolerance=200
tex.hbadness=1000
tex.vbadness=1000
tex.linepenalty=10
tex.hyphenpenalty=50
tex.exhyphenpenalty=50
tex.binoppenalty=700
tex.relpenalty=500
tex.clubpenalty=150
tex.widowpenalty=150
tex.displaywidowpenalty=50
tex.brokenpenalty=100
tex.predisplaypenalty=10000
tex.doublehyphendemerits=10000
tex.finalhyphendemerits=5000
tex.adjdemerits=10000
tex.tracinglostchars=1
tex.uchyph=1
tex.defaultskewchar=-1
tex.newlinechar=-1
tex.delimiterfactor=901
tex.showboxbreadth=5
tex.showboxdepth=3
tex.errorcontextlines=5
tex.hfuzz=tex.sp("0.1pt")
tex.vfuzz=tex.sp("0.1pt")
tex.overfullrule=tex.sp("5pt")
tex.hsize=tex.sp("6.5in")
tex.vsize=tex.sp("8.9in")
tex.maxdepth=tex.sp("4pt")
tex.splitmaxdepth=tex.sp("16383.99999pt")
tex.boxmaxdepth=tex.sp("16383.99999pt")
tex.delimitershortfall=tex.sp("5pt")
tex.nulldelimiterspace=tex.sp("1.2pt")
tex.scriptspace=tex.sp("0.5pt")
tex.parindent=tex.sp("20pt")
tex.setglue('parskip', 0, 65536, 0, 0, 0)
tex.setglue('abovedisplayskip', 786432, 196608, 589824, 0, 0)
tex.setglue('abovedisplayshortskip', 0, 196608, 0, 0, 0)
tex.setglue('belowdisplayskip', 786432, 196608, 589824, 0, 0)
tex.setglue('belowdisplayshortskip', 458752, 196608, 262144, 0, 0)
tex.setglue('topskip', 655360, 0, 0, 0, 0)
tex.setglue('splittopskip', 655360, 0, 0, 0, 0)
tex.setglue('parfillskip', 0, 65536, 0, 2, 0)
tex.setglue('baselineskip', 786432, 0, 0, 0, 0)
tex.setglue('lineskip', 65536, 0, 0, 0, 0)
