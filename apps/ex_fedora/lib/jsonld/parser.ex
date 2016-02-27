defmodule JSONLD.Parser do
  alias JSONLD.Literal
  def extract_statements(map) do
    map
      |> Enum.reduce([], &extract_statement/2)
      |> extract_id
      |> cast_values
  end


  defp extract_statement({key, values}, acc) when is_list(values) do
    Enum.reduce(values, acc, fn(value, acc_2) -> extract_statement({key, value},
      acc_2) end)
  end

  # Type's values are always URIs, and it has a spec-defined URI as predicate.
  defp extract_statement({"@type", value}, acc) do
    acc ++ [%{subject: "fillmein", predicate:
        URI.parse("http://www.w3.org/1999/02/22-rdf-syntax-ns#type"), object:
        URI.parse(value)}]
  end

  # ID is always a URI
  defp extract_statement({"@id", value}, acc) do
    acc ++ [%{subject: "fillmein", predicate: "@id", object:
        URI.parse(value)}]
  end

  # Predicates are always URIs
  defp extract_statement({key, value}, acc) do
    acc ++ [%{subject: "fillmein", predicate: URI.parse(key), object: value}]
  end

  defp extract_id(statements) do
    statements
    |> Enum.filter_map(&valid_statement?/1,
                       &apply_subject(rdf_subject(statements), &1))
  end

  defp valid_statement?(%{predicate: "@id"}) do
    false
  end

  defp valid_statement?(_) do
    true
  end

  defp apply_subject(subject, statement) do
    %{statement | subject: subject}
  end

  defp rdf_subject(statements) do
    Enum.find(statements, fn(statement) -> statement.predicate == "@id"
    end).object
  end


  defp cast_values(statements) do
    Enum.map(statements, &cast_object/1)
  end

  defp cast_object(statement = %{object: object = %{"@value" => _}}) do
    literal = %Literal{value: object["@value"], language: object["@language"]}
    %{ statement | object: literal }
  end

  defp cast_object(statement) do
    statement
  end

end
