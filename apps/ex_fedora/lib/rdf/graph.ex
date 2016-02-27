defmodule RDF.Graph do
  def size(values) when is_list(values) do
    length values
  end

  def size(%{:__struct__ => _}) do
    1
  end

  def size(map) when is_map(map) do
    Enum.reduce(map, 0, fn({_, values}, acc) -> size(values) + acc end)
  end

  def size(_) do
    1
  end

end
