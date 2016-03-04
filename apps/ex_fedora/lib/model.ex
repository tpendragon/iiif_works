require IEx
defmodule ExFedora.Model do
  alias Ecto.Changeset
  defmacro __using__(_) do
    quote do
      use ExFedora.Schema
    end
  end

  def from_graph(mod, subject, graph = %{}) when is_binary(subject) do
    map = graph_to_fields(mod, subject, graph)
    struct(mod, map)
  end

  def from_graph(mod, subject, []) do
    struct(mod, id: subject)
  end

  def graph_to_fields(mod, subject, graph=%{}) when is_binary(subject) do
    map = schema_to_map(mod.__schema__(:predicates), graph[subject])
    map = put_in(map, [:unmapped_graph], put_in(RDF.SubjectMap.new, [subject],
    map[:unmapped_graph]))
    put_in(map, [:id], subject)
  end

  def to_graph(changeset = %Changeset{}, schema) do
    to_graph(Map.to_list(changeset.data), schema)
  end

  def to_graph(fields, schema) when is_list(fields) do
    predicate_graph = 
      fields
      |> Enum.map(&predicate_to_values(&1, schema))
      |> Enum.filter(fn (val) -> val != {} end)
      |> Enum.into(RDF.PredicateMap.new)
    subject = to_string(fields[:id])
    RDF.SubjectMap.new(%{subject => predicate_graph})
  end

  def predicate_to_values({property, value}, schema) do
    case schema[property] do
      nil ->
        {}
      _ ->
        { schema[property], elem(RDF.Literal.dump(value),1) }
    end
  end

  def to_graph(map = %{:__struct__ => struct}) do
    graph = to_graph(Changeset.change(map), struct.__schema__(:predicates))
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
        {{property, elem(RDF.Literal.cast(graph[predicate]),1)}, Map.drop(graph, [predicate])}
    end
  end
end
