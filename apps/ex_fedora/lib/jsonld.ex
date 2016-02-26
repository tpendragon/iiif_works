require IEx
defmodule JSONLD do
  def parse(content) do
    poison_json = Poison.decode!(content)
    Enum.flat_map(poison_json, &extract_statements/1)
  end

  defp extract_statements(map) do
    map
      |> Enum.reduce([], &extract_statement/2)
      |> extract_id
  end

  defp extract_id(statements) do
    statements
  end

  defp extract_statement({key, values}, acc) when is_list(values) do
    Enum.reduce(values, acc, fn(value, acc_2) -> extract_statement({key, value},
      acc_2) end)
  end

  defp extract_statement({"@type", value}, acc) do
    acc ++ [%{subject: "fillmein", predicate: "http://www.w3.org/1999/02/22-rdf-syntax-ns#type", value: value}]
  end

  defp extract_statement({key, value}, acc) do
    acc ++ [%{subject: "fillmein", predicate: key, value: value}]
  end
end
