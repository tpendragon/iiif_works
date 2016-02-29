require IEx
defmodule NTriples.Serializer do
  def serialize(map = %{}) do
    map
    |> Enum.reduce([], &subject_graph_to_triples/2)
    |> Enum.map(&serialize_triple/1)
    |> Enum.reverse
    |> Enum.join("\n")
  end

  defp serialize_triple([subject, predicate, object]) do
    "#{serialize_subject(subject)} #{serialize_predicate(predicate)} #{serialize_object(object)} ."
  end

  defp serialize_subject(subject) do
    "<" <> subject <> ">"
  end

  defp serialize_predicate(predicate) do
    "<#{predicate}>"
  end

  defp serialize_object(object = %RDF.Literal{}) do
    "\"#{object.value}\"@#{object.language}"
  end

  defp serialize_object(object = %{"@id" => object_uri}) do
    "<#{object_uri}>"
  end

  defp subject_graph_to_triples({predicate, object = %RDF.Literal{}}, acc) do
    acc ++ [[predicate, object]]
  end

  defp subject_graph_to_triples({predicate, object = %{"@id" => _}}, acc) do
    acc ++ [[predicate, object]]
  end

  defp subject_graph_to_triples({predicate, object}, acc) when is_list(object) do
    list = object
    |> Enum.flat_map(&subject_graph_to_triples({predicate, &1}, acc))
  end

  defp subject_graph_to_triples({subject, map = %{}}, acc) do
    map = map
    |> Enum.reduce([], &subject_graph_to_triples/2)
    |> Enum.map(fn(lst) -> [subject | lst] end)
    map ++ acc
  end
end
