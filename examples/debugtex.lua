local debugtex = {}

local function dump_fields(n, fields)
    local dump = {}
    for _,v in ipairs(fields) do
      table.insert(dump, string.format("%s: %s", v, n[v]))
    end
    return "{" .. table.concat(dump, ",") .. "}"
end

local function dump_node(n)
  return dump_fields(n, node.fields(n.id))
end

function debugtex.show_nodes (head, raw)
  local nodes = "\n\n<NodeList>\n"
  for item in node.traverse(head) do
    local i = item.id
    if i == node.id("glyph") then
      if raw then i = string.format('<glyph U+%04X> - %s', item.char, dump_node(item)) else i = unicode.utf8.char(item.char) end
    else
      i = string.format('<%s%s> - %s', node.type(i), ( item.subtype and ("(".. item.subtype .. ")") or ''), dump_node(item))
    end
    nodes = nodes .. i .. ',\n'
  end
  nodes = nodes .. "</NodeList>\n\n"
  print(nodes)
  return true
end

return debugtex