require IEx
defmodule JSONLDTest do
  use ExUnit.Case
  doctest JSONLD

  test "parses type triples" do
    {:ok, fixture_1} = File.read("test/fixtures/simple_jsonld.jsonld")
    result = JSONLD.parse(fixture_1)
    type_triple = hd(result)
    assert type_triple == %{subject: "http://test.com", predicate:
      "http://www.w3.org/1999/02/22-rdf-syntax-ns#type", object:
      "http://type.com"}
  end
end
