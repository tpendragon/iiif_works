defmodule ExFedora.Model do
  defmacro __using__(_) do
    quote do
      use ExFedora.Schema
    end
  end

  def from_graph(mod, subject, graph = %{}) when is_binary(subject) do
    map = schema_to_map(mod.__schema__(:predicates), graph[subject])
    map = put_in(map, [:unmapped_graph], put_in(RDF.SubjectMap.new, [subject],
    map[:unmapped_graph]))
    struct(mod, map)
  end

  defp schema_to_map(schema, graph) when is_list(schema) do
    {mapped_schema, unmapped_graph} = 
      schema
      |> Enum.map_reduce(graph, &schema_to_map/2)
    mapped_schema
    |> Enum.into(%{})
    |> Map.put(:unmapped_graph, unmapped_graph)
  end

  defp schema_to_map({property, predicate}, graph=%{}) do
    case graph[predicate] do
      nil ->
        {{property, nil}, graph}
      _ ->
        {{property, graph[predicate]}, Map.drop(graph, [predicate])}
    end
  end
end
