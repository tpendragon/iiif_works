defmodule JSONLD.Parser do
  alias RDF.Literal
  def extract_statements(list) do
    list
    |> build_dataset
  end

  defp build_dataset(list) do
    list
    |> Enum.reduce(%{}, &graph_to_dataset/2)
  end

  defp graph_to_dataset(graph, dataset) do
    graph
    |> process_graph
    |> apply_to_dataset(dataset)
  end

  defp apply_to_dataset(graph, dataset) do
    dataset
    |> Map.put(graph["@id"], Map.drop(graph, ["@id"]))
  end

  defp process_graph(graph) do
    Enum.map(graph, &process_predicate/1)
    |> Enum.reduce(%{}, fn({key, val}, map) -> Map.put(map, key, val) end)
  end

  defp process_predicate({"@type", value}) do
    {"http://www.w3.org/1999/02/22-rdf-syntax-ns#type", value}
  end

  defp process_predicate({predicate, object})do
    {predicate, cast_object(object)}
  end

  defp cast_object(objects) when is_list(objects) do
    objects
    |> Enum.map(&cast_object/1)
  end

  defp cast_object(object = %{"@value" => _}) do
    %Literal{value: object["@value"], language: object["@language"]}
  end

  defp cast_object(object) do
    object
  end

end
