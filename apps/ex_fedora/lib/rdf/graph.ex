require IEx
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

  # Ignore identifier atoms like :subject/:predicate
  def size(atom) when is_atom(atom) do
    0
  end

  def size(_) do
    1
  end

  def merge(graph1, graph2) do
    Map.merge(graph1, graph2, &merge/3)
  end
  defp merge(:_type_, x, _), do: x
  defp merge(_, predicate_map1 = %{:_type_ => :predicate}, predicate_map2
  = %{:_type_ => :predicate}) do
    Map.merge(predicate_map1, predicate_map2, &merge/3)
  end
  defp merge(_, list1, list2) when is_list(list1) and is_list(list2) do
    Enum.uniq(list1 ++ list2)
  end
  defp merge(_, binary, list) when is_list(list) do
    [binary | list]
  end
  defp merge(_, list, binary) when is_list(list) do
    list ++ [binary]
  end
  defp merge(_, x, x), do: x
  defp merge(_, val1, val2) do
    [val1, val2]
  end

  # Convert the map syntax to a list of triples.
  def to_triples(map = %{:_type_ => :subject}) do
    map
    |> Enum.map(&build_triples/1)
    |> Enum.reduce([], &Enum.into/2)
  end

  defp build_triples({:_type_, _}) do
    []
  end

  defp build_triples({subject, predicate_objects = %{:_type_ => :predicate}}) do
    predicate_objects
    |> Enum.map(&build_triples/1)
    |> Enum.reduce([], &Enum.into/2)
    |> Enum.map(fn(predicate_object) -> [subject | predicate_object] end)
  end

  defp build_triples({predicate, objects}) when is_list(objects) do
    objects
    |> Enum.reverse
    |> Enum.map(fn(object) -> [predicate, object] end)
  end

  defp build_triples({predicate, object}) do
    build_triples({predicate, [object]})
  end

end
