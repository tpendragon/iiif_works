require IEx
defmodule NTriples.Serializer do
  def serialize(map = %{}) do
    map
    |> RDF.Graph.to_triples
    |> Stream.map(&serialize_triple/1)
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

  defp serialize_object(%{"@id" => object_uri}) do
    "<#{object_uri}>"
  end
end
