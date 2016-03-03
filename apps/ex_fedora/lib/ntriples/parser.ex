defmodule NTriples.Parser do
  alias RDF.Literal
  alias RDF.SubjectMap
  alias RDF.PredicateMap
  @ntriples_regex ~r/(?<subject><(?<subject_uri>[^\s]+)>|_:([A-Za-z][A-Za-z0-9\-_]*))[
  ]*(?<predicate><(?<predicate_uri>[^\s]+)>)[
  ]*(?<object><(?<object_uri>[^\s]+)>|_:([A-Za-z][A-Za-z0-9\-_]*)|"(?<literal_string>(?:\\"|[^"])*)"(@(?<literal_language>[a-z]+[\-A-Za-z0-9]*)|\^\^<(?<literal_type>[^>]+)>)?)[ ]*./i

  def parse(content) when is_binary(content) do
    content
    |> Stream.unfold(fn str ->
      case String.split(str, "\n", parts: 2, trim: true) do
        []      -> nil
        [value] -> {value, ""}
        list    -> List.to_tuple(list)
      end
    end)
    |> parse
  end

  def parse(enumerable) do
    enumerable
    |> Stream.map(&to_triples/1)
    |> Enum.reduce(SubjectMap.new, &append_triple/2)
  end

  defp to_triples("") do
    {}
  end

  defp to_triples(string) when is_binary(string) do
    Regex.named_captures(@ntriples_regex, string)
    |> to_triples
  end

  defp to_triples(capture_map = %{"subject" => _}) do
    subject = process_subject(capture_map)
    predicate = process_predicate(capture_map)
    object = process_object(capture_map)
    {subject, predicate, object}
  end

  defp append_triple({subject, predicate, object}, map) do
    case map do
      %{^subject => %{^predicate => existing_value}} when is_list(existing_value) ->
        put_in(map, [subject, predicate], [object | existing_value])
      %{^subject => %{^predicate => existing_value}} ->
        put_in(map, [subject, predicate], [object, existing_value])
      %{^subject => _} ->
        put_in(map, [subject, predicate], object)
      _ ->
        put_in(map, [subject], put_in(PredicateMap.new, [predicate], object))
    end
  end

  defp append_triple(_, map), do: map

  defp process_subject(%{"subject_uri" => subject_uri}) do
    subject_uri
  end

  defp process_predicate(%{"predicate_uri" => predicate_uri}) do
    predicate_uri
  end

  defp process_object(map = %{"object_uri" => ""}) do
    process_object(Map.drop(map, ["object_uri"]))
  end

  defp process_object(%{"object_uri" => object_uri}) do
    %{"@id" => object_uri}
  end

  defp process_object(%{"literal_string" => value, "literal_language" => language}) do
      %Literal{value: value, language: language}
  end
end
