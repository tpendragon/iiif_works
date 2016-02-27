require IEx
defmodule JSONLDTest do
  use ExUnit.Case
  doctest JSONLD
  alias JSONLD.Literal

  test "parses type triples" do
    {:ok, fixture_1} = File.read("test/fixtures/simple_jsonld.jsonld")
    result = JSONLD.parse(fixture_1)
    type_triple = hd(result)
    assert type_triple == %{subject: URI.parse("http://test.com"), predicate:
      URI.parse("http://www.w3.org/1999/02/22-rdf-syntax-ns#type"), object:
      URI.parse("http://type.com")}
  end

  test "Expanded JSON-LD" do
    {:ok, fixture_2} = File.read("test/fixtures/expanded_jsonld.jsonld")
    result = JSONLD.parse(fixture_2)
    type_triple = hd(result)
    assert type_triple == %{subject: URI.parse("http://bibdata.princeton.edu/bibliographic/1234567"), predicate:
      URI.parse("http://purl.org/dc/elements/1.1/contributor"), object:
      %Literal{value: "Copland, Aaron, 1900-1990", language: nil}}

    title = find_by_predicate(result,
    URI.parse("http://purl.org/dc/elements/1.1/title"))

    assert title[:object] == %Literal{language: "eng", value: "Christopher"}
  end

  defp find_by_predicate(statements, predicate) do
    Enum.find(statements, fn(statement) -> statement.predicate == predicate end)
  end

end
