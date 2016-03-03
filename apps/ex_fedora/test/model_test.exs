defmodule ExFedoraModelTest do
  use ExUnit.Case, async: true
  defmodule ExFedoraModel do
    use ExFedora.Schema
    schema "models" do
      property :title, predicate: "http://test.com"
    end
  end

  test "mapping properties from an RDF graph" do
    graph = put_in(RDF.SubjectMap.new, 
                ["http://subject.com"], 
                put_in(RDF.PredicateMap.new,
                    ["http://test.com"],
                    [%RDF.Literal{value: "yo"}]))
    graph = put_in(graph, ["http://subject.com", "http://predicate"],[%RDF.Literal{value: "test"}])
    model = ExFedora.Model.from_graph(ExFedoraModel, "http://subject.com", graph)
    assert %{title: [%RDF.Literal{value: "yo"}]} = model

    assert %{"http://subject.com" => %{"http://predicate" =>
          [%RDF.Literal{value: "test"}]}} = model.unmapped_graph
  end

  test "casting properties" do
    result = 
      %ExFedoraModel{}
      |> Ecto.Changeset.cast(%{title: "http://test.com"}, [:title], [])
    assert [%RDF.Literal{value: "http://test.com"}] = result.changes.title

    result = 
      %ExFedoraModel{}
      |> Ecto.Changeset.cast(%{title: %RDF.Literal{value: "Testing", language:
          "en"}}, [:title], [])
    assert [%RDF.Literal{value: "Testing", language: "en"}] = result.changes.title

    result =
      %ExFedoraModel{}
      |> Ecto.Changeset.cast(%{title: [%RDF.Literal{value: "Testing", language:
          "en"}]}, [:title], [])
    assert [%RDF.Literal{value: "Testing", language: "en"}] = result.changes.title
  end
end
