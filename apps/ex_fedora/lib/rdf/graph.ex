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
