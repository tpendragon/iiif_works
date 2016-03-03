defmodule ExFedoraSchemaTest do
  use ExUnit.Case, async: true

  defmodule FedoraSchemaTest do
    use ExFedora.Schema
    schema "books" do
      property :title, predicate: "http://test.com"
    end
  end

  test "defining field" do
    assert FedoraSchemaTest.__schema__(:fields) == [:unmapped_graph, :id, :title]
  end

  test "predicates" do
    assert FedoraSchemaTest.__schema__(:predicates) == [title: "http://test.com"]
  end
end
