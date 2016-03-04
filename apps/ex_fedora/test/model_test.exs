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
    assert %{title: ["yo"], id: "http://subject.com"} = model

    assert %{"http://subject.com" => %{"http://predicate" =>
          [%RDF.Literal{value: "test"}]}} = model.unmapped_graph
  end

  test "casting properties" do
    result = 
      %ExFedoraModel{}
      |> Ecto.Changeset.cast(%{title: "http://test.com"}, [:title], [])
    assert ["http://test.com"] = result.changes.title

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

  test "mapping properties TO an RDF graph" do
    graph = put_in(RDF.SubjectMap.new, 
                ["http://subject.com"], 
                put_in(RDF.PredicateMap.new,
                    ["http://test.com"],
                    [%RDF.Literal{value: "yo"}]))
    model = ExFedora.Model.from_graph(ExFedoraModel, "http://subject.com", graph)
    assert %{title: ["yo"]} = model
    post_graph = ExFedora.Model.to_graph(model)
    assert graph == post_graph
  end

  test "merging graphs" do
    graph = put_in(RDF.SubjectMap.new, 
                ["http://subject.com"], 
                put_in(RDF.PredicateMap.new,
                    ["http://test.com"],
                    [%RDF.Literal{value: "yo"}]))
    graph = put_in(graph, ["http://subject.com", "http://predicate"],[%RDF.Literal{value: "test"}])
    model = ExFedora.Model.from_graph(ExFedoraModel, "http://subject.com", graph)

    new_graph = ExFedora.Model.to_graph(model)
    unmapped_graph = model.unmapped_graph
    result = RDF.Graph.merge(new_graph, unmapped_graph)
    assert result == graph
  end

  test "merging graphs with values" do
    graph1 = put_in(RDF.SubjectMap.new, 
                ["http://subject.com"], 
                put_in(RDF.PredicateMap.new,
                    ["http://test.com"],
                    %RDF.Literal{value: "yo"}))
    graph2 = put_in(graph1, ["http://subject.com", "http://test.com"],
      [%RDF.Literal{value: "test"}])
    graph3 = put_in(graph1, ["http://subject.com", "http://test.com"],
      %RDF.Literal{value: "test"})
    graph4 = put_in(graph1, ["http://subject.com", "http://test.com"],
      %RDF.Literal{value: "yo"})
    expected = put_in(RDF.SubjectMap.new, 
                ["http://subject.com"], 
                put_in(RDF.PredicateMap.new,
                    ["http://test.com"],
                    [ %RDF.Literal{value: "yo"}, %RDF.Literal{value: "test"}]))
    assert RDF.Graph.merge(graph1, graph2) == expected
    assert RDF.Graph.merge(graph1, graph3) == expected
    assert RDF.Graph.merge(graph1, graph4) == graph1
    assert RDF.Graph.merge(graph2, graph2) == graph2
  end
end
