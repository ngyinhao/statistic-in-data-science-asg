local widths_by_columns = {
  [2] = {0.64, 0.36},
  [3] = {0.48, 0.24, 0.28},
  [4] = {0.23, 0.39, 0.19, 0.19},
  [5] = {0.22, 0.195, 0.195, 0.195, 0.195}
}

function Table(table_element)
  local widths = widths_by_columns[#table_element.colspecs]
  if widths == nil then
    return nil
  end

  local updated = {}
  for index, width in ipairs(widths) do
    updated[index] = {table_element.colspecs[index][1], width}
  end
  table_element.colspecs = updated
  return table_element
end
