defmodule ExFedoraModelTest do
  use ExUnit.Case, async: true
  defmodule ExFedoraModel do
    use ExFedora.Schema
    schema do
      property :title, predicate: "http://test.com"
    end
  end

  test "mapping properties from an RDF graph" do
    graph = put_in(RDF.SubjectMap.new, 
                ["http://subject.com"], 
                put_in(RDF.PredicateMap.new,
                    ["http://test.com"],
                    %RDF.Literal{value: "yo"}))
    model = ExFedora.Model.from_graph(ExFedoraModel, "http://subject.com", graph)
    assert %{title: "yo"} = model
  end
end
