local fs = require("ufy.fontspec")

local test_cases = {}

describe("fontspec", function()
    for _,case in ipairs(test_cases) do
      it(string.format("can parse '%s'", case.spec), function()
      assert.are.same(fs.parse(case.spec), case.result, string.format("Parsing string ‘%s’ failed", case.spec))
    end)
    end
end)

local function t(spec, result)
  return { spec = spec, result = result }
end

test_cases = {
  t("[lmroman10-regular]",             {filename = "lmroman10-regular"}),
  t("[abc.ttc:1]",                     {filename = "abc.ttc", fontindex = "1"}),
  t("Liberation Serif",                {fontname = "Liberation Serif"}),
  t("Liberation Serif /B",             {fontname = "Liberation Serif", options = {bold = true}}),
  t("Liberation Serif /BI/GR",         {fontname = "Liberation Serif", options = {bolditalic = true, graphite = true}}),
  t("Liberation Serif /U:+smcp",       {fontname = "Liberation Serif", features = {smcp = true}}), -- ignore unknown options
  t("Liberation Serif /S=23",          {fontname = "Liberation Serif", options = {opticalsize = '23'}}),
  t("[abc.ttf]:+smcp",                 {filename = "abc.ttf", features = {smcp = true}}),
  t("Liberation Serif:+smcp",          {fontname = "Liberation Serif", features = {smcp = true}}),
  t("[abc.ttf]:+smcp,+aalt=1",         {filename = "abc.ttf", features = {smcp = true, aalt = "1"}}),
  t("[abc.ttf]:-smcp, +aalt=1",        {filename = "abc.ttf", features = {smcp = false, aalt = "1"}}),
  t("[abc.ttf]:script=arab, lang=urd", {filename = "abc.ttf", features = {script = "arab", lang = "urd"}}),
  t("[abc.ttf:script=arab, lang=urd",  nil),
  t("[abc.ttf:script%arab, lang=urd",  nil)
}
