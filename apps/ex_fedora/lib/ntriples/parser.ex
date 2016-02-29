require IEx
defmodule NTriples.Parser do
  alias RDF.Literal
  @ntriples_regex ~r/(?<subject><(?<subject_uri>[^\s]+)>|_:([A-Za-z][A-Za-z0-9\-_]*))[
  ]*(?<predicate><(?<predicate_uri>[^\s]+)>)[
  ]*(?<object><(?<object_uri>[^\s]+)>|_:([A-Za-z][A-Za-z0-9\-_]*)|"(?<literal_string>(?:\\"|[^"])*)"(@(?<literal_language>[a-z]+[\-A-Za-z0-9]*)|\^\^<(?<literal_type>[^>]+)>)?)[ ]*./i
  def parse(content) do
    content
    |> String.split(".\n")
    |> Enum.map(&capture_triple_map/1)
    |> Enum.reduce(%{}, &process_capture/2)
  end

  defp capture_triple_map("") do
    %{}
  end

  defp capture_triple_map(string) do
    Regex.named_captures(@ntriples_regex, string)
  end

  defp process_capture(nil, accumulator) do
    accumulator
  end

  defp process_capture(map, accumulator) when map == %{} do
    accumulator
  end

  defp process_capture(capture_map, accumulator) do
    subject = process_subject(capture_map)
    predicate = process_predicate(capture_map)
    object = process_object(capture_map)
    append_triple(accumulator, {subject, predicate, object})
  end

  defp append_triple(map, {subject, predicate, object}) do
    case map do
      %{^subject => %{^predicate => existing_value}} when is_list(existing_value) ->
        new_value = [object | existing_value]
        Map.put(map, subject, Map.merge(map[subject], %{predicate => new_value}))
      %{^subject => %{^predicate => existing_value}} ->
        new_value = [object, existing_value]
        Map.put(map, subject, Map.merge(map[subject], %{predicate => new_value}))
      %{^subject => _} ->
        Map.put(map, subject, Map.merge(map[subject], %{predicate => object}))
      _ ->
        Map.put(map, subject, %{predicate => object})
    end
  end

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
