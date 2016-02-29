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

  # Convert the map syntax to a list of triples.
  def to_triples(map = %{}) do
    map
    |> deep_list_conversion
    |> Enum.reduce([], fn(subject_list, acc) -> acc ++ build_triples(subject_list) end)
  end

  defp build_triples({subject, predicate_objects}) do
    predicate_objects
    |> Enum.reduce([], fn(predicate_list, acc) -> acc ++
    condensed_list(predicate_list) end)
    |> Enum.map(fn(predicate_object) -> [subject | predicate_object] end)
  end

  defp condensed_list({predicate, objects}) do
    objects
    |> Enum.map(fn(object) -> [predicate, object] end)
  end

  def deep_list_conversion({key, object}) when is_list(object) do
    {key, Enum.reverse(object)}
  end

  def deep_list_conversion({key, object = %{"@id" => _}})do
    {key, [object]}
  end

  def deep_list_conversion({key, object = %RDF.Literal{}}) do
    {key, [object]}
  end

  def deep_list_conversion({key, map = %{}}) do
    map = map
    |> Map.to_list
    |> Enum.map(&deep_list_conversion/1)
    {key, map}
  end

  def deep_list_conversion(map = %{}) do
    map
    |> Map.to_list
    |> Enum.map(&deep_list_conversion/1)
  end


end
