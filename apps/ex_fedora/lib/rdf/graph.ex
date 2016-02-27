defmodule RDF.Graph do
  def size(values) when is_list(values) do
    length values
  end

  def size(map) when is_map(map) do
    Enum.reduce(map, 0, fn({key, values}, acc) -> size(values) + acc end)
  end

  def size(single_value) do
    1
  end

end
