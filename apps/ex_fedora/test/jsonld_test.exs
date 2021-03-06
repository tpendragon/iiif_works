defmodule JSONLDTest do
  use ExUnit.Case, async: true
  doctest JSONLD
  alias RDF.Literal

  test "returns a dataset" do
    {:ok, fixture_1} = File.read("test/fixtures/simple_jsonld.jsonld")
    result = JSONLD.parse(fixture_1)
    assert %{"http://test.com" => _, :_type_ => :subject} = result
    refute result["http://test.com"]["@id"]
  end

  test "parses type triples" do
    {:ok, fixture_1} = File.read("test/fixtures/simple_jsonld.jsonld")
    result = JSONLD.parse(fixture_1)
    assert %{"http://www.w3.org/1999/02/22-rdf-syntax-ns#type" => _, :_type_ =>
    :predicate} = result["http://test.com"]
  end

  test "parses values into literals" do
    {:ok, fixture_1} = File.read("test/fixtures/expanded_jsonld.jsonld")
    result = JSONLD.parse(fixture_1)
    assert result["http://test.com"]["http://purl.org/dc/elements/1.1/title"] ==
    [%Literal{value: "Christopher", language: "eng"}]
  end

  test "doesn't transform URIs" do
    {:ok, fixture_1} = File.read("test/fixtures/expanded_jsonld.jsonld")
    result = JSONLD.parse(fixture_1)
    assert tl(result["http://test.com"]["http://purl.org/dc/elements/1.1/creator"]) ==
      [%{"@id" => "http://me.com"}]
  end
end
